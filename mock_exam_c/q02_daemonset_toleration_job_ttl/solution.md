# q02 — Run an agent on every node and a self-cleaning Job · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Deployment `node-agent` in namespace `pine` collects host metrics, so it must run exactly one Pod on
> every node of the cluster, control-plane nodes included. A one-off database migration must also run
> once and clean up after itself.
>
> 1. Replace Deployment `node-agent` with a DaemonSet `node-agent` in `pine` that keeps the same Pod
>    labels, container name, image, command and env. Its Pods must also run on nodes tainted
>    `node-role.kubernetes.io/control-plane:NoSchedule`. Delete the Deployment.
> 2. Write the cluster's node count and the DaemonSet's `desiredNumberScheduled` and `numberReady`
>    to `/opt/course/c02/daemonset.txt` in the form `nodes=<n> desired=<n> ready=<n>`.
> 3. Create Job `db-migrate` in `pine` with image `busybox:1.36` running
>    `sh -c 'echo migration start; sleep 5; echo migration done'`, with `backoffLimit: 2`. The Job and
>    its Pods must be deleted automatically `120` seconds after the Job finishes.
> 4. Before the Job disappears, save its log to `/opt/course/c02/migrate.log` (it must contain
>    `migration done`).

**해석**

namespace `pine` 의 Deployment `node-agent` 는 호스트 지표를 모으므로, control-plane 노드를 포함한 클러스터의
모든 노드에 파드가 정확히 하나씩 떠야 한다. 일회성 DB 마이그레이션도 한 번 돌고 스스로 정리되어야 한다.

1. Deployment `node-agent` 를 `pine` 의 DaemonSet `node-agent` 로 바꾼다. 파드 라벨, 컨테이너 이름, 이미지,
   command, env 는 그대로 유지한다. 파드는 `node-role.kubernetes.io/control-plane:NoSchedule` taint 가 있는
   노드에도 떠야 한다. Deployment 는 지운다.
2. 클러스터의 노드 수와 DaemonSet 의 `desiredNumberScheduled`, `numberReady` 를
   `nodes=<n> desired=<n> ready=<n>` 형식으로 `/opt/course/c02/daemonset.txt` 에 쓴다.
3. `pine` 에 Job `db-migrate` 를 만든다. 이미지 `busybox:1.36`, 명령
   `sh -c 'echo migration start; sleep 5; echo migration done'`, `backoffLimit: 2`. Job 과 그 파드는 Job 이
   끝나고 `120` 초 뒤 자동으로 지워져야 한다.
4. Job 이 사라지기 전에 로그를 `/opt/course/c02/migrate.log` 에 저장한다(`migration done` 이 들어 있어야 한다).

## 모범 풀이

**1) Deployment → DaemonSet**

DaemonSet 은 `kubectl create` 로 만들 수 없습니다. 기존 Deployment 를 yaml 로 뽑아 고치는 것이 가장 빠르고,
라벨·command·env 를 그대로 옮기라는 조건도 자동으로 지켜집니다.

```bash
kubectl -n pine get deploy node-agent -o yaml > /tmp/ds.yaml
```

`/tmp/ds.yaml` 에서 고칠 곳:

- `kind: Deployment` → `kind: DaemonSet`
- `spec.replicas`, `spec.strategy`, `status:` 전체, `metadata` 의 `uid`·`resourceVersion`·`creationTimestamp`·
  `generation`·`annotations(deployment.kubernetes.io/revision)` 삭제
- `spec.template.spec.tolerations` 추가

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
  namespace: pine
  labels:
    app: node-agent
spec:
  selector:
    matchLabels:
      app: node-agent
  template:
    metadata:
      labels:
        app: node-agent
        tier: monitoring
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: agent
        image: busybox:1.36
        command: ["sh", "-c", "echo agent running on $NODE_NAME; while true; do sleep 3600; done"]
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

```bash
kubectl -n pine delete deploy node-agent
kubectl apply -f /tmp/ds.yaml
kubectl -n pine rollout status ds node-agent
```

`strategy` 를 남기면 DaemonSet 에는 없는 필드라 `unknown field "spec.strategy"` 로 거부됩니다(DaemonSet 은
`updateStrategy`). Deployment 를 먼저 지우는 이유는 두 컨트롤러가 같은 `app=node-agent` 라벨의 파드를 서로
자기 것이라 여기지 않게 하기 위해서입니다(각자 ownerReference 로 구분하긴 하지만 Service 등에서 중복으로
보입니다).

DaemonSet 컨트롤러는 `node.kubernetes.io/not-ready`, `unreachable`, `disk-pressure`, `memory-pressure`,
`pid-pressure`, `unschedulable` 같은 toleration 을 **자동으로** 붙이지만, control-plane taint 는 붙이지
않습니다. 그래서 toleration 이 없으면 desired 가 워커 노드 수만큼만 나옵니다. `operator: Exists` 를 쓰면 taint
값이 무엇이든(보통 빈 값) 맞습니다.

**2) 숫자 기록**

```bash
N=$(kubectl get nodes --no-headers | wc -l)
D=$(kubectl -n pine get ds node-agent -o jsonpath='{.status.desiredNumberScheduled}')
R=$(kubectl -n pine get ds node-agent -o jsonpath='{.status.numberReady}')
echo "nodes=$N desired=$D ready=$R" | tee /opt/course/c02/daemonset.txt
# nodes=3 desired=3 ready=3
```

**3) TTL 이 있는 Job** — `kubectl create job` 에는 `--ttl` 같은 플래그가 없으므로 yaml 로 뽑아 필드를 넣습니다.

```bash
kubectl -n pine create job db-migrate --image=busybox:1.36 --dry-run=client -o yaml \
  -- sh -c 'echo migration start; sleep 5; echo migration done' > /tmp/job.yaml
```

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  namespace: pine
spec:
  backoffLimit: 2
  ttlSecondsAfterFinished: 120     # Job 의 spec 바로 아래 (template 안이 아니다)
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: db-migrate
        image: busybox:1.36
        command: ["sh", "-c", "echo migration start; sleep 5; echo migration done"]
```

```bash
kubectl apply -f /tmp/job.yaml
```

`ttlSecondsAfterFinished` 는 Job 이 `Complete` 또는 `Failed` 가 된 시점부터 셉니다. TTL 컨트롤러가 Job 을
지우면 cascading 삭제로 파드도 함께 사라집니다. Job 템플릿의 `restartPolicy` 는 `Never` 나 `OnFailure` 만
됩니다(`create job` 은 `Never` 를 넣어 줍니다).

**4) 사라지기 전에 로그 저장**

```bash
kubectl -n pine wait --for=condition=complete job/db-migrate --timeout=60s
kubectl -n pine logs job/db-migrate > /opt/course/c02/migrate.log
cat /opt/course/c02/migrate.log
# migration start
# migration done
```

120초가 지나면 Job 과 파드가 지워져 `kubectl logs` 로는 더 이상 볼 수 없습니다. TTL 이 짧은 Job 은 완료를
기다렸다가 곧바로 로그를 떠 두는 습관이 필요합니다.

## 검증

```bash
kubectl -n pine get deploy                         # No resources found
kubectl -n pine get ds node-agent
# NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
# node-agent   3         3         3       3            3           <none>          1m
kubectl -n pine get pod -l app=node-agent -o wide  # NODE 열에 control-plane 노드 포함, 노드마다 하나
cat /opt/course/c02/daemonset.txt                  # nodes=3 desired=3 ready=3
kubectl -n pine get job db-migrate -o jsonpath='{.spec.ttlSecondsAfterFinished} {.spec.backoffLimit}{"\n"}'   # 120 2
grep 'migration done' /opt/course/c02/migrate.log
# 2분 뒤
kubectl -n pine get job,pod -l job-name=db-migrate   # No resources found
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: "노드마다 하나" = DaemonSet. control-plane 에도 띄우려면 `node-role.kubernetes.io/control-plane` toleration 을 직접 넣는다.
- **헷갈리는 지점**: `ttlSecondsAfterFinished` 는 `spec.template.spec` 이 아니라 Job 의 `spec` 에 둡니다. CronJob 이라면 `spec.jobTemplate.spec` 안입니다. DaemonSet 으로 옮길 때 `replicas`·`strategy` 를 남기면 거부됩니다. Job 의 실패 정책을 더 세밀하게 하고 싶으면 `podFailurePolicy`(v1.31 GA)도 있습니다.

## 참고 문서

- 검색어: `daemonset`, `ttl after finished`, `taint toleration`
- https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
- https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q03 →](../q03_native_sidecar_log_adapter/question.md)

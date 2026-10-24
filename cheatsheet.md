# 시험장 치트시트 (CKAD)

외울 것이 아니라, **모의시험 볼 때마다 실제로 쓴 것만** 남겨서 줄여 나가는 문서입니다.

## 0. 호스트에 들어갈 때마다

문제마다 지정된 호스트로 `ssh` 합니다. `k` alias와 자동완성은 호스트마다 미리 설정되어 있고, 직접 만든
alias는 다음 호스트에서 사라집니다. 꼭 필요하면 들어갈 때마다 한 줄만 붙입니다.

```bash
export do='--dry-run=client -o yaml' now='--force --grace-period=0'   # k run x --image=nginx $do
```

> yaml 붙여넣기가 밀려서 깨지면 vim에서 `:set paste` 후 붙이고 `:set nopaste`.

```bash
ssh <문제가 지정한 호스트>     # 지정 호스트가 아닌 곳에서 작업하면 0점
# ... 풀이 ...
exit                          # 베이스 터미널로 돌아온 뒤 다음 문제로
```

## 1. 매니페스트를 빨리 만드는 법

`$do` 는 **`--` 앞에** 둡니다. `--` 뒤에 쓰면 컨테이너 명령의 인자가 됩니다.

```bash
k run web --image=nginx:1.27-alpine --port=80 --labels=app=web $do > pod.yaml
k create deploy web --image=nginx:1.27-alpine --replicas=3 --port=80 $do > deploy.yaml
k create job pi --image=busybox:1.36 $do -- sh -c 'echo hi' > job.yaml
k create cronjob hello --image=busybox:1.36 --schedule='*/5 * * * *' $do -- date > cj.yaml
k create job manual-1 --from=cronjob/hello                    # CronJob 을 지금 한 번 실행
k expose deploy web --port=80 --target-port=8080 --name=web-svc $do > svc.yaml
k create svc nodeport web --tcp=80:8080 --node-port=30080 $do  # 셀렉터가 app=web 으로 만들어진다
k create cm app --from-literal=MODE=prod --from-file=app.conf $do > cm.yaml
k create secret generic db --from-literal=user=app --from-literal=pw=s3cr3t $do > secret.yaml
k create secret tls web-tls --cert=tls.crt --key=tls.key
k create sa builder
k create role pod-reader --verb=get,list,watch --resource=pods $do > role.yaml
k create rolebinding pod-reader --role=pod-reader --serviceaccount=<ns>:builder
k create ingress web --class=nginx --rule='shop.example.com/api*=api:80' $do  # * = Prefix, 없으면 Exact
k create quota q1 --hard=pods=5,requests.cpu=1,requests.memory=1Gi
k set image deploy/web nginx=nginx:1.27            # 컨테이너이름=이미지
k set resources deploy web -c nginx --requests=cpu=100m,memory=64Mi --limits=cpu=200m,memory=128Mi
k set env deploy/web --from=configmap/app          # envFrom 을 직접 쓰는 것보다 빠르다
k set serviceaccount deploy web builder
```

필드 이름이 기억나지 않을 때 문서보다 빠른 방법 (CRD도 된다):

```bash
k explain pod.spec.containers.livenessProbe --recursive | less
k explain deploy.spec.strategy.rollingUpdate
k api-resources | grep -i <kind>                   # 그룹·버전·shortName·namespaced
k explain <kind> --api-version=<group/version>
```

## 2. Application Design and Build

```bash
# 이미지 빌드 (docker 도 같은 문법)
podman build -t app:v1 -f Dockerfile .
podman build --build-arg VERSION=2 -t app:v2 .
podman tag app:v1 registry.local/app:v1
podman run --rm app:v1                             # 결과 확인
podman save -o /opt/course/x/app.tar app:v1        # docker-archive
podman save --format oci-archive -o app-oci.tar app:v1
podman images ; podman inspect app:v1 --format '{{.Config.Labels}}'
```

- 워크로드 고르기: 계속 떠 있어야 함 → Deployment / 노드마다 하나 → DaemonSet / 끝나야 함 → Job / 주기 → CronJob / 고정 이름·순서 → StatefulSet
- Job: `completions`, `parallelism`, `backoffLimit`, `activeDeadlineSeconds`, `ttlSecondsAfterFinished`, `completionMode: Indexed`
- CronJob: `concurrencyPolicy: Forbid|Replace`, `startingDeadlineSeconds`, `successfulJobsHistoryLimit`, `timeZone`
- **네이티브 사이드카(v1.33 GA)**: `initContainers` 에 넣고 `restartPolicy: Always` — 앱보다 먼저 뜨고 끝까지 같이 산다
- 볼륨: `emptyDir`(`medium: Memory`, `sizeLimit`), PVC(`persistentVolumeClaim.claimName`), `configMap`/`secret`/`projected`

## 3. Application Deployment

```bash
k rollout status deploy web
k rollout history deploy web [--revision=3]
k rollout undo deploy web [--to-revision=2]
k rollout pause deploy web ; k rollout resume deploy web
k rollout restart deploy web
k annotate deploy web kubernetes.io/change-cause='image 1.27' --overwrite
```

- blue/green: 두 Deployment, **Service 셀렉터만** 바꾼다 (`k patch svc web -p '{"spec":{"selector":{"version":"green"}}}'`)
- canary: 공통 라벨(`app=web`)로 Service 가 둘 다 잡고, replicas 비율로 트래픽 비율을 만든다. Service 셀렉터에 `track` 을 넣지 않는다

```bash
helm repo add podinfo https://stefanprodan.github.io/podinfo && helm repo update
helm search repo podinfo [--versions]
helm show values podinfo/podinfo > values.yaml
helm install web podinfo/podinfo -n ns --create-namespace --version 6.x.y -f values.yaml
helm upgrade web podinfo/podinfo -n ns --version 6.x.y --reuse-values --set replicaCount=3
helm list -A ; helm history web -n ns ; helm rollback web 1 -n ns
helm get values web -n ns [-a] ; helm get manifest web -n ns
helm template web ./chart -f values.yaml > out.yaml
helm uninstall web -n ns [--keep-history]
```

```bash
k kustomize overlays/prod          # 렌더링만
k diff -k overlays/prod
k apply -k overlays/prod
```

kustomization.yaml 에서 자주 쓰는 필드: `resources`, `namespace`, `namePrefix`, `labels`, `images`(`newTag`), `replicas`, `patches`, `configMapGenerator`, `secretGenerator`

## 4. Application Observability and Maintenance

```bash
k describe pod p | tail -20                      # Events 가 맨 아래
k events -n ns --types=Warning                    # 또는 k get events --sort-by=.lastTimestamp
k logs p -c c --previous --tail=50 --since=10m
k logs deploy/web --all-containers --prefix
k top pod -A --sort-by=cpu|memory ; k top pod p --containers
k get pod p -o jsonpath='{.status.containerStatuses[*].lastState.terminated}'
k debug -it p --image=busybox:1.36 --target=app   # 임시 컨테이너, /proc/1/root 로 대상 파일시스템
k debug p -it --copy-to=p-debug --container=app -- sh
k exec -it p -c app -- sh
```

- probe 세 가지: `startupProbe`(통과 전까지 나머지 정지) → `readinessProbe`(Service 에서 빠짐) / `livenessProbe`(재시작)
- 종료 코드: 0 정상 종료 / 1 앱 오류 / 126 실행 권한 / 127 명령 없음 / 137 SIGKILL(OOM 포함) / 143 SIGTERM
- API deprecation: 제거된 버전은 `no matches for kind`. `k api-versions`, `k explain <kind>` 의 VERSION 으로 현재 버전 확인
  - Ingress `networking.k8s.io/v1`(`pathType` 필수, `backend.service.name/port.number`), CronJob `batch/v1`, PDB `policy/v1`, HPA `autoscaling/v2`

## 5. Application Environment, Configuration and Security

```bash
k auth can-i create deploy -n ns --as=system:serviceaccount:ns:builder
k create token builder -n ns --duration=1h
k get pod p -o jsonpath='{.status.qosClass}'
k label ns team pod-security.kubernetes.io/enforce=restricted
k patch pod p --subresource resize -p '{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"200m"}}}]}}'
```

restricted 를 통과하는 컨테이너 securityContext:

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities: { drop: ["ALL"] }
  seccompProfile: { type: RuntimeDefault }
```

- QoS: requests=limits(모든 컨테이너, cpu·memory) → Guaranteed / 일부만 → Burstable / 아무것도 없음 → BestEffort
- ResourceQuota 에 걸리면 파드가 아니라 **ReplicaSet 이벤트**에 `exceeded quota` 가 남는다
- Secret 을 `subPath` 로 마운트하면 값이 바뀌어도 갱신되지 않는다. env 로 받은 값은 파드를 다시 만들어야 바뀐다
- `immutable: true` 인 ConfigMap·Secret 은 고칠 수 없다 → 지우고 다시 만든다

## 6. Services and Networking

```bash
k get endpointslice -n ns -l kubernetes.io/service-name=web      # Endpoints 는 v1.33 부터 deprecated
k run tmp --rm -it --image=curlimages/curl:8.10.1 --restart=Never -- curl -s web.ns:80
k run tmp --rm -it --image=busybox:1.36 --restart=Never -- nslookup web.ns.svc.cluster.local
k port-forward svc/web 8080:80 -n ns
```

- Service 가 안 될 때: 셀렉터 ↔ 파드 라벨 → `targetPort` ↔ 컨테이너 포트 → 파드 Ready 순으로 본다
- NetworkPolicy: 같은 `from` 원소 안의 `namespaceSelector` + `podSelector` 는 **AND**, 원소를 나누면 **OR**
- egress 를 막으면 DNS(53/UDP·TCP, kube-system)를 따로 열어야 이름 풀이가 된다
- 기존 정책을 고치지 말라는 문제는 **파드 라벨을 바꿔서** 정책에 맞춘다
- Ingress: `ingressClassName` 을 빠뜨리면 기본 클래스가 없을 때 아무 컨트롤러도 처리하지 않는다

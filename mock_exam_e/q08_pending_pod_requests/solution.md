# q08 — Find why a pod is stuck in Pending · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Pod `report-gen` in namespace `jade` never starts; it stays in `Pending`. Its manifest is at
> `/opt/course/e08/report-gen.yaml`.
>
> 1. Using only built-in `kubectl` tools (`describe`, events), find out why the scheduler cannot
>    place the pod, and write the scheduler's message for that reason (for example the part that
>    starts with `0/<n> nodes are available`) to `/opt/course/e08/reason.txt`.
> 2. Fix the manifest so that the container requests `100m` CPU and `64Mi` memory (keep the image
>    and command), then recreate the pod.
> 3. Confirm that `report-gen` is `Running`.

**해석**

`jade` 네임스페이스의 파드 `report-gen` 이 시작하지 못하고 `Pending` 에 머물러 있다. 매니페스트는
`/opt/course/e08/report-gen.yaml` 에 있다.

1. `kubectl` 내장 도구(`describe`, 이벤트)만으로 스케줄러가 파드를 배치하지 못하는 이유를 찾고, 그
   이유에 대한 스케줄러 메시지(예: `0/<n> nodes are available` 로 시작하는 부분)를
   `/opt/course/e08/reason.txt` 에 쓴다.
2. 컨테이너가 CPU `100m`, 메모리 `64Mi` 를 요청하도록 매니페스트를 고치고(이미지와 명령은 유지)
   파드를 다시 만든다.
3. `report-gen` 이 `Running` 인지 확인한다.

## 모범 풀이

**1) Pending 의 이유는 Events 에 있습니다**

```bash
kubectl -n jade get pod report-gen -o wide            # NODE 가 <none>
kubectl -n jade describe pod report-gen | sed -n '/Events:/,$p'
# Warning  FailedScheduling  default-scheduler  0/3 nodes are available: 1 node(s) had untolerated
#   taint {node-role.kubernetes.io/control-plane: }, 2 Insufficient cpu. preemption: 0/3 nodes are
#   available: 1 Preemption is not helpful for scheduling, 2 No preemption victims found for incoming pod.
kubectl -n jade get events --field-selector reason=FailedScheduling -o jsonpath='{.items[0].message}{"\n"}'
kubectl -n jade get events --field-selector reason=FailedScheduling \
  -o jsonpath='{.items[0].message}{"\n"}' > /opt/course/e08/reason.txt
```

`Pending` 이고 NODE 가 비어 있다면 아직 **스케줄링 전**이라 컨테이너 로그는 없습니다(`kubectl logs` 는
아무것도 못 보여 줍니다). 원인은 스케줄러가 남긴 `FailedScheduling` 이벤트 하나에 다 들어 있습니다.
`Insufficient cpu` 는 "노드의 allocatable 에서 이미 잡힌 requests 를 뺀 나머지가 이 파드의 requests
보다 작다"는 뜻입니다. 실제 사용량이 아니라 **requests** 기준입니다.

```bash
kubectl -n jade get pod report-gen -o jsonpath='{.spec.containers[0].resources}{"\n"}'
# {"requests":{"cpu":"100","memory":"64Mi"}}           ← 100 은 100코어. 100m 의 오타
kubectl get nodes -o custom-columns='NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory'
kubectl describe node <worker> | grep -A8 'Allocated resources'
```

**2) requests 를 고치고 다시 만듭니다**

```bash
vi /opt/course/e08/report-gen.yaml        # cpu: "100" → cpu: 100m
kubectl replace --force -f /opt/course/e08/report-gen.yaml
```

```yaml
    resources:
      requests:
        cpu: 100m
        memory: 64Mi
```

v1.35 GA 인 in-place resize(`kubectl patch pod --subresource resize`)는 이미 노드에 배치되어 실행 중인
파드의 자원을 바꾸는 기능입니다. 배치조차 안 된 파드는 매니페스트를 고쳐 다시 만드는 것이 가장 확실합니다.

**3) 확인**

```bash
kubectl -n jade wait --for=condition=Ready pod/report-gen --timeout=60s
kubectl -n jade get pod report-gen -o wide
```

## 검증

```bash
cat /opt/course/e08/reason.txt
# 0/3 nodes are available: ... 2 Insufficient cpu. ...
grep -c 'Insufficient cpu' /opt/course/e08/reason.txt          # 1
kubectl -n jade get pod report-gen -o jsonpath='{.spec.containers[0].resources.requests}{"\n"}'
# {"cpu":"100m","memory":"64Mi"}
kubectl -n jade get pod report-gen -o wide
# NAME         READY   STATUS    RESTARTS   AGE   IP          NODE
# report-gen   1/1     Running   0          20s   10.0.1.40   worker-1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Pending + NODE `<none>` → 로그가 아니라 `describe` 의 `FailedScheduling` 이벤트. `Insufficient cpu` 는 requests 기준이다.
- **헷갈리는 지점**: CPU 단위 `100` 은 100코어, `100m` 은 0.1코어입니다. 메시지 앞부분의 control-plane taint 는 원인이 아니라 "그 노드는 원래 제외"라는 설명입니다. 실행 중인 파드의 CPU/메모리는 v1.35 부터 `--subresource resize` 로 바꿀 수 있지만, 스케줄되지 못한 파드에는 다시 만드는 쪽이 정석입니다.

## 참고 문서

- 검색어: `assign cpu resources`, `debug pods pending`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q09 →](../q09_fix_removed_api_versions/question.md)

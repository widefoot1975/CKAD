# q13 — ResourceQuota blocks Deployment replicas · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Deployment `worker` in namespace `loire` should run `4` replicas, but only some of its Pods exist.
>
> 1. Find out what prevents the missing Pods from being created. Write the name of the blocking
>    object and the name of the exhausted resource, separated by a single space, to
>    `/opt/course/f13/blocker.txt` (for example `myobject requests.memory`).
> 2. Without changing the blocking object or the replica count, set the CPU request of container
>    `worker` to the largest multiple of `50m` that lets all 4 replicas run. Leave the memory request
>    unchanged.
> 3. Make sure Deployment `worker` shows `4/4` ready.

**해석**

`loire` 네임스페이스의 Deployment `worker` 는 replica `4` 개여야 하지만 Pod 가 일부만 있다.

1. 나머지 Pod 가 만들어지지 못하는 원인을 찾는다. 막고 있는 객체의 이름과 소진된 리소스 이름을 공백 하나로
   구분해 `/opt/course/f13/blocker.txt` 에 적는다(예: `myobject requests.memory`).
2. 막고 있는 객체와 replica 수는 바꾸지 않고, 컨테이너 `worker` 의 CPU request 를 4개 replica 가 모두 뜰 수
   있는 `50m` 배수 중 가장 큰 값으로 바꾼다. 메모리 request 는 그대로 둔다.
3. Deployment `worker` 가 `4/4` ready 인지 확인한다.

## 모범 풀이

**1) 원인 찾기 — Pod 가 아니라 ReplicaSet 의 이벤트를 봅니다**

```bash
kubectl -n loire get deploy,rs,pod
# deployment.apps/worker   2/4   2   2
# replicaset.apps/worker-6d5f...   4   2   2      ← DESIRED 4, CURRENT 2
kubectl -n loire describe rs -l app=worker | grep -A2 FailedCreate | head -3
#   Warning  FailedCreate  ...  Error creating: pods "worker-6d5f...-x" is forbidden: exceeded quota: loire-quota,
#   requested: requests.cpu=400m, used: requests.cpu=800m, limited: requests.cpu=1
kubectl -n loire describe resourcequota loire-quota
# Resource         Used   Hard
# pods             2      10
# requests.cpu     800m   1
# requests.memory  128Mi  1Gi

echo "loire-quota requests.cpu" > /opt/course/f13/blocker.txt
```

quota 에 걸린 Pod 는 **만들어지지조차 않으므로** Pending Pod 도 없고 `describe pod` 로 볼 대상도 없습니다. 거부는
Pod 를 만들려던 ReplicaSet 컨트롤러가 받으므로 이벤트도 ReplicaSet 에 남습니다.
(`kubectl -n loire get events --field-selector reason=FailedCreate` 로도 보입니다.)

**2) CPU request 계산과 변경**

hard `requests.cpu: 1` = 1000m, 4개 replica → Pod 당 최대 1000m / 4 = **250m** (50m 의 배수). quota 는 사용량이
hard 와 **같을 때까지** 허용하므로 250m × 4 = 1000m 가 들어갑니다.

```bash
kubectl -n loire set resources deploy worker -c worker --requests=cpu=250m
kubectl -n loire rollout status deploy worker
```

`set resources` 는 준 항목만 바꾸므로 `memory: 64Mi` 는 그대로입니다. 이 Deployment 는 `strategy: Recreate`
라서 옛 Pod 를 모두 지운 뒤 새 Pod 4개를 만들고, quota 에 여유가 생깁니다.

RollingUpdate 였다면 옛 Pod(400m×2=800m)가 quota 를 쥔 채 새 Pod(250m)를 먼저 만들려 하기 때문에, 여유가
200m 뿐이라 롤아웃이 멈출 수 있습니다. 그럴 때는 `kubectl scale deploy worker --replicas=0` 후 다시 4 로
올리거나, quota 에 여유를 둔 값을 고릅니다.

## 검증

```bash
cat /opt/course/f13/blocker.txt                 # loire-quota requests.cpu
kubectl -n loire get deploy worker
# NAME     READY   UP-TO-DATE   AVAILABLE
# worker   4/4     4            4
kubectl -n loire get deploy worker -o jsonpath='{.spec.template.spec.containers[0].resources.requests}{"\n"}'
# {"cpu":"250m","memory":"64Mi"}
kubectl -n loire describe resourcequota loire-quota | grep requests
# requests.cpu     1      1
# requests.memory  256Mi  1Gi
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: replica 가 모자라고 Pending Pod 도 없으면 `describe rs` 의 `FailedCreate ... exceeded quota` 를 본다.
- **헷갈리는 지점**: quota 거부는 Pod 생성 단계에서 일어나 Pod 이벤트가 없습니다. quota 에 `requests.cpu` 가 있으면 request 를 안 적은 Pod 도 거부됩니다(LimitRange 기본값이 없을 때). 사용량이 hard 와 같으면 허용, 넘으면 거부입니다.

## 참고 문서

- 검색어: `resource quotas`, `configure memory and cpu quotas for a namespace`
- https://kubernetes.io/docs/concepts/policy/resource-quotas/
- https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q14 →](../q14_crd_explain_custom_resource/question.md)

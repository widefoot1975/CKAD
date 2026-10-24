# q12 — Fit a Deployment into a ResourceQuota and LimitRange · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Deployment `worker` in namespace `mu` should run `4` replicas, but no Pods are created. The
> ResourceQuota and the LimitRange in `mu` are policy and must not be changed.
>
> 1. Find out why the Pods are not created and write the reason, as reported by the cluster, in
>    one line to `/opt/course/a12/reason.txt`.
> 2. Change the container resources of Deployment `worker` so that all 4 replicas can run at the
>    same time. Use the **largest** CPU and memory values that make this possible, and make the
>    Pods get the QoS class `Guaranteed`.
> 3. Write the values you chose to `/opt/course/a12/resources.txt` in the form
>    `cpu=<value> memory=<value>`.
> 4. All 4 Pods must be `Running`, and every Pod of `worker` must report QoS class `Guaranteed`.

**해석**

`mu` 네임스페이스의 Deployment `worker` 는 레플리카 `4` 개로 돌아야 하지만 Pod 가 하나도 만들어지지 않는다. `mu` 의
ResourceQuota 와 LimitRange 는 정책이므로 바꾸면 안 된다.

1. Pod 가 만들어지지 않는 이유를 찾아, 클러스터가 보고한 그대로 한 줄로 `/opt/course/a12/reason.txt` 에 쓴다.
2. 4개 레플리카가 동시에 돌 수 있도록 Deployment `worker` 의 컨테이너 리소스를 바꾼다. 이것이 가능한 **가장 큰** CPU·메모리
   값을 쓰고, Pod 가 QoS 클래스 `Guaranteed` 를 받게 한다.
3. 고른 값을 `cpu=<값> memory=<값>` 형식으로 `/opt/course/a12/resources.txt` 에 쓴다.
4. 4개 Pod 가 모두 `Running` 이어야 하고, `worker` 의 모든 Pod 가 QoS 클래스 `Guaranteed` 여야 한다.

## 모범 풀이

**1) 원인 — Pod 가 없으면 ReplicaSet 의 이벤트를 봅니다**

```bash
alias k=kubectl
k -n mu get deploy,rs,pod
# deployment.apps/worker   0/4   0   0
# replicaset.apps/worker-6b..   4   0   0       ← DESIRED 4, CURRENT 0
k -n mu describe rs -l app=worker | tail -5
# Warning  FailedCreate  ...  Error creating: pods "worker-6b...-x" is forbidden:
#   [maximum cpu usage per Container is 300m, but limit is 500m, maximum memory usage per Container is 300Mi, but limit is 512Mi]
k -n mu describe rs -l app=worker | grep -m1 'Error creating' | sed 's/^.*Error creating: //' > /opt/course/a12/reason.txt
```

Pod 는 admission 단계에서 거부되어 **만들어지지도 않았기 때문에** `get pod` 에도, Pod 이벤트에도 아무것도 없습니다.
거부 메시지는 Pod 를 만들려고 한 주체, 즉 ReplicaSet 의 `FailedCreate` 이벤트에 남습니다
(`k -n mu get events --field-selector reason=FailedCreate` 로도 볼 수 있음).

**2) 정책에서 허용 범위 계산**

```bash
k -n mu describe quota mu-quota
# Resource         Used  Hard
# limits.cpu       0     1
# limits.memory    0     1Gi
# requests.cpu     0     1
# requests.memory  0     1Gi
k -n mu describe limitrange mu-limits
# Type       Resource  Min  Max    Default Request  Default Limit
# Container  cpu       -    300m   100m             300m
# Container  memory    -    300Mi  128Mi            300Mi
k -n mu get deploy worker -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
# {"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"200m","memory":"128Mi"}}
```

| 제약 | CPU | 메모리 |
|---|---|---|
| LimitRange 컨테이너 max | 300m | 300Mi |
| Quota 합계 ÷ 4 Pod | 1000m / 4 = **250m** | 1024Mi / 4 = **256Mi** |
| 둘 중 작은 값 (최댓값) | **250m** | **256Mi** |

LimitRange 의 max(300m) 까지 올리면 Pod 하나는 통과하지만, 4개 합계가 1200m 이 되어 4번째 Pod 가
`exceeded quota: mu-quota, requested: limits.cpu=300m, used: limits.cpu=900m, limited: limits.cpu=1` 로 거부됩니다.
"모두 동시에" 와 "가장 크게" 를 같이 만족하는 값은 quota 를 4로 나눈 값입니다.

**Guaranteed** 는 모든 컨테이너가 CPU·메모리 둘 다 `requests == limits` 일 때만 붙습니다.

```bash
k -n mu set resources deploy worker --requests=cpu=250m,memory=256Mi --limits=cpu=250m,memory=256Mi
k -n mu rollout status deploy worker
echo "cpu=250m memory=256Mi" > /opt/course/a12/resources.txt
```

limits 만 주고 requests 를 지워도 requests 가 limits 와 같은 값으로 채워져 Guaranteed 가 되지만, 여기서는 기존 requests
(200m/128Mi)가 남아 있으므로 `set resources` 에 둘 다 명시하는 것이 안전합니다. LimitRange 의 기본값은 값이 **비어 있을 때만**
채워지므로 이번처럼 명시하면 관여하지 않습니다.

## 검증

```bash
k -n mu get pod -l app=worker -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,QOS:.status.qosClass
# worker-7d...-a   Running   Guaranteed   (4줄)
k -n mu get deploy worker            # READY 4/4
k -n mu describe quota mu-quota
# limits.cpu 1/1 · limits.memory 1Gi/1Gi · requests.cpu 1/1 · requests.memory 1Gi/1Gi
cat /opt/course/a12/reason.txt /opt/course/a12/resources.txt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Pod 가 아예 없으면 `describe rs` 의 `FailedCreate`. 한 Pod 값 = min(LimitRange max, Quota ÷ 레플리카 수).
- **헷갈리는 지점**: LimitRange 는 **컨테이너 하나**의 상·하한과 기본값, ResourceQuota 는 **네임스페이스 합계**입니다. quota 에 `limits.cpu` 가 있으면 모든 Pod 가 그 값을 가져야 하고(없으면 LimitRange 기본값이 채움), 롤링 업데이트 중에는 maxSurge 만큼 Pod 가 더 생기므로 quota 를 꽉 채운 설정은 다음 rollout 에서 막힐 수 있습니다. v1.35 GA 인 in-place resize 로도 QoS 클래스는 바꿀 수 없습니다.

## 참고 문서

- 검색어: `resource quotas`, `limit ranges`, `configure quality of service for pods`
- https://kubernetes.io/docs/concepts/policy/resource-quotas/
- https://kubernetes.io/docs/concepts/policy/limit-range/
- https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q13 →](../q13_pod_security_restricted_fix/question.md)

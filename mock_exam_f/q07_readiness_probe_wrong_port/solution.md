# q07 — Fix a readiness probe on the wrong port · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The Pods of Deployment `cache` in namespace `volga` are `Running` but never become `Ready`, so
> Service `cache` has no ready endpoints.
>
> 1. Find out which port the readiness probe checks and write that port number to
>    `/opt/course/f07/probe-port.txt`.
> 2. Fix the Deployment so that the readiness probe checks the port Redis actually listens on. Keep
>    it a `tcpSocket` probe and do not change anything else.
> 3. Make sure the Deployment shows `2/2` ready and that the EndpointSlice of Service `cache` lists
>    2 ready endpoints.

**해석**

`volga` 네임스페이스의 Deployment `cache` Pod 들은 `Running` 이지만 `Ready` 가 되지 않아, Service `cache`
에 ready endpoint 가 없다.

1. readiness probe 가 확인하는 포트를 찾아 그 번호를 `/opt/course/f07/probe-port.txt` 에 적는다.
2. readiness probe 가 Redis 가 실제로 듣는 포트를 확인하도록 Deployment 를 고친다. `tcpSocket` probe 는
   유지하고 다른 것은 바꾸지 않는다.
3. Deployment 가 `2/2` ready 이고 Service `cache` 의 EndpointSlice 에 ready endpoint 가 2개인지 확인한다.

## 모범 풀이

**1) 증상과 원인 확인**

```bash
kubectl -n volga get pods
# cache-xxxx-aaaa   0/1   Running   0   1m       ← Running 인데 READY 0/1, RESTARTS 0
kubectl -n volga describe pod -l app=cache | grep -E 'Readiness|Unhealthy' | head -3
#     Readiness:  tcp-socket :6380 delay=2s timeout=1s period=5s #success=1 #failure=3
#   Warning  Unhealthy  ...  Readiness probe failed: dial tcp 10.0.1.23:6380: connect: connection refused
kubectl -n volga get deploy cache \
  -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.tcpSocket.port}{"\n"}'
# 6380
echo 6380 > /opt/course/f07/probe-port.txt
```

readiness 실패는 컨테이너를 재시작하지 않습니다(RESTARTS 0). Pod 를 Service endpoint 에서 빼기만 합니다.
재시작이 반복되면 liveness probe 를 의심합니다. Redis 의 포트는 `containerPort: 6379` 와 이미지 기본값으로 확인됩니다.

**2) probe 포트 수정** — Pod 가 아니라 Deployment 의 템플릿을 고칩니다.

```bash
kubectl -n volga patch deploy cache --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/tcpSocket/port","value":6379}
]'
kubectl -n volga rollout status deploy cache
```

`kubectl -n volga edit deploy cache` 로 `port: 6380` → `6379` 를 바꿔도 같습니다. 포트 이름이 있으므로
`port: redis` 로 써도 됩니다. Pod 를 직접 고치는 것은 소용없습니다. probe 는 Pod 에서 바꿀 수 없는 필드이고,
고쳐도 ReplicaSet 이 템플릿대로 다시 만듭니다.

## 검증

```bash
cat /opt/course/f07/probe-port.txt     # 6380
kubectl -n volga get deploy cache
# NAME    READY   UP-TO-DATE   AVAILABLE
# cache   2/2     2            2
kubectl -n volga get endpointslice -l kubernetes.io/service-name=cache \
  -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]} ready={.conditions.ready}{"\n"}{end}'
# 10.0.1.31 ready=true
# 10.0.2.18 ready=true
kubectl -n volga get deploy cache -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}{"\n"}'
# {"failureThreshold":3,"initialDelaySeconds":2,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":6379},"timeoutSeconds":1}
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Running` + `0/1` + RESTARTS 0 → readiness 실패. `describe pod` 의 `Readiness:` 줄과 `Unhealthy` 이벤트로 포트를 바로 읽는다.
- **헷갈리는 지점**: readiness 실패는 재시작이 아니라 endpoint 제외, liveness 실패는 재시작입니다. Service 확인은 deprecated 된 Endpoints 대신 EndpointSlice 의 `conditions.ready` 를 봅니다.

## 참고 문서

- 검색어: `configure liveness readiness startup probes`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q08 →](../q08_debug_shellless_container/question.md)

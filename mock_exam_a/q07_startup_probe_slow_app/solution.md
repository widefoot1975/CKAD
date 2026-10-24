# q07 — Rescue a slow-starting app with a startupProbe · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Deployment `ledger` in namespace `eta` never becomes Ready and its Pod keeps restarting. The
> application needs up to 60 seconds to start. Once started, it answers `GET /healthz` on port
> `8080` with HTTP `200`.
>
> 1. Find out why the container keeps restarting and write the reason in one line to
>    `/opt/course/a07/cause.txt`.
> 2. Add a startup probe (`httpGet` on `/healthz`, port `8080`, `periodSeconds: 5`) that gives the
>    application at least `90` seconds to start.
> 3. Change the liveness probe so that it has no `initialDelaySeconds` and restarts the
>    container only after `3` consecutive failures `10` seconds apart. Keep its `httpGet` on
>    `/healthz`, port `8080`.
> 4. Fix the readiness probe so that the Pod can become Ready.
> 5. The rollout must complete, and the new Pod must be Ready (`1/1`) with `0` restarts.

**해석**

`eta` 네임스페이스의 Deployment `ledger` 가 Ready 가 되지 않고 Pod 가 계속 재시작한다. 애플리케이션은 시작에
최대 60초가 걸린다. 시작한 뒤에는 포트 `8080` 의 `GET /healthz` 에 HTTP `200` 으로 응답한다.

1. 컨테이너가 계속 재시작하는 이유를 찾아 `/opt/course/a07/cause.txt` 에 한 줄로 쓴다.
2. 애플리케이션에 최소 `90` 초의 시작 시간을 주는 startup probe(`/healthz` 에 `httpGet`, 포트 `8080`,
   `periodSeconds: 5`)를 추가한다.
3. liveness probe 를 `initialDelaySeconds` 없이, `10` 초 간격으로 `3` 번 연속 실패했을 때만 컨테이너를 재시작하도록
   바꾼다. `httpGet` 은 `/healthz`, 포트 `8080` 그대로 둔다.
4. Pod 가 Ready 가 될 수 있도록 readiness probe 를 고친다.
5. 롤아웃이 완료되어야 하고, 새 Pod 는 Ready(`1/1`)이며 재시작 `0` 이어야 한다.

## 모범 풀이

**1) 원인 찾기 — Events 와 로그**

```bash
alias k=kubectl
k -n eta get pod -l app=ledger
# ledger-5c7...   0/1   Running   3 (12s ago)   1m
k -n eta describe pod -l app=ledger | sed -n '/Liveness/,/Events/p;/Events:/,$p'
#     Liveness:   http-get http://:8080/healthz delay=5s timeout=1s period=5s #success=1 #failure=2
#     Readiness:  http-get http://:8000/healthz delay=0s timeout=1s period=5s #success=1 #failure=3
#   Warning  Unhealthy  ...  Liveness probe failed: Get "http://10.0.1.7:8080/healthz": dial tcp ... connect: connection refused
#   Normal   Killing    ...  Container ledger failed liveness probe, will be restarted
k -n eta logs deploy/ledger --previous
# ledger: warming up caches (about 45s)          ← "listening" 줄이 찍히기 전에 죽었다
```

```bash
echo "liveness probe (delay 5s, period 5s, failureThreshold 2) kills the container about 10s after start, before the ~45-60s startup finishes" \
  > /opt/course/a07/cause.txt
```

Events 의 `Killing ... failed liveness probe, will be restarted` 가 결정적인 증거입니다. 로그가 에러 없이 시작 단계에서
끊긴 것도 "앱이 죽은 게 아니라 kubelet 이 죽였다"는 신호입니다. 그리고 Readiness 줄을 보면 포트가 **8000** 이라
앱이 떠도 Ready 가 될 수 없다는 두 번째 고장도 보입니다.

**2) ~ 4) probe 세 개 정리**

```bash
k -n eta edit deploy ledger
```

```yaml
        startupProbe:                 # 2) 시작 단계 전용: 성공할 때까지 liveness/readiness 를 멈춘다
          httpGet:
            path: /healthz
            port: 8080
          periodSeconds: 5
          failureThreshold: 18        # 5s × 18 = 90s
        livenessProbe:                # 3) initialDelaySeconds 제거
          httpGet:
            path: /healthz
            port: 8080
          periodSeconds: 10
          failureThreshold: 3         # 10s × 3 = 30s 연속 실패 시 재시작
        readinessProbe:               # 4) 포트 8000 → 8080
          httpGet:
            path: /healthz
            port: 8080
          periodSeconds: 5
```

startupProbe 가 정의되어 있으면 kubelet 은 그것이 **한 번 성공할 때까지 liveness·readiness 를 실행하지 않습니다**.
허용 시간은 `initialDelaySeconds + periodSeconds × failureThreshold` 이므로 5 × 18 = 90초입니다. 그 안에 성공하지
못하면 startupProbe 실패로 컨테이너가 재시작됩니다. 한 번 성공한 뒤로는 다시 실행되지 않고 liveness 가 넘겨받습니다.

`initialDelaySeconds` 를 70 같은 큰 값으로 늘려도 재시작은 멈추지만, 그러면 앱이 빨리 떠도 70초 동안 감시가 비고,
시작이 조금만 늦어도 또 죽습니다. 시작 시간이 들쭉날쭉한 앱에는 startupProbe 가 정답입니다.

**5) 롤아웃 확인**

```bash
k -n eta rollout status deploy ledger --timeout=150s
```

## 검증

```bash
k -n eta get pod -l app=ledger
# NAME          READY   STATUS    RESTARTS   AGE
# ledger-6f...  1/1     Running   0          70s
k -n eta get deploy ledger -o jsonpath='{.spec.template.spec.containers[0].startupProbe}{"\n"}{.spec.template.spec.containers[0].livenessProbe}{"\n"}{.spec.template.spec.containers[0].readinessProbe.httpGet.port}{"\n"}'
# {"failureThreshold":18,"httpGet":{"path":"/healthz","port":8080,...},"periodSeconds":5,...}
# {"failureThreshold":3,"httpGet":{...},"periodSeconds":10,...}     ← initialDelaySeconds 없음
# 8080
k -n eta describe pod -l app=ledger | grep -E 'Startup|Liveness|Readiness'
cat /opt/course/a07/cause.txt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 느리게 뜨는 앱 = startupProbe(`periodSeconds × failureThreshold` ≥ 최대 시작 시간). 성공 전까지 liveness/readiness 는 멈춘다.
- **헷갈리는 지점**: liveness 실패는 **재시작**, readiness 실패는 **엔드포인트 제외**(재시작 없음)입니다. 그래서 readiness 포트가 틀려도 RESTARTS 는 늘지 않고 `0/1 Running` 으로만 남습니다. 컨테이너 PID 1 이 `sh` 면 SIGTERM 을 무시해 `terminationGracePeriodSeconds` 만큼 종료가 늦어집니다.

## 참고 문서

- 검색어: `configure liveness readiness startup probes`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q08 →](../q08_crashloop_configmap_key_command/question.md)

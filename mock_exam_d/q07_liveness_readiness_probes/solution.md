# q07 — Add liveness and readiness probes · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Deployment `kestrel-app` in namespace `kestrel` has no health checks. Add them to container `app`
> without changing anything else.
>
> 1. Add a readiness probe that sends an HTTP GET to path `/index.html` on port `80`, starting after
>    `5` seconds and repeating every `10` seconds.
> 2. Add a liveness probe that sends an HTTP GET to path `/` on port `80`, starting after `15`
>    seconds, repeating every `20` seconds, and restarting the container after `3` consecutive
>    failures.
> 3. Make sure the rollout finishes and both Pods are ready with `0` restarts.

**해석**

`kestrel` 네임스페이스의 Deployment `kestrel-app` 에는 헬스 체크가 없다. 다른 것은 바꾸지 말고
컨테이너 `app` 에 추가한다.

1. 포트 `80` 의 경로 `/index.html` 로 HTTP GET 을 보내는 readiness probe 를 추가한다. `5` 초 뒤 시작하고
   `10` 초마다 반복한다.
2. 포트 `80` 의 경로 `/` 로 HTTP GET 을 보내는 liveness probe 를 추가한다. `15` 초 뒤 시작하고 `20` 초마다
   반복하며, 연속 `3` 번 실패하면 컨테이너를 재시작한다.
3. rollout 이 끝나고 두 파드가 재시작 `0` 회로 Ready 인지 확인한다.

## 모범 풀이

**1)–2) 파드 템플릿의 컨테이너에 probe 두 개**

```bash
kubectl -n kestrel edit deploy kestrel-app
```

`spec.template.spec.containers[name=app]` 아래에 넣습니다.

```yaml
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
          failureThreshold: 3
```

편집기 대신 patch 한 줄로도 됩니다. strategic merge patch 는 `containers` 를 `name` 으로 합치므로 다른 필드는 그대로입니다.

```bash
kubectl -n kestrel patch deploy kestrel-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"app",
 "readinessProbe":{"httpGet":{"path":"/index.html","port":80},"initialDelaySeconds":5,"periodSeconds":10},
 "livenessProbe":{"httpGet":{"path":"/","port":80},"initialDelaySeconds":15,"periodSeconds":20,"failureThreshold":3}}]}}}}'
```

probe 는 Deployment 의 `spec` 이 아니라 **파드 템플릿 안 컨테이너**의 필드입니다. `failureThreshold` 기본값이 3 이라
빼도 같은 동작이지만, 문제에서 명시했으니 적어 둡니다. readiness 실패는 Service 엔드포인트에서 빠지는 것, liveness
실패는 컨테이너 재시작이라는 차이를 기억합니다.

**3) rollout 확인**

```bash
kubectl -n kestrel rollout status deploy kestrel-app
kubectl -n kestrel get pods                 # READY 1/1, RESTARTS 0 (두 개)
```

템플릿이 바뀌었으므로 파드가 새로 만들어집니다. readiness 가 통과해야 새 파드가 Ready 가 되고 옛 파드가 내려갑니다.

## 검증

```bash
kubectl -n kestrel get deploy kestrel-app -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}{"\n"}{.spec.template.spec.containers[0].livenessProbe}{"\n"}'
# {"failureThreshold":3,"httpGet":{"path":"/index.html","port":80,"scheme":"HTTP"},"initialDelaySeconds":5,"periodSeconds":10,...}
# {"failureThreshold":3,"httpGet":{"path":"/","port":80,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":20,...}
kubectl -n kestrel describe pod -l app=kestrel-app | grep -E 'Liveness|Readiness'
# Liveness:   http-get http://:80/ delay=15s timeout=1s period=20s #success=1 #failure=3
# Readiness:  http-get http://:80/index.html delay=5s timeout=1s period=10s #success=1 #failure=3
kubectl -n kestrel get pods -l app=kestrel-app      # 2개, 1/1 Running, RESTARTS 0
kubectl -n kestrel get events --field-selector reason=Unhealthy   # 없어야 한다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: readiness 실패 = 트래픽에서 제외, liveness 실패 = 컨테이너 재시작. 둘 다 `containers[]` 아래.
- **헷갈리는 지점**: liveness 의 `initialDelaySeconds` 가 너무 짧으면 느리게 뜨는 앱이 시작 중에 계속 재시작됩니다. 이럴 때는 `startupProbe` 를 따로 두는 것이 정석입니다(startup 이 성공할 때까지 liveness/readiness 는 실행되지 않음). `port` 에는 숫자 대신 컨테이너 포트 이름(`name: http`)도 쓸 수 있습니다.

## 참고 문서

- 검색어: `configure liveness readiness startup probes`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q08 →](../q08_top_pod_cpu/question.md)

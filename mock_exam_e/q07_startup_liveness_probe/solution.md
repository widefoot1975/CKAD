# q07 — Add startup and liveness probes to a slow app · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Pod `slow-app` in namespace `onyx` needs about 40 seconds to start and has no health checks.
> Add probes so that Kubernetes waits for the start-up and afterwards restarts the container if it
> stops answering. The manifest is at `/opt/course/e07/slow-app.yaml`.
>
> 1. Add a `startupProbe` to container `app` that runs the command `cat /tmp/started`, every
>    `5` seconds, allowing up to `18` failures.
> 2. Add a `livenessProbe` that sends an HTTP GET to path `/healthz` on port `8080`, every `10`
>    seconds, with a failure threshold of `3`.
> 3. Recreate pod `slow-app` from the updated manifest and confirm that it becomes `Ready` with
>    `0` restarts.

**해석**

`onyx` 네임스페이스의 파드 `slow-app` 은 기동에 약 40초가 걸리고 헬스 체크가 없다. Kubernetes 가 기동을
기다려 주고, 그 뒤에는 응답이 멈추면 컨테이너를 재시작하도록 probe 를 추가한다. 매니페스트는
`/opt/course/e07/slow-app.yaml` 에 있다.

1. 컨테이너 `app` 에 `startupProbe` 를 추가한다. 명령 `cat /tmp/started` 를 `5` 초마다 실행하고 실패를
   최대 `18` 번까지 허용한다.
2. 포트 `8080` 의 경로 `/healthz` 로 HTTP GET 을 보내는 `livenessProbe` 를 추가한다. 주기는 `10` 초,
   실패 임계값은 `3` 이다.
3. 고친 매니페스트로 파드 `slow-app` 을 다시 만들고, 재시작 `0` 회로 `Ready` 가 되는지 확인한다.

## 모범 풀이

**1)·2) 매니페스트에 probe 두 개를 넣습니다**

```bash
vi /opt/course/e07/slow-app.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: slow-app
  namespace: onyx
  labels:
    app: slow-app
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "echo booting; sleep 40; mkdir -p /www; echo ok > /www/healthz; touch /tmp/started; echo started; exec httpd -f -p 8080 -h /www"]
    ports:
    - containerPort: 8080
    startupProbe:                 # 추가
      exec:
        command: ["cat", "/tmp/started"]
      periodSeconds: 5
      failureThreshold: 18        # 5초 × 18 = 최대 90초까지 기동을 기다린다
    livenessProbe:                # 추가
      httpGet:
        path: /healthz
        port: 8080
      periodSeconds: 10
      failureThreshold: 3
```

startupProbe 가 한 번 성공하기 전까지 kubelet 은 liveness/readiness probe 를 **실행하지 않습니다**.
그래서 느린 기동 동안 liveness 가 컨테이너를 죽이지 않고, 기동 뒤에는 짧은 주기의 liveness 가 그대로
동작합니다. 기동 허용 시간은 `periodSeconds × failureThreshold` 입니다. 40초 기동에 90초 예산이라
여유가 있습니다.

`exec.command` 는 셸을 거치지 않으므로 배열로 적습니다. `cat` 은 파일이 없으면 0 이 아닌 코드로
끝나 실패, 있으면 0 으로 성공입니다.

**3) 파드를 다시 만듭니다**

파드의 probe 필드는 바꿀 수 없으므로(immutable) 제자리 수정이 안 됩니다.

```bash
kubectl replace --force -f /opt/course/e07/slow-app.yaml
kubectl -n onyx get pod slow-app -w
# slow-app   0/1   Running   0   5s      ← startup probe 진행 중, 아직 Ready 아님
# slow-app   1/1   Running   0   45s     ← /tmp/started 생성 후 Ready
```

readinessProbe 가 없어도 startupProbe 가 성공하기 전에는 컨테이너가 Ready 가 되지 않습니다.

### 그림 — 시간축으로 본 두 probe

```mermaid
flowchart LR
    S["0s 컨테이너 시작"] --> P["startupProbe<br/>5s 마다 cat /tmp/started<br/>실패 허용 18회 (90s)"]
    P -->|"약 40s 성공"| L["livenessProbe 시작<br/>10s 마다 GET /healthz:8080"]
    P -.->|"90s 안에 성공 못 함"| K["컨테이너 kill → 재시작"]
    L -->|"3회 연속 실패"| K
    L -->|"성공"| L
```

1. 시작 직후에는 startupProbe 만 돕니다. 실패해도 18번까지는 아무 일도 일어나지 않습니다.
2. 약 40초 뒤 `/tmp/started` 가 생겨 startupProbe 가 성공하면 그때부터 livenessProbe 가 돌고 컨테이너가 Ready 가 됩니다.
3. 이후 `/healthz` 가 3번 연속 실패하면 kubelet 이 컨테이너를 재시작합니다. startupProbe 가 90초 안에 성공하지 못해도 재시작됩니다.

## 검증

```bash
kubectl -n onyx get pod slow-app
# NAME       READY   STATUS    RESTARTS   AGE
# slow-app   1/1     Running   0          70s
kubectl -n onyx get pod slow-app -o jsonpath='{.spec.containers[0].startupProbe}{"\n"}{.spec.containers[0].livenessProbe}{"\n"}'
# {"exec":{"command":["cat","/tmp/started"]},"failureThreshold":18,"periodSeconds":5,...}
# {"failureThreshold":3,"httpGet":{"path":"/healthz","port":8080,"scheme":"HTTP"},"periodSeconds":10,...}
kubectl -n onyx describe pod slow-app | grep -E 'Startup|Liveness'
kubectl -n onyx get events --field-selector involvedObject.name=slow-app | grep -i unhealthy   # 기동 중 Startup probe failed 몇 번 (정상)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 느린 기동은 `initialDelaySeconds` 를 늘리기보다 startupProbe(`periodSeconds × failureThreshold`)로 보호한다.
- **헷갈리는 지점**: liveness 에 큰 `initialDelaySeconds` 를 주는 방법도 통하지만, 기동이 빨라도 그만큼 감시가 늦어지고 기동이 더 느려지면 재시작 루프에 빠집니다. probe 는 파드에서 바꿀 수 없는 필드라 `replace --force` 로 다시 만들어야 하며, 기동 중의 `Startup probe failed` 이벤트는 예상된 것입니다.

## 참고 문서

- 검색어: `liveness readiness startup probes`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q08 →](../q08_pending_pod_requests/question.md)

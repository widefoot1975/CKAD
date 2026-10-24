# q10 — Configure a Pod from a ConfigMap · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The application in namespace `swallow` reads a properties file and a log level from its
> environment.
>
> 1. Create a ConfigMap named `swallow-config` in namespace `swallow` with two keys: key
>    `app.properties` taken from the file `/opt/course/d10/app.properties`, and key `LOG_LEVEL` with
>    the literal value `debug`.
> 2. Create a Pod named `swallow-app` (image `busybox:1.36`, command `sleep 3600`) that mounts the
>    ConfigMap as a volume at `/etc/swallow`, so the file `/etc/swallow/app.properties` exists.
> 3. In the same Pod, set the environment variable `LOG_LEVEL` from key `LOG_LEVEL` of the
>    ConfigMap.

**해석**

`swallow` 네임스페이스의 애플리케이션은 properties 파일 하나와 환경 변수의 로그 레벨을 읽는다.

1. `swallow` 네임스페이스에 키가 두 개인 ConfigMap `swallow-config` 를 만든다. 키 `app.properties` 는 파일
   `/opt/course/d10/app.properties` 에서 가져오고, 키 `LOG_LEVEL` 은 리터럴 값 `debug` 로 한다.
2. ConfigMap 을 볼륨으로 `/etc/swallow` 에 마운트해 `/etc/swallow/app.properties` 파일이 보이는 Pod
   `swallow-app`(이미지 `busybox:1.36`, 명령 `sleep 3600`)을 만든다.
3. 같은 파드에서 환경 변수 `LOG_LEVEL` 을 ConfigMap 의 키 `LOG_LEVEL` 에서 가져온다.

## 모범 풀이

**1) ConfigMap — 파일과 리터럴을 한 번에**

```bash
kubectl -n swallow create configmap swallow-config \
  --from-file=/opt/course/d10/app.properties \
  --from-literal=LOG_LEVEL=debug
kubectl -n swallow describe cm swallow-config     # Data: app.properties, LOG_LEVEL
```

`--from-file=<경로>` 는 **파일 이름이 키**가 됩니다. 다른 키 이름이 필요하면 `--from-file=<키>=<경로>` 로 씁니다.
`--from-env-file` 은 파일의 각 줄을 따로 키로 쪼개므로 이 문제(파일 통째로 한 키)에는 맞지 않습니다.

**2)–3) 파드 — 볼륨과 env 하나**

```bash
export do="--dry-run=client -o yaml"
kubectl -n swallow run swallow-app --image=busybox:1.36 $do -- sleep 3600 > pod.yaml
```

`run ... -- sleep 3600` 은 `args` 로 들어갑니다. busybox 이미지에는 ENTRYPOINT 가 없어서 `args` 가 그대로 실행 명령이
됩니다. `command:` 로 적고 싶으면 `--command -- sleep 3600` 을 씁니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: swallow-app
  namespace: swallow
spec:
  volumes:
  - name: config
    configMap:
      name: swallow-config
  containers:
  - name: swallow-app
    image: busybox:1.36
    args: ["sleep", "3600"]
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: swallow-config
          key: LOG_LEVEL
    volumeMounts:
    - name: config
      mountPath: /etc/swallow
```

```bash
kubectl apply -f pod.yaml
```

ConfigMap 볼륨은 키마다 파일 하나를 만듭니다. 그래서 `/etc/swallow/app.properties` 와 `/etc/swallow/LOG_LEVEL` 이
같이 생깁니다. `app.properties` 만 원하면 `items: [{key: app.properties, path: app.properties}]` 로 고릅니다.

## 검증

```bash
kubectl -n swallow get pod swallow-app                          # Running
kubectl -n swallow exec swallow-app -- cat /etc/swallow/app.properties
# app.name=swallow
# app.mode=production
# cache.size=128
kubectl -n swallow exec swallow-app -- sh -c 'echo $LOG_LEVEL'   # debug
kubectl -n swallow get cm swallow-config -o jsonpath='{.data.LOG_LEVEL}{"\n"}'   # debug
```

`exec ... -- echo $LOG_LEVEL` 처럼 쓰면 **로컬 셸**이 먼저 변수를 펼쳐 빈 값이 넘어갑니다. `sh -c '...'` 로 감싸
컨테이너 안에서 펼치게 합니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `--from-file` 은 파일 이름이 키, `--from-literal=K=V` 는 한 쌍. 볼륨은 `configMap.name`, env 하나는 `valueFrom.configMapKeyRef`.
- **헷갈리는 지점**: ConfigMap 을 바꾸면 볼륨 파일은 잠시 뒤 갱신되지만(`subPath` 마운트는 제외) 환경 변수는 파드를 다시 만들어야 바뀝니다. 키 전체를 env 로 넣는 것은 `envFrom.configMapRef` 지만, `app.properties` 처럼 점이 든 여러 줄 값은 셸 변수로 쓰기 어려우니 파일(볼륨)로 주는 것이 맞습니다.

## 참고 문서

- 검색어: `configure a pod to use a configmap`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/docs/concepts/configuration/configmap/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q11 →](../q11_secret_envfrom/question.md)

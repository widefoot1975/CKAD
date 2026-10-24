# q13 — SecurityContext precedence and a read-only root filesystem · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Pod `secure-web` in namespace `poplar` must run hardened, but container `web` keeps crashing. Its
> manifest is `/opt/course/c13/secure-web.yaml`.
>
> 1. Keep the Pod-level security context (`runAsUser: 1000`, `runAsGroup: 3000`,
>    `runAsNonRoot: true`).
> 2. Container `web` must run as UID `2000`, overriding the Pod-level user for this container only,
>    with `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false` and all capabilities
>    dropped. Container `helper` must keep the Pod-level user.
> 3. Make `web` start while its root filesystem stays read-only, by giving it writable `emptyDir`
>    volumes at exactly `/tmp` and `/var/cache/nginx` and nowhere else.
> 4. Write the output of `id` from `web` and then from `helper` (two lines) to
>    `/opt/course/c13/ids.txt`. Write the error that `web` prints for `touch /etc/nginx/probe` to
>    `/opt/course/c13/rofs.txt`. Save the `<title>` line of the page that `helper` gets from
>    `http://localhost:8080/` to `/opt/course/c13/page.txt`.

**해석**

namespace `poplar` 의 Pod `secure-web` 은 강화된 설정으로 돌아야 하는데 컨테이너 `web` 이 계속 죽는다. 매니페스트는
`/opt/course/c13/secure-web.yaml` 이다.

1. Pod 수준 security context(`runAsUser: 1000`, `runAsGroup: 3000`, `runAsNonRoot: true`)는 유지한다.
2. 컨테이너 `web` 은 이 컨테이너에서만 Pod 수준 사용자를 덮어써 UID `2000` 으로 돌고, `readOnlyRootFilesystem: true`,
   `allowPrivilegeEscalation: false`, 모든 capability 제거를 갖는다. 컨테이너 `helper` 는 Pod 수준 사용자를 그대로 쓴다.
3. 루트 파일시스템은 읽기 전용으로 둔 채, 정확히 `/tmp` 와 `/var/cache/nginx` 에만 쓰기 가능한 `emptyDir` 볼륨을 주어
   `web` 이 기동하게 한다(다른 곳에는 주지 않는다).
4. `web`, 그다음 `helper` 에서 실행한 `id` 출력(두 줄)을 `/opt/course/c13/ids.txt` 에 쓴다. `web` 이
   `touch /etc/nginx/probe` 에 대해 출력하는 오류를 `/opt/course/c13/rofs.txt` 에 쓴다. `helper` 가
   `http://localhost:8080/` 에서 받은 페이지의 `<title>` 줄을 `/opt/course/c13/page.txt` 에 저장한다.

## 모범 풀이

**0) 왜 죽는지 먼저**

```bash
kubectl -n poplar logs secure-web -c web --previous | tail -3
# nginx: [emerg] mkdir() "/tmp/client_temp" failed (30: Read-only file system)
```

`nginx-unprivileged` 이미지는 pid 파일과 임시 디렉터리(`client_temp`, `proxy_temp` 등)를 `/tmp` 아래에 둡니다.
루트 파일시스템이 읽기 전용이면 `/tmp` 도 읽기 전용이라 기동 즉시 죽습니다. 해결은 `readOnlyRootFilesystem` 을 끄는
것이 아니라, **쓰기가 필요한 경로에만 emptyDir 을 덮는 것**입니다.

**1)~3) 매니페스트 수정** — 컨테이너의 securityContext 와 볼륨은 실행 중에 바꿀 수 없으므로 다시 만듭니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-web
  namespace: poplar
  labels:
    app: secure-web
spec:
  securityContext:                 # Pod 수준: 모든 컨테이너의 기본값
    runAsUser: 1000
    runAsGroup: 3000
    runAsNonRoot: true
  containers:
  - name: web
    image: nginxinc/nginx-unprivileged:1.27-alpine
    ports:
    - containerPort: 8080
    securityContext:               # 컨테이너 수준: 같은 필드는 이쪽이 이긴다
      runAsUser: 2000
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /var/cache/nginx
  - name: helper
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

```bash
vi /opt/course/c13/secure-web.yaml          # 위처럼 수정
kubectl replace --force -f /opt/course/c13/secure-web.yaml
kubectl -n poplar wait --for=condition=Ready pod/secure-web --timeout=60s
```

- **우선순위**: `runAsUser`, `runAsGroup`, `runAsNonRoot`, `seLinuxOptions`, `seccompProfile` 처럼 두 곳에 다 있는
  필드는 컨테이너 수준이 Pod 수준을 덮어씁니다. 덮어쓰지 않은 필드(`runAsGroup: 3000`)는 Pod 수준에서 물려받습니다.
  그래서 `web` 은 uid 2000 / gid 3000, `helper` 는 uid 1000 / gid 3000 입니다.
- `readOnlyRootFilesystem`, `allowPrivilegeEscalation`, `capabilities`, `privileged` 는 **컨테이너 수준에만** 있는
  필드입니다. Pod 의 `securityContext` 에 쓰면 `unknown field` 로 거부됩니다.
- `fsGroup`·`supplementalGroups`·`sysctls` 는 반대로 Pod 수준에만 있습니다.
- emptyDir 은 기본 권한이 모두 쓰기 가능(0777)이라 uid 2000 으로도 쓸 수 있습니다.
- nginx 가 8080(1024 이상)에서 듣기 때문에 `NET_BIND_SERVICE` 없이 `drop: ["ALL"]` 로도 됩니다. 80 포트였다면
  capability 를 다시 추가해야 했을 것입니다.

**4) 확인과 기록**

```bash
{ kubectl -n poplar exec secure-web -c web -- id; kubectl -n poplar exec secure-web -c helper -- id; } \
  | tee /opt/course/c13/ids.txt
# uid=2000 gid=3000 groups=3000
# uid=1000 gid=3000 groups=3000

kubectl -n poplar exec secure-web -c web -- touch /etc/nginx/probe 2> /opt/course/c13/rofs.txt
cat /opt/course/c13/rofs.txt
# touch: /etc/nginx/probe: Read-only file system
# command terminated with exit code 1

kubectl -n poplar exec secure-web -c helper -- wget -qO- http://localhost:8080/ | grep '<title>' \
  | tee /opt/course/c13/page.txt
# <title>Welcome to nginx!</title>
```

같은 Pod 의 컨테이너는 네트워크 namespace 를 공유하므로 `helper` 에서 `localhost:8080` 이 `web` 입니다.

## 검증

```bash
kubectl -n poplar get pod secure-web                     # 2/2 Running, RESTARTS 0
cat /opt/course/c13/ids.txt                              # uid=2000 ... / uid=1000 ...
grep -q 'Read-only file system' /opt/course/c13/rofs.txt && echo ok
cat /opt/course/c13/page.txt                             # <title>Welcome to nginx!</title>
kubectl -n poplar get pod secure-web -o jsonpath='{.spec.containers[?(@.name=="web")].securityContext}{"\n"}'
# {"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsUser":2000}
kubectl -n poplar get pod secure-web -o jsonpath='{.spec.containers[?(@.name=="web")].volumeMounts[*].mountPath}{"\n"}'
# /tmp /var/cache/nginx   (+ 자동 마운트되는 serviceaccount 경로)
kubectl -n poplar exec secure-web -c web -- touch /tmp/ok && echo tmp-writable
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 같은 필드는 container securityContext 가 pod securityContext 를 이긴다. `readOnlyRootFilesystem`·`capabilities`·`allowPrivilegeEscalation` 은 컨테이너 수준에만 있다.
- **헷갈리는 지점**: 읽기 전용 루트 FS 로 죽는 앱은 `readOnlyRootFilesystem` 을 끄지 말고 쓰기 경로에 emptyDir 을 줍니다. Pod Security Admission 의 `restricted` 프로필은 `runAsNonRoot`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, seccomp `RuntimeDefault` 를 요구합니다.

## 참고 문서

- 검색어: `configure security context`, `pod security standards`
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- https://kubernetes.io/docs/concepts/security/pod-security-standards/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q14 →](../q14_operator_crd_discovery/question.md)

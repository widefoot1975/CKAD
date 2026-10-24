# q14 — Harden a Pod with a securityContext · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The Pod defined in `/opt/course/d14/lark-secure.yaml` must run with minimal privileges in
> namespace `lark`. Edit the file and create the Pod from it.
>
> 1. At Pod level, run all containers as user ID `1000` and require that they do not run as root.
> 2. For container `app`, make the root filesystem read-only, disallow privilege escalation and drop
>    all Linux capabilities.
> 3. The container still has to write to `/tmp`. Mount an `emptyDir` volume named `tmp` at `/tmp`.
>    The Pod must be `Running`.
> 4. Write the output of `id -u` executed inside container `app` to `/opt/course/d14/uid.txt`.

**해석**

`/opt/course/d14/lark-secure.yaml` 에 정의된 파드를 `lark` 네임스페이스에서 최소 권한으로 돌려야 한다. 파일을
고치고 그 파일로 파드를 만든다.

1. 파드 수준에서 모든 컨테이너를 사용자 ID `1000` 으로 실행하고, root 로 실행되지 않도록 강제한다.
2. 컨테이너 `app` 의 루트 파일시스템을 읽기 전용으로 하고, 권한 상승을 막고, 모든 Linux capability 를 뺀다.
3. 컨테이너는 여전히 `/tmp` 에 써야 한다. `emptyDir` 볼륨 `tmp` 를 `/tmp` 에 마운트한다. 파드는 `Running` 이어야
   한다.
4. 컨테이너 `app` 안에서 실행한 `id -u` 의 출력을 `/opt/course/d14/uid.txt` 에 적는다.

## 모범 풀이

**1)–3) 파드 수준과 컨테이너 수준을 나눠 적습니다**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lark-secure
  namespace: lark
spec:
  securityContext:                  # 파드 수준 (PodSecurityContext)
    runAsUser: 1000
    runAsNonRoot: true
  volumes:
  - name: tmp
    emptyDir: {}
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /tmp/heartbeat.log; sleep 10; done"]
    securityContext:                # 컨테이너 수준 (SecurityContext)
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    volumeMounts:
    - name: tmp
      mountPath: /tmp
```

```bash
kubectl apply -f /opt/course/d14/lark-secure.yaml
kubectl -n lark get pod lark-secure          # Running
```

`readOnlyRootFilesystem`, `allowPrivilegeEscalation`, `capabilities` 는 **컨테이너 수준에만** 있는 필드입니다. 파드
`spec.securityContext` 에 넣으면 `unknown field` 로 거부됩니다. 반대로 `runAsUser`·`runAsNonRoot` 는 양쪽에 다 있고
컨테이너 값이 파드 값보다 우선합니다. busybox 이미지는 기본 사용자가 root 라서 `runAsUser` 없이 `runAsNonRoot: true`
만 주면 `CreateContainerConfigError`(image will run as root)로 막힙니다. 루트 파일시스템이 읽기 전용이 되면 `/tmp`
쓰기도 실패하므로 emptyDir 을 마운트해 그 경로만 쓰기 가능하게 합니다(emptyDir 은 기본 권한 0777).

**4) 확인**

```bash
kubectl -n lark exec lark-secure -c app -- id -u > /opt/course/d14/uid.txt
cat /opt/course/d14/uid.txt                  # 1000
```

## 검증

```bash
kubectl -n lark exec lark-secure -- id                       # uid=1000 gid=0(root) groups=0(root)
kubectl -n lark exec lark-secure -- touch /test              # touch: /test: Read-only file system
kubectl -n lark exec lark-secure -- tail -2 /tmp/heartbeat.log   # 날짜 두 줄 (쓰기 성공)
kubectl -n lark exec lark-secure -- grep Cap /proc/1/status
# CapInh/CapPrm/CapEff/CapBnd/CapAmb: 0000000000000000      ← 모든 capability 제거
kubectl -n lark get pod lark-secure -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}{"\n"}'
# {"runAsNonRoot":true,"runAsUser":1000}
# {"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}
cat /opt/course/d14/uid.txt                                  # 1000
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 파드 수준 = `runAsUser/runAsGroup/runAsNonRoot/fsGroup`, 컨테이너 전용 = `readOnlyRootFilesystem/allowPrivilegeEscalation/capabilities/privileged`.
- **헷갈리는 지점**: `capabilities.drop` 값은 `ALL` (대문자, `CAP_` 접두사 없음)입니다. 파드 securityContext 는 만든 뒤 바꿀 수 없어 `kubectl replace --force -f` 로 다시 만듭니다. 네임스페이스에 Pod Security Admission `restricted` 라벨이 붙어 있으면 이 네 가지에 더해 `seccompProfile.type: RuntimeDefault` 도 있어야 통과합니다.

## 참고 문서

- 검색어: `configure a security context for a pod or container`
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- https://kubernetes.io/docs/concepts/security/pod-security-standards/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q15 →](../q15_clusterip_service_endpointslice/question.md)

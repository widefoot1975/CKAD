# q10 — Rotate an immutable Secret · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Secret `api-token` in namespace `spruce` is marked immutable. Its token has leaked and must be
> rotated without giving up immutability.
>
> 1. The key `token` of Secret `api-token` must have the value `new-token-222`. The Secret must keep
>    its name and must still be immutable.
> 2. The running Pods of Deployment `client` must use the new value in their environment variable
>    `API_TOKEN`. Do not edit the Deployment's manifest.
> 3. Create Pod `auditor` in `spruce` with image `busybox:1.36` running `sleep 3600` that exposes only
>    the key `token` of Secret `api-token`, as the environment variable `AUDIT_KEY`.
> 4. Write the value of `API_TOKEN` as seen inside one `client` Pod to `/opt/course/c10/client.txt`
>    and the value of `AUDIT_KEY` inside `auditor` to `/opt/course/c10/auditor.txt`.

**해석**

namespace `spruce` 의 Secret `api-token` 은 immutable 로 표시되어 있다. 토큰이 유출되어, immutable 을 포기하지
않고 교체해야 한다.

1. Secret `api-token` 의 키 `token` 값은 `new-token-222` 여야 한다. Secret 은 이름을 유지하고 여전히 immutable 이어야
   한다.
2. Deployment `client` 의 실행 중인 파드가 환경 변수 `API_TOKEN` 에서 새 값을 써야 한다. Deployment 매니페스트는
   편집하지 않는다.
3. `spruce` 에 이미지 `busybox:1.36`, `sleep 3600` 을 실행하는 Pod `auditor` 를 만든다. Secret `api-token` 의 키
   `token` 만 환경 변수 `AUDIT_KEY` 로 노출한다.
4. `client` 파드 하나 안에서 본 `API_TOKEN` 값을 `/opt/course/c10/client.txt` 에, `auditor` 안의 `AUDIT_KEY` 값을
   `/opt/course/c10/auditor.txt` 에 쓴다.

## 모범 풀이

**1) immutable Secret 은 고칠 수 없고, 지우고 다시 만든다**

```bash
kubectl -n spruce patch secret api-token -p '{"stringData":{"token":"new-token-222"}}'
# The Secret "api-token" is invalid: data: Forbidden: field is immutable when `immutable` is set
```

`immutable: true` 인 Secret/ConfigMap 은 `data`·`stringData` 를 바꿀 수 없고, `immutable` 자체도 `false` 로 되돌릴 수
없습니다. 남은 방법은 **삭제 후 재생성**입니다. `kubectl create secret` 에는 immutable 플래그가 없으므로 yaml 로
뽑아 필드를 붙입니다.

```bash
kubectl -n spruce create secret generic api-token --from-literal=token=new-token-222 \
  --dry-run=client -o yaml > /tmp/api-token.yaml
echo 'immutable: true' >> /tmp/api-token.yaml          # 최상위 필드라 맨 끝에 붙여도 된다
kubectl replace --force -f /tmp/api-token.yaml          # delete + create
```

**2) 실행 중인 파드는 옛 값을 계속 쓴다 → 재시작**

```bash
kubectl -n spruce exec deploy/client -- printenv API_TOKEN     # 아직 old-token-111
kubectl -n spruce rollout restart deploy client
kubectl -n spruce rollout status deploy client
```

환경 변수는 **컨테이너가 시작될 때 한 번** 채워집니다. Secret 을 바꿔도(지우고 다시 만들어도) 이미 떠 있는
컨테이너의 env 는 그대로입니다. `rollout restart` 는 파드 템플릿에 `kubectl.kubernetes.io/restartedAt` 어노테이션만
넣어 새 파드를 굴리므로, 매니페스트의 내용(이미지·env 정의)을 편집하지 않고 새 값을 읽게 합니다. 볼륨으로 마운트한
경우에도 immutable Secret 은 kubelet 이 감시(watch)하지 않으므로 갱신되지 않습니다 — 이것이 immutable 의 성능상
이점이자 대가입니다.

**3) 다른 이름의 env 로 키 하나만**

```bash
kubectl -n spruce run auditor --image=busybox:1.36 --dry-run=client -o yaml -- sleep 3600 > /tmp/auditor.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: auditor
  namespace: spruce
spec:
  containers:
  - name: auditor
    image: busybox:1.36
    args: ["sleep", "3600"]
    env:
    - name: AUDIT_KEY                 # env 이름은 자유
      valueFrom:
        secretKeyRef:
          name: api-token
          key: token                  # Secret 의 키
```

```bash
kubectl apply -f /tmp/auditor.yaml
kubectl -n spruce wait --for=condition=Ready pod/auditor
```

`envFrom.secretRef` 를 쓰면 Secret 의 **모든 키가 키 이름 그대로** 들어갑니다(`token`). 다른 이름, 한 키만이라면
`env[].valueFrom.secretKeyRef` 입니다. `kubectl set env pod/... --from=secret/api-token --keys=token --prefix=...`
같은 방식은 이름을 바꿀 수 없고 Pod 에는 env 추가도 안 됩니다(불변).

**4) 확인과 기록**

```bash
kubectl -n spruce exec deploy/client -- printenv API_TOKEN | tee /opt/course/c10/client.txt    # new-token-222
kubectl -n spruce exec auditor -- printenv AUDIT_KEY | tee /opt/course/c10/auditor.txt         # new-token-222
```

`exec deploy/client` 는 Deployment 의 파드 중 하나를 골라 실행합니다. 재시작 뒤라 어느 파드든 새 값입니다.

## 검증

```bash
kubectl -n spruce get secret api-token -o jsonpath='{.immutable} {.data.token}{"\n"}'
# true bmV3LXRva2VuLTIyMg==
kubectl -n spruce get secret api-token -o jsonpath='{.data.token}' | base64 -d; echo    # new-token-222
for p in $(kubectl -n spruce get pod -l app=client -o name); do kubectl -n spruce exec $p -- printenv API_TOKEN; done
# new-token-222 (두 파드 모두)
kubectl -n spruce exec auditor -- env | grep -E 'AUDIT_KEY|token'    # AUDIT_KEY=new-token-222 한 줄만
cat /opt/course/c10/client.txt /opt/course/c10/auditor.txt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: immutable Secret 은 삭제 후 재생성만 가능하다. env 로 읽은 값은 파드를 다시 띄워야(`rollout restart`) 바뀐다.
- **헷갈리는 지점**: `kubectl create secret` 에는 immutable 옵션이 없어 yaml 에 `immutable: true` 를 직접 넣습니다. 이름을 그대로 두는 대신 `api-token-v2` 같은 새 이름으로 만들고 Deployment 참조를 바꾸는 방법도 있지만(kustomize 해시 방식), 이 문제는 이름 유지가 조건입니다.

## 참고 문서

- 검색어: `immutable secrets`, `secret environment variable`
- https://kubernetes.io/docs/concepts/configuration/secret/#secret-immutable
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q11 →](../q11_rbac_clusterrole_rolebinding/question.md)

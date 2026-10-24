# q11 — ServiceAccount token and automount · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A CI job needs its own identity in namespace `indus`.
>
> 1. Create a ServiceAccount `deployer` in namespace `indus`.
> 2. Request a token for ServiceAccount `deployer` that is valid for `2h` and write only the token
>    to `/opt/course/f11/token.txt`.
> 3. Create a Pod `runner` in namespace `indus` (image `busybox:1.36`, command `sleep 3600`) that
>    runs as ServiceAccount `deployer` but does not get an API token mounted automatically. Configure
>    this on the Pod, not on the ServiceAccount.

**해석**

CI 작업이 `indus` 네임스페이스에서 쓸 자기 신원이 필요하다.

1. `indus` 네임스페이스에 ServiceAccount `deployer` 를 만든다.
2. ServiceAccount `deployer` 의 토큰을 `2h` 유효하게 발급받아, 토큰만 `/opt/course/f11/token.txt` 에 적는다.
3. `indus` 네임스페이스에 Pod `runner`(이미지 `busybox:1.36`, 명령 `sleep 3600`)를 만든다. ServiceAccount
   `deployer` 로 실행되지만 API 토큰이 자동으로 마운트되지 않게 한다. 이 설정은 ServiceAccount 가 아니라
   Pod 에 한다.

## 모범 풀이

**1) ServiceAccount**

```bash
kubectl -n indus create sa deployer
```

**2) 2시간짜리 토큰**

```bash
kubectl -n indus create token deployer --duration=2h > /opt/course/f11/token.txt
head -c 20 /opt/course/f11/token.txt; echo     # eyJhbGciOiJSUzI1NiIs...
```

v1.24 부터 ServiceAccount 를 만들어도 토큰 Secret 이 자동으로 생기지 않습니다. `kubectl create token` 은
TokenRequest API 로 기한이 있는 토큰을 바로 받아 표준 출력에 토큰만 찍습니다. 저장되지 않으므로 파일로 받아 둡니다.
API 서버가 최대 기한을 더 짧게 제한하면 그 값으로 줄어들 수 있습니다.

**3) automount 끈 Pod**

```bash
kubectl -n indus run runner --image=busybox:1.36 --dry-run=client -o yaml \
  --command -- sleep 3600 > /tmp/runner.yaml
```

`spec` 에 두 줄을 넣습니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: runner
  namespace: indus
  labels:
    run: runner
spec:
  serviceAccountName: deployer
  automountServiceAccountToken: false
  containers:
  - name: runner
    image: busybox:1.36
    command: ["sleep", "3600"]
```

```bash
kubectl apply -f /tmp/runner.yaml
kubectl -n indus wait pod runner --for=condition=Ready
```

`automountServiceAccountToken` 은 ServiceAccount 와 Pod 양쪽에 있고, **Pod 의 값이 우선**합니다. Pod 에
`false` 를 주면 SA 설정과 상관없이 projected 토큰 볼륨이 붙지 않습니다. `kubectl run --serviceaccount` 플래그는
없어졌으므로 YAML 로 넣습니다.

## 검증

```bash
kubectl -n indus get sa deployer
kubectl -n indus get pod runner -o jsonpath='{.spec.serviceAccountName} {.spec.automountServiceAccountToken}{"\n"}'
# deployer false
kubectl -n indus exec runner -- ls /var/run/secrets/kubernetes.io/serviceaccount
# ls: /var/run/secrets/kubernetes.io/serviceaccount: No such file or directory
kubectl -n indus get pod runner -o jsonpath='{.spec.volumes}{"\n"}'     # kube-api-access-* 볼륨 없음

# 토큰의 주체와 기한 (JWT payload 디코드, exp - iat = 7200)
P=$(cut -d. -f2 /opt/course/f11/token.txt | tr '_-' '/+')
while [ $(( ${#P} % 4 )) -ne 0 ]; do P="$P="; done
echo "$P" | base64 -d; echo
# {"aud":[...],"exp":17xxxxxxxx,"iat":17xxxxxxxx,...,"sub":"system:serviceaccount:indus:deployer"}
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 토큰은 `kubectl create token <sa> -n <ns> --duration=2h`, 마운트 끄기는 Pod `spec.automountServiceAccountToken: false`.
- **헷갈리는 지점**: SA 를 만들어도 토큰 Secret 은 더 이상 자동 생성되지 않습니다(v1.24~). `serviceAccount` 필드는 deprecated 이고 `serviceAccountName` 을 씁니다. Pod 와 SA 에 둘 다 설정하면 Pod 값이 이깁니다.

## 참고 문서

- 검색어: `configure service accounts for pods`, `kubectl create token`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_token/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q12 →](../q12_container_capabilities/question.md)

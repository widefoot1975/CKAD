# q12 — Run a Deployment with a dedicated ServiceAccount · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The security team wants Deployment `crane-api` in namespace `crane` to stop using the `default`
> ServiceAccount.
>
> 1. Create a ServiceAccount named `crane-sa` in namespace `crane`.
> 2. Configure Deployment `crane-api` so that its Pods run with ServiceAccount `crane-sa`. All Pods
>    of the Deployment must be replaced and ready.
> 3. Create a token for ServiceAccount `crane-sa` that is valid for `1h` and write it to
>    `/opt/course/d12/token.txt`.

**해석**

보안팀은 `crane` 네임스페이스의 Deployment `crane-api` 가 더 이상 `default` ServiceAccount 를 쓰지 않기를
원한다.

1. `crane` 네임스페이스에 ServiceAccount `crane-sa` 를 만든다.
2. Deployment `crane-api` 의 파드가 ServiceAccount `crane-sa` 로 돌도록 설정한다. Deployment 의 모든 파드가
   교체되고 Ready 여야 한다.
3. ServiceAccount `crane-sa` 에 대해 `1h` 동안 유효한 토큰을 만들어 `/opt/course/d12/token.txt` 에 적는다.

## 모범 풀이

**1) ServiceAccount**

```bash
kubectl -n crane create serviceaccount crane-sa
```

**2) Deployment 에 연결**

```bash
kubectl -n crane set serviceaccount deploy crane-api crane-sa
kubectl -n crane rollout status deploy crane-api
```

`set serviceaccount`(`set sa`)는 `spec.template.spec.serviceAccountName` 을 바꿉니다. 파드 템플릿이 바뀌므로 새
ReplicaSet 이 만들어지고 파드가 모두 교체됩니다. 파드의 ServiceAccount 는 만든 뒤 바꿀 수 없는 필드라, 파드에 직접
`edit` 하면 거부됩니다. 반드시 Deployment(템플릿)를 고칩니다. `kubectl edit deploy` 로 바꿀 때 필드 이름은
`serviceAccountName` 입니다(`serviceAccount` 는 예전 별칭이라 쓰지 않습니다).

**3) 기간 제한 토큰**

```bash
kubectl -n crane create token crane-sa --duration=1h > /opt/course/d12/token.txt
```

1.24 부터 ServiceAccount 를 만들어도 토큰 Secret 이 자동으로 생기지 않습니다. 필요할 때 `kubectl create token` 으로
TokenRequest API 를 불러 **만료 시간이 있는** 토큰을 받습니다. 파드 안에는 kubelet 이 projected 볼륨으로 따로 토큰을
넣어 주고 자동으로 갱신합니다.

## 검증

```bash
kubectl -n crane get sa crane-sa
kubectl -n crane get deploy crane-api -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'   # crane-sa
kubectl -n crane get pods -l app=crane-api \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.serviceAccountName}{"\n"}{end}'
# crane-api-xxxx  crane-sa   (두 개 모두)
kubectl -n crane get deploy crane-api                       # READY 2/2
cut -d. -f2 /opt/course/d12/token.txt | base64 -d 2>/dev/null | head -c 300; echo
# {"aud":[...],"exp":...,"iat":...,"kubernetes.io":{"namespace":"crane",...,"serviceaccount":{"name":"crane-sa",...}},...}
# exp - iat = 3600
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl set sa deploy/<d> <sa>` 로 템플릿을 바꾸고, 토큰은 `kubectl create token <sa> --duration=1h`.
- **헷갈리는 지점**: SA 만 만들고 권한(Role/RoleBinding)이 없으면 그 SA 로는 API 를 거의 쓸 수 없습니다. 토큰 자체가 필요 없는 앱이면 `automountServiceAccountToken: false` 로 파드에 토큰을 넣지 않게 합니다. `kubectl get secret` 에 SA 토큰이 안 보이는 것은 정상(1.24+)입니다.

## 참고 문서

- 검색어: `configure service accounts for pods`, `kubectl create token`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_token/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q13 →](../q13_resourcequota_requests_limits/question.md)

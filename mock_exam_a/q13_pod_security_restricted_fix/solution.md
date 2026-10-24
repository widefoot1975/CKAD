# q13 — Make a Deployment pass Pod Security restricted · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Namespace `nu` enforces the Pod Security Standard `restricted`. Deployment `portal` in this
> namespace has no Pods. Do not change the labels of the namespace.
>
> 1. Find out why the Pods are rejected and write the full rejection message to
>    `/opt/course/a13/violations.txt`.
> 2. The current image needs root, so change the container of Deployment `portal` to image
>    `hashicorp/http-echo:1.0` with args `-text=portal` and `-listen=:8080` and container port
>    `8080`.
> 3. Make the Pod template compliant with `restricted`: run as non-root with UID `10001`, use
>    the `RuntimeDefault` seccomp profile, forbid privilege escalation and drop all
>    capabilities. Put every setting at the level of the spec where Kubernetes allows it; set
>    the Pod-wide settings in the Pod's `securityContext`.
> 4. Both replicas must be `Running` and Ready, and their log must show that the server listens
>    on `:8080`.

**해석**

`nu` 네임스페이스는 Pod Security Standard `restricted` 를 강제한다. 이 네임스페이스의 Deployment `portal` 에 Pod 가 하나도 없다.
네임스페이스 라벨은 바꾸지 않는다.

1. Pod 가 거부되는 이유를 찾아 거부 메시지 전체를 `/opt/course/a13/violations.txt` 에 쓴다.
2. 지금 이미지는 root 가 필요하므로, Deployment `portal` 의 컨테이너를 이미지 `hashicorp/http-echo:1.0`, args `-text=portal`,
   `-listen=:8080`, 컨테이너 포트 `8080` 으로 바꾼다.
3. Pod 템플릿이 `restricted` 를 만족하게 한다. UID `10001` 의 비 root 로 실행하고, `RuntimeDefault` seccomp 프로필을 쓰고,
   권한 상승을 금지하고, 모든 capability 를 버린다. 각 설정은 쿠버네티스가 허용하는 spec 위치에 넣고, Pod 전체에 걸 수 있는
   설정은 Pod 의 `securityContext` 에 넣는다.
4. 두 레플리카 모두 `Running` · Ready 여야 하고, 로그에 서버가 `:8080` 에서 대기한다는 내용이 보여야 한다.

## 모범 풀이

**1) 거부 메시지 — ReplicaSet 이벤트에 있습니다**

```bash
alias k=kubectl
k get ns nu --show-labels
# nu   Active   ...   pod-security.kubernetes.io/enforce=restricted,pod-security.kubernetes.io/enforce-version=latest,...
k -n nu describe rs -l app=portal | grep -m1 'Error creating' | sed 's/^.*Error creating: //' > /opt/course/a13/violations.txt
cat /opt/course/a13/violations.txt
# pods "portal-7c..." is forbidden: violates PodSecurity "restricted:latest":
#   allowPrivilegeEscalation != false (container "portal" must set securityContext.allowPrivilegeEscalation=false),
#   unrestricted capabilities (container "portal" must set securityContext.capabilities.drop=["ALL"]),
#   runAsNonRoot != true (pod or container "portal" must set securityContext.runAsNonRoot=true),
#   seccompProfile (pod or container "portal" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

Pod Security Admission 은 **Pod 를 만들 때** 검사합니다. Deployment 자체는 만들어지고(`warn` 라벨이 있으면 경고만 출력),
ReplicaSet 이 만들려던 Pod 가 거부되어 `FailedCreate` 이벤트로 남습니다.

메시지가 `pod or container` 라고 하는 항목(runAsNonRoot, seccompProfile)은 Pod 수준에 둘 수 있고, `container` 라고만 하는
항목(allowPrivilegeEscalation, capabilities)은 **컨테이너 수준에만 있는 필드**입니다. PodSecurityContext 에는 이 두 필드가
없어서 Pod 수준에 쓰면 `unknown field` 로 거부됩니다.

**2) · 3) Pod 템플릿 고치기**

```bash
k -n nu edit deploy portal
```

```yaml
    spec:
      securityContext:                      # Pod 수준: 모든 컨테이너에 적용
        runAsNonRoot: true
        runAsUser: 10001
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: portal
        image: hashicorp/http-echo:1.0
        args: ["-text=portal", "-listen=:8080"]
        ports:
        - containerPort: 8080
        securityContext:                    # 컨테이너 수준에만 있는 필드
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
```

```bash
k -n nu rollout status deploy portal
```

| 설정 | Pod `securityContext` | 컨테이너 `securityContext` |
|---|---|---|
| `runAsNonRoot`, `runAsUser`, `runAsGroup` | O | O (컨테이너 값이 우선) |
| `seccompProfile` | O | O |
| `fsGroup`, `supplementalGroups` | O | X |
| `allowPrivilegeEscalation`, `capabilities`, `privileged`, `readOnlyRootFilesystem` | X | O |

`runAsNonRoot: true` 만 두고 `runAsUser` 를 빼면, kubelet 은 이미지의 `USER` 로 판단합니다. 이미지가 root 이거나 `USER app`
처럼 **이름**만 있으면 숫자인지 확인할 수 없어 `CreateContainerConfigError`(container has runAsNonRoot and image will run as root /
non-numeric user)가 납니다. 숫자 UID 를 명시하면 이미지와 상관없이 통과합니다. nginx 공식 이미지는 80 포트 바인드와 캐시
디렉터리 때문에 root 가 필요하므로 이미지 교체가 필요했습니다. restricted 는 `capabilities.add` 로 `NET_BIND_SERVICE` 하나만 허용합니다.

## 검증

```bash
k -n nu get pod -l app=portal
# portal-5f...-a   1/1   Running   0   20s
# portal-5f...-b   1/1   Running   0   20s
k -n nu logs -l app=portal --prefix | grep 8080
# [pod/portal-.../portal] ... server is listening on :8080
k -n nu get deploy portal -o jsonpath='{.spec.template.spec.securityContext}{"\n"}{.spec.template.spec.containers[0].securityContext}{"\n"}'
# {"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}
# {"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}
k label --dry-run=server --overwrite ns nu pod-security.kubernetes.io/enforce=restricted   # 경고 없음 = 기존 Pod 모두 준수
k get ns nu --show-labels                                                                  # 라벨 그대로
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: restricted 4종 세트 = `runAsNonRoot: true`(+숫자 UID), `seccompProfile: RuntimeDefault`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`. 뒤의 둘은 컨테이너 수준에만 있다.
- **헷갈리는 지점**: 거부된 Pod 는 존재하지 않으므로 `describe rs`(또는 `get events`)에서 메시지를 찾습니다. 라벨의 `enforce` 는 Pod 를 거부, `warn` 은 kubectl 에 경고, `audit` 은 감사 로그에만 남깁니다. init·사이드카 컨테이너가 있다면 그 컨테이너들에도 같은 컨테이너 수준 설정이 필요합니다.

## 참고 문서

- 검색어: `pod security standards`, `pod security admission`, `configure a security context`
- https://kubernetes.io/docs/concepts/security/pod-security-standards/
- https://kubernetes.io/docs/concepts/security/pod-security-admission/
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q14 →](../q14_crd_schema_scale_subresource/question.md)

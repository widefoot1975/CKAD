# q13 — Admit a pod under the restricted Pod Security level · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Namespace `beryl` enforces the Pod Security Standard `restricted`. The manifest
> `/opt/course/e13/secure-app.yaml` for pod `secure-app` is rejected when you apply it.
>
> 1. Apply the manifest once and write the complete error message to
>    `/opt/course/e13/rejection.txt`.
> 2. Fix the manifest so that the pod is admitted under `restricted`, without changing the
>    namespace labels, the image or the command. The container must run as user ID `1000`.
> 3. Create the pod and confirm that it is `Running`.

**해석**

`beryl` 네임스페이스는 Pod Security Standard `restricted` 를 강제한다. 파드 `secure-app` 의 매니페스트
`/opt/course/e13/secure-app.yaml` 은 적용하면 거부된다.

1. 매니페스트를 한 번 적용해 보고 에러 메시지 전체를 `/opt/course/e13/rejection.txt` 에 쓴다.
2. 네임스페이스 라벨, 이미지, 명령은 바꾸지 않고 파드가 `restricted` 에서 허용되도록 매니페스트를
   고친다. 컨테이너는 사용자 ID `1000` 으로 실행되어야 한다.
3. 파드를 만들고 `Running` 인지 확인한다.

## 모범 풀이

**1) 거부 메시지 기록**

```bash
kubectl get ns beryl --show-labels
kubectl apply -f /opt/course/e13/secure-app.yaml 2> /opt/course/e13/rejection.txt
cat /opt/course/e13/rejection.txt
# Error from server (Forbidden): error when creating "/opt/course/e13/secure-app.yaml": pods "secure-app"
# is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container
# "app" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container
# "app" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "app"
# must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "app" must set
# securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

에러는 stderr 로 나오므로 `>` 가 아니라 `2>` 로 받습니다(둘 다 받으려면 `> file 2>&1`). 메시지가 고칠
목록을 그대로 알려 줍니다. 네 가지입니다.

**2) securityContext 네 가지 + runAsUser**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: beryl
spec:
  securityContext:                 # 파드 수준
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date; sleep 10; done"]
    securityContext:               # 컨테이너 수준
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
```

`runAsNonRoot: true` 만 주면 busybox 이미지의 기본 사용자가 root(UID 0)라서 kubelet 이
`container has runAsNonRoot and image will run as root` 로 **기동을 막습니다**(admission 은 통과하지만
`CreateContainerConfigError`). 그래서 숫자 UID `runAsUser: 1000` 이 함께 필요합니다.
`allowPrivilegeEscalation` 과 `capabilities` 는 컨테이너 수준에만 있는 필드입니다.

**3) 생성과 확인**

```bash
kubectl apply -f /opt/course/e13/secure-app.yaml
kubectl -n beryl wait --for=condition=Ready pod/secure-app --timeout=60s
kubectl -n beryl exec secure-app -- id          # uid=1000 gid=0(root)
```

## 검증

```bash
grep -c 'violates PodSecurity "restricted' /opt/course/e13/rejection.txt     # 1
kubectl get ns beryl -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}'   # restricted
kubectl -n beryl get pod secure-app
# NAME         READY   STATUS    RESTARTS   AGE
# secure-app   1/1     Running   0          20s
kubectl -n beryl exec secure-app -- id -u                                   # 1000
kubectl -n beryl get pod secure-app -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}{"\n"}'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: restricted 통과 4종: `runAsNonRoot: true`(+숫자 `runAsUser`), `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`, `seccompProfile.type: RuntimeDefault`.
- **헷갈리는 지점**: PSA 는 파드를 만들 때(admission) 검사하므로 Deployment 는 만들어져도 ReplicaSet 이 파드를 못 만들고 이벤트에만 `FailedCreate` 가 남습니다(`kubectl describe rs`). `enforce` 는 거부, `warn` 은 경고만, `audit` 는 감사 로그만 남깁니다. 더 세밀한 사용자 정의 규칙이 필요하면 v1.30 GA 인 ValidatingAdmissionPolicy 를 씁니다.

## 참고 문서

- 검색어: `pod security standards`, `pod security admission`
- https://kubernetes.io/docs/concepts/security/pod-security-standards/
- https://kubernetes.io/docs/concepts/security/pod-security-admission/
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q14 →](../q14_crd_custom_resource/question.md)

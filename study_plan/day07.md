# 7일차 (D-4) — 보안과 리소스 (SecurityContext · RBAC · PSA · Quota)

[← 6일차](day06.md) · [계획 전체](README.md) · [8일차 →](day08.md)

## 오늘의 목표

- restricted Pod Security 를 통과하는 securityContext 를 외워서 쓸 수 있게 합니다.
- ResourceQuota 에 걸린 파드의 오류가 어디에 남는지(ReplicaSet 이벤트) 확인합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §5 Application Environment, Configuration and Security |
| 0:15 – 0:40 | 아래 문제 5개 풀기 |
| 0:40 – 0:52 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:52 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D13 | Env & Security | ResourceQuota 안에 파드 맞추기 | 5 | 5분 | [Q](../mock_exam_d/q13_resourcequota_requests_limits/question.md) · [S](../mock_exam_d/q13_resourcequota_requests_limits/solution.md) ☐ |
| D14 | Env & Security | securityContext 로 파드 강화 | 5 | 5분 | [Q](../mock_exam_d/q14_securitycontext_busybox/question.md) · [S](../mock_exam_d/q14_securitycontext_busybox/solution.md) ☐ |
| E12 | Env & Security | ServiceAccount 에 pods list 권한 | 5 | 5분 | [Q](../mock_exam_e/q12_rbac_serviceaccount_pods/question.md) · [S](../mock_exam_e/q12_rbac_serviceaccount_pods/solution.md) ☐ |
| E13 | Env & Security | restricted Pod Security 통과 | 5 | 5분 | [Q](../mock_exam_e/q13_pod_security_restricted/question.md) · [S](../mock_exam_e/q13_pod_security_restricted/solution.md) ☐ |
| F12 | Env & Security | Linux capability 하나만 부여 | 5 | 5분 | [Q](../mock_exam_f/q12_container_capabilities/question.md) · [S](../mock_exam_f/q12_container_capabilities/solution.md) ☐ |

합계 25점, 목표 25분.

## 꼭 잡을 것

```yaml
securityContext:              # restricted 4종 — 뒤의 둘은 컨테이너 수준에만 있다
  runAsNonRoot: true
  seccompProfile: { type: RuntimeDefault }
  allowPrivilegeEscalation: false
  capabilities: { drop: ["ALL"] }
```

```bash
kubectl auth can-i list pods -n ns --as=system:serviceaccount:ns:builder
kubectl -n ns describe rs -l app=web | grep -i quota
```

- `runAsNonRoot: true` 만 두면 이미지 USER 가 root 이거나 이름일 때 `CreateContainerConfigError` 가 납니다. 숫자 UID 를 같이 줍니다.
- capability 하나만 주라는 문제는 `drop: [ALL]` 다음에 `add: [NET_BIND_SERVICE]` 처럼 씁니다.
- quota 가 있는 네임스페이스는 **모든 컨테이너에** requests·limits 가 있어야 파드가 만들어집니다.

## 여유가 있으면

- 심화 [A13 Deployment 를 restricted 에 통과시키기](../mock_exam_a/q13_pod_security_restricted_fix/question.md)
- 심화 [B12 ValidatingAdmissionPolicy 를 통과하는 Deployment](../mock_exam_b/q12_validating_admission_policy/question.md)

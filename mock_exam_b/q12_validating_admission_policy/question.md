# q12 — Get a Deployment past a ValidatingAdmissionPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q12_validating_admission_policy
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에 ValidatingAdmissionPolicy 와 그 Binding 이 하나씩 있고(이름에 `b12` 포함), namespace `callisto` 에는 레이블이 붙어 있지만 Deployment 는 없다. `/opt/course/b12/orders.yaml` 에 적용이 거부되는 매니페스트가 있다.
ValidatingAdmissionPolicy 는 v1.30 에서 GA 이다. 정책·Binding·네임스페이스 레이블은 문제에서 바꾸면 안 된다.

## Task

The platform team enforces rules for Deployments with an admission policy. A developer cannot
apply `/opt/course/b12/orders.yaml` to namespace `callisto`.

1. Apply `/opt/course/b12/orders.yaml` and write the complete error returned by the API server to
   `/opt/course/b12/denied.txt`.
2. Find the ValidatingAdmissionPolicy and the ValidatingAdmissionPolicyBinding responsible, and
   write their names to `/opt/course/b12/policy.txt` in the form `<policy> <binding>`. In
   `/opt/course/b12/scope.txt`, write the namespace label (`key=value`) that makes the binding
   apply to `callisto`.
3. Fix `/opt/course/b12/orders.yaml` so that it satisfies every rule of the policy: the Deployment
   must belong to team `payments`, and any container without limits gets limits `cpu: 50m` and
   `memory: 32Mi`. Do not remove containers and do not change the existing values.
4. Apply the fixed manifest. Deployment `orders` must have 2 ready replicas.
5. Do not modify the policy, the binding or the labels of namespace `callisto`.

## My attempt

```bash

```

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q11](../q11_projected_sa_token_audience/question.md) · [q13 →](../q13_securitycontext_fsgroup_capabilities/question.md)

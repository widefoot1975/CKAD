# q13 — Admit a pod under the restricted Pod Security level

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q13_pod_security_restricted
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `beryl` 에는 라벨 `pod-security.kubernetes.io/enforce=restricted` 가 붙어 있고 파드는 없다.
매니페스트 `/opt/course/e13/secure-app.yaml`(securityContext 없음)이 있으며, 지금 그대로 적용하면 거부된다.

## Task

Namespace `beryl` enforces the Pod Security Standard `restricted`. The manifest
`/opt/course/e13/secure-app.yaml` for pod `secure-app` is rejected when you apply it.

1. Apply the manifest once and write the complete error message to
   `/opt/course/e13/rejection.txt`.
2. Fix the manifest so that the pod is admitted under `restricted`, without changing the
   namespace labels, the image or the command. The container must run as user ID `1000`.
3. Create the pod and confirm that it is `Running`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_rbac_serviceaccount_pods/question.md) · [q14 →](../q14_crd_custom_resource/question.md)

# q12 — Run a Deployment with a dedicated ServiceAccount

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q12_serviceaccount_deployment
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `crane` 에 Deployment `crane-api`(replicas 2, 이미지 `nginx:1.27-alpine`)가 ServiceAccount `default` 로 Ready 상태다. ServiceAccount `crane-sa` 는 없고 `/opt/course/d12/` 는 비어 있다.

## Task

The security team wants Deployment `crane-api` in namespace `crane` to stop using the `default`
ServiceAccount.

1. Create a ServiceAccount named `crane-sa` in namespace `crane`.
2. Configure Deployment `crane-api` so that its Pods run with ServiceAccount `crane-sa`. All Pods
   of the Deployment must be replaced and ready.
3. Create a token for ServiceAccount `crane-sa` that is valid for `1h` and write it to
   `/opt/course/d12/token.txt`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_secret_envfrom/question.md) · [q13 →](../q13_resourcequota_requests_limits/question.md)

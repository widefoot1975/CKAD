# q11 — ServiceAccount token and automount

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q11_serviceaccount_token_automount
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `indus` 는 비어 있다(`default` ServiceAccount 만 있음). ServiceAccount `deployer`, Pod `runner`, 토큰 파일은 모두 문제에서 만든다.

## Task

A CI job needs its own identity in namespace `indus`.

1. Create a ServiceAccount `deployer` in namespace `indus`.
2. Request a token for ServiceAccount `deployer` that is valid for `2h` and write only the token
   to `/opt/course/f11/token.txt`.
3. Create a Pod `runner` in namespace `indus` (image `busybox:1.36`, command `sleep 3600`) that
   runs as ServiceAccount `deployer` but does not get an API token mounted automatically. Configure
   this on the Pod, not on the ServiceAccount.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_configmap_env_restart_immutable/question.md) · [q12 →](../q12_container_capabilities/question.md)

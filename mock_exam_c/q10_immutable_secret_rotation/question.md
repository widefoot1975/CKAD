# q10 — Rotate an immutable Secret

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q10_immutable_secret_rotation
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `spruce` 에 `immutable: true` 인 Secret `api-token`(키 `token` = `old-token-111`)과, 이 키를 환경 변수 `API_TOKEN` 으로 읽는 Deployment `client`(replicas 2)가 있다. Pod `auditor` 는 아직 없다.

## Task

Secret `api-token` in namespace `spruce` is marked immutable. Its token has leaked and must be
rotated without giving up immutability.

1. The key `token` of Secret `api-token` must have the value `new-token-222`. The Secret must keep
   its name and must still be immutable.
2. The running Pods of Deployment `client` must use the new value in their environment variable
   `API_TOKEN`. Do not edit the Deployment's manifest.
3. Create Pod `auditor` in `spruce` with image `busybox:1.36` running `sleep 3600` that exposes only
   the key `token` of Secret `api-token`, as the environment variable `AUDIT_KEY`.
4. Write the value of `API_TOKEN` as seen inside one `client` Pod to `/opt/course/c10/client.txt`
   and the value of `AUDIT_KEY` inside `auditor` to `/opt/course/c10/auditor.txt`.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_api_deprecation_hpa_v2/question.md) · [q11 →](../q11_rbac_clusterrole_rolebinding/question.md)

# q04 — Canary release behind a shared Service

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q04_canary_deployment_promote
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `mars` 에 Deployment `web-stable`(4개, `nginx:1.27-alpine`)과 Service `web`(80)이 있고, 모든 요청이 stable 파드로 간다. `web-canary` 와 `/opt/course/b04/` 의 답안 파일은 아직 없다.
응답이 어느 버전인지는 HTTP 응답 헤더 `Server` 로 구분된다(`nginx/...` = stable, `Apache/...` = canary).

## Task

In namespace `mars`, Deployment `web-stable` (4 replicas, image `nginx:1.27-alpine`, container
`web`) serves traffic through Service `web` on port `80`. The team wants to try the new version,
image `httpd:2.4-alpine`, on about 20% of the traffic first.

1. Create Deployment `web-canary` in `mars` with 1 replica, container `web`, image
   `httpd:2.4-alpine`, and pod labels `app=web` and `track=canary`. Do not change the number of
   stable replicas.
2. Make Service `web` send traffic to both stable and canary pods, without exposing any pods other
   than those of the two Deployments.
3. From a temporary Pod using image `curlimages/curl:8.10.1`, send 50 requests to Service `web` and
   write the number of answers from each version to `/opt/course/b04/split.txt` in the form
   `stable=<n> canary=<n>`.
4. Promote the canary: update `web-stable` so that all 4 of its pods run `httpd:2.4-alpine`, and
   only after that rollout has completed, delete `web-canary`.
5. Service `web` must end up with 4 ready endpoints, all running `httpd:2.4-alpine`.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_ephemeral_volumes_memory_generic/question.md) · [q05 →](../q05_helm_upgrade_reuse_rollback/question.md)

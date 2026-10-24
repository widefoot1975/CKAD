# q04 — Canary release with replica ratios

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q04_canary_shared_service
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `danube` 에는 Deployment `shop-stable`(4 replicas, 응답 `stable`)과 Service `shop`(port 80)만 있고, EndpointSlice 에는 endpoint 가 4개다. `shop-canary` 는 아직 없다.

## Task

Namespace `danube` runs the stable version of the shop application as Deployment `shop-stable`
(4 replicas) behind Service `shop`. Release a canary version so that roughly one in five requests
reaches it.

1. Create a Deployment `shop-canary` in namespace `danube` with `1` replica. Base its Pod template
   on `shop-stable`, but use the label `track: canary` instead of `track: stable`, and make the
   container answer `canary` (argument `-text=canary`). The selector of `shop-canary` must not
   match the stable Pods.
2. Do not modify Service `shop` or Deployment `shop-stable`. Confirm that the EndpointSlice of
   Service `shop` now lists `5` ready endpoints, and write that number to
   `/opt/course/f04/endpoints.txt`.
3. From a temporary Pod using image `curlimages/curl:8.10.1`, send 20 requests to
   `http://shop.danube` and write the responses, one per line, to `/opt/course/f04/responses.txt`.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_pvc_local_path_persistence/question.md) · [q05 →](../q05_helm_upgrade_outdated_release/question.md)

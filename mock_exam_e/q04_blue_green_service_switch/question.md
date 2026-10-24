# q04 — Switch a Service from blue to green

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q04_blue_green_service_switch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `topaz` 에 Deployment `web-blue`(파드 라벨 `app=web,version=blue`, 응답 `blue`)와 `web-green`(`app=web,version=green`, 응답 `green`)이 각 2개씩 Ready 로 떠 있다.
Service `web`(ClusterIP, 80 → 5678)은 아직 blue 만 고른다. `/opt/course/e04/` 는 비어 있다.

## Task

Namespace `topaz` runs two versions of the same application side by side: Deployment `web-blue`
(version `blue`) and Deployment `web-green` (version `green`). Service `web` currently sends all
traffic to blue. Perform a blue/green switch.

1. Change Service `web` so that it selects only the pods with labels `app=web` and
   `version=green`. Do not modify either Deployment.
2. Confirm with the Service's EndpointSlice that its endpoints are now exactly the IPs of the
   `web-green` pods, and write those endpoint IPs, one per line, to `/opt/course/e04/endpoints.txt`.
3. From a temporary pod using image `curlimages/curl:8.10.1`, request `http://web` and write the
   response body to `/opt/course/e04/response.txt` (it must contain `green`).
4. Scale Deployment `web-blue` to `0` replicas so that only green keeps running.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_native_sidecar_log_tail/question.md) · [q05 →](../q05_helm_values_upgrade_rollback/question.md)

# q04 — Blue/green switch behind a Service

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q04_blue_green_service_switch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `gamma` 에는 Deployment `shop-blue`(3개, 응답 `blue`)와 Service `shop`(80 → 5678, blue 파드 선택), 테스트용 파드 `curl-a04` 가 있다. `shop-green` 은 없다.
`kubectl -n gamma exec curl-a04 -- curl -s http://shop` 으로 현재 응답(`blue`)을 볼 수 있다.

## Task

Namespace `gamma` serves version blue of the `shop` application through Service `shop`.
Release version green with a blue/green switch so that clients never see an outage.

1. Create Deployment `shop-green` in namespace `gamma` with `3` replicas, image
   `hashicorp/http-echo:1.0`, container args `-text=green`, container port `5678`, a TCP
   readiness probe on port `5678`, and Pod labels `app=shop` and `version=green`. Its selector
   must not match any Pod of `shop-blue`.
2. Only after all 3 green Pods are Ready, switch Service `shop` so that it sends traffic to the
   green Pods only. Do not delete or recreate the Service; its ClusterIP must stay the same.
3. Confirm with the EndpointSlice of Service `shop` that it contains exactly the 3 green Pod
   IPs. Then write the response of `curl -s http://shop` executed in Pod `curl-a04` to
   `/opt/course/a04/after.txt`.
4. Scale `shop-blue` to `0` replicas. Keep the Deployment so it can be used for a rollback.
5. Write to `/opt/course/a04/rollback.txt` the commands that would move traffic back to blue
   without an outage. Do not run them.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_init_native_sidecar_shared_volume/question.md) · [q05 →](../q05_helm_local_chart_upgrade_rollback/question.md)

# q15 — Expose a Deployment with a ClusterIP Service

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q15_clusterip_service_endpointslice
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `dove` 에 Deployment `dove-api`(replicas 2, 라벨 `app=dove-api`, 이미지 `hashicorp/http-echo:1.0`, 포트 `8080` 에서 `dove-api` 라는 글자를 응답)가 Ready 로 있다. Service 와 클라이언트 파드는 없고 `/opt/course/d15/` 는 비어 있다.

## Task

Other applications in namespace `dove` need a stable address for Deployment `dove-api`.

1. Create a Service named `dove-api` of type `ClusterIP` in namespace `dove` that selects the Pods
   of Deployment `dove-api` and forwards port `80` to container port `8080`.
2. Using the EndpointSlice API, confirm that the Service has two ready endpoints and write their
   Pod IP addresses (separated by spaces) to `/opt/course/d15/endpoints.txt`.
3. Create a Pod named `dove-client` (image `curlimages/curl:8.10.1`) in namespace `dove` that keeps
   running with `sleep 3600`. From it, request `http://dove-api` and write the response to
   `/opt/course/d15/response.txt`.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_securitycontext_busybox/question.md) · [q16 →](../q16_ingress_two_paths/question.md)

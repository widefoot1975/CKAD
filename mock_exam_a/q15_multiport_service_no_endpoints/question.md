# q15 — Repair a multi-port Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **엔드포인트가 비어 있는 Service** 에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q15_multiport_service_no_endpoints
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `omicron` 에는 Deployment `metrics-app`(podinfo, 2개)과 포트 두 개짜리 Service `metrics-app` 이 있다. 파드는 `Running` 이지만 READY `0/1` 이고, Service 의 EndpointSlice 에는 엔드포인트가 없다.
노드가 `ghcr.io` 와 Docker Hub 에서 이미지를 받을 수 있어야 한다.

## Task

Service `metrics-app` in namespace `omicron` should expose the HTTP API of Deployment
`metrics-app` on port `80` and its Prometheus metrics on port `9090`, but the Service has no
endpoints.

1. Find every cause and write each one in one line to `/opt/course/a15/causes.txt`.
2. Fix all causes. Do not change the Service's ports (names, port numbers and `targetPort`
   names) or the container ports of the Pods. You may change the Service selector and the
   Deployment's probes.
3. The readiness probe must still check `/readyz` on the HTTP container port, referring to that
   port by its **name**.
4. Confirm with the EndpointSlice of the Service that it lists 2 ready endpoints with both
   ports. Save that EndpointSlice output (`kubectl get endpointslice ...`) to
   `/opt/course/a15/endpointslice.txt`.
5. From a Pod with image `curlimages/curl:8.10.1` in namespace `omicron`, request
   `http://metrics-app/` and `http://metrics-app:9090/metrics` and write the two HTTP status
   codes to `/opt/course/a15/curl.txt` as `web=<code>` and `metrics=<code>` on separate lines.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_crd_schema_scale_subresource/question.md) · [q16 →](../q16_ingress_tls_two_paths_default_backend/question.md)

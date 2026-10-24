# q07 — Add liveness and readiness probes

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q07_liveness_readiness_probes
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `kestrel` 에 Deployment `kestrel-app`(replicas 2, 컨테이너 `app`, 이미지 `nginx:1.27-alpine`, 포트 80)이 Ready 로 있고, probe 는 하나도 없다.

## Task

Deployment `kestrel-app` in namespace `kestrel` has no health checks. Add them to container `app`
without changing anything else.

1. Add a readiness probe that sends an HTTP GET to path `/index.html` on port `80`, starting after
   `5` seconds and repeating every `10` seconds.
2. Add a liveness probe that sends an HTTP GET to path `/` on port `80`, starting after `15`
   seconds, repeating every `20` seconds, and restarting the container after `3` consecutive
   failures.
3. Make sure the rollout finishes and both Pods are ready with `0` restarts.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_kustomize_overlay/question.md) · [q08 →](../q08_top_pod_cpu/question.md)

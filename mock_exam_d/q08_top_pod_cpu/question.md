# q08 — Find the busiest Pod with kubectl top

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q08_top_pod_cpu
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `magpie` 에 파드 3개가 Running 이고, metrics-server 가 설치되어 `kubectl top` 이 동작한다(없으면 setup 이 설치한다, 첫 수집까지 1분쯤 걸릴 수 있다). `/opt/course/d08/` 는 비어 있다.
metrics-server 매니페스트를 받기 위해 `github.com` 으로 인터넷 연결이 되어야 한다.

## Task

Someone reports that a Pod in namespace `magpie` is using far more CPU than the others.

1. Write a single `kubectl` command that shows the Pods of namespace `magpie` sorted by CPU usage
   (highest first) to `/opt/course/d08/top.sh`.
2. Write only the name of the Pod in namespace `magpie` that currently uses the most CPU to
   `/opt/course/d08/pod.txt`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_liveness_readiness_probes/question.md) · [q09 →](../q09_logs_previous_container/question.md)

# q08 — Find why a pod is stuck in Pending

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q08_pending_pod_requests
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `jade` 의 파드 `report-gen` 은 `Pending` 이고, 스케줄러의 `FailedScheduling` 이벤트가 이미 기록되어 있다. 같은 내용의 매니페스트가 `/opt/course/e08/report-gen.yaml` 에 있다.
원인은 문제에서 직접 찾는다. 어떤 노드에도 CPU 100코어는 없다고 가정한다.

## Task

Pod `report-gen` in namespace `jade` never starts; it stays in `Pending`. Its manifest is at
`/opt/course/e08/report-gen.yaml`.

1. Using only built-in `kubectl` tools (`describe`, events), find out why the scheduler cannot
   place the pod, and write the scheduler's message for that reason (for example the part that
   starts with `0/<n> nodes are available`) to `/opt/course/e08/reason.txt`.
2. Fix the manifest so that the container requests `100m` CPU and `64Mi` memory (keep the image
   and command), then recreate the pod.
3. Confirm that `report-gen` is `Running`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_startup_liveness_probe/question.md) · [q09 →](../q09_fix_removed_api_versions/question.md)

# q08 — Triage several broken Pods from events

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **일부러 고장 낸 파드 세 개**에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q08_events_triage_broken_pods
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `elm` 의 Pod `catalog`, `payments`, `reports` 는 모두 `Running` 이 아니며, 각각 원인이 다르다. Warning 이벤트가 이미 쌓여 있다(setup 이 `reports` 가 한 번 이상 재시작할 때까지 기다린다).

## Task

Three Pods in namespace `elm` (`catalog`, `payments`, `reports`) are not running, each for a different
reason. Diagnose them from the cluster's own signals, record the evidence, then repair them.

1. Save all `Warning` events of namespace `elm`, ordered from oldest to newest, to
   `/opt/course/c08/events.txt`.
2. Before changing anything, write one line per Pod, sorted by Pod name, in the form
   `<pod> <reason>` to `/opt/course/c08/reasons.txt`, where `<reason>` is the current `waiting`
   reason of the Pod's container taken from the Pod status.
3. Repair the Pods:
   - `catalog` must run image `nginx:1.27-alpine`.
   - `payments` must start **without modifying the Pod**: create what it is missing, a Secret
     with the key `password` and the value `pay-c08`.
   - `reports` must run `sleep 3600` with its current image.
4. When all three Pods are `Running`, save the output of `kubectl -n elm get pods` to
   `/opt/course/c08/pods-after.txt`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_graceful_shutdown_prestop/question.md) · [q09 →](../q09_api_deprecation_hpa_v2/question.md)

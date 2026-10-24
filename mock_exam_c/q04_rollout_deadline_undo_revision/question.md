# q04 — Detect a stalled rollout and undo to a chosen revision

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q04_rollout_deadline_undo_revision
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `birch` 의 Deployment `shop`(replicas 3, 컨테이너 `web`)은 리비전 2개를 가진다. 리비전 1 은 `nginx:1.27-alpine`, 현재 리비전 2 는 `httpd:2.4-alpine` 이고 둘 다 change-cause 가 기록되어 있다.
`minReadySeconds` 와 `progressDeadlineSeconds` 는 기본값(0, 600)이다.

## Task

Deployment `shop` in namespace `birch` has two revisions. A new release must go out with tighter
rollout guards. The release is expected to fail and must be detected and reverted.

1. Configure `shop` so that a new Pod only counts as available after it has been ready for `10`
   seconds, and a rollout that makes no progress for `30` seconds is reported as failed.
2. Update container `web` to image `nginx:1.27-alpine-c04` (this tag does not exist) and record the
   change-cause `release c04`.
3. Wait until the Deployment reports the rollout as failed. Write the `reason` of its `Progressing`
   condition to `/opt/course/c04/condition.txt` and the revision number of this failed rollout to
   `/opt/course/c04/failed-revision.txt`.
4. Roll back to the revision that runs `nginx:1.27-alpine` (this is not simply the previous
   revision) and set the change-cause to `rollback to nginx 1.27`. All `3` replicas must be
   available with image `nginx:1.27-alpine`.
5. Save the output of `kubectl rollout history` for `shop` to `/opt/course/c04/history.txt`.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_native_sidecar_log_adapter/question.md) · [q05 →](../q05_helm_local_chart_list_values/question.md)

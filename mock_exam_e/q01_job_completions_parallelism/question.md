# q01 — Run a parallel Job and collect its logs

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q01_job_completions_parallelism
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ruby` 는 비어 있고(Job 없음) `/opt/course/e01/` 디렉터리만 만들어져 있다.
이미지 `busybox:1.36` 을 받을 수 있어야 한다.

## Task

A batch step must process six work items, two at a time, and the team wants every pod's output
kept in one file.

1. In namespace `ruby`, create a Job named `batch-counter` using image `busybox:1.36` that runs
   `sh -c 'echo "item done by $(hostname)"; sleep 5'`.
2. The Job must need `6` successful completions, run at most `2` pods at the same time, and give
   up after `3` retries (`backoffLimit`).
3. Wait until the Job is complete, then write the logs of **all** of the Job's pods to
   `/opt/course/e01/job.log` (one line per pod, six lines in total).

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_daemonset_log_agent/question.md)

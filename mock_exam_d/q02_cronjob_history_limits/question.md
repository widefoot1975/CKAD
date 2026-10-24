# q02 — Schedule a CronJob with history limits

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q02_cronjob_history_limits
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `falcon` 만 있고 CronJob·Job 은 하나도 없다. `/opt/course/d02/` 는 비어 있다.

## Task

The `falcon` team needs a small report task that runs on a fixed schedule in namespace `falcon`.

1. Create a CronJob named `falcon-report` in namespace `falcon` that runs every 5 minutes. Its
   container is named `report`, uses image `busybox:1.36` and runs
   `sh -c 'date; echo falcon report done'`.
2. The CronJob must keep at most `2` successful Jobs and at most `4` failed Jobs in its history,
   and its Pods must use `restartPolicy: OnFailure`.
3. Without waiting for the schedule, create a Job named `falcon-report-manual` from the CronJob,
   wait until it completes and write its logs to `/opt/course/d02/manual.log`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_podman_build_save_image/question.md) · [q03 →](../q03_init_container_emptydir/question.md)

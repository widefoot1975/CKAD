# q02 — CronJob with concurrency, deadlines and a manual run

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q02_cronjob_forbid_timezone_manual_run
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `alpha` 는 비어 있고(CronJob·Job 없음) `/opt/course/a02/` 는 빈 디렉터리다. CronJob 과 Job 은 문제에서 직접 만든다.

## Task

The reporting team needs a nightly report in namespace `alpha`. Runs must never overlap, and a
run that cannot start on time must be skipped instead of being started late.

1. Create a CronJob named `nightly-report` in namespace `alpha` with the schedule `30 2 * * *`,
   evaluated in the time zone `Asia/Seoul`.
2. Configure the CronJob so that:
   - a new run is skipped while the previous run is still active,
   - a run that cannot start within `120` seconds of its scheduled time is skipped,
   - only the last `2` successful Jobs and the last `1` failed Job are kept.
3. Each Job created by the CronJob must be terminated when it runs longer than `60` seconds and
   must not be retried after a failure. Its Pod uses `restartPolicy: Never` and has one container
   named `report` with image `busybox:1.36` that runs:
   `sh -c 'echo "report for $(date +%F)"; echo "rows=42"'`
4. Without waiting for the schedule, create a Job named `nightly-report-manual` in namespace
   `alpha` from this CronJob. Wait until it has completed and write its log output to
   `/opt/course/a02/manual.log`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_dockerfile_fix_build_oci_archive/question.md) · [q03 →](../q03_init_native_sidecar_shared_volume/question.md)

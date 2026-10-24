# q02 — Indexed Job with per-index retries and a pod failure policy

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q02_indexed_job_pod_failure_policy
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `mercury` 에 ConfigMap `shard-data`(`worker.sh` 와 `shard-0.txt` … `shard-4.txt`)만 있고 Job `shard-worker` 는 없다. `/opt/course/b02/` 는 비어 있다.
`worker.sh` 의 종료 코드 규칙은 `kubectl -n mercury get cm shard-data -o yaml` 로 직접 읽어 볼 수 있다.

## Task

Namespace `mercury` contains ConfigMap `shard-data` with a script `worker.sh` and one input file per
shard. The script picks its shard from the environment variable `JOB_COMPLETION_INDEX` and exits
with code `3` for a corrupt shard and code `42` when its input is missing (a configuration error).

1. Create a Job `shard-worker` in namespace `mercury` with a single container named `worker`,
   image `busybox:1.36`, command `sh /data/worker.sh`, and ConfigMap `shard-data` mounted at `/data`.
2. The Job must run 5 shards, numbered 0 to 4, so that each pod receives its shard number in
   `JOB_COMPLETION_INDEX`, with at most 2 pods running at the same time.
3. Each shard may be retried at most once, counted per shard and not for the Job as a whole.
4. Add a pod failure policy for container `worker`: exit code `42` fails the whole Job immediately,
   exit code `3` fails only that shard without retrying it, and exit code `143` is ignored (not
   counted as a failure).
5. When the Job has finished, write its completed and failed shard numbers, exactly as reported
   in the Job status, to `/opt/course/b02/indexes.txt` in the form
   `completed=<value> failed=<value>`, and write the type and reason of its terminal condition
   to `/opt/course/b02/condition.txt` in the form `<type> <reason>`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_multistage_dockerfile_nonroot/question.md) · [q03 →](../q03_ephemeral_volumes_memory_generic/question.md)

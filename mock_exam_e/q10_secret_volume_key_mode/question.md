# q10 — Mount one Secret key as a read-only file

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q10_secret_volume_key_mode
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `pearl` 에 Secret `db-creds`(키 `username`, `password`, `host`)가 있고 파드는 없다. `/opt/course/e10/` 는 비어 있다.

## Task

Namespace `pearl` contains Secret `db-creds` with the keys `username`, `password` and `host`.
A client pod must see only the password, as a file that only its owner can read.

1. Create a pod named `db-client` in namespace `pearl` with image `busybox:1.36` and command
   `sleep 3600`.
2. Mount Secret `db-creds` into the pod at `/etc/db` so that only key `password` appears, as the
   file `/etc/db/pass.txt`, with file mode `0400`. The mount must be read-only.
3. Write the output of `ls -lL /etc/db` run inside the pod to `/opt/course/e10/files.txt`.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_fix_removed_api_versions/question.md) · [q11 →](../q11_limitrange_defaults/question.md)

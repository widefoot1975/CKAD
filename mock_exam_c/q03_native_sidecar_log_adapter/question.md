# q03 — Log adapter as a native sidecar with a startup probe

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q03_native_sidecar_log_adapter
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `maple` 에 컨테이너 `app` 하나만 있는 Pod `legacy-app` 이 돌며 `/var/log/legacy/app.log` 에 `시각|레벨|메시지` 형식으로 2초마다 한 줄씩 쓴다. stdout 에는 아무것도 나오지 않는다.
같은 Pod 매니페스트가 `/opt/course/c03/legacy-app.yaml` 에 있다. 네이티브 사이드카(v1.33 GA)를 쓰므로 클러스터가 v1.33 이상이어야 한다.

## Task

Pod `legacy-app` in namespace `maple` writes its log only to `/var/log/legacy/app.log`, one line per
event in the format `<time>|<LEVEL>|<message>`. The log platform only collects container stdout, as
JSON.

1. Recreate Pod `legacy-app` (keep container `app` unchanged) with an adapter container named
   `adapter` that is a native sidecar: an entry under `initContainers` that keeps running for the
   whole life of the Pod. Use image `busybox:1.36` and mount the existing log volume at
   `/var/log/legacy`.
2. The adapter must print every line of `app.log`, starting from the first line of the file, to its
   stdout as `{"time":"<time>","level":"<LEVEL>","msg":"<message>"}`.
3. Give the adapter a `startupProbe` that runs `test -e /var/log/legacy/app.log` every `2` seconds.
   Container `app` must only start after this probe has succeeded.
4. Save the first `3` lines of the adapter's log to `/opt/course/c03/adapter.log`.
5. Write the start times of both containers to `/opt/course/c03/start-order.txt` in the form
   `adapter=<startedAt> app=<startedAt>`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_daemonset_toleration_job_ttl/question.md) · [q04 →](../q04_rollout_deadline_undo_revision/question.md)

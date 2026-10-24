# q03 — Init container and native sidecar sharing volumes

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q03_init_native_sidecar_shared_volume
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `beta` 는 비어 있고, 초안 매니페스트 `/opt/course/a03/log-pipeline.yaml` 만 있다. 파드 `log-pipeline` 은 아직 만들어지지 않았다.
네이티브 사이드카(`initContainers` 의 `restartPolicy: Always`)를 쓰므로 클러스터가 v1.29 이상이어야 한다.

## Task

A draft manifest for Pod `log-pipeline` in namespace `beta` is stored at
`/opt/course/a03/log-pipeline.yaml`. A Pod created from the draft never leaves the
initialization phase. Fix the file in place and create the Pod from it. Do not change any
`command`, image or volume name.

1. Init container `prepare` must run first and run to completion. Its output file
   `/work/app.conf` must be written into the emptyDir volume `config`.
2. Container `log-tailer` must be a **native sidecar**: it starts after `prepare` has completed,
   it is already running when container `app` starts, and it keeps running for the whole
   lifetime of the Pod.
3. `log-tailer` must follow the same file that container `app` appends to
   (`/var/log/app/app.log` in volume `logs`).
4. The Pod must be `Running` with `log-tailer` and `app` both running, and
   `kubectl -n beta logs log-pipeline -c log-tailer` must show lines that contain
   `mode=production`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_cronjob_forbid_timezone_manual_run/question.md) · [q04 →](../q04_blue_green_service_switch/question.md)

# q03 — Tail an application log with a native sidecar

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q03_native_sidecar_log_tail
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `emerald` 는 비어 있고, 파드 매니페스트 `/opt/course/e03/web-app.yaml` 만 있다(아직 적용하지 않았다).
이 매니페스트의 컨테이너 `app` 은 2초마다 emptyDir 볼륨의 `/var/log/app/app.log` 에 한 줄씩 쓴다. 네이티브 사이드카는 v1.33 GA 라 v1.37 클러스터에서 그대로 쓸 수 있다.

## Task

The application in `/opt/course/e03/web-app.yaml` writes its log only to a file, so
`kubectl logs` shows nothing useful. Add a log-shipping sidecar using the native sidecar feature.

1. Edit `/opt/course/e03/web-app.yaml`: add a sidecar container named `log-tailer` (image
   `busybox:1.36`) that runs `tail -F /var/log/app/app.log`. Define it as a native sidecar, i.e. as
   an init container that keeps running for the whole life of the pod.
2. Mount the existing `logs` volume into `log-tailer` at `/var/log/app`.
3. Create the pod `web-app` in namespace `emerald` from the file and confirm that both containers
   are ready, then write the last `5` lines of the `log-tailer` container's logs to
   `/opt/course/e03/sidecar.log`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_daemonset_log_agent/question.md) · [q04 →](../q04_blue_green_service_switch/question.md)

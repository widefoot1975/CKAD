# q07 — Add startup and liveness probes to a slow app

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q07_startup_liveness_probe
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `onyx` 에 probe 가 하나도 없는 파드 `slow-app` 이 떠 있고, 같은 내용의 매니페스트가 `/opt/course/e07/slow-app.yaml` 에 있다.
이 앱은 기동에 약 40초가 걸린다. 그 뒤에 `/tmp/started` 를 만들고 포트 `8080` 에서 `/healthz` 를 서비스한다. 그 전에는 둘 다 없다.

## Task

Pod `slow-app` in namespace `onyx` needs about 40 seconds to start and has no health checks.
Add probes so that Kubernetes waits for the start-up and afterwards restarts the container if it
stops answering. The manifest is at `/opt/course/e07/slow-app.yaml`.

1. Add a `startupProbe` to container `app` that runs the command `cat /tmp/started`, every
   `5` seconds, allowing up to `18` failures.
2. Add a `livenessProbe` that sends an HTTP GET to path `/healthz` on port `8080`, every `10`
   seconds, with a failure threshold of `3`.
3. Recreate pod `slow-app` from the updated manifest and confirm that it becomes `Ready` with
   `0` restarts.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_kustomize_configmap_patch/question.md) · [q08 →](../q08_pending_pod_requests/question.md)

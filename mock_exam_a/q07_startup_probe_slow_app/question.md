# q07 — Rescue a slow-starting app with a startupProbe

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **probe 설정이 잘못된 Deployment** 에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q07_startup_probe_slow_app
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `eta` 의 Deployment `ledger` 파드는 READY `0/1` 이고 RESTARTS 가 1 이상이다(재시작이 계속 늘어난다). setup 은 첫 재시작이 일어날 때까지 기다리므로 1~2분 걸린다.

## Task

Deployment `ledger` in namespace `eta` never becomes Ready and its Pod keeps restarting. The
application needs up to 60 seconds to start. Once started, it answers `GET /healthz` on port
`8080` with HTTP `200`.

1. Find out why the container keeps restarting and write the reason in one line to
   `/opt/course/a07/cause.txt`.
2. Add a startup probe (`httpGet` on `/healthz`, port `8080`, `periodSeconds: 5`) that gives the
   application at least `90` seconds to start.
3. Change the liveness probe so that it has no `initialDelaySeconds` and restarts the
   container only after `3` consecutive failures `10` seconds apart. Keep its `httpGet` on
   `/healthz`, port `8080`.
4. Fix the readiness probe so that the Pod can become Ready.
5. The rollout must complete, and the new Pod must be Ready (`1/1`) with `0` restarts.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_kustomize_prod_overlay_generator/question.md) · [q08 →](../q08_crashloop_configmap_key_command/question.md)

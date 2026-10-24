# q08 — Debug a CrashLoopBackOff Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **일부러 고장 낸 Deployment** 에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q08_crashloop_configmap_key_command
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `theta` 에는 ConfigMap `billing-config`, `billing-scripts` 와 Deployment `billing`(2개)이 있고, 두 파드 모두 `CrashLoopBackOff` 이며 RESTARTS 가 1 이상이다.

## Task

The Pods of Deployment `billing` in namespace `theta` are in `CrashLoopBackOff`. The
ConfigMaps `billing-config` and `billing-scripts` are correct and must not be changed.

1. Before changing anything, save the events of namespace `theta`, sorted by their last
   timestamp, to `/opt/course/a08/events.txt`.
2. Use `describe`, the logs of the previous container instance and the events to find **every**
   cause of the crash. Write each cause in one line to `/opt/course/a08/cause.txt`.
3. Fix the Deployment so that both replicas are `Running` and Ready and stop restarting. The log
   of each Pod must contain `connected to postgres://billing@db.theta.svc:5432/billing`.
4. The environment variable `DB_URL` must not be optional: if its ConfigMap key is missing, the
   container must not be started at all.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_startup_probe_slow_app/question.md) · [q09 →](../q09_migrate_removed_api_versions/question.md)

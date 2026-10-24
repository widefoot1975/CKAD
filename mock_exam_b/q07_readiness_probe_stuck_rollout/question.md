# q07 — Unblock a rollout gated by a readiness probe

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q07_readiness_probe_stuck_rollout
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `neptune` 에서 Deployment `catalog` 는 v1(ConfigMap `catalog-v1`)으로 3개가 Ready 이고, v2(ConfigMap `catalog-v2`)로 가는 롤아웃이 **멈춰 있다**(새 파드 1개가 `0/1`). Service `catalog`(80)는 아직 v1 을 응답한다.
`progressDeadlineSeconds` 가 120 이라 설정 후 2분쯤 지나면 `rollout status` 가 데드라인 초과를 보고한다. `/opt/course/b07/` 는 비어 있다.

## Task

In namespace `neptune`, a rollout of Deployment `catalog` from v1 (ConfigMap `catalog-v1`) to v2
(ConfigMap `catalog-v2`) was started but has not finished. Users report no outage.

1. Find out why the rollout does not progress. Write the exact readiness failure message from the
   events of the new pod to `/opt/course/b07/reason.txt` (one line, starting with
   `Readiness probe failed`).
2. Write the response body that Service `catalog` returns on path `/` right now to
   `/opt/course/b07/during.txt`, and in one line in `/opt/course/b07/why-no-outage.txt` name the
   rollout setting that keeps the old pods serving.
3. Fix the readiness probe of the new version so that it matches the health endpoint defined in
   ConfigMap `catalog-v2`. Do not roll back, and do not change the image, the ConfigMaps or the
   rollout strategy.
4. Let the rollout finish: all 3 pods must be ready and use ConfigMap `catalog-v2`, and Service
   `catalog` must answer `catalog v2` on path `/`.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_kustomize_patches_target_labels/question.md) · [q08 →](../q08_debug_distroless_ephemeral/question.md)

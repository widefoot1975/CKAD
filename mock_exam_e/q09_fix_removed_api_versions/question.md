# q09 — Repair manifests that use removed API versions

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q09_fix_removed_api_versions
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `amber` 는 비어 있고, 오래된 매니페스트 `/opt/course/e09/legacy.yaml`(Deployment `ledger`, CronJob `ledger-cleanup`)이 있다.
이 파일은 지금 그대로는 적용되지 않는다. 클러스터에는 `amber` 의 리소스가 아직 하나도 없다.

## Task

An old manifest `/opt/course/e09/legacy.yaml` was written for a much older Kubernetes release
and fails to apply on this v1.37 cluster.

1. Find the API group/version that this cluster serves for the kinds `Deployment` and `CronJob`
   and write them to `/opt/course/e09/apis.txt`, one per line in the form `<Kind> <apiVersion>`
   (for example `Pod v1`).
2. Fix `/opt/course/e09/legacy.yaml` in place so that it applies cleanly. Keep all names, labels,
   images, replica counts and the schedule unchanged, and add any field that the current API
   version requires.
3. Apply the file and confirm that Deployment `ledger` has `2` ready replicas and CronJob
   `ledger-cleanup` exists in namespace `amber`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_pending_pod_requests/question.md) · [q10 →](../q10_secret_volume_key_mode/question.md)

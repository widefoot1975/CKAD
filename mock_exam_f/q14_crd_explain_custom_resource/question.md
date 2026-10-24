# q14 — Explore a CRD and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q14_crd_explain_custom_resource
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에 API 그룹 `f14.example.com` 의 CRD 하나가 설치되어 있고(operator 는 없음), namespace `elbe` 에는 그 종류의 리소스가 없다. `/opt/course/f14/` 는 비어 있다.

## Task

A backup operator is being introduced. Its CustomResourceDefinition in API group `f14.example.com`
is already installed; the operator itself is not running yet, but the team wants the first backup
object to be ready.

1. Using `kubectl api-resources` and `kubectl explain`, find the kind of the resource in API group
   `f14.example.com` and the fields that are required in its `spec`. Write them to
   `/opt/course/f14/info.txt` as exactly two lines, listing the required fields in alphabetical
   order:

   ```
   kind=<Kind>
   required=<field>,<field>
   ```

2. Create a resource of that kind named `nightly` in namespace `elbe` that backs up the
   PersistentVolumeClaim `orders-db` every day at `02:00` (cron `0 2 * * *`) and keeps backups for
   `7` days. Find the field names with `kubectl explain`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_resourcequota_blocks_replicas/question.md) · [q15 →](../q15_service_selector_mismatch/question.md)

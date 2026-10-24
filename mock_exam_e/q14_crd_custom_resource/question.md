# q14 — Create a custom resource from an existing CRD

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q14_crd_custom_resource
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에 CRD `backups.e14.example.com`(그룹 `e14.example.com`, namespaced)이 등록되어 있고, namespace `coral` 은 비어 있다(Backup 리소스 없음).
CRD 의 kind, 버전, 필드는 문제에서 직접 찾는다. `/opt/course/e14/` 는 비어 있다.

## Task

A backup operator team has installed a CustomResourceDefinition in API group `e14.example.com`.
Use it to declare a backup for the `coral` namespace.

1. Find the kind, the served version and the fields of the custom resource defined in group
   `e14.example.com`.
2. In namespace `coral`, create a resource of that kind named `nightly-db` with
   `source: postgres-main`, `schedule: "0 2 * * *"` and `retentionDays: 7` in its `spec`.
3. Write the output of listing these resources in namespace `coral` (the default `kubectl get`
   table) to `/opt/course/e14/backups.txt`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_pod_security_restricted/question.md) · [q15 →](../q15_nodeport_targetport_fix/question.md)

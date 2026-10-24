# q14 — Custom resources and a stuck finalizer

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q14_crd_finalizer_terminating
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 CRD `backups.b14.example.com` 이 설치되어 있고, namespace `deimos` 에는 삭제가 끝나지 않는 `Backup` 리소스 `legacy-nightly` 하나가 있다. `/opt/course/b14/files-weekly.yaml` 에 적용이 거부되는 매니페스트가 있다.
이 CRD 를 처리하는 컨트롤러(오퍼레이터)는 클러스터에서 돌고 있지 않다.

## Task

A backup operator was installed with the CustomResourceDefinition `backups.b14.example.com`. Its
controller has since been removed, but the CRD must stay.

1. Create a `Backup` named `db-daily` in namespace `deimos` with `schedule` `0 2 * * *`, `target`
   `postgres` and `retentionDays` `7`.
2. Apply `/opt/course/b14/files-weekly.yaml`. It is rejected; fix the file so that it is accepted
   while keeping the intended schedule, target and a retention of 30 days, then apply it.
3. Using the short name of the resource, list the `Backup` resources in `deimos` and write the
   output, including the custom columns, to `/opt/course/b14/list.txt`.
4. `Backup` `legacy-nightly` in `deimos` was deleted some time ago but still exists. Write the
   value of its `metadata.finalizers` to `/opt/course/b14/finalizer.txt` and, in one line in
   `/opt/course/b14/why.txt`, explain why it does not disappear.
5. Make the deletion of `legacy-nightly` complete without deleting the CRD, the namespace or the
   other `Backup` resources.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_securitycontext_fsgroup_capabilities/question.md) · [q15 →](../q15_statefulset_headless_dns/question.md)

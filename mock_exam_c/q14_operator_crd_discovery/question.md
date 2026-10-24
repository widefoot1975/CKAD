# q14 — Discover an operator's CRDs and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q14_operator_crd_discovery
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 그룹 `c14.example.com` 의 CRD 3개(라벨 `app.kubernetes.io/part-of=c14-operator`)와, 다른 팀의 CRD 1개(`c14x.example.com`)가 있다. 커스텀 리소스는 `rowan` 과 `alder` 두 namespace 에 흩어져 있다.
컨트롤러(오퍼레이터 파드)는 설치하지 않는다. 이 문제는 API 객체만 다룬다.

## Task

An operator was installed into the cluster by another team. Its CRDs carry the label
`app.kubernetes.io/part-of=c14-operator`. Find out what it added and use its API.

1. Write the names of all CRDs that belong to this operator, sorted, one per line, to
   `/opt/course/c14/crds.txt`.
2. Count the `Backup` objects of group `c14.example.com` in all namespaces and write the number to
   `/opt/course/c14/backup-count.txt`. List them as `<namespace>/<name>`, one per line, in
   `/opt/course/c14/backups.txt`.
3. The `Backup` CRD serves more than one version. Write the version that is used for storage to
   `/opt/course/c14/storage-version.txt`.
4. Create a `Backup` named `inventory-nightly` in namespace `alder` using that storage version.
   Discover the field names with `kubectl explain`: it must back up the database `inventory`,
   keep backups for `14` days and run on the cron schedule `30 1 * * *`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_securitycontext_readonly_rootfs/question.md) · [q15 →](../q15_service_targetport_externalname/question.md)

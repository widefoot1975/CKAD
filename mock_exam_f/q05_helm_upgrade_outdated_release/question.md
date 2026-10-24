# q05 — Upgrade the outdated Helm release

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q05_helm_upgrade_outdated_release
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 차트 저장소 `podinfo` 가 추가되어 있고, 차트 `podinfo/podinfo` 로 설치한 릴리스 두 개(서로 다른 namespace, 서로 다른 고정 버전)가 각각 revision 1 로 돌고 있다. `/opt/course/f05/` 는 비어 있다.
차트와 이미지를 받아야 하므로 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 필요하다.

## Task

Two releases of the chart `podinfo/podinfo` (repository `podinfo` is already added) run in the
cluster. The platform team requires every release to use chart version `6.7.1`.

1. Using `helm list -A`, find the release whose chart version is older than `6.7.1`. Write its
   release name and namespace, separated by a single space, to `/opt/course/f05/outdated.txt`
   (for example `myrelease myns`).
2. Upgrade that release to chart `podinfo/podinfo` version `6.7.1`. The user-supplied value
   `replicaCount=2` of that release must be kept.
3. Write the output of `helm history` for that release to `/opt/course/f05/history.txt`. It must
   show 2 revisions, the latest one `deployed` with chart `podinfo-6.7.1`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_canary_shared_service/question.md) · [q06 →](../q06_rollout_pause_resume/question.md)

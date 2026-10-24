# q06 — Batch Deployment changes with rollout pause

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Deployment (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q06_rollout_pause_resume
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `seine` 에 Deployment `api`(3 replicas, 컨테이너 `web`, 이미지 `httpd:2.4-alpine`, 리소스 설정 없음)가 있고 rollout history 에는 revision 1 하나만 있다. 일시정지 상태가 아니다.

## Task

Deployment `api` in namespace `seine` (container `web`) must move to a new image and get resource
settings. Both changes must be rolled out together as a single new revision.

1. Pause the rollout of Deployment `api`.
2. While it is paused, change the image of container `web` to `nginx:1.27-alpine` and set its
   resources to requests `cpu=100m,memory=64Mi` and limits `cpu=200m,memory=128Mi`. Record the
   change cause `switch to nginx with resources` in the annotation `kubernetes.io/change-cause`.
3. Resume the rollout, wait until it has finished, and write the output of
   `kubectl -n seine rollout history deployment api` to `/opt/course/f06/history.txt`. It must
   show exactly one new revision (2 revisions in total) with that change cause.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_helm_upgrade_outdated_release/question.md) · [q07 →](../q07_readiness_probe_wrong_port/question.md)

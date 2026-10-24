# q04 — Rolling update and rollback of a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q04_rolling_update_rollback
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `heron` 에 Deployment `heron-api`(replicas 4, 컨테이너 `api`, 이미지 `nginx:1.27-alpine`, 기본 롤링 업데이트 전략)가 Ready 상태로 있고 rollout 리비전은 1개다. `/opt/course/d04/` 는 비어 있다.

## Task

Deployment `heron-api` in namespace `heron` must be updated without ever dropping below its
desired number of ready Pods.

1. Change the rolling update strategy of `heron-api` to `maxSurge: 1` and `maxUnavailable: 0`.
2. Using `kubectl set image`, change the image of container `api` to `httpd:2.4-alpine` and wait
   until the rollout has finished.
3. Write the output of `kubectl rollout history` for `heron-api` to
   `/opt/course/d04/history.txt`. It must list two revisions.
4. The new image turned out to be wrong. Roll `heron-api` back to the previous revision and make
   sure all 4 Pods run `nginx:1.27-alpine` again.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_init_container_emptydir/question.md) · [q05 →](../q05_helm_reinstall_namespace/question.md)

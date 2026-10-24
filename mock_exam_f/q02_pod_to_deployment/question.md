# q02 — Turn a standalone Pod into a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q02_pod_to_deployment
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `amazon` 에는 컨트롤러 없이 직접 만든 Pod `web` 하나만 Running 이다. Deployment 와 `/opt/course/f02/web-deploy.yaml` 은 아직 없다.

## Task

In namespace `amazon` the Pod `web` was started by hand. It has to be managed by a Deployment so
that it is recreated on failure and can be scaled.

1. Create a Deployment named `web` in namespace `amazon` with `3` replicas. Its Pod template must
   carry the same labels as Pod `web` and the same container definition (container name, image,
   port, environment variables and resources). Use these labels as the Deployment's selector.
2. Save the Deployment manifest you applied to `/opt/course/f02/web-deploy.yaml`.
3. Delete the original Pod `web` and make sure 3 Pods of the Deployment are `Ready`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_podman_rebuild_modified_image/question.md) · [q03 →](../q03_pvc_local_path_persistence/question.md)

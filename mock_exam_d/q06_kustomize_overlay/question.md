# q06 — Customize a Deployment with a Kustomize overlay

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Deployment (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q06_kustomize_overlay
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/d06/base/`(Deployment `web` 과 Service `web`, 이미지 `nginx:1.27`, replicas 1)와 `/opt/course/d06/overlays/prod/kustomization.yaml`(namespace `sparrow`, base 참조만 있음)이 있다. namespace `sparrow` 는 비어 있다.

## Task

The manifests in `/opt/course/d06/base/` must be deployed to namespace `sparrow` through the
overlay `/opt/course/d06/overlays/prod/`. Change only the overlay's `kustomization.yaml`; do not
edit any file in `base/`.

1. Make every resource name of the overlay start with the prefix `prod-`.
2. Change the tag of image `nginx` to `1.27-alpine` using the `images` field.
3. Set the replica count of the Deployment to `3` using the `replicas` field.
4. Apply the overlay with `kubectl apply -k` so that Deployment `prod-web` runs 3 ready Pods with
   image `nginx:1.27-alpine` in namespace `sparrow`.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_helm_reinstall_namespace/question.md) · [q07 →](../q07_liveness_readiness_probes/question.md)

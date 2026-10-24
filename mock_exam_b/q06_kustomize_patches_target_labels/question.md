# q06 — Kustomize patches with target selectors and labels

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Deployment (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q06_kustomize_patches_target_labels
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/b06/app/` 에 `kustomization.yaml`(deprecated 된 `commonLabels` 사용)과 Deployment 3개(`frontend`, `api`, `batch`)의 매니페스트가 있고, 이 kustomization 으로 namespace `saturn` 에 이미 배포되어 있다(모두 레플리카 1).
`api` 파드에는 native sidecar(`initContainers` 의 `restartPolicy: Always`) `log-agent` 가 있다. `rendered.yaml` 과 패치 파일은 아직 없다.

## Task

The Kustomize directory `/opt/course/b06/app` was used to deploy Deployments `frontend`, `api` and
`batch` to namespace `saturn`. Update the kustomization; do not edit `frontend.yaml`, `api.yaml` or
`batch.yaml`.

1. Replace the deprecated `commonLabels` field with the `labels` field. The Deployments are already
   running, so the rendered labels and selectors must stay exactly as they are today.
2. Add an entry to `patches` that uses a target selector to match every Deployment with the label
   `exposure=public` and, using an inline JSON6902 operation, sets `spec.replicas` to `3`. Do not
   name individual Deployments in this patch.
3. Create the strategic-merge patch file `/opt/course/b06/app/log-agent-limits.yaml`, reference it
   from `patches`, and use it to give the `log-agent` sidecar of Deployment `api` requests
   `cpu: 10m, memory: 16Mi` and limits `cpu: 50m, memory: 32Mi`.
4. Render the kustomization with `kubectl kustomize` into `/opt/course/b06/rendered.yaml`, then apply
   that file. Rendering must not print any deprecation warning.
5. In the end, `frontend` and `api` run 3 replicas, `batch` still runs 1, and every `api` pod has
   the `log-agent` sidecar with the resources above.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_helm_upgrade_reuse_rollback/question.md) · [q07 →](../q07_readiness_probe_stuck_rollout/question.md)

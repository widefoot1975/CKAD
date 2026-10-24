# q06 — Kustomize a ConfigMap generator and an env patch

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Deployment (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q06_kustomize_configmap_patch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `garnet` 은 비어 있고, `/opt/course/e06/` 에 `deployment.yaml`(Deployment `shop`, 컨테이너 `shop`)과 `kustomization.yaml`(resources 와 namespace 만 있음)이 있다.
아직 아무것도 적용하지 않았다. `kubectl` 에 내장된 kustomize(`-k`)만 쓴다.

## Task

The Kustomize directory `/opt/course/e06/` deploys Deployment `shop` into namespace `garnet`.
Extend it without editing `deployment.yaml`.

1. In `/opt/course/e06/kustomization.yaml`, add a `configMapGenerator` that creates a ConfigMap
   named `shop-config` with the literal `MODE=production`.
2. Create the strategic-merge patch file `/opt/course/e06/env-patch.yaml` that adds the
   environment variable `APP_MODE` to container `shop`, taking its value from key `MODE` of
   ConfigMap `shop-config`. Reference the patch with the `patches:` field.
3. Write the rendered output of the directory to `/opt/course/e06/rendered.yaml`, then apply the
   directory with `kubectl apply -k` and confirm that `APP_MODE=production` is set inside the
   running `shop` pod.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_helm_values_upgrade_rollback/question.md) · [q07 →](../q07_startup_liveness_probe/question.md)

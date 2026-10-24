# q05 — Render, upgrade and roll back a local Helm chart

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q05_helm_local_chart_upgrade_rollback
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/a05/chart/` 에 로컬 차트 `inventory` 가 있고, namespace `delta` 와 릴리스 `inventory` 는 없다. 차트 저장소는 쓰지 않는다.
`helm` 이 설치되어 있어야 하고, 노드가 `nginx:1.27-alpine` 이미지를 받을 수 있어야 한다.

## Task

A local Helm chart is stored at `/opt/course/a05/chart`. Deploy it to namespace `delta`, go
through a failed upgrade and recover.

1. Create the values file `/opt/course/a05/values-delta.yaml` that sets `replicaCount` to `2`
   and adds the Pod label `team: delta` through the chart value `podLabels`.
2. Without installing anything, render the chart with release name `inventory`, namespace
   `delta` and this values file into `/opt/course/a05/rendered.yaml`.
3. Install release `inventory` from the local chart into namespace `delta` (create the
   namespace) with this values file. Its Deployment must have 2 ready Pods.
4. Upgrade the release so that `image.tag` is `1.27-alpine-broken`, keeping every value from
   step 1. Write the waiting reason of the new Pod's container (as shown in its status) to
   `/opt/course/a05/upgrade-error.txt`.
5. Roll the release back to revision `1`. Write the output of `helm history` for the release to
   `/opt/course/a05/history.txt`. The Deployment must again run 2 ready Pods with image
   `nginx:1.27-alpine`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_blue_green_service_switch/question.md) · [q06 →](../q06_kustomize_prod_overlay_generator/question.md)

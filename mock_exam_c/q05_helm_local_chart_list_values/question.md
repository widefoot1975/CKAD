# q05 — Install a local Helm chart with list values and keep its history

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q05_helm_local_chart_list_values
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/c05/inventory/` 에 의존성 없는 로컬 차트 `inventory`(Deployment + Service)가 있다. namespace `cedar` 와 릴리스 `inventory` 는 아직 없다.
차트 저장소를 쓰지 않으므로 인터넷 연결 없이 풀 수 있다(이미지 `nginx:1.27-alpine` 만 받으면 된다). `helm` 이 필요하다.

## Task

The team packages its inventory service as a local chart in `/opt/course/c05/inventory/`. Install it,
capture what Helm rendered, then remove it while keeping the release record for auditing.

1. Install release `inventory` from the chart directory `/opt/course/c05/inventory` into namespace
   `cedar`, which does not exist yet and must be created by the same `helm` command. Using only
   `--set` (no values file), set `replicaCount` to `2` and set the list `env` to two items:
   `MODE=production` and `REGION=eu-west-1` (each item has the keys `name` and `value`).
2. Confirm that both Pods have the two environment variables. Save the output of
   `helm get values` for the release to `/opt/course/c05/values.txt` and the rendered manifests
   (`helm get manifest`) to `/opt/course/c05/manifest.yaml`.
3. Uninstall the release so that its history is kept. Save the output of
   `helm list -n cedar --uninstalled` to `/opt/course/c05/uninstalled.txt`.
4. Write the output of `kubectl get ns cedar -o name` to `/opt/course/c05/namespace.txt`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_rollout_deadline_undo_revision/question.md) · [q06 →](../q06_kustomize_secretgenerator_overlay/question.md)

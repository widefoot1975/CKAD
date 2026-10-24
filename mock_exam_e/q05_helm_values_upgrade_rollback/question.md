# q05 — Install, upgrade and roll back a Helm release

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q05_helm_values_upgrade_rollback
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `opal` 은 비어 있고 `podinfo` 저장소와 릴리스는 없다. `/opt/course/e05/values.yaml`(replicaCount 2, ui.message) 만 준비되어 있다.
차트를 받아야 하므로 `ckad-c1` 에서 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 되어야 한다.

## Task

The team deploys the `podinfo` demo with Helm and wants to practise a release's full life cycle.
A values file is ready at `/opt/course/e05/values.yaml`.

1. Add the chart repository `podinfo` at `https://stefanprodan.github.io/podinfo` and write the
   default values of chart `podinfo/podinfo` to `/opt/course/e05/default-values.yaml`.
2. Install release `podinfo` from chart `podinfo/podinfo` into namespace `opal` using the values
   file `/opt/course/e05/values.yaml`.
3. Upgrade the release so that it runs `3` replicas while keeping every other value from the
   values file.
4. Roll the release back to revision `1`, then write the output of `helm history` for the release
   to `/opt/course/e05/history.txt`. The Deployment must run `2` replicas again.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_blue_green_service_switch/question.md) · [q06 →](../q06_kustomize_configmap_patch/question.md)

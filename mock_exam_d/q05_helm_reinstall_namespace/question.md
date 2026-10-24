# q05 — Move a Helm release to the right namespace

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q05_helm_reinstall_namespace
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 podinfo 차트로 만든 릴리스 `podinfo` 가 **어느 한 네임스페이스**에 설치되어 있고, 로컬 Helm 저장소 목록에 `podinfo` 는 없으며 namespace `raven` 도 없다. `/opt/course/d05/` 는 비어 있다.
차트를 받아야 하므로 `ckad-c1` 에서 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 되어야 하고, `helm` 이 설치되어 있어야 한다.

## Task

A colleague installed the Helm release `podinfo` (chart `podinfo`) into the wrong namespace. It
belongs in namespace `raven`.

1. Add the chart repository `podinfo` with URL `https://stefanprodan.github.io/podinfo` and
   refresh the repository index.
2. List the Helm releases of all namespaces, find the namespace where release `podinfo` is
   currently installed and write only that namespace name to `/opt/course/d05/wrong-ns.txt`.
3. Uninstall release `podinfo` from that namespace.
4. Install release `podinfo` from chart `podinfo/podinfo` into namespace `raven` (create the
   namespace) with the value `replicaCount=2`. Both Pods must become ready.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_rolling_update_rollback/question.md) · [q06 →](../q06_kustomize_overlay/question.md)

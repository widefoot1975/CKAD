# q06 — Kustomize overlay with a generated Secret

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Deployment (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q06_kustomize_secretgenerator_overlay
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/c06/base/` 에 Deployment `api`(Secret `api-creds` 를 `envFrom` 으로 읽음)와 `kustomization.yaml` 이 있고, `/opt/course/c06/overlays/prod/` 에는 `db-password.txt` 만 있다.
namespace `willow` 는 비어 있다. `kubectl` 내장 kustomize(`-k`)를 쓴다.

## Task

The `api` application is deployed with Kustomize. The base is in `/opt/course/c06/base/`. Build the
production overlay in `/opt/course/c06/overlays/prod/`, without editing the base.

1. Create `/opt/course/c06/overlays/prod/kustomization.yaml` that uses `../../base` and:
   - puts all resources into namespace `willow`,
   - sets the replicas of Deployment `api` to `3`,
   - generates Secret `api-creds` with the literal `DB_USER=app` and the key `DB_PASSWORD` taken
     from the file `db-password.txt`,
   - adds the label `env=prod` to the metadata of all resources but not to selectors. Do not use
     the deprecated `commonLabels` field.
2. Before applying, save the output of `kubectl diff -k` for the overlay to
   `/opt/course/c06/diff-1.txt`.
3. Apply the overlay and wait for the rollout. Write the name of the Secret that was actually
   created to `/opt/course/c06/secret-1.txt`.
4. Change the literal to `DB_USER=app-v2` and apply again. Write the new Secret name to
   `/opt/course/c06/secret-2.txt`. The Deployment must roll out new Pods whose log shows
   `user=app-v2`.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_helm_local_chart_list_values/question.md) · [q07 →](../q07_graceful_shutdown_prestop/question.md)

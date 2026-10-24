# q09 — Migrate manifests off removed API versions

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q09_migrate_removed_api_versions
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `iota` 에는 Deployment `web` 과 Service `web`(80) 만 있고, 옛 API 버전으로 쓴 4개 문서짜리 매니페스트 `/opt/course/a09/legacy.yaml` 이 있다. Ingress·CronJob·PDB·HPA 는 아직 없다.
Ingress 는 객체만 만들면 되므로 Ingress 컨트롤러는 필요 없다.

## Task

The multi-document manifest `/opt/course/a09/legacy.yaml` was written for an old cluster.
`kubectl apply` fails with it on this cluster. Do not modify `legacy.yaml`.

1. Find out which API versions used in the file are no longer served by this cluster. Write one
   line per object to `/opt/course/a09/versions.txt` in the format
   `<Kind> <old apiVersion> -> <new apiVersion>`.
2. Create `/opt/course/a09/current.yaml` that contains all four objects converted to the
   current stable API versions, keeping their names, namespace and behaviour, including every
   field whose structure changed between the versions.
3. The Ingress rule for path `/` must use path type `Prefix`.
4. Apply `/opt/course/a09/current.yaml`. All four objects must exist in namespace `iota`, and
   `kubectl` must not print any deprecation warning.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_crashloop_configmap_key_command/question.md) · [q10 →](../q10_projected_volume_configmap_secret/question.md)

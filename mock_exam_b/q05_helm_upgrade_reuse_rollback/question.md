# q05 — Upgrade and roll back a Helm release without losing values

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Deployment (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q05_helm_upgrade_reuse_rollback
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `jupiter` 에 Helm 릴리스 `podinfo`(차트 `podinfo/podinfo` **6.7.0**, 리비전 2개)가 있고, 저장소 `podinfo` 가 helm 에 등록되어 있다. `/opt/course/b05/` 는 비어 있다.
차트와 이미지를 받으므로 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 필요하다. 저장소 등록 `podinfo` 는 다른 문제와 같이 쓰므로 정리할 때 지우지 않는다.

## Task

Helm release `podinfo` in namespace `jupiter` runs chart `podinfo/podinfo` version `6.7.0`. Over
time, operators set several values on it with `--set` and values files.

1. Write the values that users supplied for the current revision, as YAML, to
   `/opt/course/b05/user-values.yaml`, and the complete computed values (chart defaults merged with
   user values), as YAML, to `/opt/course/b05/all-values.yaml`.
2. Upgrade the release to chart version `6.7.1`. Every user-supplied value must be kept, and every
   value that users did not set must come from the defaults of chart `6.7.1`. Do not set any value
   explicitly during this upgrade.
3. Verify that the Deployment of the release now runs image `ghcr.io/stefanprodan/podinfo:6.7.1`
   and write the image to `/opt/course/b05/image.txt`.
4. Roll the release back to the revision in which it was first installed, then write the output of
   `helm history podinfo -n jupiter` to `/opt/course/b05/history.txt`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_canary_deployment_promote/question.md) · [q06 →](../q06_kustomize_patches_target_labels/question.md)

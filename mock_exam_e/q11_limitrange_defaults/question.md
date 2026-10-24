# q11 — Apply default resources with a LimitRange

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q11_limitrange_defaults
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `quartz` 는 비어 있다(LimitRange, ResourceQuota, 파드 모두 없음). `/opt/course/e11/` 는 비어 있다.

## Task

Developers in namespace `quartz` often forget to set resources. Give every new container sensible
defaults.

1. Create a LimitRange named `quartz-defaults` in namespace `quartz` for type `Container` with
   default requests `cpu: 100m`, `memory: 64Mi` and default limits `cpu: 250m`, `memory: 128Mi`.
2. Create a pod named `plain` in namespace `quartz` with image `nginx:1.27-alpine` and **no**
   `resources` section.
3. Write the `resources` of pod `plain`'s container, as stored by the API server, in JSON to
   `/opt/course/e11/resources.json`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_secret_volume_key_mode/question.md) · [q12 →](../q12_rbac_serviceaccount_pods/question.md)

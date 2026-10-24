# q12 — Let a ServiceAccount list pods

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q12_rbac_serviceaccount_pods
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `agate` 에 ServiceAccount `pod-watcher` 가 있고 Role 과 RoleBinding 은 없다. `/opt/course/e12/` 는 비어 있다.

## Task

A monitoring tool runs as ServiceAccount `pod-watcher` in namespace `agate` and must be able to
read pods there, and nothing more.

1. Create a Role named `pod-reader` in namespace `agate` that allows the verbs `get`, `list` and
   `watch` on `pods`.
2. Create a RoleBinding named `pod-reader-binding` in namespace `agate` that grants this Role to
   ServiceAccount `pod-watcher`.
3. Using `kubectl auth can-i` while impersonating the ServiceAccount, check these three
   questions and write the three answers (`yes`/`no`), one per line in this order, to
   `/opt/course/e12/can-i.txt`:
   list pods in `agate`; delete pods in `agate`; list pods in namespace `default`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_limitrange_defaults/question.md) · [q13 →](../q13_pod_security_restricted/question.md)

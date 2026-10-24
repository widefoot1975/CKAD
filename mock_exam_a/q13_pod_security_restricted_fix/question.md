# q13 — Make a Deployment pass Pod Security restricted

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q13_pod_security_restricted_fix
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `nu` 에는 Pod Security 라벨(`enforce=restricted`, `warn=restricted`)이 붙어 있고, Deployment `portal`(replicas 2)이 있지만 파드는 하나도 없다(READY `0/2`).

## Task

Namespace `nu` enforces the Pod Security Standard `restricted`. Deployment `portal` in this
namespace has no Pods. Do not change the labels of the namespace.

1. Find out why the Pods are rejected and write the full rejection message to
   `/opt/course/a13/violations.txt`.
2. The current image needs root, so change the container of Deployment `portal` to image
   `hashicorp/http-echo:1.0` with args `-text=portal` and `-listen=:8080` and container port
   `8080`.
3. Make the Pod template compliant with `restricted`: run as non-root with UID `10001`, use
   the `RuntimeDefault` seccomp profile, forbid privilege escalation and drop all
   capabilities. Put every setting at the level of the spec where Kubernetes allows it; set
   the Pod-wide settings in the Pod's `securityContext`.
4. Both replicas must be `Running` and Ready, and their log must show that the server listens
   on `:8080`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_quota_limitrange_guaranteed_qos/question.md) · [q14 →](../q14_crd_schema_scale_subresource/question.md)

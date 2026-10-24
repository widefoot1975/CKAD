# q12 — Fit a Deployment into a ResourceQuota and LimitRange

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q12_quota_limitrange_guaranteed_qos
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `mu` 에는 ResourceQuota `mu-quota`, LimitRange `mu-limits`, Deployment `worker`(replicas 4)가 있고, `worker` 의 파드는 하나도 없다(READY `0/4`).

## Task

Deployment `worker` in namespace `mu` should run `4` replicas, but no Pods are created. The
ResourceQuota and the LimitRange in `mu` are policy and must not be changed.

1. Find out why the Pods are not created and write the reason, as reported by the cluster, in
   one line to `/opt/course/a12/reason.txt`.
2. Change the container resources of Deployment `worker` so that all 4 replicas can run at the
   same time. Use the **largest** CPU and memory values that make this possible, and make the
   Pods get the QoS class `Guaranteed`.
3. Write the values you chose to `/opt/course/a12/resources.txt` in the form
   `cpu=<value> memory=<value>`.
4. All 4 Pods must be `Running`, and every Pod of `worker` must report QoS class `Guaranteed`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_serviceaccount_rbac_can_i/question.md) · [q13 →](../q13_pod_security_restricted_fix/question.md)

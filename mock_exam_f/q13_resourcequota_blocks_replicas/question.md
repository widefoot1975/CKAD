# q13 — ResourceQuota blocks Deployment replicas

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

이 문제는 **replica 가 다 뜨지 못한 Deployment** 에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q13_resourcequota_blocks_replicas
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `loire` 의 Deployment `worker` 는 READY `2/4` 이고 나머지 Pod 는 만들어지지 않는다. Pending Pod 도 없다.

## Task

Deployment `worker` in namespace `loire` should run `4` replicas, but only some of its Pods exist.

1. Find out what prevents the missing Pods from being created. Write the name of the blocking
   object and the name of the exhausted resource, separated by a single space, to
   `/opt/course/f13/blocker.txt` (for example `myobject requests.memory`).
2. Without changing the blocking object or the replica count, set the CPU request of container
   `worker` to the largest multiple of `50m` that lets all 4 replicas run. Leave the memory request
   unchanged.
3. Make sure Deployment `worker` shows `4/4` ready.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_container_capabilities/question.md) · [q14 →](../q14_crd_explain_custom_resource/question.md)

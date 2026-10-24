# q13 — Fit a Pod under a ResourceQuota

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q13_resourcequota_requests_limits
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `finch` 에 ResourceQuota `finch-quota` 와 이미 쿼터 일부를 쓰고 있는 Pod `finch-base` 가 있고, 매니페스트 `/opt/course/d13/finch-job.yaml`(resources 없음)이 있다. Pod `finch-job` 은 아직 없다.

## Task

Namespace `finch` is protected by ResourceQuota `finch-quota`. A new Pod must run there.

1. Try to create the Pod from `/opt/course/d13/finch-job.yaml` without changes and write the error
   message you get to `/opt/course/d13/error.txt`.
2. Edit `/opt/course/d13/finch-job.yaml` so that container `app` requests `250m` CPU and `100Mi`
   memory and is limited to `500m` CPU and `200Mi` memory. Create the Pod; it must be `Running`.
3. Write the amount of `requests.cpu` that the quota now reports as used to
   `/opt/course/d13/used-cpu.txt`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_serviceaccount_deployment/question.md) · [q14 →](../q14_securitycontext_busybox/question.md)

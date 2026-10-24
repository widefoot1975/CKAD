# q07 — Fix a readiness probe on the wrong port

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **일부러 고장 낸 Deployment** 에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q07_readiness_probe_wrong_port
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `volga` 의 Deployment `cache` Pod 2개는 `Running` 이지만 READY 가 `0/1` 이고, Service `cache` 의 EndpointSlice 에는 ready endpoint 가 없다. 이벤트에 readiness probe 실패가 쌓여 있다.

## Task

The Pods of Deployment `cache` in namespace `volga` are `Running` but never become `Ready`, so
Service `cache` has no ready endpoints.

1. Find out which port the readiness probe checks and write that port number to
   `/opt/course/f07/probe-port.txt`.
2. Fix the Deployment so that the readiness probe checks the port Redis actually listens on. Keep
   it a `tcpSocket` probe and do not change anything else.
3. Make sure the Deployment shows `2/2` ready and that the EndpointSlice of Service `cache` lists
   2 ready endpoints.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_rollout_pause_resume/question.md) · [q08 →](../q08_debug_shellless_container/question.md)

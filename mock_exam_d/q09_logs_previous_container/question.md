# q09 — Read the logs of a crashed container

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q09_logs_previous_container
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `wren` 에 Pod `wren-worker` 가 있고, 이미 한 번 이상 죽었다가 다시 시작된 상태다(RESTARTS 1 이상, 다시 시작한 인스턴스는 몇 초 동안 살아 있다가 또 죽는다). `/opt/course/d09/` 는 비어 있다.

## Task

Pod `wren-worker` in namespace `wren` keeps restarting. Collect evidence for the developers. Do not
delete or change the Pod.

1. From the container instance that terminated most recently (not the one that is currently
   starting), write the log line that contains `ERROR` to `/opt/course/d09/error.txt`.
2. Write the exit code of that terminated instance to `/opt/course/d09/exit-code.txt`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_top_pod_cpu/question.md) · [q10 →](../q10_configmap_file_env/question.md)

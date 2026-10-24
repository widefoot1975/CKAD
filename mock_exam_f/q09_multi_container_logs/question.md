# q09 — Read logs from a multi-container Pod

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q09_multi_container_logs
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `mekong` 에 컨테이너 두 개(`app`, `audit`)를 가진 Pod `shipper` 가 Running 이고, 두 컨테이너 모두 로그가 수십 초 분량 쌓여 있다. `/opt/course/f09/` 는 비어 있다.

## Task

Pod `shipper` in namespace `mekong` has two containers, `app` and `audit`, which both keep
writing to standard output.

1. Write the last `5` log lines of container `audit` to `/opt/course/f09/audit-last5.txt`.
2. Write only the log lines that container `app` produced during the last `20` seconds to
   `/opt/course/f09/app-recent.txt`.
3. Write the logs of all containers of the Pod to `/opt/course/f09/all.txt`, with every line
   prefixed by the Pod and container it came from.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_debug_shellless_container/question.md) · [q10 →](../q10_configmap_env_restart_immutable/question.md)

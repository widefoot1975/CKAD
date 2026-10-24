# q12 — Grant a single Linux capability

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q12_container_capabilities
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/f12/netadmin.yaml` 에 securityContext 가 없는 Pod 매니페스트가 있고, namespace `tigris` 에는 아직 Pod 가 없다.
namespace `tigris` 에는 Pod Security Admission 라벨이 없다(baseline 이상이 강제되면 `NET_ADMIN` 추가가 거부된다).

## Task

A network troubleshooting Pod must be allowed to change network settings, but nothing else that
needs extra privileges.

1. Edit `/opt/course/f12/netadmin.yaml` so that container `tool` drops all Linux capabilities, adds
   only `NET_ADMIN`, and does not allow privilege escalation. Then create the Pod from that file.
2. Inside the running container, run `grep Cap /proc/1/status` and write its output to
   `/opt/course/f12/caps.txt`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_serviceaccount_token_automount/question.md) · [q13 →](../q13_resourcequota_blocks_replicas/question.md)

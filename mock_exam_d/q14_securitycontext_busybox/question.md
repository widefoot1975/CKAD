# q14 — Harden a Pod with a securityContext

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q14_securitycontext_busybox
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `lark` 는 비어 있고, securityContext 가 없는 매니페스트 `/opt/course/d14/lark-secure.yaml`(Pod `lark-secure`, 컨테이너 `app` 이 10초마다 `/tmp/heartbeat.log` 에 기록)이 있다.

## Task

The Pod defined in `/opt/course/d14/lark-secure.yaml` must run with minimal privileges in
namespace `lark`. Edit the file and create the Pod from it.

1. At Pod level, run all containers as user ID `1000` and require that they do not run as root.
2. For container `app`, make the root filesystem read-only, disallow privilege escalation and drop
   all Linux capabilities.
3. The container still has to write to `/tmp`. Mount an `emptyDir` volume named `tmp` at `/tmp`.
   The Pod must be `Running`.
4. Write the output of `id -u` executed inside container `app` to `/opt/course/d14/uid.txt`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_resourcequota_requests_limits/question.md) · [q15 →](../q15_clusterip_service_endpointslice/question.md)

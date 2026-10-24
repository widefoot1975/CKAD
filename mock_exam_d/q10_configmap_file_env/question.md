# q10 — Configure a Pod from a ConfigMap

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q10_configmap_file_env
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `swallow` 는 비어 있고(ConfigMap·Pod 없음), 설정 파일 `/opt/course/d10/app.properties` 가 있다.

## Task

The application in namespace `swallow` reads a properties file and a log level from its
environment.

1. Create a ConfigMap named `swallow-config` in namespace `swallow` with two keys: key
   `app.properties` taken from the file `/opt/course/d10/app.properties`, and key `LOG_LEVEL` with
   the literal value `debug`.
2. Create a Pod named `swallow-app` (image `busybox:1.36`, command `sleep 3600`) that mounts the
   ConfigMap as a volume at `/etc/swallow`, so the file `/etc/swallow/app.properties` exists.
3. In the same Pod, set the environment variable `LOG_LEVEL` from key `LOG_LEVEL` of the
   ConfigMap.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_logs_previous_container/question.md) · [q11 →](../q11_secret_envfrom/question.md)

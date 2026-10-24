# q10 — Roll out a ConfigMap change and lock it

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q10_configmap_env_restart_immutable
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ganges` 에 ConfigMap `app-config`(`LOG_LEVEL=info`, `REGION=eu-west`)와 이를 `envFrom` 으로 읽는 Deployment `reporter`(2 replicas)가 있다. ConfigMap 은 아직 immutable 이 아니다.

## Task

Deployment `reporter` in namespace `ganges` reads its settings from ConfigMap `app-config` as
environment variables.

1. Change the value of key `LOG_LEVEL` in ConfigMap `app-config` to `debug`. Leave the other keys
   unchanged.
2. Make the Pods of Deployment `reporter` use the new value by using a `kubectl rollout` command
   (do not edit the Deployment manifest by hand). Write the value of `LOG_LEVEL` as seen inside
   one of the new Pods to `/opt/course/f10/log-level.txt`.
3. Make ConfigMap `app-config` immutable.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_multi_container_logs/question.md) · [q11 →](../q11_serviceaccount_token_automount/question.md)

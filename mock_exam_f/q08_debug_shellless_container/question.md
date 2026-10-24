# q08 — Debug a container that has no shell

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q08_debug_shellless_container
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `yukon` 의 Pod `ledger` 가 Ready 이고, 컨테이너 `app` 의 이미지에는 셸이 없어 `kubectl exec ... -- sh` 가 실패한다. Pod 에 ephemeral container 는 아직 없다.
build id 는 실행할 때마다 무작위로 정해지고, 컨테이너 `app` 의 파일 시스템에만 있다.

## Task

Pod `ledger` in namespace `yukon` runs container `app` from an image that contains no shell and no
tools, so `kubectl exec` cannot be used to look inside it. At start-up the Pod places a build
identifier in the file `/var/run/app/build-id` of container `app`.

1. Attach an ephemeral debug container that uses image `busybox:1.36` to Pod `ledger` and targets
   container `app`, so that it shares the process namespace of `app`. Do not restart, recreate or
   modify the Pod in any other way.
2. From the debug container, read the file `/var/run/app/build-id` as container `app` sees it and
   write its exact content to `/opt/course/f08/build-id.txt`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_readiness_probe_wrong_port/question.md) · [q09 →](../q09_multi_container_logs/question.md)

# q08 — Debug a container that has no shell

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q08_debug_distroless_ephemeral
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `pluto` 에 Pod `ledger`(컨테이너 `app`, 이미지 `hashicorp/http-echo:1.0`, 셸 없음)와 Service `ledger`(80 → 8080)가 있다. 파드는 `Running` 이지만 Service 로 접속하면 연결이 거부된다.
`ledger-copy` 파드와 `/opt/course/b08/` 의 답안 파일은 아직 없다. 디버그 이미지 `busybox:1.36` 을 받을 수 있어야 한다.

## Task

Pod `ledger` in namespace `pluto` is `Running`, but requests to Service `ledger` on port `80` are
refused. Its image has no shell, so `kubectl exec ... -- sh` does not work.

1. Add an ephemeral container named `dbg` with image `busybox:1.36` to Pod `ledger` that shares the
   process namespace of container `app`. Using it, write the full command line of the application
   process to `/opt/course/b08/cmdline.txt` and the list of listening TCP sockets to
   `/opt/course/b08/listen.txt`.
2. With `kubectl debug`, create a copy of the Pod named `ledger-copy` in which container `app` runs
   `/http-echo -listen=:8080 -text=ledger-ok` instead of its original command. The copy must not
   receive traffic from Service `ledger`.
3. Send a request to port `8080` of `ledger-copy`'s Pod IP from a temporary Pod using image
   `curlimages/curl:8.10.1` and write the response to `/opt/course/b08/copy-test.txt`.
4. In one line in `/opt/course/b08/cause.txt`, state why Service `ledger` could not reach the
   application.
5. Fix Pod `ledger` so that Service `ledger` answers `ledger-ok` on port `80`. Keep the Pod name,
   labels, image and container name. Then delete `ledger-copy`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_readiness_probe_stuck_rollout/question.md) · [q09 →](../q09_top_memory_oomkilled/question.md)

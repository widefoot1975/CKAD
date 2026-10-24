# q13 — Non-root Pod with fsGroup and minimal capabilities

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q13_securitycontext_fsgroup_capabilities
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `phobos` 는 비어 있고, Pod Security Admission 레이블 `pod-security.kubernetes.io/enforce=restricted` 가 붙어 있다. `/opt/course/b13/` 는 비어 있다.
`restricted` 를 만족하지 않는 Pod 는 생성 단계에서 거부된다. 거부 메시지가 무엇이 빠졌는지 알려 준다.

## Task

A small web server must run in namespace `phobos` without root privileges and still serve on port
`80`. Files it writes to its data volume must be group-owned by the shared group `2000`.

1. Create Pod `edge` in `phobos` with one container `web`, image `busybox:1.36`, and the command
   `sh -c 'echo hello-b13 > /data/index.html && exec httpd -f -p 80 -h /data'`. Mount an `emptyDir`
   volume named `data` at `/data`.
2. All processes in the Pod run as UID `1000` and primary GID `3000`, volumes are owned by group
   `2000`, and the Pod must refuse to start as root.
3. Container `web` drops all Linux capabilities and adds back only `NET_BIND_SERVICE`, and it may
   not gain more privileges than its parent process.
4. The Pod must be admitted by the namespace's existing Pod Security settings, which you may not
   change.
5. Write the output of `id` run in the container to `/opt/course/b13/id.txt`, the output of
   `ls -ln /data` to `/opt/course/b13/ls.txt`, and the `CapBnd` and `CapEff` lines of
   `/proc/1/status` to `/opt/course/b13/caps.txt`. Confirm that `http://127.0.0.1:80/` inside the
   container returns `hello-b13`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_validating_admission_policy/question.md) · [q14 →](../q14_crd_finalizer_terminating/question.md)

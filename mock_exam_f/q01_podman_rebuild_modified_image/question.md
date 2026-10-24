# q01 — Modify a Dockerfile and rebuild the image

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q01_podman_rebuild_modified_image
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/f01/build/` 에 `Dockerfile` 과 `greet.sh` 가 있고, 이미지 `localhost/f01-greeter:v1` 만 빌드되어 있다. `:v2` 이미지와 tar 파일은 없다.
`ckad-c1` 에 `podman`(없으면 `docker`)이 있어야 하고, `docker.io` 에서 `busybox:1.36` 을 받을 수 있어야 한다. 클러스터는 쓰지 않는다.

## Task

The image `localhost/f01-greeter:v1` was built from the build context in `/opt/course/f01/build`.
The next version must use a different default color and run in long mode.

1. Edit `/opt/course/f01/build/Dockerfile` so that the environment variable `APP_COLOR` is set to
   `green` and the default command runs `sh /app/greet.sh long`. Do not change `greet.sh`.
2. Build the image `localhost/f01-greeter:v2` from `/opt/course/f01/build` using `podman`.
3. Run the new image once without passing any command or environment variables and write its
   output to `/opt/course/f01/v2-output.txt`. It must contain `color=green` and `mode=long`.
4. Save the image `localhost/f01-greeter:v2` as an **OCI archive** to
   `/opt/course/f01/greeter-v2.tar`.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_pod_to_deployment/question.md)

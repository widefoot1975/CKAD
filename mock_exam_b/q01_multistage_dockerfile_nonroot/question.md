# q01 — Multi-stage build with a non-root image

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q01_multistage_dockerfile_nonroot
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/b01/app/` 에 Go 소스(`main.go`, `go.mod`)와 **단일 스테이지** `Dockerfile` 이 있고, 이미지 `b01-app:single`·`b01-app:multi` 와 답안 파일은 아직 없다.
`ckad-c1` 에 `podman`(또는 `docker`)이 있어야 하고, 베이스 이미지 `docker.io/library/golang:1.23-alpine` 을 받기 위해 Docker Hub 로 인터넷 연결이 되어야 한다. 클러스터 리소스는 쓰지 않는다.

## Task

A developer wrote a single-stage `Dockerfile` for a small Go program in `/opt/course/b01/app/`. The
resulting image is large and runs as root. Use `podman` (or `docker`) for all steps.

1. Build the current `Dockerfile` unchanged as image `b01-app:single`.
2. Rewrite `/opt/course/b01/app/Dockerfile` as a multi-stage build:
   - a build stage named `build` based on `docker.io/library/golang:1.23-alpine` that compiles a
     statically linked binary,
   - a final stage based on `scratch` that contains only the binary at `/hello`,
   - the final image runs as UID `65532` and GID `65532`,
   - the binary is the image `ENTRYPOINT`, and its default argument `-msg=from-b01` is supplied in
     a way that can be replaced on `podman run` without retyping the binary path.
3. Build the new `Dockerfile` as image `b01-app:multi`. Running `podman run --rm b01-app:multi`
   must print `from-b01 uid=65532 gid=65532`, and `podman run --rm b01-app:multi -msg=override`
   must print `override uid=65532 gid=65532`.
4. Write the sizes of both images to `/opt/course/b01/sizes.txt`, one line each, in the form
   `single <SIZE>` and `multi <SIZE>`, using the size shown by `podman images`.
5. Save image `b01-app:multi` in docker-archive format to `/opt/course/b01/b01-app-multi.tar`.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_indexed_job_pod_failure_policy/question.md)

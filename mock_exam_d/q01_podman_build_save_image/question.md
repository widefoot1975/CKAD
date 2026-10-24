# q01 — Build and save a container image with Podman

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q01_podman_build_save_image
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/d01/app/` 에 `Dockerfile` 과 `index.html` 이 있고, 이미지 `robin-web:v1`·tar 파일·컨테이너 `robin-test` 는 아직 없다.
`ckad-c1` 에 `podman`(또는 `docker`)이 있어야 하고, 베이스 이미지를 받기 위해 `docker.io` 로 인터넷 연결이 되어야 한다.

## Task

The `robin` team keeps the source of a small static web image in `/opt/course/d01/app/`.
Package it as an image file that can be handed over to another host.

1. Using `podman`, build an image from the Dockerfile in `/opt/course/d01/app/` and tag it
   `robin-web:v1`. Do not change the Dockerfile.
2. Save the image `robin-web:v1` in docker-archive format to `/opt/course/d01/robin-web-v1.tar`.
3. Run a container named `robin-test` from the image in the background, publishing host port
   `8081` to container port `80`. Write the response of `curl -s http://localhost:8081` to
   `/opt/course/d01/curl.txt`, then remove the container `robin-test`.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_cronjob_history_limits/question.md)

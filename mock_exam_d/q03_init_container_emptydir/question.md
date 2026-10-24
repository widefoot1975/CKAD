# q03 — Prepare web content with an init container

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q03_init_container_emptydir
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `eagle` 만 있고 Pod `eagle-web` 은 없다. `/opt/course/d03/` 는 비어 있다.

## Task

In namespace `eagle`, the web page must be generated before the web server starts.

1. Create a Pod named `eagle-web` in namespace `eagle` with an `emptyDir` volume named `html`.
2. Add an init container named `prepare` (image `busybox:1.36`) that mounts `html` at `/work` and
   writes the text `<h1>eagle ready</h1>` to `/work/index.html`.
3. Add a container named `web` (image `nginx:1.27-alpine`) that mounts `html` at
   `/usr/share/nginx/html`.
4. When the Pod is `Running`, write the response of `http://localhost/` as seen from inside
   container `web` to `/opt/course/d03/response.txt`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_cronjob_history_limits/question.md) · [q04 →](../q04_rolling_update_rollback/question.md)

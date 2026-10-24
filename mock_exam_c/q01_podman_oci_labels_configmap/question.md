# q01 — Build a labelled image and reuse its config in a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q01_podman_oci_labels_configmap
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/c01/build/` 에 `Dockerfile`(LABEL 없음)과 `default.conf`(8080 에서 응답하는 nginx 설정)가 있고, 이미지 `localhost/c01-web`, 컨테이너 `c01-web`, namespace `oak` 의 ConfigMap·Pod 는 아직 없다.
호스트에 `podman`(또는 `docker`)이 있어야 하고, `docker.io` 에서 `nginx:1.27-alpine` 을 받을 수 있어야 한다.

## Task

The team ships a small nginx front page. Its build context is `/opt/course/c01/build/`. The image
must carry OCI metadata, and the cluster must serve the same nginx configuration without using the
custom image, which is not in any registry the cluster can pull from.

1. Edit the `Dockerfile` so the image has the labels `org.opencontainers.image.title=c01-web`,
   `org.opencontainers.image.version=1.0.0` and `org.opencontainers.image.vendor=c01-team`. Do not
   add a `HEALTHCHECK`. Build the image as `localhost/c01-web:1.0.0`.
2. Run a detached container named `c01-web` from that image, publishing host port `18080` to
   container port `8080`. Save the response body of `curl -s http://localhost:18080/` to
   `/opt/course/c01/curl.txt`.
3. Using `podman image inspect --format`, write only the value of the label
   `org.opencontainers.image.version` to `/opt/course/c01/version.txt`, and all labels of the image
   as JSON to `/opt/course/c01/labels.json`.
4. Stop and remove the container, then save the image as an **OCI archive** to
   `/opt/course/c01/c01-web-oci.tar`.
5. In namespace `oak`, create ConfigMap `web-conf` from the file
   `/opt/course/c01/build/default.conf` (key `default.conf`) and Pod `web` with image
   `nginx:1.27-alpine` that mounts this ConfigMap so nginx in the Pod returns the same response on
   port `8080` as the local container did.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_daemonset_toleration_job_ttl/question.md)

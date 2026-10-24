# q01 — Build and save a container image with Podman · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The `robin` team keeps the source of a small static web image in `/opt/course/d01/app/`.
> Package it as an image file that can be handed over to another host.
>
> 1. Using `podman`, build an image from the Dockerfile in `/opt/course/d01/app/` and tag it
>    `robin-web:v1`. Do not change the Dockerfile.
> 2. Save the image `robin-web:v1` in docker-archive format to `/opt/course/d01/robin-web-v1.tar`.
> 3. Run a container named `robin-test` from the image in the background, publishing host port
>    `8081` to container port `80`. Write the response of `curl -s http://localhost:8081` to
>    `/opt/course/d01/curl.txt`, then remove the container `robin-test`.

**해석**

`robin` 팀은 작은 정적 웹 이미지의 소스를 `/opt/course/d01/app/` 에 두고 있다. 다른 호스트로 넘길 수
있는 이미지 파일로 묶는다.

1. `podman` 으로 `/opt/course/d01/app/` 의 Dockerfile 을 빌드하고 태그를 `robin-web:v1` 로 붙인다.
   Dockerfile 은 고치지 않는다.
2. 이미지 `robin-web:v1` 을 docker-archive 형식으로 `/opt/course/d01/robin-web-v1.tar` 에 저장한다.
3. 이 이미지로 컨테이너 `robin-test` 를 백그라운드로 띄우고 호스트 포트 `8081` 을 컨테이너 포트 `80` 에
   연결한다. `curl -s http://localhost:8081` 의 응답을 `/opt/course/d01/curl.txt` 에 적은 뒤 컨테이너
   `robin-test` 를 삭제한다.

## 모범 풀이

**1) 빌드**

```bash
cat /opt/course/d01/app/Dockerfile        # FROM docker.io/library/nginx:1.27-alpine ... COPY index.html ...
podman build -t robin-web:v1 /opt/course/d01/app
podman images robin-web
# REPOSITORY           TAG   IMAGE ID      CREATED        SIZE
# localhost/robin-web  v1    3f2a...       5 seconds ago  48 MB
```

마지막 인자는 Dockerfile 경로가 아니라 **빌드 컨텍스트 디렉터리**입니다. `COPY index.html` 은 이 디렉터리
기준으로 파일을 찾습니다. Dockerfile 이 다른 이름이면 `-f` 로 지정합니다. podman 은 레지스트리 없이
붙인 이름 앞에 `localhost/` 를 붙여 보여 주지만 `robin-web:v1` 으로 그대로 참조할 수 있습니다.
(docker: `docker build -t robin-web:v1 /opt/course/d01/app`)

**2) tar 로 저장**

```bash
podman save -o /opt/course/d01/robin-web-v1.tar robin-web:v1
# docker: docker save -o /opt/course/d01/robin-web-v1.tar robin-web:v1
```

podman 의 기본 `--format` 이 `docker-archive` 라서 따로 줄 필요가 없습니다. OCI 형식이 필요하면
`--format oci-archive` 를 줍니다. 받는 쪽은 `podman load -i robin-web-v1.tar` 로 불러옵니다.

**3) 컨테이너로 확인하고 지우기**

```bash
podman run -d --name robin-test -p 8081:80 robin-web:v1
curl -s http://localhost:8081 > /opt/course/d01/curl.txt
cat /opt/course/d01/curl.txt              # <h1>robin-web v1</h1>
podman rm -f robin-test
```

`-p 호스트:컨테이너` 순서입니다. `rm -f` 는 실행 중인 컨테이너를 멈추고 지웁니다(`stop` 후 `rm` 과 같음).
이미지는 남아 있어야 하므로 `rmi` 는 하지 않습니다.

## 검증

```bash
podman images --format '{{.Repository}}:{{.Tag}}' | grep robin-web    # localhost/robin-web:v1
ls -l /opt/course/d01/robin-web-v1.tar                                 # 수십 MB
tar -tf /opt/course/d01/robin-web-v1.tar | grep manifest.json          # manifest.json → docker-archive
tar -xOf /opt/course/d01/robin-web-v1.tar manifest.json                # "RepoTags":["localhost/robin-web:v1"]
cat /opt/course/d01/curl.txt                                           # <h1>robin-web v1</h1>
podman ps -a --filter name=robin-test                                  # 아무것도 없어야 한다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `podman build -t 이름:태그 <컨텍스트>` → `podman save -o 파일.tar 이름:태그` → `podman load -i 파일.tar`.
- **헷갈리는 지점**: `save`/`load` 는 이미지(레이어+태그), `export`/`import` 는 컨테이너 파일시스템이라 태그와 히스토리가 사라집니다. `-o` 를 빼면 tar 가 표준출력으로 쏟아집니다. Dockerfile 의 `FROM` 에 레지스트리를 빼면 podman 은 short-name 해석 때문에 프롬프트를 띄우거나 실패할 수 있어 `docker.io/library/...` 처럼 전체 이름을 쓰는 편이 안전합니다.

## 참고 문서

시험 중에는 podman/docker 문서를 열 수 없으므로 `podman build --help`, `podman save --help` 로 확인합니다.

- 검색어: `images`, `container images`
- https://kubernetes.io/docs/concepts/containers/images/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q02 →](../q02_cronjob_history_limits/question.md)

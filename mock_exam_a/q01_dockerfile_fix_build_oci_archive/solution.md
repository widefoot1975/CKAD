# q01 — Fix a Dockerfile, build and save an OCI image · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The `orders-api` image no longer builds. Its build context is `/opt/course/a01/build/`, which
> contains a `Dockerfile` and the application file `src/app.py`. The application listens on port
> `8080` and answers every request with one line that shows its version and the UID it runs as.
>
> 1. Fix `/opt/course/a01/build/Dockerfile` so that the image builds, copies `src/app.py` to
>    `/app/app.py`, declares port `8080` with `EXPOSE`, and runs the application as the non-root
>    user with UID `10001`. The value passed with the build argument `APP_VERSION` must end up in
>    the environment variable `APP_VERSION` of the running container.
> 2. Build the image with `--build-arg APP_VERSION=2.1.0` and give it both tags
>    `localhost/orders-api:2.1.0` and `localhost/orders-api:stable`.
> 3. Save the image `localhost/orders-api:2.1.0` as an **OCI archive** to
>    `/opt/course/a01/orders-api-2.1.0.tar`.
> 4. Run a detached container named `orders-api-a01` from `localhost/orders-api:stable` that
>    publishes host port `18080` to container port `8080`. Write the response of
>    `curl -s http://localhost:18080/` to `/opt/course/a01/output.txt` and leave the container
>    running.
>
> Use `podman` (or `docker` if `podman` is not installed).

**해석**

`orders-api` 이미지가 더 이상 빌드되지 않는다. 빌드 컨텍스트는 `/opt/course/a01/build/` 이고 그 안에
`Dockerfile` 과 애플리케이션 파일 `src/app.py` 가 있다. 애플리케이션은 포트 `8080` 에서 대기하며, 모든
요청에 자신의 버전과 실행 UID 를 보여 주는 한 줄로 응답한다.

1. `/opt/course/a01/build/Dockerfile` 을 고쳐 이미지가 빌드되고, `src/app.py` 를 `/app/app.py` 로 복사하고,
   `EXPOSE` 로 포트 `8080` 을 선언하고, UID `10001` 인 비 root 사용자로 애플리케이션을 실행하게 한다.
   빌드 인자 `APP_VERSION` 으로 넘긴 값이 실행 중인 컨테이너의 환경 변수 `APP_VERSION` 에 들어가야 한다.
2. `--build-arg APP_VERSION=2.1.0` 으로 이미지를 빌드하고 `localhost/orders-api:2.1.0` 과
   `localhost/orders-api:stable` 두 태그를 모두 붙인다.
3. 이미지 `localhost/orders-api:2.1.0` 을 **OCI 아카이브**로 `/opt/course/a01/orders-api-2.1.0.tar` 에 저장한다.
4. `localhost/orders-api:stable` 로 이름이 `orders-api-a01` 인 컨테이너를 백그라운드로 실행하고, 호스트 포트
   `18080` 을 컨테이너 포트 `8080` 에 연결한다. `curl -s http://localhost:18080/` 의 응답을
   `/opt/course/a01/output.txt` 에 쓰고 컨테이너는 계속 실행해 둔다.

`podman` 을 쓴다(`podman` 이 없으면 `docker`).

## 모범 풀이

**1) Dockerfile 고치기 — 고장은 네 군데입니다**

```bash
cd /opt/course/a01/build
cat Dockerfile
# ARG APP_VERSION=dev
# FROM python:3.12-alpine
# ENV APP_VERSION=${APP_VERSION}
# WORKDIR /app
# COPY app.py /app/app.py
# CMD ["python", "/app/app.py"]
ls -R .            # ./Dockerfile, ./src/app.py  ← app.py 는 src/ 안에 있다
```

고친 결과:

```dockerfile
FROM python:3.12-alpine
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
WORKDIR /app
COPY src/app.py /app/app.py
EXPOSE 8080
USER 10001
CMD ["python", "/app/app.py"]
```

| 고장 | 증상 | 수정 |
|---|---|---|
| `COPY app.py` | 빌드 실패: 컨텍스트 루트에 `app.py` 가 없다 | `COPY src/app.py /app/app.py` (경로는 **빌드 컨텍스트 기준**) |
| `ARG` 가 `FROM` 앞 | 빌드는 되지만 버전이 빈 문자열 | `ARG` 를 `FROM` **뒤**로 옮긴다 |
| `EXPOSE` 없음 | 동작은 하지만 요구사항 위반, `inspect` 에 포트가 없다 | `EXPOSE 8080` |
| `USER` 없음 | root(UID 0)로 실행 | `USER 10001` |

가장 놓치기 쉬운 것이 **`ARG` 의 범위**입니다. `FROM` 앞에 선언한 `ARG` 는 `FROM` 줄에서만 쓸 수 있고, 빌드
스테이지 안으로 들어오지 않습니다. 그래서 `ENV APP_VERSION=${APP_VERSION}` 이 빈 값이 되고, 빌드는 성공하는데
응답이 `orders-api  uid=0` 처럼 나옵니다. 스테이지 안에서 쓰려면 `FROM` 뒤에서 (다시) `ARG` 를 선언합니다.
`USER` 는 `/etc/passwd` 에 없는 숫자 UID 여도 됩니다. 쿠버네티스에서 `runAsNonRoot: true` 를 검증하려면 이름이
아니라 **숫자 UID** 여야 한다는 점도 같이 기억합니다(q13).

**2) 빌드와 태그 두 개**

```bash
podman build --build-arg APP_VERSION=2.1.0 \
  -t localhost/orders-api:2.1.0 -t localhost/orders-api:stable /opt/course/a01/build
podman images localhost/orders-api
# REPOSITORY            TAG     IMAGE ID      ...
# localhost/orders-api  2.1.0   3f1c...
# localhost/orders-api  stable  3f1c...      ← 같은 IMAGE ID
```

`-t` 는 여러 번 줄 수 있습니다. 빌드 후에 붙여도 됩니다: `podman tag localhost/orders-api:2.1.0 localhost/orders-api:stable`.
docker 도 같은 명령입니다(`docker build ... -t ... -t ...`).

**3) OCI 아카이브로 저장**

```bash
podman save --format oci-archive -o /opt/course/a01/orders-api-2.1.0.tar localhost/orders-api:2.1.0
tar -tf /opt/course/a01/orders-api-2.1.0.tar | head
# blobs/
# blobs/sha256/...
# index.json
# oci-layout          ← OCI 레이아웃이라는 표시
```

`podman save` 의 기본 형식은 `docker-archive` 입니다(`manifest.json`, `repositories`). 문제에서 OCI 를
요구했으므로 `--format oci-archive` 를 꼭 붙입니다. docker 는 형식 옵션이 없고, Docker 25 이상의 `docker save`
는 OCI 레이아웃(`index.json`, `oci-layout`)과 docker 호환 `manifest.json` 을 함께 담은 tar 를 만듭니다.

**4) 실행과 출력 저장**

```bash
podman run -d --name orders-api-a01 -p 18080:8080 localhost/orders-api:stable
curl -s http://localhost:18080/ > /opt/course/a01/output.txt
cat /opt/course/a01/output.txt
# orders-api 2.1.0 uid=10001
```

`-p 호스트:컨테이너` 순서입니다. 컨테이너가 막 떴을 때 curl 이 연결 거부되면 1초 뒤에 다시 시도합니다.

## 검증

```bash
podman image inspect localhost/orders-api:stable --format '{{.Config.User}} {{.Config.ExposedPorts}}'
# 10001 map[8080/tcp:{}]
podman image inspect localhost/orders-api:stable --format '{{.Config.Env}}'   # ... APP_VERSION=2.1.0 ...
podman images localhost/orders-api        # 두 태그, 같은 IMAGE ID
tar -tf /opt/course/a01/orders-api-2.1.0.tar | grep -E '^(oci-layout|index.json)$'
# index.json
# oci-layout
podman ps --filter name=orders-api-a01    # STATUS Up, PORTS 0.0.0.0:18080->8080/tcp
cat /opt/course/a01/output.txt            # orders-api 2.1.0 uid=10001
podman logs orders-api-a01                # 시작 줄도 같은 내용
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `FROM` 앞의 `ARG` 는 스테이지 안에서 보이지 않는다. 스테이지에서 쓸 `ARG` 는 `FROM` 뒤에 선언한다.
- **헷갈리는 지점**: `COPY` 의 원본 경로는 Dockerfile 위치가 아니라 **빌드 컨텍스트**(마지막 인자) 기준입니다. `podman save` 는 기본이 docker-archive 라 `--format oci-archive` 를 빼면 OCI 가 아닙니다. `EXPOSE` 는 문서화일 뿐 포트를 열지 않으므로, 호스트에서 접속하려면 여전히 `-p` 가 필요합니다.

## 참고 문서

시험 중에는 Dockerfile 레퍼런스(docs.docker.com)를 열 수 없으므로 `podman build --help`, `podman save --help` 를 씁니다.

- 검색어: `container images`, `security context`
- https://kubernetes.io/docs/concepts/containers/images/
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q02 →](../q02_cronjob_forbid_timezone_manual_run/question.md)

# q01 — Modify a Dockerfile and rebuild the image · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The image `localhost/f01-greeter:v1` was built from the build context in `/opt/course/f01/build`.
> The next version must use a different default color and run in long mode.
>
> 1. Edit `/opt/course/f01/build/Dockerfile` so that the environment variable `APP_COLOR` is set to
>    `green` and the default command runs `sh /app/greet.sh long`. Do not change `greet.sh`.
> 2. Build the image `localhost/f01-greeter:v2` from `/opt/course/f01/build` using `podman`.
> 3. Run the new image once without passing any command or environment variables and write its
>    output to `/opt/course/f01/v2-output.txt`. It must contain `color=green` and `mode=long`.
> 4. Save the image `localhost/f01-greeter:v2` as an **OCI archive** to
>    `/opt/course/f01/greeter-v2.tar`.

**해석**

이미지 `localhost/f01-greeter:v1` 은 `/opt/course/f01/build` 의 빌드 컨텍스트로 만들어졌다. 다음 버전은
기본 색을 바꾸고 long 모드로 실행되어야 한다.

1. `/opt/course/f01/build/Dockerfile` 을 고쳐 환경 변수 `APP_COLOR` 를 `green` 으로 하고, 기본 명령이
   `sh /app/greet.sh long` 을 실행하게 한다. `greet.sh` 는 바꾸지 않는다.
2. `podman` 으로 `/opt/course/f01/build` 에서 이미지 `localhost/f01-greeter:v2` 를 빌드한다.
3. 명령이나 환경 변수를 넘기지 않고 새 이미지를 한 번 실행해, 출력을 `/opt/course/f01/v2-output.txt` 에
   적는다. 출력에 `color=green` 과 `mode=long` 이 있어야 한다.
4. 이미지 `localhost/f01-greeter:v2` 를 **OCI 아카이브**로 `/opt/course/f01/greeter-v2.tar` 에 저장한다.

## 모범 풀이

**1) Dockerfile 수정**

```bash
cd /opt/course/f01/build
cat Dockerfile
# FROM docker.io/library/busybox:1.36
# ENV APP_COLOR=blue
# WORKDIR /app
# COPY greet.sh /app/greet.sh
# CMD ["sh", "/app/greet.sh", "short"]

sed -i 's/^ENV APP_COLOR=blue/ENV APP_COLOR=green/' Dockerfile
sed -i 's|^CMD .*|CMD ["sh", "/app/greet.sh", "long"]|' Dockerfile
cat Dockerfile
```

`CMD` 는 exec 형식(JSON 배열)을 그대로 유지합니다. 배열 안 문자열은 반드시 큰따옴표여야 하고, 작은따옴표를
쓰면 JSON 으로 해석되지 않아 셸 형식(`/bin/sh -c '...'`)으로 바뀝니다. `ENV` 값은 빌드 때 이미지 설정에
구워지므로, 파일만 고치고 다시 빌드하지 않으면 아무것도 바뀌지 않습니다.

**2) v2 빌드**

```bash
podman build -t localhost/f01-greeter:v2 /opt/course/f01/build
podman images | grep f01-greeter
# localhost/f01-greeter  v2  ...
# localhost/f01-greeter  v1  ...
```

podman 은 레지스트리 없이 붙인 이름 앞에 `localhost/` 를 붙이므로, 처음부터 `localhost/...` 로 태그하면
이름이 헷갈리지 않습니다. docker 라면 `docker build -t localhost/f01-greeter:v2 .` 로 같습니다.

**3) 실행해서 바뀐 값 확인**

```bash
podman run --rm localhost/f01-greeter:v2 > /opt/course/f01/v2-output.txt
cat /opt/course/f01/v2-output.txt
# color=green
# mode=long
```

`podman run` 뒤에 명령을 붙이면 `CMD` 가 덮어써져 검증이 되지 않습니다. `-e APP_COLOR=...` 도 이미지의
`ENV` 를 덮어쓰므로 주지 않습니다.

**4) OCI 아카이브로 저장**

```bash
podman save --format oci-archive -o /opt/course/f01/greeter-v2.tar localhost/f01-greeter:v2
tar -tf /opt/course/f01/greeter-v2.tar | head
# blobs/
# blobs/sha256/...
# index.json
# oci-layout
```

`podman save` 의 기본 형식은 `docker-archive` 입니다. 문제가 OCI 를 요구하면 `--format oci-archive` 를
반드시 붙입니다. docker 에는 `--format` 이 없고 `docker save -o file.tar img:tag` 만 있습니다(Docker 25 부터
결과 tar 안에 `index.json`·`oci-layout` 이 함께 들어 있습니다).

## 검증

```bash
grep -E '^(ENV|CMD)' /opt/course/f01/build/Dockerfile
# ENV APP_COLOR=green
# CMD ["sh", "/app/greet.sh", "long"]
podman image inspect localhost/f01-greeter:v2 --format '{{.Config.Env}} {{.Config.Cmd}}'
# [PATH=... APP_COLOR=green] [sh /app/greet.sh long]
cat /opt/course/f01/v2-output.txt
# color=green
# mode=long
tar -xOf /opt/course/f01/greeter-v2.tar oci-layout
# {"imageLayoutVersion": "1.0.0"}
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Dockerfile 을 고쳤으면 새 태그로 다시 build 하고, OCI 로 저장할 때는 `podman save --format oci-archive -o <file> <img:tag>`.
- **헷갈리는 지점**: `podman save` 기본값은 docker-archive 라 형식 지정을 빠뜨리기 쉽습니다. `podman run img <명령>` 은 `CMD` 를 덮어쓰고(`ENTRYPOINT` 는 그대로), `podman run -e` 는 `ENV` 를 덮어쓰므로 "기본 동작" 확인에는 둘 다 쓰지 않습니다.

## 참고 문서

시험 중 podman 옵션은 `podman save --help`, `podman build --help` 가 가장 빠릅니다.

- 검색어: `images`, `container image`
- https://kubernetes.io/docs/concepts/containers/images/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q02 →](../q02_pod_to_deployment/question.md)

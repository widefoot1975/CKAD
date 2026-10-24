#!/usr/bin/env bash
# b01 — Multi-stage build with a non-root image · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이미지 빌드 도구 확인
command -v podman >/dev/null || command -v docker >/dev/null || { echo "podman 또는 docker 가 필요하다"; exit 1; }
if command -v podman >/dev/null; then E=podman; else E=docker; fi

# 1) 이전 실습 흔적 정리: 빌드한 이미지와 작업 디렉터리
$E rmi -f b01-app:single b01-app:multi >/dev/null 2>&1 || true
rm -rf /opt/course/b01

# 2) 작은 Go 프로그램과 단일 스테이지 Dockerfile 만들기
mkdir -p /opt/course/b01/app
cat > /opt/course/b01/app/go.mod <<'GOMOD'
module b01app

go 1.23
GOMOD

cat > /opt/course/b01/app/main.go <<'GO'
package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	msg := flag.String("msg", "hello", "message to print")
	flag.Parse()
	fmt.Printf("%s uid=%d gid=%d\n", *msg, os.Getuid(), os.Getgid())
}
GO

cat > /opt/course/b01/app/Dockerfile <<'DOCKERFILE'
FROM docker.io/library/golang:1.23-alpine
WORKDIR /src
COPY go.mod main.go ./
RUN go build -o /usr/local/bin/hello .
CMD /usr/local/bin/hello -msg=from-b01
DOCKERFILE

# 3) 시작 상태 확인: 소스와 Dockerfile 만 있고 이미지는 없다
ls -l /opt/course/b01/app
$E images | grep b01-app || echo "b01-app 이미지 없음 (정상)"

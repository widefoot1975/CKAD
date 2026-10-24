#!/usr/bin/env bash
# f01 — Modify a Dockerfile and rebuild the image · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이미지 빌드 도구 확인 (podman 우선, 없으면 docker)
command -v podman >/dev/null || command -v docker >/dev/null || { echo "podman 또는 docker 가 필요하다"; exit 1; }
if command -v podman >/dev/null; then CE=podman; else CE=docker; fi

# 1) 이전 실습 흔적 정리: 이 문제의 이미지와 작업 디렉터리
$CE rmi -f localhost/f01-greeter:v2 localhost/f01-greeter:v1 >/dev/null 2>&1 || true
rm -rf /opt/course/f01

# 2) 빌드 컨텍스트: Dockerfile 과 스크립트 (후보자가 Dockerfile 을 고친다)
#    FROM 은 전체 경로로 적어 podman 의 short-name 확인 프롬프트를 피한다
mkdir -p /opt/course/f01/build
cat <<'EOF' > /opt/course/f01/build/Dockerfile
FROM docker.io/library/busybox:1.36
ENV APP_COLOR=blue
WORKDIR /app
COPY greet.sh /app/greet.sh
CMD ["sh", "/app/greet.sh", "short"]
EOF
cat <<'EOF' > /opt/course/f01/build/greet.sh
#!/bin/sh
echo "color=${APP_COLOR}"
echo "mode=${1:-none}"
EOF

# 3) 현재 버전 v1 을 미리 빌드해 둔다
$CE build -t localhost/f01-greeter:v1 /opt/course/f01/build

# 4) 시작 상태 확인: v1 은 color=blue / mode=short 를 출력하고, v2 는 아직 없다
$CE run --rm localhost/f01-greeter:v1
$CE images | grep f01-greeter

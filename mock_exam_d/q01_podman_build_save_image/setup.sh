#!/usr/bin/env bash
# d01 — Build and save a container image with Podman · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) podman 또는 docker 가 있는지 확인 (없으면 여기서 멈춘다)
command -v podman >/dev/null || command -v docker >/dev/null || { echo "podman 또는 docker 가 필요하다"; exit 1; }
ENG=$(command -v podman || command -v docker)

# 1) 이전 실습 흔적 정리: 컨테이너, 이미지, 결과 파일
"$ENG" rm -f robin-test >/dev/null 2>&1 || true
"$ENG" rmi -f robin-web:v1 localhost/robin-web:v1 >/dev/null 2>&1 || true
rm -rf /opt/course/d01

# 2) 빌드 컨텍스트: Dockerfile 과 index.html
mkdir -p /opt/course/d01/app
cat <<'EOF' > /opt/course/d01/app/Dockerfile
FROM docker.io/library/nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
cat <<'EOF' > /opt/course/d01/app/index.html
<h1>robin-web v1</h1>
EOF

# 3) 시작 상태 확인: 소스 파일만 있고 이미지·tar 는 없다
ls -l /opt/course/d01/app
"$ENG" images 2>/dev/null | grep robin-web || echo "이미지 robin-web 없음 (정상)"

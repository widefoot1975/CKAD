#!/usr/bin/env bash
# a01 — Fix a Dockerfile, build and save an OCI image · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) podman 또는 docker 확인 (podman 우선)
command -v podman >/dev/null || command -v docker >/dev/null || { echo "podman 또는 docker 가 필요하다"; exit 1; }
CE=$(command -v podman || command -v docker)

# 1) 이전 실습 흔적 정리: 컨테이너, 이미지 두 태그, 작업 디렉터리
"$CE" rm -f orders-api-a01 >/dev/null 2>&1 || true
"$CE" rmi -f localhost/orders-api:2.1.0 localhost/orders-api:stable >/dev/null 2>&1 || true
rm -rf /opt/course/a01

# 2) 빌드 컨텍스트: 애플리케이션은 src/ 아래에 있다
mkdir -p /opt/course/a01/build/src
cat > /opt/course/a01/build/src/app.py <<'PY'
import http.server
import os

VERSION = os.environ.get("APP_VERSION", "")
MSG = "orders-api %s uid=%d\n" % (VERSION, os.getuid())


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = MSG.encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


print(MSG, end="", flush=True)
http.server.HTTPServer(("", 8080), Handler).serve_forever()
PY

# 3) 고장 난 Dockerfile: ARG 위치, COPY 경로, EXPOSE 없음, root 로 실행
cat > /opt/course/a01/build/Dockerfile <<'DOCKERFILE'
ARG APP_VERSION=dev
FROM python:3.12-alpine
ENV APP_VERSION=${APP_VERSION}
WORKDIR /app
COPY app.py /app/app.py
CMD ["python", "/app/app.py"]
DOCKERFILE

# 4) 시작 상태 확인
find /opt/course/a01 -type f
"$CE" images localhost/orders-api

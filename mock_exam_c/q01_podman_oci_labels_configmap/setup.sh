#!/usr/bin/env bash
# c01 — Build a labelled image and reuse its config in a Pod · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) podman 또는 docker 확인 (podman 우선)
command -v podman >/dev/null || command -v docker >/dev/null || { echo "podman 또는 docker 가 필요하다"; exit 1; }
CT=podman; command -v podman >/dev/null || CT=docker

# 1) 이전 실습 흔적 정리: 컨테이너, 이미지, namespace, 결과 파일
$CT rm -f c01-web >/dev/null 2>&1 || true
$CT rmi -f localhost/c01-web:1.0.0 >/dev/null 2>&1 || true
kubectl delete ns oak --ignore-not-found --wait=true
rm -rf /opt/course/c01

# 2) 빌드 컨텍스트: LABEL 이 없는 Dockerfile 과 8080 에서 고정 응답을 주는 nginx 설정
mkdir -p /opt/course/c01/build
cat > /opt/course/c01/build/Dockerfile <<'EOF'
FROM docker.io/library/nginx:1.27-alpine
COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
EOF
cat > /opt/course/c01/build/default.conf <<'EOF'
server {
    listen 8080;
    server_name _;
    location / {
        default_type text/plain;
        return 200 "c01 web ok\n";
    }
}
EOF

# 3) 클러스터 쪽 namespace 만 만든다 (ConfigMap·Pod 는 문제에서 만든다)
kubectl create ns oak

# 4) 시작 상태 확인
ls -l /opt/course/c01/build
$CT images localhost/c01-web 2>/dev/null | grep c01-web || echo "이미지 localhost/c01-web 없음 (정상)"
kubectl -n oak get cm,pod

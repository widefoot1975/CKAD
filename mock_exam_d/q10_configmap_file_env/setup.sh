#!/usr/bin/env bash
# d10 — Configure a Pod from a ConfigMap · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns swallow --ignore-not-found --wait=true
rm -rf /opt/course/d10

# 1) namespace
kubectl create ns swallow

# 2) ConfigMap 에 넣을 설정 파일
mkdir -p /opt/course/d10
cat <<'EOF' > /opt/course/d10/app.properties
app.name=swallow
app.mode=production
cache.size=128
EOF

# 3) 시작 상태 확인: 파일만 있고 ConfigMap·Pod 는 없다
cat /opt/course/d10/app.properties
kubectl -n swallow get cm,pod

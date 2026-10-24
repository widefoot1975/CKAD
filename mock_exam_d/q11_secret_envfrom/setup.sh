#!/usr/bin/env bash
# d11 — Inject a Secret with envFrom · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns pelican --ignore-not-found --wait=true
rm -rf /opt/course/d11

# 1) namespace 와 답안 디렉터리
kubectl create ns pelican
mkdir -p /opt/course/d11

# 2) 시작 상태 확인: Secret pelican-db 와 Pod 가 없어야 한다
kubectl -n pelican get secret,pod

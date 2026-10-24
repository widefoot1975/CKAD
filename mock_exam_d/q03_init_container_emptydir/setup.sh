#!/usr/bin/env bash
# d03 — Prepare web content with an init container · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns eagle --ignore-not-found --wait=true
rm -rf /opt/course/d03

# 1) namespace 와 답안 디렉터리
kubectl create ns eagle
mkdir -p /opt/course/d03

# 2) 시작 상태 확인: 파드가 없어야 한다
kubectl -n eagle get pod

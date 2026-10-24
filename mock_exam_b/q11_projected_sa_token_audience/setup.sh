#!/usr/bin/env bash
# b11 — Projected ServiceAccount token with a custom audience · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns ganymede --ignore-not-found --wait=true
rm -rf /opt/course/b11

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns ganymede
mkdir -p /opt/course/b11

# 2) 시작 상태 확인: default SA 만 있고 reporter 는 없다
kubectl -n ganymede get sa
kubectl -n ganymede get pod

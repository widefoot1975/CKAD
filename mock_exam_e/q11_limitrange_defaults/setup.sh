#!/usr/bin/env bash
# e11 — Apply default resources with a LimitRange · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns quartz --ignore-not-found --wait=true
rm -rf /opt/course/e11

# 1) 빈 namespace 와 결과 디렉터리
kubectl create ns quartz
mkdir -p /opt/course/e11

# 2) 시작 상태 확인: LimitRange, ResourceQuota, 파드가 없다
kubectl -n quartz get limitrange,resourcequota,pods

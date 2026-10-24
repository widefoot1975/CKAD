#!/usr/bin/env bash
# f11 — ServiceAccount token and automount · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns indus --ignore-not-found --wait=true
rm -rf /opt/course/f11

# 1) 빈 namespace 와 답안 디렉터리 (ServiceAccount, Pod, 토큰은 문제에서 만든다)
kubectl create ns indus
mkdir -p /opt/course/f11

# 2) 시작 상태 확인: default ServiceAccount 만 있고 Pod 는 없다
kubectl -n indus get sa,pod

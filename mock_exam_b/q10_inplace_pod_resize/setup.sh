#!/usr/bin/env bash
# b10 — Resize a running Pod in place · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns io --ignore-not-found --wait=true
rm -rf /opt/course/b10

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns io
mkdir -p /opt/course/b10

# 2) 시작 상태 확인: io 는 비어 있다, kubectl 이 resize 서브리소스를 아는지 확인
kubectl -n io get pod
kubectl patch --help | grep -q -- '--subresource' && echo "kubectl patch --subresource 지원 (정상)"
kubectl version

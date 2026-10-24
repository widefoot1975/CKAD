#!/usr/bin/env bash
# b13 — Non-root Pod with fsGroup and minimal capabilities · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns phobos --ignore-not-found --wait=true
rm -rf /opt/course/b13

# 1) restricted Pod Security 가 강제되는 네임스페이스
kubectl create ns phobos
kubectl label ns phobos \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest
mkdir -p /opt/course/b13

# 2) 시작 상태 확인: 레이블만 있고 Pod 는 없다
kubectl get ns phobos --show-labels
kubectl -n phobos get pod

#!/usr/bin/env bash
# d15 — Expose a Deployment with a ClusterIP Service · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns dove --ignore-not-found --wait=true
rm -rf /opt/course/d15

# 1) namespace 와 백엔드: 8080 에서 "dove-api" 를 응답하는 http-echo 2개 (라벨 app=dove-api)
kubectl create ns dove
kubectl -n dove create deploy dove-api --image=hashicorp/http-echo:1.0 --replicas=2 \
  -- /http-echo -listen=:8080 -text=dove-api
kubectl -n dove rollout status deploy dove-api --timeout=180s

# 2) 답안 디렉터리
mkdir -p /opt/course/d15

# 3) 시작 상태 확인: 파드 2개, Service 없음
kubectl -n dove get deploy,pod,svc -o wide

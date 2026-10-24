#!/usr/bin/env bash
# d12 — Run a Deployment with a dedicated ServiceAccount · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns crane --ignore-not-found --wait=true
rm -rf /opt/course/d12

# 1) namespace 와 default SA 로 도는 Deployment crane-api
kubectl create ns crane
kubectl -n crane create deploy crane-api --image=nginx:1.27-alpine --replicas=2
kubectl -n crane rollout status deploy crane-api --timeout=180s

# 2) 답안 디렉터리
mkdir -p /opt/course/d12

# 3) 시작 상태 확인: 파드는 default SA, crane-sa 는 없다
kubectl -n crane get deploy crane-api
kubectl -n crane get pods -l app=crane-api -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.serviceAccountName}{"\n"}{end}'
kubectl -n crane get sa

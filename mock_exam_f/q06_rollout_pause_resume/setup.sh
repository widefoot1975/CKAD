#!/usr/bin/env bash
# f06 — Batch Deployment changes with rollout pause · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns seine --ignore-not-found --wait=true
rm -rf /opt/course/f06

# 1) namespace 와 답안 디렉터리
kubectl create ns seine
mkdir -p /opt/course/f06

# 2) Deployment api (revision 1: httpd, 리소스 설정 없음, change-cause 기록)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: seine
  annotations:
    kubernetes.io/change-cause: "initial release httpd 2.4"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: web
        image: httpd:2.4-alpine
        ports:
        - containerPort: 80
YAML
kubectl -n seine rollout status deploy api --timeout=120s

# 3) 시작 상태 확인: revision 1 하나, 일시정지 아님
kubectl -n seine rollout history deploy api
kubectl -n seine get deploy api -o jsonpath='paused={.spec.paused}{"\n"}'

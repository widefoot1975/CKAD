#!/usr/bin/env bash
# b04 — Canary release behind a shared Service · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns mars --ignore-not-found --wait=true
rm -rf /opt/course/b04

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns mars
mkdir -p /opt/course/b04

# 2) stable Deployment 와 Service (Service 셀렉터에 track=stable 이 들어 있다)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-stable
  namespace: mars
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web
      track: stable
  template:
    metadata:
      labels:
        app: web
        track: stable
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: mars
spec:
  selector:
    app: web
    track: stable
  ports:
  - name: http
    port: 80
    targetPort: 80
YAML

kubectl -n mars rollout status deploy web-stable --timeout=180s

# 3) 시작 상태 확인
kubectl -n mars get deploy,svc
kubectl get endpointslice -n mars -l kubernetes.io/service-name=web

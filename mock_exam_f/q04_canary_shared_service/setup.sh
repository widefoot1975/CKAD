#!/usr/bin/env bash
# f04 — Canary release with replica ratios · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns danube --ignore-not-found --wait=true
rm -rf /opt/course/f04

# 1) namespace 와 답안 디렉터리
kubectl create ns danube
mkdir -p /opt/course/f04

# 2) stable 버전: Deployment shop-stable (4 replicas, "stable" 응답) 과 Service shop (selector app=shop)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-stable
  namespace: danube
  labels:
    app: shop
    track: stable
spec:
  replicas: 4
  selector:
    matchLabels:
      app: shop
      track: stable
  template:
    metadata:
      labels:
        app: shop
        track: stable
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:1.0
        args: ["-text=stable"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: shop
  namespace: danube
spec:
  selector:
    app: shop
  ports:
  - port: 80
    targetPort: 5678
YAML
kubectl -n danube rollout status deploy shop-stable --timeout=120s

# 3) 시작 상태 확인: Deployment 는 shop-stable 하나, EndpointSlice 에 endpoint 4개
kubectl -n danube get deploy,svc
kubectl -n danube get endpointslice -l kubernetes.io/service-name=shop

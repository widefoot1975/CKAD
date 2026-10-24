#!/usr/bin/env bash
# c04 — Detect a stalled rollout and undo to a chosen revision · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns birch --ignore-not-found --wait=true
rm -rf /opt/course/c04
mkdir -p /opt/course/c04

# 1) 리비전 1: nginx:1.27-alpine
kubectl create ns birch
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  namespace: birch
  annotations:
    kubernetes.io/change-cause: "initial release nginx 1.27"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML
kubectl -n birch rollout status deploy shop --timeout=120s

# 2) 리비전 2: httpd:2.4-alpine (정상 동작하지만 "nginx 리비전"은 아니다)
kubectl -n birch set image deploy/shop web=httpd:2.4-alpine
kubectl -n birch annotate deploy shop kubernetes.io/change-cause="switch to httpd 2.4" --overwrite
kubectl -n birch rollout status deploy shop --timeout=120s

# 3) 시작 상태 확인
kubectl -n birch rollout history deploy shop
kubectl -n birch get deploy shop -o jsonpath='minReadySeconds={.spec.minReadySeconds} progressDeadlineSeconds={.spec.progressDeadlineSeconds}{"\n"}'

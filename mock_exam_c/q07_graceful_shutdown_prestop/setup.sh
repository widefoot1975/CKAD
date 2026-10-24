#!/usr/bin/env bash
# c07 — Graceful shutdown with preStop and the grace period · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns aspen --ignore-not-found --wait=true
rm -rf /opt/course/c07
mkdir -p /opt/course/c07

# 1) probe·preStop 없이 grace period 만 15초인 Deployment 와 Service
kubectl create ns aspen
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout
  namespace: aspen
spec:
  replicas: 2
  selector:
    matchLabels:
      app: checkout
  template:
    metadata:
      labels:
        app: checkout
    spec:
      terminationGracePeriodSeconds: 15
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: checkout
  namespace: aspen
spec:
  selector:
    app: checkout
  ports:
  - port: 80
    targetPort: 80
YAML
kubectl -n aspen rollout status deploy checkout --timeout=120s

# 2) 시작 상태 확인
kubectl -n aspen get deploy,pod,svc
kubectl -n aspen get deploy checkout -o jsonpath='grace={.spec.template.spec.terminationGracePeriodSeconds} lifecycle={.spec.template.spec.containers[0].lifecycle} readiness={.spec.template.spec.containers[0].readinessProbe}{"\n"}'
kubectl -n aspen get endpointslice -l kubernetes.io/service-name=checkout

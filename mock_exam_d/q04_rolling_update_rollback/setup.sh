#!/usr/bin/env bash
# d04 — Rolling update and rollback of a Deployment · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns heron --ignore-not-found --wait=true
rm -rf /opt/course/d04

# 1) namespace 와 Deployment heron-api (컨테이너 이름 api, 기본 전략 25%/25%)
kubectl create ns heron
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: heron-api
  namespace: heron
  labels:
    app: heron-api
spec:
  replicas: 4
  selector:
    matchLabels:
      app: heron-api
  template:
    metadata:
      labels:
        app: heron-api
    spec:
      containers:
      - name: api
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML
kubectl -n heron rollout status deploy heron-api --timeout=180s

# 2) 답안 디렉터리
mkdir -p /opt/course/d04

# 3) 시작 상태 확인: 4/4 Ready, 리비전 1 개
kubectl -n heron get deploy heron-api
kubectl -n heron rollout history deploy heron-api

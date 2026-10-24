#!/usr/bin/env bash
# d07 — Add liveness and readiness probes · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns kestrel --ignore-not-found --wait=true

# 1) namespace 와 probe 가 없는 Deployment kestrel-app
kubectl create ns kestrel
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kestrel-app
  namespace: kestrel
  labels:
    app: kestrel-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kestrel-app
  template:
    metadata:
      labels:
        app: kestrel-app
    spec:
      containers:
      - name: app
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML
kubectl -n kestrel rollout status deploy kestrel-app --timeout=180s

# 2) 시작 상태 확인: 2/2 Ready, probe 없음
kubectl -n kestrel get deploy kestrel-app
kubectl -n kestrel describe deploy kestrel-app | grep -E 'Liveness|Readiness' || echo "probe 없음 (정상)"

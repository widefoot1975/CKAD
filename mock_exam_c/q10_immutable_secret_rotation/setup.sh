#!/usr/bin/env bash
# c10 — Rotate an immutable Secret · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns spruce --ignore-not-found --wait=true
rm -rf /opt/course/c10
mkdir -p /opt/course/c10

# 1) immutable Secret 과 그 키를 env 로 읽는 Deployment
kubectl create ns spruce
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: api-token
  namespace: spruce
type: Opaque
immutable: true
stringData:
  token: old-token-111
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
  namespace: spruce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client
        image: busybox:1.36
        command: ["sh", "-c", "while true; do sleep 3600; done"]
        env:
        - name: API_TOKEN
          valueFrom:
            secretKeyRef:
              name: api-token
              key: token
YAML
kubectl -n spruce rollout status deploy client --timeout=120s

# 2) 시작 상태 확인
kubectl -n spruce get secret api-token -o jsonpath='immutable={.immutable}{"\n"}'
kubectl -n spruce exec deploy/client -- printenv API_TOKEN

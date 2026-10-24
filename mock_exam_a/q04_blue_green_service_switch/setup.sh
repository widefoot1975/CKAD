#!/usr/bin/env bash
# a04 — Blue/green switch behind a Service · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns gamma --ignore-not-found --wait=true
rm -rf /opt/course/a04

# 1) namespace 와 결과 디렉터리
kubectl create ns gamma
mkdir -p /opt/course/a04

# 2) blue 버전: Deployment shop-blue (3개) + Service shop (blue 선택)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-blue
  namespace: gamma
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shop
      version: blue
  template:
    metadata:
      labels:
        app: shop
        version: blue
    spec:
      containers:
      - name: http-echo
        image: hashicorp/http-echo:1.0
        args: ["-text=blue"]
        ports:
        - containerPort: 5678
        readinessProbe:
          tcpSocket:
            port: 5678
          periodSeconds: 2
---
apiVersion: v1
kind: Service
metadata:
  name: shop
  namespace: gamma
spec:
  selector:
    app: shop
    version: blue
  ports:
  - port: 80
    targetPort: 5678
---
apiVersion: v1
kind: Pod
metadata:
  name: curl-a04
  namespace: gamma
  labels:
    role: client
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.10.1
    command: ["sleep", "86400"]
YAML

# 3) 준비될 때까지 대기
kubectl -n gamma rollout status deploy shop-blue --timeout=120s
kubectl -n gamma wait --for=condition=Ready pod/curl-a04 --timeout=120s

# 4) 시작 상태 확인: 응답은 blue, shop-green 은 없음
kubectl -n gamma get deploy,svc,pod
kubectl -n gamma exec curl-a04 -- curl -s http://shop

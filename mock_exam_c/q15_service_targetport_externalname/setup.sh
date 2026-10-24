#!/usr/bin/env bash
# c15 — Repair a Service port and add an ExternalName alias · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns yew --ignore-not-found --wait=true
rm -rf /opt/course/c15
mkdir -p /opt/course/c15

# 1) 백엔드: http-echo 는 5678 에서 듣고, 포트 이름은 http
kubectl create ns yew
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders
  namespace: yew
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orders
  template:
    metadata:
      labels:
        app: orders
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:1.0
        args: ["-text=orders ok", "-listen=:5678"]
        ports:
        - name: http
          containerPort: 5678
---
# 2) 고장: selector 는 맞지만 targetPort 가 아무도 듣지 않는 8080
apiVersion: v1
kind: Service
metadata:
  name: orders
  namespace: yew
spec:
  selector:
    app: orders
  ports:
  - name: web
    port: 80
    targetPort: 8080
YAML
kubectl -n yew rollout status deploy orders --timeout=120s

# 3) 시작 상태 확인: EndpointSlice 는 비어 있지 않은데 포트가 8080
kubectl -n yew get svc orders
kubectl -n yew get endpointslice -l kubernetes.io/service-name=orders
kubectl -n yew get svc orders-db 2>/dev/null || echo "Service orders-db 없음 (정상)"

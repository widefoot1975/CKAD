#!/usr/bin/env bash
# f15 — Service with a wrong selector · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns oder --ignore-not-found --wait=true
rm -rf /opt/course/f15

# 1) namespace 와 답안 디렉터리
kubectl create ns oder
mkdir -p /opt/course/f15

# 2) Deployment catalog (Pod 라벨 app=catalog, tier=api) 와
#    고장 낸 Service catalog (selector 가 tier=backend 라 어떤 Pod 도 고르지 못한다)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
  namespace: oder
spec:
  replicas: 2
  selector:
    matchLabels:
      app: catalog
      tier: api
  template:
    metadata:
      labels:
        app: catalog
        tier: api
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:1.0
        args: ["-text=catalog"]
        ports:
        - name: http
          containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: catalog
  namespace: oder
spec:
  selector:
    app: catalog
    tier: backend
  ports:
  - port: 80
    targetPort: 5678
YAML
kubectl -n oder rollout status deploy catalog --timeout=120s

# 3) 시작 상태 확인: Pod 2개는 Ready, EndpointSlice 에는 endpoint 가 없다
kubectl -n oder get pods --show-labels
kubectl -n oder get endpointslice -l kubernetes.io/service-name=catalog

#!/usr/bin/env bash
# e04 — Switch a Service from blue to green · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns topaz --ignore-not-found --wait=true
rm -rf /opt/course/e04

# 1) namespace 와 결과 디렉터리
kubectl create ns topaz
mkdir -p /opt/course/e04

# 2) blue / green 두 Deployment (http-echo, 컨테이너 포트 5678) 와 blue 를 고르는 Service web
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-blue
  namespace: topaz
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
      version: blue
  template:
    metadata:
      labels:
        app: web
        version: blue
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo:1.0
        args: ["-text=blue"]
        ports:
        - containerPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-green
  namespace: topaz
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
      version: green
  template:
    metadata:
      labels:
        app: web
        version: green
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo:1.0
        args: ["-text=green"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: topaz
spec:
  selector:
    app: web
    version: blue
  ports:
  - port: 80
    targetPort: 5678
YAML

kubectl -n topaz rollout status deploy web-blue --timeout=120s
kubectl -n topaz rollout status deploy web-green --timeout=120s

# 3) 시작 상태 확인: Service 는 blue 를 고른다
kubectl -n topaz get deploy,svc
kubectl -n topaz get svc web -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n topaz get endpointslice -l kubernetes.io/service-name=web

#!/usr/bin/env bash
# e06 — Kustomize a ConfigMap generator and an env patch · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns garnet --ignore-not-found --wait=true
rm -rf /opt/course/e06

# 1) namespace 와 kustomize 디렉터리
kubectl create ns garnet
mkdir -p /opt/course/e06

cat > /opt/course/e06/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  labels:
    app: shop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
      - name: shop
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML

cat > /opt/course/e06/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: garnet
resources:
- deployment.yaml
YAML

# 2) 시작 상태 확인: 렌더링은 되고, garnet 에는 아직 아무것도 없다
kubectl kustomize /opt/course/e06 | head -20
kubectl -n garnet get deploy,cm

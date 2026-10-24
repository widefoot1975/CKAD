#!/usr/bin/env bash
# d06 — Customize a Deployment with a Kustomize overlay · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns sparrow --ignore-not-found --wait=true
rm -rf /opt/course/d06

# 1) namespace (오버레이가 이 namespace 로 배포한다)
kubectl create ns sparrow

# 2) base: Deployment web + Service web (이미지 nginx:1.27, replicas 1)
mkdir -p /opt/course/d06/base /opt/course/d06/overlays/prod
cat <<'YAML' > /opt/course/d06/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.27
        ports:
        - containerPort: 80
YAML
cat <<'YAML' > /opt/course/d06/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
YAML
cat <<'YAML' > /opt/course/d06/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
YAML

# 3) overlay: namespace 와 base 참조만 있다 (나머지는 문제에서 채운다)
cat <<'YAML' > /opt/course/d06/overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: sparrow
resources:
- ../../base
YAML

# 4) 시작 상태 확인: 파일만 있고 sparrow 에는 리소스가 없다
find /opt/course/d06 -type f | sort
kubectl -n sparrow get deploy,svc

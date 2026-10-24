#!/usr/bin/env bash
# a10 — Projected volume from a ConfigMap and a Secret · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns kappa --ignore-not-found --wait=true
rm -rf /opt/course/a10

# 1) namespace 와 결과 디렉터리
kubectl create ns kappa
mkdir -p /opt/course/a10

# 2) ConfigMap (키 3개, 그중 unused.txt 는 볼륨에 들어가면 안 된다) 과 Secret (키 3개)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: gateway-config
  namespace: kappa
data:
  gateway.yaml: |
    listen: 8443
    log: info
  routes.yaml: |
    - /orders -> orders:80
  unused.txt: |
    this key must not be projected
---
apiVersion: v1
kind: Secret
metadata:
  name: gateway-creds
  namespace: kappa
type: Opaque
stringData:
  api-key: K-a10-7f3c
  username: gw
  password: S3cr3t-a10
YAML

# 3) 시작 상태 확인: ConfigMap 과 Secret 만 있고 Pod 는 없다
kubectl -n kappa get cm,secret,pod

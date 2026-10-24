#!/usr/bin/env bash
# c06 — Kustomize overlay with a generated Secret · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns willow --ignore-not-found --wait=true
rm -rf /opt/course/c06

# 1) base: Secret api-creds 를 envFrom 으로 읽는 Deployment api
mkdir -p /opt/course/c06/base /opt/course/c06/overlays/prod
cat > /opt/course/c06/base/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: busybox:1.36
        command: ["sh", "-c", "echo user=$DB_USER; while true; do sleep 3600; done"]
        envFrom:
        - secretRef:
            name: api-creds
YAML
cat > /opt/course/c06/base/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
YAML

# 2) overlay 재료: 비밀번호 파일 (끝에 줄바꿈 없음)
printf '%s' 'S3cr3t-c06' > /opt/course/c06/overlays/prod/db-password.txt

# 3) 대상 namespace (비어 있음)
kubectl create ns willow

# 4) 시작 상태 확인
find /opt/course/c06 -type f | sort
kubectl -n willow get all,secret

#!/usr/bin/env bash
# b06 — Kustomize patches with target selectors and labels · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns saturn --ignore-not-found --wait=true
rm -rf /opt/course/b06

# 1) 네임스페이스와 kustomize 디렉터리
kubectl create ns saturn
mkdir -p /opt/course/b06/app
cd /opt/course/b06/app

cat > kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: saturn
commonLabels:
  app.kubernetes.io/part-of: shop
resources:
- frontend.yaml
- api.yaml
- batch.yaml
YAML

cat > frontend.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
    exposure: public
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML

cat > api.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app: api
    exposure: public
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
      initContainers:
      - name: log-agent
        image: busybox:1.36
        restartPolicy: Always
        command: ["sh", "-c", "while true; do echo shipping logs; sleep 30; done"]
      containers:
      - name: api
        image: hashicorp/http-echo:1.0
        args: ["-text=api", "-listen=:5678"]
        ports:
        - containerPort: 5678
YAML

cat > batch.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch
  labels:
    app: batch
    exposure: internal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: batch
  template:
    metadata:
      labels:
        app: batch
    spec:
      containers:
      - name: batch
        image: busybox:1.36
        command: ["sh", "-c", "while true; do sleep 3600; done"]
YAML

# 2) 지금의 kustomization(commonLabels)으로 배포해 둔다
kubectl apply -k /opt/course/b06/app
for d in frontend api batch; do
  kubectl -n saturn rollout status deploy "$d" --timeout=180s
done

# 3) 시작 상태 확인
kubectl -n saturn get deploy
ls -l /opt/course/b06/app

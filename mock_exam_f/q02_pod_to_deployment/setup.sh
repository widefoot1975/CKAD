#!/usr/bin/env bash
# f02 — Turn a standalone Pod into a Deployment · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns amazon --ignore-not-found --wait=true
rm -rf /opt/course/f02

# 1) namespace 와 답안 디렉터리
kubectl create ns amazon
mkdir -p /opt/course/f02

# 2) 손으로 띄운 단독 Pod web (컨트롤러 없음)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: amazon
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:1.27-alpine
    ports:
    - name: http
      containerPort: 80
    env:
    - name: GREETING
      value: hello-f02
    resources:
      requests:
        cpu: 50m
        memory: 32Mi
      limits:
        memory: 64Mi
YAML
kubectl -n amazon wait pod web --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: Pod web 하나만 있고 Deployment 는 없다
kubectl -n amazon get pod web --show-labels
kubectl -n amazon get deploy

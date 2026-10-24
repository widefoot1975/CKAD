#!/usr/bin/env bash
# f07 — Fix a readiness probe on the wrong port · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns volga --ignore-not-found --wait=true
rm -rf /opt/course/f07

# 1) namespace 와 답안 디렉터리
kubectl create ns volga
mkdir -p /opt/course/f07

# 2) 고장 내기: redis 는 6379 에서 듣는데 readiness probe 는 6380 을 확인한다
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  namespace: volga
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
      - name: redis
        image: redis:7.4-alpine
        ports:
        - name: redis
          containerPort: 6379
        readinessProbe:
          tcpSocket:
            port: 6380
          initialDelaySeconds: 2
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: cache
  namespace: volga
spec:
  selector:
    app: cache
  ports:
  - port: 6379
    targetPort: 6379
YAML

# 3) 컨테이너가 Running 이 되고 readiness 실패 이벤트가 쌓일 때까지 기다린다
for i in $(seq 1 30); do
  [ "$(kubectl -n volga get pods -l app=cache -o name | wc -l)" -ge 2 ] && break
  sleep 2
done
kubectl -n volga wait pod -l app=cache --for=jsonpath='{.status.phase}'=Running --timeout=120s
for i in $(seq 1 30); do
  kubectl -n volga get events --field-selector reason=Unhealthy -o name 2>/dev/null | grep -q . && break
  sleep 2
done

# 4) 시작 상태 확인: Pod 는 Running 이지만 READY 0/1, EndpointSlice 에 ready endpoint 없음
kubectl -n volga get deploy,pods
kubectl -n volga get endpointslice -l kubernetes.io/service-name=cache

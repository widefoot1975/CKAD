#!/usr/bin/env bash
# a15 — Repair a multi-port Service with no endpoints · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns omicron --ignore-not-found --wait=true
rm -rf /opt/course/a15

# 1) namespace 와 결과 디렉터리
kubectl create ns omicron
mkdir -p /opt/course/a15

# 2) 고장 두 개: Service selector 오타(back-end), readiness probe 포트 9899(아무도 안 들음)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-app
  namespace: omicron
spec:
  replicas: 2
  selector:
    matchLabels:
      app: metrics-app
  template:
    metadata:
      labels:
        app: metrics-app
        tier: backend
    spec:
      containers:
      - name: podinfo
        image: ghcr.io/stefanprodan/podinfo:6.7.1
        command: ["./podinfo", "--port=9898", "--port-metrics=9797", "--level=info"]
        ports:
        - name: http
          containerPort: 9898
        - name: metrics
          containerPort: 9797
        readinessProbe:
          httpGet:
            path: /readyz
            port: 9899
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-app
  namespace: omicron
spec:
  selector:
    app: metrics-app
    tier: back-end
  ports:
  - name: web
    port: 80
    targetPort: http
  - name: prom
    port: 9090
    targetPort: metrics
YAML

# 3) 파드가 Running 이 될 때까지 기다린다 (Ready 는 되지 않는다)
for i in $(seq 1 60); do
  N=$(kubectl -n omicron get pod -l app=metrics-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l || true)
  [ "$N" -ge 2 ] && break
  sleep 3
done

# 4) 시작 상태 확인: 파드 0/1 Running, EndpointSlice 비어 있음
kubectl -n omicron get pod,svc
kubectl -n omicron get endpointslice -l kubernetes.io/service-name=metrics-app

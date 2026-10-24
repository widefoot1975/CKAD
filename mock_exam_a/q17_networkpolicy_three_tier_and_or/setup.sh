#!/usr/bin/env bash
# a17 — Three-tier NetworkPolicy across namespaces · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns rho sigma --ignore-not-found --wait=true
rm -rf /opt/course/a17

# 1) namespace 두 개 (kubernetes.io/metadata.name 라벨은 자동으로 붙는다)
kubectl create ns rho
kubectl create ns sigma
mkdir -p /opt/course/a17

# 2) rho: 진짜 frontend 와 라벨이 다른 intruder
#    sigma: api(HTTP 5678) + db(redis 6379) + 라벨만 frontend 인 impostor
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: rho
  labels:
    app: frontend
spec:
  containers:
  - name: client
    image: busybox:1.36
    command: ["sleep", "86400"]
---
apiVersion: v1
kind: Pod
metadata:
  name: intruder
  namespace: rho
  labels:
    app: other
spec:
  containers:
  - name: client
    image: busybox:1.36
    command: ["sleep", "86400"]
---
apiVersion: v1
kind: Pod
metadata:
  name: impostor
  namespace: sigma
  labels:
    app: frontend
spec:
  containers:
  - name: client
    image: busybox:1.36
    command: ["sleep", "86400"]
---
apiVersion: v1
kind: Pod
metadata:
  name: api
  namespace: sigma
  labels:
    app: api
spec:
  containers:
  - name: api
    image: python:3.12-alpine
    command: ["python", "-m", "http.server", "5678"]
    ports:
    - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: sigma
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 5678
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: sigma
  labels:
    app: db
spec:
  containers:
  - name: redis
    image: redis:7.4-alpine
    ports:
    - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: sigma
spec:
  selector:
    app: db
  ports:
  - port: 6379
    targetPort: 6379
YAML

# 3) 모든 파드가 Ready 가 될 때까지 대기
kubectl -n rho wait --for=condition=Ready pod --all --timeout=180s
kubectl -n sigma wait --for=condition=Ready pod --all --timeout=180s

# 4) 시작 상태 확인: NetworkPolicy 없음, frontend → api 와 frontend → db 모두 열려 있음
kubectl -n rho get pod --show-labels
kubectl -n sigma get pod,svc,netpol --show-labels
kubectl -n rho exec frontend -- wget -qO- -T 3 http://api.sigma >/dev/null && echo "frontend -> api: 열림 (정책 없음)"
kubectl -n rho exec frontend -- sh -c 'echo PING | nc -w 3 db.sigma 6379' || true

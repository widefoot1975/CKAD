#!/usr/bin/env bash
# f17 — Restrict egress to DNS and one backend · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
# NetworkPolicy 를 강제하는 CNI(Calico, Cilium 등)가 필요하다
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns shannon --ignore-not-found --wait=true
rm -rf /opt/course/f17

# 1) namespace 와 답안 디렉터리
kubectl create ns shannon
mkdir -p /opt/course/f17

# 2) Pod 세 개와 Service 두 개
#    client  : busybox (wget, nslookup 으로 시험하는 쪽)
#    backend : http-echo "backend" :5678  ← Service backend:80
#    other   : http-echo "other"   :5678  ← Service other:80
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: client
  namespace: shannon
  labels:
    app: client
spec:
  containers:
  - name: client
    image: busybox:1.36
    command: ["sh", "-c", "sleep 86400"]
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: shannon
  labels:
    app: backend
spec:
  containers:
  - name: echo
    image: hashicorp/http-echo:1.0
    args: ["-text=backend"]
    ports:
    - containerPort: 5678
---
apiVersion: v1
kind: Pod
metadata:
  name: other
  namespace: shannon
  labels:
    app: other
spec:
  containers:
  - name: echo
    image: hashicorp/http-echo:1.0
    args: ["-text=other"]
    ports:
    - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: shannon
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: other
  namespace: shannon
spec:
  selector:
    app: other
  ports:
  - port: 80
    targetPort: 5678
YAML
kubectl -n shannon wait pod --all --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: NetworkPolicy 가 없어 client 는 backend 와 other 모두에 닿는다
kubectl -n shannon get pod,svc,networkpolicy
kubectl -n shannon exec client -- wget -qO- -T 3 http://backend || true
kubectl -n shannon exec client -- wget -qO- -T 3 http://other || true

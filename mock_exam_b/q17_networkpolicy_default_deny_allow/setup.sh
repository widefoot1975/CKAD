#!/usr/bin/env bash
# b17 — Open precise paths through a default-deny namespace · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns ariel miranda charon --ignore-not-found --wait=true
rm -rf /opt/course/b17

# 1) 네임스페이스 (miranda 만 접근 허용 레이블)
kubectl create ns ariel
kubectl create ns miranda
kubectl create ns charon
kubectl label ns miranda access=b17-api
mkdir -p /opt/course/b17

# 2) ariel: api(busybox httpd 8080), db(redis 6379), Service, default-deny
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api
  namespace: ariel
  labels:
    app: api
spec:
  containers:
  - name: api
    image: busybox:1.36
    command: ["sh", "-c", "mkdir -p /www && echo api > /www/index.html && exec httpd -f -p 8080 -h /www"]
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: ariel
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
  name: api
  namespace: ariel
spec:
  selector:
    app: api
  ports:
  - name: http
    port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: ariel
spec:
  selector:
    app: db
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: ariel
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
YAML

# 3) 클라이언트 파드 (miranda 는 허용 대상, charon 은 아님)
for ns in miranda charon; do
  kubectl -n "$ns" run client --image=curlimages/curl:8.10.1 --labels=app=client \
    --command -- sleep 86400
done

kubectl -n ariel wait pod --all --for=condition=Ready --timeout=120s
kubectl -n miranda wait pod client --for=condition=Ready --timeout=120s
kubectl -n charon wait pod client --for=condition=Ready --timeout=120s

# 4) 시작 상태 확인: 모든 경로가 막혀 있어야 한다
kubectl -n ariel get pod,svc,netpol
kubectl -n miranda exec client -- curl -s -m 3 http://api.ariel:8080 \
  && echo "miranda->api 가 열려 있다 (CNI 가 NetworkPolicy 를 집행하는지 확인)" \
  || echo "miranda->api 차단됨 (정상: 시작 상태)"

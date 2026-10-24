#!/usr/bin/env bash
# d17 — Reach a backend through NetworkPolicies by relabeling a Pod · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
# NetworkPolicy 를 실제로 적용하는 CNI(Calico, Cilium 등)가 필요하다.
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns osprey --ignore-not-found --wait=true
rm -rf /opt/course/d17

# 1) namespace, backend 파드 + Service, frontend 파드 (role=client — 정책이 원하는 값과 다르다)
kubectl create ns osprey
kubectl -n osprey run backend --image=nginx:1.27-alpine --labels=app=backend --port=80
kubectl -n osprey expose pod backend --name=backend --port=80 --target-port=80
kubectl -n osprey run frontend --image=busybox:1.36 --labels=app=frontend,role=client -- sleep 86400
kubectl -n osprey wait pod backend frontend --for=condition=Ready --timeout=120s

# 2) NetworkPolicy 4개: 전체 차단, DNS 허용, backend 로 들어오는 것, api-client 에서 나가는 것
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: osprey
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: osprey
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress
  namespace: osprey
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: api-client
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: client-egress
  namespace: osprey
spec:
  podSelector:
    matchLabels:
      role: api-client
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
YAML

# 3) 답안 디렉터리
mkdir -p /opt/course/d17

# 4) 시작 상태 확인: frontend → backend 는 시간 초과로 실패해야 한다
sleep 3
kubectl -n osprey get pod --show-labels
kubectl -n osprey get netpol
if kubectl -n osprey exec frontend -- wget -qO- -T 3 http://backend >/dev/null 2>&1; then
  echo "경고: 지금 frontend → backend 가 통한다. CNI 가 NetworkPolicy 를 적용하지 않는 것 같다"
else
  echo "frontend → backend 차단됨 (정상)"
fi

#!/usr/bin/env bash
# c17 — Repair a NetworkPolicy with three faults · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
#      NetworkPolicy 를 강제하는 CNI(Calico, Cilium 등)가 있어야 결과가 의미 있다
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns cypress --ignore-not-found --wait=true
rm -rf /opt/course/c17
mkdir -p /opt/course/c17

# 1) 파드와 Service: api 는 5678 에서 듣고 Service 는 80 → 5678
kubectl create ns cypress
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api
  namespace: cypress
  labels:
    app: api
    tier: backend
spec:
  containers:
  - name: api
    image: hashicorp/http-echo:1.0
    args: ["-text=api ok", "-listen=:5678"]
    ports:
    - name: http
      containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: cypress
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: http
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: cypress
  labels:
    app: frontend
    tier: web
spec:
  containers:
  - name: shell
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
---
apiVersion: v1
kind: Pod
metadata:
  name: intruder
  namespace: cypress
  labels:
    app: intruder
    tier: web
spec:
  containers:
  - name: shell
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
YAML
kubectl -n cypress wait --for=condition=Ready pod/api pod/frontend pod/intruder --timeout=90s

# 2) 정책: default deny 는 의도된 것, allow 정책에는 고장 세 개
#    (1) from.podSelector 라벨이 실제 파드와 다름  (2) 포트가 Service port 80   (3) namespaceSelector 키가 name
cat > /opt/course/c17/allow-frontend-to-api.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: cypress
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: cypress
      podSelector:
        matchLabels:
          app: front-end
    ports:
    - protocol: TCP
      port: 80
YAML
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: cypress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
YAML
kubectl apply -f /opt/course/c17/allow-frontend-to-api.yaml

# 3) 시작 상태 확인: 둘 다 막혀 있어야 한다
kubectl -n cypress get pod --show-labels
kubectl get ns cypress --show-labels
kubectl -n cypress get networkpolicy
for p in frontend intruder; do
  if kubectl -n cypress exec $p -- wget -qO- -T 3 http://api >/dev/null 2>&1; then echo "$p -> api: ok"; else echo "$p -> api: blocked"; fi
done

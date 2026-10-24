#!/usr/bin/env bash
# b16 — Repair an Ingress that serves two hosts · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns oberon --ignore-not-found --wait=true
rm -rf /opt/course/b16

# 1) F5 NGINX Ingress Controller (공용 인프라, 이미 있으면 그대로)
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/deployment/nginx-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/service/nodeport.yaml
kubectl -n nginx-ingress rollout status deploy nginx-ingress --timeout=180s

# 2) 네임스페이스, 앱 두 개와 Service (blog 의 포트 이름은 web)
kubectl create ns oberon
mkdir -p /opt/course/b16
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  namespace: oberon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
      - name: shop
        image: hashicorp/http-echo:1.0
        args: ["-text=shop", "-listen=:5678"]
        ports:
        - containerPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blog
  namespace: oberon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blog
  template:
    metadata:
      labels:
        app: blog
    spec:
      containers:
      - name: blog
        image: hashicorp/http-echo:1.0
        args: ["-text=blog", "-listen=:5678"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: shop
  namespace: oberon
spec:
  selector:
    app: shop
  ports:
  - name: http
    port: 80
    targetPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: blog
  namespace: oberon
spec:
  selector:
    app: blog
  ports:
  - name: web
    port: 8080
    targetPort: 5678
YAML
kubectl -n oberon rollout status deploy shop --timeout=120s
kubectl -n oberon rollout status deploy blog --timeout=120s

# 3) 고장 난 Ingress: shop 은 pathType Exact, blog 는 없는 포트 이름(http)을 참조
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sites
  namespace: oberon
spec:
  ingressClassName: nginx
  rules:
  - host: shop.b16.example
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: shop
            port:
              name: http
  - host: blog.b16.example
    http:
      paths:
      - path: /posts
        pathType: Prefix
        backend:
          service:
            name: blog
            port:
              name: http
YAML

# 4) 시작 상태 확인
sleep 5
kubectl -n oberon get deploy,svc,ingress
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Ingress 컨트롤러 주소: http://$NODE:$NP"

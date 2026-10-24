#!/usr/bin/env bash
# c16 — Serve an Ingress through the right IngressClass · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Ingress 컨트롤러: F5 NGINX Ingress Controller v5.6.3 (IngressClass nginx, Service 는 NodePort)
#    은퇴한 ingress-nginx 가 아니라 nginx/kubernetes-ingress 다. 이미 설치돼 있으면 그대로 넘어간다.
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/deployment/nginx-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/service/nodeport.yaml
kubectl -n nginx-ingress rollout status deploy nginx-ingress --timeout=180s

# 2) 이전 실습 흔적 정리: namespace, 두 번째 IngressClass, nginx 클래스의 default 어노테이션
kubectl delete ns sequoia --ignore-not-found --wait=true
kubectl delete ingressclass c16-legacy --ignore-not-found
kubectl annotate ingressclass nginx ingressclass.kubernetes.io/is-default-class- >/dev/null 2>&1 || true
rm -rf /opt/course/c16
mkdir -p /opt/course/c16

# 3) 컨트롤러가 없는 두 번째 IngressClass
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: c16-legacy
spec:
  controller: example.com/c16-legacy-controller
YAML

# 4) 백엔드와, 클래스가 없는 Ingress (default 클래스가 없을 때 만들어서 클래스가 비어 있다)
kubectl create ns sequoia
kubectl -n sequoia create deploy menu --image=hashicorp/http-echo:1.0 -- /http-echo -text=menu
kubectl -n sequoia expose deploy menu --port=80 --target-port=5678
kubectl -n sequoia rollout status deploy menu --timeout=120s
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: menu
  namespace: sequoia
spec:
  rules:
  - host: menu.c16.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: menu
            port:
              number: 80
YAML

# 5) 시작 상태 확인
kubectl get ingressclass
kubectl -n sequoia get ingress menu

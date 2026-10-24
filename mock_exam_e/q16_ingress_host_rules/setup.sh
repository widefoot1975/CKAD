#!/usr/bin/env bash
# e16 — Route two hosts with one Ingress · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) Ingress 컨트롤러: F5 NGINX Ingress Controller v5.6.3 (IngressClass nginx, Service 는 NodePort)
#    은퇴한 ingress-nginx 가 아니라 nginx/kubernetes-ingress 다. 이미 설치돼 있으면 그대로 넘어간다.
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/deployment/nginx-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/service/nodeport.yaml
kubectl -n nginx-ingress rollout status deploy nginx-ingress --timeout=180s

# 1) 이전 실습 흔적 정리
kubectl delete ns citrine --ignore-not-found --wait=true
rm -rf /opt/course/e16

# 2) namespace 와 두 백엔드 (http-echo 5678 → Service 80)
kubectl create ns citrine
mkdir -p /opt/course/e16
kubectl -n citrine create deploy shop --image=hashicorp/http-echo:1.0 --port=5678 -- /http-echo -text=shop
kubectl -n citrine create deploy blog --image=hashicorp/http-echo:1.0 --port=5678 -- /http-echo -text=blog
kubectl -n citrine expose deploy shop --name=shop-svc --port=80 --target-port=5678
kubectl -n citrine expose deploy blog --name=blog-svc --port=80 --target-port=5678
kubectl -n citrine rollout status deploy shop --timeout=120s
kubectl -n citrine rollout status deploy blog --timeout=120s

# 3) 시작 상태 확인: IngressClass nginx 가 있고 citrine 에는 Ingress 가 없다
kubectl get ingressclass
kubectl -n citrine get deploy,svc,ingress

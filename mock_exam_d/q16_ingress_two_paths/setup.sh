#!/usr/bin/env bash
# d16 — Route two paths with an Ingress · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns hawk --ignore-not-found --wait=true
rm -rf /opt/course/d16

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

# 2) namespace 와 백엔드 두 개: 어떤 경로든 "shop"/"blog" 를 응답하는 http-echo (컨테이너 포트 5678) → Service :80
kubectl create ns hawk
for app in shop blog; do
  kubectl -n hawk create deploy "$app" --image=hashicorp/http-echo:1.0 -- /http-echo -text="$app"
  kubectl -n hawk expose deploy "$app" --name="$app-svc" --port=80 --target-port=5678
done
kubectl -n hawk rollout status deploy shop --timeout=180s
kubectl -n hawk rollout status deploy blog --timeout=180s

# 3) 답안 디렉터리
mkdir -p /opt/course/d16

# 4) 시작 상태 확인: IngressClass nginx 가 있고 hawk 에는 Ingress 가 없다
kubectl get ingressclass
kubectl -n hawk get deploy,svc,ingress

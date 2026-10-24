#!/usr/bin/env bash
# f16 — Repair a broken Ingress · 사전 환경 설정
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
kubectl delete ns tagus --ignore-not-found --wait=true
rm -rf /opt/course/f16

# 2) namespace 와 답안 디렉터리
kubectl create ns tagus
mkdir -p /opt/course/f16

# 3) 백엔드: http-echo (컨테이너 포트 5678) → Service docs:8080
kubectl -n tagus create deploy docs --image=hashicorp/http-echo:1.0 -- /http-echo -text=docs
kubectl -n tagus expose deploy docs --name=docs --port=8080 --target-port=5678
kubectl -n tagus rollout status deploy docs --timeout=120s

# 4) 고장 낸 Ingress: ingressClassName 없음, 백엔드 포트 80 (Service 에 없는 포트)
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: docs
  namespace: tagus
spec:
  rules:
  - host: docs.tagus.local
    http:
      paths:
      - path: /docs
        pathType: Prefix
        backend:
          service:
            name: docs
            port:
              number: 80
YAML
#    클러스터에 기본 IngressClass 가 있으면 생성 시 ingressClassName 이 자동으로 채워진다 → 고장 상태를 위해 지운다
if [ -n "$(kubectl -n tagus get ingress docs -o jsonpath='{.spec.ingressClassName}')" ]; then
  kubectl -n tagus patch ingress docs --type=json -p='[{"op":"remove","path":"/spec/ingressClassName"}]'
fi

# 5) 시작 상태 확인: Ingress CLASS 가 <none>, Service docs 는 8080
kubectl get ingressclass
kubectl -n tagus get deploy,svc,ingress

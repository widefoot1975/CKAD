#!/usr/bin/env bash
# a16 — TLS Ingress with two paths and a default backend · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) openssl 확인
command -v openssl >/dev/null || { echo "openssl 이 필요하다"; exit 1; }

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

# 2) 이전 실습 흔적 정리 후 namespace pi
kubectl delete ns pi --ignore-not-found --wait=true
rm -rf /opt/course/a16
kubectl create ns pi

# 3) 백엔드 세 개: 어떤 경로든 자기 이름을 돌려주는 http-echo (5678) → Service :80
for s in web api fallback; do
  kubectl -n pi create deploy store-$s --image=hashicorp/http-echo:1.0 -- /http-echo -text=$s
  kubectl -n pi expose deploy store-$s --port=80 --target-port=5678
done
for s in web api fallback; do
  kubectl -n pi rollout status deploy store-$s --timeout=120s
done

# 4) 자체 서명 인증서 (CN·SAN = store.a16.test). Secret 은 문제에서 직접 만든다
mkdir -p /opt/course/a16
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /opt/course/a16/tls.key -out /opt/course/a16/tls.crt \
  -subj "/CN=store.a16.test" -addext "subjectAltName=DNS:store.a16.test" 2>/dev/null

# 5) 시작 상태 확인: Service 3개, 인증서 파일 2개, Secret·Ingress 없음
kubectl get ingressclass
kubectl -n pi get deploy,svc,secret,ingress
ls -l /opt/course/a16/

#!/usr/bin/env bash
# a11 — ServiceAccount with least-privilege RBAC · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns lambda --ignore-not-found --wait=true
rm -rf /opt/course/a11

# 1) namespace 와 ServiceAccount (토큰 자동 마운트를 끈 SA)
kubectl create ns lambda
mkdir -p /opt/course/a11
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deployer
  namespace: lambda
automountServiceAccountToken: false
YAML

# 2) Deployment 초안 (serviceAccountName / automountServiceAccountToken 없음, 적용하지 않는다)
cat > /opt/course/a11/deploy-bot.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-bot
  namespace: lambda
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deploy-bot
  template:
    metadata:
      labels:
        app: deploy-bot
    spec:
      containers:
      - name: bot
        image: curlimages/curl:8.10.1
        command:
        - sh
        - -c
        - |
          SA_DIR=/var/run/secrets/kubernetes.io/serviceaccount
          while true; do
            TOKEN=$(cat $SA_DIR/token 2>/dev/null)
            CODE=$(curl -s -o /dev/null -w '%{http_code}' --cacert $SA_DIR/ca.crt \
              -H "Authorization: Bearer $TOKEN" \
              https://kubernetes.default.svc/apis/apps/v1/namespaces/lambda/deployments)
            echo "list deployments: $CODE"
            sleep 10
          done
YAML

# 3) 시작 상태 확인
kubectl -n lambda get sa deployer -o jsonpath='{.metadata.name} automount={.automountServiceAccountToken}{"\n"}'
kubectl -n lambda get role,rolebinding,deploy
ls -l /opt/course/a11/

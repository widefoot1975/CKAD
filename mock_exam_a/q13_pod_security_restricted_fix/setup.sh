#!/usr/bin/env bash
# a13 — Make a Deployment pass Pod Security restricted · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns nu --ignore-not-found --wait=true
rm -rf /opt/course/a13

# 1) restricted 를 강제하는 namespace
kubectl create ns nu
kubectl label ns nu \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/warn-version=latest
mkdir -p /opt/course/a13

# 2) 고장 내기: securityContext 없는 root 이미지 → 모든 Pod 가 admission 에서 거부된다
#    (warn 라벨 때문에 apply 시 경고가 출력되는 것은 정상)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portal
  namespace: nu
spec:
  replicas: 2
  selector:
    matchLabels:
      app: portal
  template:
    metadata:
      labels:
        app: portal
    spec:
      containers:
      - name: portal
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
YAML

# 3) ReplicaSet 이 FailedCreate 이벤트를 남길 때까지 잠시 기다린다
for i in $(seq 1 20); do
  kubectl -n nu get events --field-selector reason=FailedCreate 2>/dev/null | grep -q FailedCreate && break
  sleep 2
done

# 4) 시작 상태 확인: READY 0/2, 파드 없음
kubectl get ns nu --show-labels
kubectl -n nu get deploy,rs,pod

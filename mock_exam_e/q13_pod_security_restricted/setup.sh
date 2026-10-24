#!/usr/bin/env bash
# e13 — Admit a pod under the restricted Pod Security level · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns beryl --ignore-not-found --wait=true
rm -rf /opt/course/e13

# 1) restricted 를 강제하는 namespace
kubectl create ns beryl
kubectl label ns beryl \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest

# 2) securityContext 가 없는 매니페스트 (이대로는 거부된다)
mkdir -p /opt/course/e13
cat > /opt/course/e13/secure-app.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: beryl
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date; sleep 10; done"]
YAML

# 3) 시작 상태 확인: 라벨이 있고 파드는 없다
kubectl get ns beryl --show-labels
kubectl -n beryl get pods

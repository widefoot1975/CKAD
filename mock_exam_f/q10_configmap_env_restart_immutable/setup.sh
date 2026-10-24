#!/usr/bin/env bash
# f10 — Roll out a ConfigMap change and lock it · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (immutable ConfigMap 도 namespace 째 지우면 사라진다)
kubectl delete ns ganges --ignore-not-found --wait=true
rm -rf /opt/course/f10

# 1) namespace 와 답안 디렉터리
kubectl create ns ganges
mkdir -p /opt/course/f10

# 2) ConfigMap app-config 와, 그것을 envFrom 으로 읽는 Deployment reporter
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: ganges
data:
  LOG_LEVEL: info
  REGION: eu-west
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reporter
  namespace: ganges
spec:
  replicas: 2
  selector:
    matchLabels:
      app: reporter
  template:
    metadata:
      labels:
        app: reporter
    spec:
      containers:
      - name: reporter
        image: busybox:1.36
        command: ["sh", "-c", "echo \"start LOG_LEVEL=$LOG_LEVEL REGION=$REGION\"; sleep 86400"]
        envFrom:
        - configMapRef:
            name: app-config
YAML
kubectl -n ganges rollout status deploy reporter --timeout=120s

# 3) 시작 상태 확인: Pod 의 LOG_LEVEL 은 info, ConfigMap 은 immutable 아님
kubectl -n ganges get cm app-config -o jsonpath='{.data}{" immutable="}{.immutable}{"\n"}'
kubectl -n ganges exec deploy/reporter -- printenv LOG_LEVEL

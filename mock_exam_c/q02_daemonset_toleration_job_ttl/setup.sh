#!/usr/bin/env bash
# c02 — Run an agent on every node and a self-cleaning Job · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns pine --ignore-not-found --wait=true
rm -rf /opt/course/c02
mkdir -p /opt/course/c02

# 1) 잘못 고른 워크로드: 노드마다 하나씩 떠야 하는 에이전트가 Deployment(replicas 2)로 되어 있다
kubectl create ns pine
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-agent
  namespace: pine
  labels:
    app: node-agent
spec:
  replicas: 2
  selector:
    matchLabels:
      app: node-agent
  template:
    metadata:
      labels:
        app: node-agent
        tier: monitoring
    spec:
      containers:
      - name: agent
        image: busybox:1.36
        command: ["sh", "-c", "echo agent running on $NODE_NAME; while true; do sleep 3600; done"]
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
YAML
kubectl -n pine rollout status deploy node-agent --timeout=120s

# 2) 시작 상태 확인: 노드 수와 상관없이 파드가 2개, control-plane 의 taint
kubectl get nodes
kubectl describe nodes | grep -E '^Name:|^Taints:'
kubectl -n pine get deploy,pod -o wide

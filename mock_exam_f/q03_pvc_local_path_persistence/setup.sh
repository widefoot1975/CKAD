#!/usr/bin/env bash
# f03 — Persist data with a PersistentVolumeClaim · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 동적 프로비저너: local-path provisioner (StorageClass local-path). 이미 있으면 그대로 넘어간다
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 1) 이전 실습 흔적 정리 (namespace 를 지우면 PVC 가 지워지고, reclaimPolicy Delete 라 PV 도 정리된다)
kubectl delete ns nile --ignore-not-found --wait=true
rm -rf /opt/course/f03

# 2) namespace 와 답안 디렉터리
kubectl create ns nile
mkdir -p /opt/course/f03

# 3) 시작 상태 확인: StorageClass local-path 가 있고, nile 에는 PVC/Pod 가 없다
kubectl get storageclass local-path
kubectl -n nile get pvc,pod

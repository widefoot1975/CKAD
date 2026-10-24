#!/usr/bin/env bash
# b03 — Memory-backed and generic ephemeral volumes · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns venus --ignore-not-found --wait=true
rm -rf /opt/course/b03

# 1) local-path provisioner (공용 인프라, 이미 있으면 그대로 둔다)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 네임스페이스와 답안 디렉터리
kubectl create ns venus
mkdir -p /opt/course/b03

# 3) 시작 상태 확인: StorageClass local-path 가 있고 venus 는 비어 있다
kubectl get storageclass local-path
kubectl -n venus get pod,pvc

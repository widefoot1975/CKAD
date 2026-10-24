#!/usr/bin/env bash
# e02 — Run a log agent on every worker node · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns sapphire --ignore-not-found --wait=true
rm -rf /opt/course/e02

# 1) 빈 namespace 와 결과 파일 디렉터리
kubectl create ns sapphire
mkdir -p /opt/course/e02

# 2) 시작 상태 확인: 노드 목록(taint 포함)과, sapphire 에 DaemonSet 이 없음
kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints[*].key'
kubectl -n sapphire get ds,pods

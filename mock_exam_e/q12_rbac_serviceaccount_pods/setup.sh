#!/usr/bin/env bash
# e12 — Let a ServiceAccount list pods · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns agate --ignore-not-found --wait=true
rm -rf /opt/course/e12

# 1) namespace, ServiceAccount, 확인용 파드 하나
kubectl create ns agate
mkdir -p /opt/course/e12
kubectl -n agate create serviceaccount pod-watcher
kubectl -n agate run sample --image=registry.k8s.io/pause:3.10

# 2) 시작 상태 확인: SA 는 있고 Role/RoleBinding 은 없다, 아직 권한 없음(no)
kubectl -n agate get sa,role,rolebinding
kubectl auth can-i list pods -n agate --as=system:serviceaccount:agate:pod-watcher || true

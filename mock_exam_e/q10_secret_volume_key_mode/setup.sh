#!/usr/bin/env bash
# e10 — Mount one Secret key as a read-only file · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns pearl --ignore-not-found --wait=true
rm -rf /opt/course/e10

# 1) namespace 와 Secret (키 3개)
kubectl create ns pearl
mkdir -p /opt/course/e10
kubectl -n pearl create secret generic db-creds \
  --from-literal=username=app \
  --from-literal=password=s3cr3t-pearl \
  --from-literal=host=db.pearl.svc.cluster.local

# 2) 시작 상태 확인: Secret 은 있고 파드는 없다
kubectl -n pearl describe secret db-creds | sed -n '/Data/,$p'
kubectl -n pearl get pods

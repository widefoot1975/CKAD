#!/usr/bin/env bash
# b15 — StatefulSet pod DNS through a headless Service · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns triton --ignore-not-found --wait=true
rm -rf /opt/course/b15

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns triton
mkdir -p /opt/course/b15

# 2) 고장 내기: Service 는 ClusterIP(headless 아님), StatefulSet 은 없는 Service 이름을 가리킨다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kvstore
  namespace: triton
  labels:
    app: kvstore
spec:
  selector:
    app: kvstore
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kvstore
  namespace: triton
  labels:
    app: kvstore
spec:
  serviceName: kvstore-headless
  replicas: 3
  selector:
    matchLabels:
      app: kvstore
  template:
    metadata:
      labels:
        app: kvstore
    spec:
      containers:
      - name: redis
        image: redis:7.4-alpine
        ports:
        - name: redis
          containerPort: 6379
YAML

kubectl -n triton rollout status sts kvstore --timeout=240s

# 3) 시작 상태 확인: 파드 3개 Running, 파드별 DNS 는 실패
kubectl -n triton get sts,pod,svc
kubectl -n triton run b15-probe --image=busybox:1.36 --restart=Never --rm -i -- \
  nslookup kvstore-0.kvstore.triton.svc.cluster.local || echo "kvstore-0.kvstore 조회 실패 (정상: 고장 난 상태)"

#!/usr/bin/env bash
# c12 — QoS classes under a LimitRange · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns hazel --ignore-not-found --wait=true
rm -rf /opt/course/c12
mkdir -p /opt/course/c12

# 1) resources 없는 파드 세 개 (지금은 모두 BestEffort)
kubectl create ns hazel
for p in be bu gu; do
cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $p
  namespace: hazel
  labels:
    app: qos-demo
spec:
  containers:
  - name: app
    image: registry.k8s.io/pause:3.10
YAML
done
kubectl -n hazel wait --for=condition=Ready pod/be pod/bu pod/gu --timeout=90s

# 2) 파드가 생긴 뒤에 LimitRange 추가 — 이미 있는 파드에는 영향이 없고, 새로 만드는 파드에만 적용된다
#    max 만 주면 API 기본값 처리로 default(limit) 와 defaultRequest 가 max 값으로 채워진다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: hazel-limits
  namespace: hazel
spec:
  limits:
  - type: Container
    max:
      cpu: 500m
      memory: 256Mi
YAML

# 3) 시작 상태 확인
kubectl -n hazel get pod -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
kubectl -n hazel describe limitrange hazel-limits

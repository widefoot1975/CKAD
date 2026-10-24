#!/usr/bin/env bash
# a12 — Fit a Deployment into a ResourceQuota and LimitRange · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns mu --ignore-not-found --wait=true
rm -rf /opt/course/a12

# 1) namespace, 결과 디렉터리, 정책 (Quota 합계 1 CPU / 1Gi, 컨테이너당 max 300m / 300Mi)
kubectl create ns mu
mkdir -p /opt/course/a12
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mu-quota
  namespace: mu
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "1"
    limits.memory: 1Gi
    pods: "6"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: mu-limits
  namespace: mu
spec:
  limits:
  - type: Container
    max:
      cpu: 300m
      memory: 300Mi
    default:
      cpu: 300m
      memory: 300Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
YAML

# 2) 고장 내기: limit 이 LimitRange max 를 넘어 Pod 가 admission 에서 모두 거부된다
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: mu
spec:
  replicas: 4
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - name: worker
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo working; sleep 30; done"]
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
YAML

# 3) ReplicaSet 이 FailedCreate 이벤트를 남길 때까지 잠시 기다린다
for i in $(seq 1 20); do
  kubectl -n mu get events --field-selector reason=FailedCreate 2>/dev/null | grep -q FailedCreate && break
  sleep 2
done

# 4) 시작 상태 확인: READY 0/4, 파드 없음
kubectl -n mu get quota,limitrange,deploy,rs,pod

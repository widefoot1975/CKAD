#!/usr/bin/env bash
# f09 — Read logs from a multi-container Pod · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns mekong --ignore-not-found --wait=true
rm -rf /opt/course/f09

# 1) namespace 와 답안 디렉터리
kubectl create ns mekong
mkdir -p /opt/course/f09

# 2) 컨테이너 두 개짜리 Pod shipper: app 은 2초마다, audit 은 5초마다 한 줄씩 로그를 쓴다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: shipper
  namespace: mekong
  labels:
    app: shipper
spec:
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=1
      while true; do
        echo "app: order $i processed"
        i=$((i+1))
        sleep 2
      done
  - name: audit
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=1
      while true; do
        echo "audit: check $i ok"
        i=$((i+1))
        sleep 5
      done
YAML
kubectl -n mekong wait pod shipper --for=condition=Ready --timeout=120s

# 3) 로그가 충분히 쌓이도록 40초 기다린다 (audit 8줄 이상, app 20줄 이상)
sleep 40

# 4) 시작 상태 확인
kubectl -n mekong get pod shipper
kubectl -n mekong get pod shipper -o jsonpath='{.spec.containers[*].name}{"\n"}'

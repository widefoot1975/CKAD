#!/usr/bin/env bash
# d14 — Harden a Pod with a securityContext · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns lark --ignore-not-found --wait=true
rm -rf /opt/course/d14

# 1) namespace
kubectl create ns lark

# 2) 문제에서 고칠 매니페스트 (securityContext·볼륨 없음, /tmp 에 계속 기록)
mkdir -p /opt/course/d14
cat <<'YAML' > /opt/course/d14/lark-secure.yaml
apiVersion: v1
kind: Pod
metadata:
  name: lark-secure
  namespace: lark
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /tmp/heartbeat.log; sleep 10; done"]
YAML

# 3) 시작 상태 확인: 파일만 있고 파드는 없다
cat /opt/course/d14/lark-secure.yaml
kubectl -n lark get pod

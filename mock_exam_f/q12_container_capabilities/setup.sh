#!/usr/bin/env bash
# f12 — Grant a single Linux capability · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns tigris --ignore-not-found --wait=true
rm -rf /opt/course/f12

# 1) namespace 와 답안 디렉터리
kubectl create ns tigris
mkdir -p /opt/course/f12

# 2) 후보자가 고칠 Pod 매니페스트 (securityContext 없음, 아직 적용하지 않는다)
cat <<'YAML' > /opt/course/f12/netadmin.yaml
apiVersion: v1
kind: Pod
metadata:
  name: netadmin
  namespace: tigris
  labels:
    app: netadmin
spec:
  containers:
  - name: tool
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
YAML

# 3) 시작 상태 확인: 매니페스트 파일만 있고 Pod 는 없다
ls -l /opt/course/f12/
kubectl -n tigris get pod

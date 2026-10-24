#!/usr/bin/env bash
# e03 — Tail an application log with a native sidecar · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns emerald --ignore-not-found --wait=true
rm -rf /opt/course/e03

# 1) namespace 와 작업 디렉터리
kubectl create ns emerald
mkdir -p /opt/course/e03

# 2) 고칠 매니페스트: 앱은 로그를 파일에만 쓴다 (사이드카 없음, 아직 적용하지 않는다)
cat > /opt/course/e03/web-app.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  namespace: emerald
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "i=0; while true; do echo \"$(date) request $i\" >> /var/log/app/app.log; i=$((i+1)); sleep 2; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
  volumes:
  - name: logs
    emptyDir: {}
YAML

# 3) 시작 상태 확인: 파일은 있고 파드는 없다
kubectl apply --dry-run=server -f /opt/course/e03/web-app.yaml
kubectl -n emerald get pods

#!/usr/bin/env bash
# c13 — SecurityContext precedence and a read-only root filesystem · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns poplar --ignore-not-found --wait=true
rm -rf /opt/course/c13
mkdir -p /opt/course/c13

# 1) 고장 난 시작 상태: 루트 파일시스템이 읽기 전용인데 nginx 가 쓸 곳(/tmp)이 없다
kubectl create ns poplar
cat > /opt/course/c13/secure-web.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: secure-web
  namespace: poplar
  labels:
    app: secure-web
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    runAsNonRoot: true
  containers:
  - name: web
    image: nginxinc/nginx-unprivileged:1.27-alpine
    ports:
    - containerPort: 8080
    securityContext:
      readOnlyRootFilesystem: true
  - name: helper
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
YAML
kubectl apply -f /opt/course/c13/secure-web.yaml

# 2) web 이 한 번 이상 재시작할 때까지 기다린다
for i in $(seq 1 60); do
  RC=$(kubectl -n poplar get pod secure-web -o jsonpath='{.status.containerStatuses[?(@.name=="web")].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 시작 상태 확인
kubectl -n poplar get pod secure-web
kubectl -n poplar logs secure-web -c web --previous --tail=3 2>/dev/null || true

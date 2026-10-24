#!/usr/bin/env bash
# e07 — Add startup and liveness probes to a slow app · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns onyx --ignore-not-found --wait=true
rm -rf /opt/course/e07

# 1) namespace 와 매니페스트: 기동 40초, 그 뒤 /tmp/started 생성 + :8080/healthz 서비스 (probe 없음)
kubectl create ns onyx
mkdir -p /opt/course/e07
cat > /opt/course/e07/slow-app.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: slow-app
  namespace: onyx
  labels:
    app: slow-app
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "echo booting; sleep 40; mkdir -p /www; echo ok > /www/healthz; touch /tmp/started; echo started; exec httpd -f -p 8080 -h /www"]
    ports:
    - containerPort: 8080
YAML

# 2) 현재 상태의 파드를 띄운다 (probe 가 없어서 기동 중에도 바로 Ready 로 보인다)
kubectl apply -f /opt/course/e07/slow-app.yaml
kubectl -n onyx wait --for=condition=Ready pod/slow-app --timeout=90s

# 3) 시작 상태 확인: probe 가 없다
kubectl -n onyx get pod slow-app
kubectl -n onyx get pod slow-app -o jsonpath='{.spec.containers[0].startupProbe}{.spec.containers[0].livenessProbe}{"\n"}'
echo "(위 줄이 비어 있으면 probe 없음 — 정상)"

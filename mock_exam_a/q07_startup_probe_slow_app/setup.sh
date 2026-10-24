#!/usr/bin/env bash
# a07 — Rescue a slow-starting app with a startupProbe · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns eta --ignore-not-found --wait=true
rm -rf /opt/course/a07

# 1) namespace 와 결과 디렉터리
kubectl create ns eta
mkdir -p /opt/course/a07

# 2) 고장 내기: 시작에 45초 걸리는 앱 + 15초 만에 죽이는 liveness + 포트가 틀린 readiness
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: eta
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      terminationGracePeriodSeconds: 5
      containers:
      - name: ledger
        image: python:3.12-alpine
        command:
        - sh
        - -c
        - |
          echo "ledger: warming up caches (about 45s)"
          sleep 45
          mkdir -p /srv && echo ok > /srv/healthz
          echo "ledger: listening on 8080"
          exec python -m http.server 8080 -d /srv
        ports:
        - name: http
          containerPort: 8080
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 2
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8000
          periodSeconds: 5
YAML

# 3) 한 번 이상 재시작할 때까지 기다린다 (그래야 --previous 로그와 Killing 이벤트가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n eta get pod -l app=ledger -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 4) 시작 상태 확인: READY 0/1, RESTARTS 1 이상
kubectl -n eta get pod -l app=ledger

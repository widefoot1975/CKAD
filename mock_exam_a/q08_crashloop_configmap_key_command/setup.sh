#!/usr/bin/env bash
# a08 — Debug a CrashLoopBackOff Deployment · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns theta --ignore-not-found --wait=true
rm -rf /opt/course/a08

# 1) namespace 와 결과 디렉터리
kubectl create ns theta
mkdir -p /opt/course/a08

# 2) 올바른 ConfigMap 두 개 + 고장 두 겹인 Deployment
#    고장 1: command 경로 /script (마운트는 /scripts)
#    고장 2: env 가 없는 키 db-url 을 optional:true 로 참조 (실제 키는 database-url)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: billing-config
  namespace: theta
data:
  database-url: postgres://billing@db.theta.svc:5432/billing
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: billing-scripts
  namespace: theta
data:
  run.sh: |
    echo "billing starting"
    if [ -z "$DB_URL" ]; then
      echo "FATAL: DB_URL is empty" >&2
      exit 1
    fi
    echo "connected to $DB_URL"
    while true; do sleep 3600; done
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: billing
  namespace: theta
spec:
  replicas: 2
  selector:
    matchLabels:
      app: billing
  template:
    metadata:
      labels:
        app: billing
    spec:
      terminationGracePeriodSeconds: 5
      containers:
      - name: billing
        image: busybox:1.36
        command: ["sh", "/script/run.sh"]
        env:
        - name: DB_URL
          valueFrom:
            configMapKeyRef:
              name: billing-config
              key: db-url
              optional: true
        volumeMounts:
        - name: scripts
          mountPath: /scripts
      volumes:
      - name: scripts
        configMap:
          name: billing-scripts
YAML

# 3) 한 번 이상 재시작할 때까지 기다린다 (그래야 --previous 로그와 BackOff 이벤트가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n theta get pod -l app=billing -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 4) 시작 상태 확인: CrashLoopBackOff 또는 Error, RESTARTS 1 이상
kubectl -n theta get cm,deploy,pod

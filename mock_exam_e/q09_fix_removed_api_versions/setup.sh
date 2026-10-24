#!/usr/bin/env bash
# e09 — Repair manifests that use removed API versions · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns amber --ignore-not-found --wait=true
rm -rf /opt/course/e09

# 1) namespace 와 오래된 매니페스트 (apps/v1beta1 Deployment 에 selector 없음, batch/v1beta1 CronJob)
kubectl create ns amber
mkdir -p /opt/course/e09
cat > /opt/course/e09/legacy.yaml <<'YAML'
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: ledger
  namespace: amber
  labels:
    app: ledger
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
      - name: ledger
        image: nginx:1.27-alpine
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: ledger-cleanup
  namespace: amber
spec:
  schedule: "*/10 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "echo cleaning ledger"]
YAML

# 2) 시작 상태 확인: 이 파일은 지금 적용되지 않는다 (서버 dry-run 으로만 확인, 아무것도 만들지 않음)
kubectl apply --dry-run=server -f /opt/course/e09/legacy.yaml 2>&1 | sed 's/^/  /' || true
kubectl -n amber get deploy,cronjob

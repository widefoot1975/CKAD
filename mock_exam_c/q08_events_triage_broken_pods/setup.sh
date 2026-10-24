#!/usr/bin/env bash
# c08 — Triage several broken Pods from events · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns elm --ignore-not-found --wait=true
rm -rf /opt/course/c08
mkdir -p /opt/course/c08

kubectl create ns elm

# 1) 고장 세 가지
#    catalog : 이미지 태그 오타          → ErrImagePull / ImagePullBackOff
#    payments: 없는 Secret 의 키를 env 로 → CreateContainerConfigError
#    reports : 명령 오타(slep)           → exit 127, CrashLoopBackOff
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: catalog
  namespace: elm
  labels:
    app: catalog
spec:
  containers:
  - name: web
    image: nginx:1.27-alpnie
---
apiVersion: v1
kind: Pod
metadata:
  name: payments
  namespace: elm
  labels:
    app: payments
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "echo payments up; while true; do sleep 3600; done"]
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: payments-db
          key: password
---
apiVersion: v1
kind: Pod
metadata:
  name: reports
  namespace: elm
  labels:
    app: reports
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "slep 3600"]
YAML

# 2) 상태가 자리 잡을 때까지 기다린다: reports 가 한 번 이상 재시작, catalog 가 pull 실패
for i in $(seq 1 60); do
  RC=$(kubectl -n elm get pod reports -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  CR=$(kubectl -n elm get pod catalog -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || true)
  if [ "${RC:-0}" -ge 1 ] && [ -n "$CR" ] && [ "$CR" != "ContainerCreating" ]; then break; fi
  sleep 3
done

# 3) 시작 상태 확인
kubectl -n elm get pods
kubectl -n elm get secret payments-db 2>/dev/null || echo "Secret payments-db 없음 (정상)"

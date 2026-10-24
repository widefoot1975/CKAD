#!/usr/bin/env bash
# d09 — Read the logs of a crashed container · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns wren --ignore-not-found --wait=true
rm -rf /opt/course/d09

# 1) 고장 내기: 시작 로그를 찍고 8초 살아 있다가 ERROR 한 줄을 남기고 exit 3 으로 죽는다
kubectl create ns wren
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: wren-worker
  namespace: wren
  labels:
    app: wren-worker
spec:
  restartPolicy: Always
  containers:
  - name: worker
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      echo "wren-worker 2.3 starting"
      echo "reading queue settings"
      sleep 8
      echo "ERROR: queue redis-queue:6379 unreachable (connection refused)"
      exit 3
YAML

# 2) 한 번 이상 재시작할 때까지 기다린다 (그래야 lastState 와 --previous 로그가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n wren get pod wren-worker -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 답안 디렉터리
mkdir -p /opt/course/d09

# 4) 시작 상태 확인: RESTARTS 1 이상
kubectl -n wren get pod wren-worker

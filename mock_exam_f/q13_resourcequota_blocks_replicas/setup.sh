#!/usr/bin/env bash
# f13 — ResourceQuota blocks Deployment replicas · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns loire --ignore-not-found --wait=true
rm -rf /opt/course/f13

# 1) namespace 와 답안 디렉터리
kubectl create ns loire
mkdir -p /opt/course/f13

# 2) ResourceQuota 를 먼저 만든다: requests.cpu 1 (=1000m)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: loire-quota
  namespace: loire
spec:
  hard:
    pods: "10"
    requests.cpu: "1"
    requests.memory: 1Gi
YAML

# 3) Deployment worker: 4 replicas × requests.cpu 400m = 1600m → 2개만 만들어진다
#    전략은 Recreate (작업 큐 소비자라 버전이 섞이면 안 되는 앱)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: loire
spec:
  replicas: 4
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      terminationGracePeriodSeconds: 5
      containers:
      - name: worker
        image: busybox:1.36
        command: ["sh", "-c", "while true; do sleep 30; done"]
        resources:
          requests:
            cpu: 400m
            memory: 64Mi
YAML

# 4) Pod 2개가 Ready 가 되고 ReplicaSet 에 FailedCreate 이벤트가 생길 때까지 기다린다
for i in $(seq 1 60); do
  READY=$(kubectl -n loire get deploy worker -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)
  EV=$(kubectl -n loire get events --field-selector reason=FailedCreate -o name 2>/dev/null | wc -l)
  [ "${READY:-0}" -ge 2 ] && [ "$EV" -ge 1 ] && break
  sleep 2
done

# 5) 시작 상태 확인: READY 2/4
kubectl -n loire get deploy,rs,pod
kubectl -n loire get resourcequota

#!/usr/bin/env bash
# b08 — Debug a container that has no shell · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns pluto --ignore-not-found --wait=true
rm -rf /opt/course/b08

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns pluto
mkdir -p /opt/course/b08

# 2) 고장 내기: 셸 없는 http-echo 가 루프백(127.0.0.1)에서만 듣는다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ledger
  namespace: pluto
  labels:
    app: ledger
spec:
  containers:
  - name: app
    image: hashicorp/http-echo:1.0
    args: ["-listen=127.0.0.1:8080", "-text=ledger-ok"]
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: ledger
  namespace: pluto
spec:
  selector:
    app: ledger
  ports:
  - name: http
    port: 80
    targetPort: 8080
YAML

kubectl -n pluto wait pod ledger --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: 파드는 Running, Service 로는 연결 거부
kubectl -n pluto get pod,svc
kubectl -n pluto run b08-probe --image=curlimages/curl:8.10.1 --restart=Never --rm -i \
  -- -s -m 3 http://ledger/ || echo "Service ledger 접속 실패 (정상: 고장 난 상태)"

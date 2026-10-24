#!/usr/bin/env bash
# b09 — Find a memory hog and an OOMKilled container · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns titan europa --ignore-not-found --wait=true
rm -rf /opt/course/b09

# 1) metrics-server (공용 인프라, 이미 있으면 그대로)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) 네임스페이스와 답안 디렉터리
kubectl create ns titan
kubectl create ns europa
mkdir -p /opt/course/b09

# 3) 워크로드: 메모리를 정해진 양만큼 실제로 채우는 파드들
#    ingest-buffer ≈ 200MB, report-gen ≈ 100MB, thumbnailer/resize 는 48MB 를 쓰는데 limit 이 32Mi → OOMKilled
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ingest-buffer
  namespace: titan
  labels:
    app: ingest-buffer
spec:
  containers:
  - name: buffer
    image: python:3.12-alpine
    command: ["python3", "-c", "import time; b=b'x'*(200*1024*1024); print('buffer filled', flush=True); time.sleep(86400)"]
    resources:
      requests:
        memory: 64Mi
      limits:
        memory: 512Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: gateway
  namespace: titan
  labels:
    app: gateway
spec:
  containers:
  - name: web
    image: nginx:1.27-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: report-gen
  namespace: europa
  labels:
    app: report-gen
spec:
  containers:
  - name: report
    image: python:3.12-alpine
    command: ["python3", "-c", "import time; b=b'x'*(100*1024*1024); print('report cache ready', flush=True); time.sleep(86400)"]
    resources:
      requests:
        memory: 64Mi
      limits:
        memory: 256Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: thumbnailer
  namespace: europa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: thumbnailer
  template:
    metadata:
      labels:
        app: thumbnailer
    spec:
      containers:
      - name: fetch
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo fetching; sleep 30; done"]
        resources:
          requests:
            memory: 16Mi
          limits:
            memory: 64Mi
      - name: resize
        image: python:3.12-alpine
        command: ["python3", "-c", "import time; print('loading model (48MB)', flush=True); b=b'x'*(48*1024*1024); print('model loaded', flush=True); time.sleep(86400)"]
        resources:
          requests:
            memory: 16Mi
          limits:
            memory: 32Mi
YAML

kubectl -n titan wait pod --all --for=condition=Ready --timeout=180s
kubectl -n europa wait pod report-gen --for=condition=Ready --timeout=180s

# 4) resize 컨테이너가 한 번 이상 OOMKilled 로 재시작할 때까지 기다린다
for i in $(seq 1 60); do
  RC=$(kubectl -n europa get pods -l app=thumbnailer \
       -o jsonpath='{.items[0].status.containerStatuses[?(@.name=="resize")].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 5) 첫 메트릭 수집까지 기다렸다가 시작 상태 확인
for i in $(seq 1 30); do
  kubectl top pod -n titan >/dev/null 2>&1 && break
  sleep 5
done
kubectl get pods -n titan
kubectl get pods -n europa
kubectl top pod -n titan || true

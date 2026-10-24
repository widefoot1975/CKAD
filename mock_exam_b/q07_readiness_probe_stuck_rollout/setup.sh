#!/usr/bin/env bash
# b07 — Unblock a rollout gated by a readiness probe · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns neptune --ignore-not-found --wait=true
rm -rf /opt/course/b07

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns neptune
mkdir -p /opt/course/b07

# 2) v1·v2 nginx 설정 (v1 헬스: /healthz, v2 헬스: /ready, 둘 다 X-Probe: kubelet 헤더 필요)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: catalog-v1
  namespace: neptune
data:
  default.conf: |
    server {
        listen 8080;
        location = / {
            default_type text/plain;
            return 200 "catalog v1\n";
        }
        location = /healthz {
            if ($http_x_probe != "kubelet") { return 403; }
            default_type text/plain;
            return 200 "ok\n";
        }
        location / { return 404; }
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: catalog-v2
  namespace: neptune
data:
  default.conf: |
    server {
        listen 8080;
        location = / {
            default_type text/plain;
            return 200 "catalog v2\n";
        }
        location = /ready {
            if ($http_x_probe != "kubelet") { return 403; }
            default_type text/plain;
            return 200 "ready\n";
        }
        location / { return 404; }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: catalog
  namespace: neptune
spec:
  selector:
    app: catalog
  ports:
  - name: http
    port: 80
    targetPort: 8080
YAML

# 3) v1 배포 (probe 정상)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
  namespace: neptune
spec:
  replicas: 3
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: catalog
  template:
    metadata:
      labels:
        app: catalog
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
            httpHeaders:
            - name: X-Probe
              value: kubelet
          periodSeconds: 5
        volumeMounts:
        - name: conf
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: conf
        configMap:
          name: catalog-v1
YAML
kubectl -n neptune rollout status deploy catalog --timeout=180s

# 4) v2 롤아웃 시작 (probe 의 경로와 헤더 값이 틀렸다 → 새 파드가 Ready 가 되지 않는다)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
  namespace: neptune
spec:
  replicas: 3
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: catalog
  template:
    metadata:
      labels:
        app: catalog
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8080
            httpHeaders:
            - name: X-Probe
              value: k8s
          periodSeconds: 5
        volumeMounts:
        - name: conf
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: conf
        configMap:
          name: catalog-v2
YAML

# 5) 새 파드가 뜨고 probe 실패가 쌓일 때까지 잠시 기다린다
sleep 25

# 6) 시작 상태 확인: v1 RS 3/3, v2 RS 0/1
kubectl -n neptune get rs,pods -l app=catalog

#!/usr/bin/env bash
# a09 — Migrate manifests off removed API versions · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns iota --ignore-not-found --wait=true
rm -rf /opt/course/a09

# 1) namespace 와 대상 워크로드 (Ingress·PDB·HPA 가 가리킬 Deployment/Service)
kubectl create ns iota
mkdir -p /opt/course/a09
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: iota
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: iota
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
YAML

# 2) 옛 API 버전으로 쓴 매니페스트 (모두 제거된 버전이라 apply 하면 no matches for kind 로 실패한다)
cat > /opt/course/a09/legacy.yaml <<'YAML'
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web
  namespace: iota
spec:
  rules:
  - host: web.iota.local
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 80
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cleanup
  namespace: iota
spec:
  schedule: "*/30 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "echo cleanup"]
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: web
  namespace: iota
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: web
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: web
  namespace: iota
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 70
YAML

kubectl -n iota rollout status deploy web --timeout=120s

# 3) 시작 상태 확인: Deployment/Service 만 있고, legacy.yaml 은 적용되지 않는다
kubectl -n iota get deploy,svc,ingress,cronjob,pdb,hpa
grep -E '^(apiVersion|kind):' /opt/course/a09/legacy.yaml

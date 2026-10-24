#!/usr/bin/env bash
# a05 — Render, upgrade and roll back a local Helm chart · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 작업 디렉터리
if helm status inventory -n delta >/dev/null 2>&1; then
  helm uninstall inventory -n delta --wait
fi
kubectl delete ns delta --ignore-not-found --wait=true
rm -rf /opt/course/a05

# 2) 로컬 차트 inventory 0.3.0 (인터넷의 차트 저장소를 쓰지 않는다)
mkdir -p /opt/course/a05/chart/templates
cat > /opt/course/a05/chart/Chart.yaml <<'YAML'
apiVersion: v2
name: inventory
description: Inventory web front end (CKAD mock a05)
type: application
version: 0.3.0
appVersion: "1.27"
YAML

cat > /opt/course/a05/chart/values.yaml <<'YAML'
replicaCount: 1
image:
  repository: nginx
  tag: 1.27-alpine
podLabels: {}
service:
  port: 80
YAML

cat > /opt/course/a05/chart/templates/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ .Chart.Name }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      containers:
      - name: web
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - name: http
          containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: http
          periodSeconds: 3
YAML

cat > /opt/course/a05/chart/templates/service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  selector:
    app.kubernetes.io/instance: {{ .Release.Name }}
  ports:
  - name: http
    port: {{ .Values.service.port }}
    targetPort: http
YAML

# 3) 차트가 올바른지 확인
helm lint /opt/course/a05/chart

# 4) 시작 상태 확인: 차트는 있고 네임스페이스·릴리스는 없다
find /opt/course/a05 -type f
kubectl get ns delta 2>/dev/null || echo "namespace delta 없음 (정상)"

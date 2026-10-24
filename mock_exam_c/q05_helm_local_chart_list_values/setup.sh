#!/usr/bin/env bash
# c05 — Install a local Helm chart with list values and keep its history · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 확인
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스(남겨 둔 히스토리 포함), namespace, 결과 파일
#    --keep-history 로 남은 릴리스는 옵션 없는 uninstall 로 완전히 지워진다
helm uninstall inventory -n cedar >/dev/null 2>&1 || true
kubectl delete ns cedar --ignore-not-found --wait=true
rm -rf /opt/course/c05

# 2) 로컬 차트 (저장소·의존성 없음)
mkdir -p /opt/course/c05/inventory/templates
cat > /opt/course/c05/inventory/Chart.yaml <<'EOF'
apiVersion: v2
name: inventory
description: Inventory service (c05 practice chart)
type: application
version: 0.3.0
appVersion: "1.27"
EOF

cat > /opt/course/c05/inventory/values.yaml <<'EOF'
replicaCount: 1

image:
  repository: nginx
  tag: 1.27-alpine

service:
  port: 80

# 컨테이너 환경 변수 목록. 각 항목은 name / value 키를 가진다.
env: []
EOF

cat > /opt/course/c05/inventory/templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
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
    spec:
      containers:
      - name: app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
        {{- with .Values.env }}
        env:
          {{- toYaml . | nindent 10 }}
        {{- end }}
EOF

cat > /opt/course/c05/inventory/templates/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  selector:
    app.kubernetes.io/instance: {{ .Release.Name }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
EOF

# 3) 시작 상태 확인: 차트는 lint 통과, namespace·릴리스 없음
helm lint /opt/course/c05/inventory
kubectl get ns cedar 2>/dev/null || echo "namespace cedar 없음 (정상)"
helm list -A --all | grep inventory || echo "릴리스 inventory 없음 (정상)"

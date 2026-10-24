#!/usr/bin/env bash
# c09 — Find preferred API versions and migrate an HPA to v2 · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (클러스터에는 만드는 것이 없다)
rm -rf /opt/course/c09
mkdir -p /opt/course/c09

# 1) v1.26 에서 제거된 autoscaling/v2beta2 로 쓰인 옛 HPA 매니페스트
cat > /opt/course/c09/hpa-v2beta2.yaml <<'YAML'
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  labels:
    app: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 200Mi
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
YAML

# 2) 시작 상태 확인
cat /opt/course/c09/hpa-v2beta2.yaml
kubectl api-versions | grep '^autoscaling/'

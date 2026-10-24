#!/usr/bin/env bash
# f14 — Explore a CRD and create a custom resource · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리: namespace, CRD(이 문제 id 가 들어간 클러스터 객체), 결과 파일
kubectl delete ns elbe --ignore-not-found --wait=true
kubectl delete crd backups.f14.example.com --ignore-not-found --wait=true
rm -rf /opt/course/f14

# 1) namespace 와 답안 디렉터리
kubectl create ns elbe
mkdir -p /opt/course/f14

# 2) "백업 operator" 가 설치한 CRD (operator 자체는 아직 없다)
cat <<'YAML' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.f14.example.com
spec:
  group: f14.example.com
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames: ["bk"]
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - name: Schedule
      type: string
      jsonPath: .spec.schedule
    - name: Target
      type: string
      jsonPath: .spec.target
    - name: Retention
      type: integer
      jsonPath: .spec.retentionDays
    schema:
      openAPIV3Schema:
        type: object
        description: Backup describes a scheduled backup of one PersistentVolumeClaim.
        required: ["spec"]
        properties:
          spec:
            type: object
            description: Desired backup settings.
            required: ["schedule", "target"]
            properties:
              schedule:
                type: string
                description: Cron expression that defines when the backup runs, e.g. "30 1 * * *".
              target:
                type: string
                description: Name of the PersistentVolumeClaim in the same namespace to back up.
              retentionDays:
                type: integer
                minimum: 1
                maximum: 90
                description: Number of days a backup is kept. Defaults to 3 when omitted.
YAML
kubectl wait --for=condition=Established crd/backups.f14.example.com --timeout=60s

# 3) 시작 상태 확인: CRD 는 있고 elbe 에 커스텀 리소스는 없다
kubectl api-resources --api-group=f14.example.com || true
kubectl -n elbe get backups.f14.example.com || true

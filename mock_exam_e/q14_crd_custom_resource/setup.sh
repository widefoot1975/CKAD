#!/usr/bin/env bash
# e14 — Create a custom resource from an existing CRD · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CRD 를 지우면 그 커스텀 리소스도 함께 지워진다)
kubectl delete ns coral --ignore-not-found --wait=true
kubectl delete crd backups.e14.example.com --ignore-not-found --wait=true
rm -rf /opt/course/e14

# 1) CRD: 그룹 e14.example.com, kind Backup, v1, namespaced
cat <<'YAML' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.e14.example.com
spec:
  group: e14.example.com
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
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["source"]
            properties:
              source:
                type: string
                description: Name of the database to back up.
              schedule:
                type: string
                description: Cron schedule of the backup.
              retentionDays:
                type: integer
                minimum: 1
                maximum: 30
                description: How many days to keep each backup.
    additionalPrinterColumns:
    - name: Source
      type: string
      jsonPath: .spec.source
    - name: Schedule
      type: string
      jsonPath: .spec.schedule
    - name: Retention
      type: integer
      jsonPath: .spec.retentionDays
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
YAML
kubectl wait --for=condition=Established crd/backups.e14.example.com --timeout=60s

# 2) namespace 와 결과 디렉터리
kubectl create ns coral
mkdir -p /opt/course/e14

# 3) 시작 상태 확인: CRD 는 있고 coral 에는 Backup 이 없다
kubectl get crd backups.e14.example.com
kubectl -n coral get backups.e14.example.com

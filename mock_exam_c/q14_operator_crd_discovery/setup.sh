#!/usr/bin/env bash
# c14 — Discover an operator's CRDs and create a custom resource · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CRD 를 지우면 그 커스텀 리소스도 함께 지워진다)
kubectl delete crd backups.c14.example.com restores.c14.example.com backupstores.c14.example.com \
  backups.c14x.example.com --ignore-not-found --wait=true
kubectl delete ns rowan alder --ignore-not-found --wait=true
rm -rf /opt/course/c14
mkdir -p /opt/course/c14

# 1) 오퍼레이터 c14-operator 의 CRD 3개
cat <<'YAML' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.c14.example.com
  labels:
    app.kubernetes.io/part-of: c14-operator
spec:
  group: c14.example.com
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames: ["bk"]
  versions:
  - name: v1alpha1
    served: true
    storage: false
    deprecated: true
    deprecationWarning: "c14.example.com/v1alpha1 Backup is deprecated; use c14.example.com/v1"
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["database", "retention"]
            properties:
              database:
                type: string
                description: Name of the database to back up.
              schedule:
                type: string
                description: Cron expression (five fields) that decides when the backup runs.
              retention:
                type: object
                description: How long finished backups are kept.
                required: ["keepDays"]
                properties:
                  keepDays:
                    type: integer
                    minimum: 1
                    maximum: 30
                    description: Number of days a finished backup is kept (1-30).
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - name: Database
      type: string
      jsonPath: .spec.database
    - name: Schedule
      type: string
      jsonPath: .spec.schedule
    - name: KeepDays
      type: integer
      jsonPath: .spec.retention.keepDays
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["database", "retention"]
            properties:
              database:
                type: string
                description: Name of the database to back up.
              schedule:
                type: string
                description: Cron expression (five fields) that decides when the backup runs.
              retention:
                type: object
                description: How long finished backups are kept.
                required: ["keepDays"]
                properties:
                  keepDays:
                    type: integer
                    minimum: 1
                    maximum: 30
                    description: Number of days a finished backup is kept (1-30).
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: restores.c14.example.com
  labels:
    app.kubernetes.io/part-of: c14-operator
spec:
  group: c14.example.com
  scope: Namespaced
  names:
    plural: restores
    singular: restore
    kind: Restore
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
            properties:
              backupName:
                type: string
                description: Name of the Backup to restore from.
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backupstores.c14.example.com
  labels:
    app.kubernetes.io/part-of: c14-operator
spec:
  group: c14.example.com
  scope: Cluster
  names:
    plural: backupstores
    singular: backupstore
    kind: BackupStore
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
            properties:
              endpoint:
                type: string
---
# 2) 다른 팀의 CRD: 이름(kind Backup, plural backups)이 겹친다 — 함정
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.c14x.example.com
  labels:
    app.kubernetes.io/part-of: c14-legacy-tools
spec:
  group: c14x.example.com
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
YAML
kubectl wait --for=condition=Established --timeout=60s \
  crd/backups.c14.example.com crd/restores.c14.example.com crd/backupstores.c14.example.com crd/backups.c14x.example.com

# 3) 커스텀 리소스: rowan 과 alder 에 흩어 놓는다
kubectl create ns rowan
kubectl create ns alder
cat <<'YAML' | kubectl apply -f -
apiVersion: c14.example.com/v1
kind: Backup
metadata:
  name: orders-daily
  namespace: rowan
spec:
  database: orders
  schedule: "0 2 * * *"
  retention:
    keepDays: 7
---
apiVersion: c14.example.com/v1
kind: Backup
metadata:
  name: users-daily
  namespace: rowan
spec:
  database: users
  schedule: "15 2 * * *"
  retention:
    keepDays: 7
---
apiVersion: c14.example.com/v1
kind: Backup
metadata:
  name: billing-weekly
  namespace: alder
spec:
  database: billing
  schedule: "0 3 * * 0"
  retention:
    keepDays: 30
---
apiVersion: c14.example.com/v1
kind: Restore
metadata:
  name: billing-restore-1
  namespace: alder
spec:
  backupName: billing-weekly
---
apiVersion: c14.example.com/v1
kind: BackupStore
metadata:
  name: s3-main
spec:
  endpoint: https://s3.c14.example.com
---
apiVersion: c14x.example.com/v1
kind: Backup
metadata:
  name: legacy-dump
  namespace: rowan
spec:
  target: /var/backups
YAML

# 4) 시작 상태 확인
kubectl get crd -L app.kubernetes.io/part-of | grep -E 'NAME|c14'

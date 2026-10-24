#!/usr/bin/env bash
# b14 — Custom resources and a stuck finalizer · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — finalizer 가 남은 CR 이 있으면 ns/CRD 삭제가 멈추므로 먼저 finalizer 를 뗀다
if kubectl get crd backups.b14.example.com >/dev/null 2>&1; then
  for b in $(kubectl get backups.b14.example.com -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" "}{end}'); do
    kubectl -n "${b%%/*}" patch backups.b14.example.com "${b##*/}" --type=merge -p '{"metadata":{"finalizers":null}}' || true
  done
fi
kubectl delete ns deimos --ignore-not-found --wait=true
kubectl delete crd backups.b14.example.com --ignore-not-found --wait=true
rm -rf /opt/course/b14

# 1) CRD (짧은 이름 bk, 사용자 정의 열, 스키마 검사)
cat <<'YAML' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.b14.example.com
spec:
  group: b14.example.com
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
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["schedule", "target"]
            properties:
              schedule:
                type: string
              target:
                type: string
                enum: ["postgres", "redis", "nfs"]
              retentionDays:
                type: integer
                minimum: 1
                maximum: 90
YAML
kubectl wait --for=condition=Established crd/backups.b14.example.com --timeout=60s

# 2) 네임스페이스와, 컨트롤러가 사라져 finalizer 가 풀리지 않는 CR
kubectl create ns deimos
mkdir -p /opt/course/b14
cat <<'YAML' | kubectl apply -f -
apiVersion: b14.example.com/v1
kind: Backup
metadata:
  name: legacy-nightly
  namespace: deimos
  finalizers:
  - b14.example.com/snapshot-cleanup
spec:
  schedule: "0 1 * * *"
  target: redis
  retentionDays: 14
YAML
kubectl -n deimos delete backups.b14.example.com legacy-nightly --wait=false

# 3) 거부되는 매니페스트 (retentionDays 가 문자열)
cat > /opt/course/b14/files-weekly.yaml <<'YAML'
apiVersion: b14.example.com/v1
kind: Backup
metadata:
  name: files-weekly
  namespace: deimos
spec:
  schedule: "0 3 * * 0"
  target: nfs
  retentionDays: "30"
YAML

# 4) 시작 상태 확인: legacy-nightly 에 deletionTimestamp 가 찍혀 있다
kubectl -n deimos get backups.b14.example.com
kubectl -n deimos get backups.b14.example.com legacy-nightly \
  -o jsonpath='deletionTimestamp={.metadata.deletionTimestamp} finalizers={.metadata.finalizers}{"\n"}'

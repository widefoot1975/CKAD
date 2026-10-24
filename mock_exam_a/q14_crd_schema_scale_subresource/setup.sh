#!/usr/bin/env bash
# a14 — Work with a CRD that has a schema and a scale subresource · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CRD 를 지우면 그 커스텀 리소스도 함께 지워진다)
kubectl delete ns xi --ignore-not-found --wait=true
kubectl delete crd queues.a14.example.com --ignore-not-found --wait=true
rm -rf /opt/course/a14

# 1) CRD: 스키마(enum, min/max, required) + status/scale 서브리소스
cat <<'YAML' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: queues.a14.example.com
spec:
  group: a14.example.com
  scope: Namespaced
  names:
    plural: queues
    singular: queue
    kind: Queue
    shortNames:
    - qu
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        required:
        - spec
        properties:
          spec:
            type: object
            required:
            - backend
            - replicas
            properties:
              backend:
                type: string
                description: Message broker that backs the queue.
                enum:
                - redis
                - rabbitmq
              replicas:
                type: integer
                description: Number of consumer workers.
                minimum: 1
                maximum: 10
              retentionHours:
                type: integer
                description: How long messages are kept.
                default: 24
          status:
            type: object
            properties:
              replicas:
                type: integer
    subresources:
      status: {}
      scale:
        specReplicasPath: .spec.replicas
        statusReplicasPath: .status.replicas
    additionalPrinterColumns:
    - name: Backend
      type: string
      jsonPath: .spec.backend
    - name: Replicas
      type: integer
      jsonPath: .spec.replicas
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
YAML
kubectl wait --for=condition=Established crd/queues.a14.example.com --timeout=60s

# 2) namespace 와 결과 디렉터리
kubectl create ns xi
mkdir -p /opt/course/a14

# 3) 시작 상태 확인: CRD 는 있고 커스텀 리소스는 없다
kubectl get crd queues.a14.example.com
kubectl -n xi get queues

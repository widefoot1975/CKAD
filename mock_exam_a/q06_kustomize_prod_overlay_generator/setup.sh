#!/usr/bin/env bash
# a06 — Complete a Kustomize prod overlay · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (dev overlay 의 namespace zeta 도 혹시 적용됐다면 지운다)
kubectl delete ns epsilon zeta --ignore-not-found --wait=true
rm -rf /opt/course/a06

# 1) prod 가 쓸 빈 namespace (Kustomize 의 namespace 필드는 Namespace 를 만들지 않는다)
kubectl create ns epsilon

# 2) base
mkdir -p /opt/course/a06/base /opt/course/a06/overlays/dev /opt/course/a06/overlays/prod
cat > /opt/course/a06/base/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
YAML

cat > /opt/course/a06/base/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
  labels:
    app: catalog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: catalog
  template:
    metadata:
      labels:
        app: catalog
    spec:
      containers:
      - name: catalog
        image: ghcr.io/stefanprodan/podinfo:6.7.0
        ports:
        - name: http
          containerPort: 9898
        envFrom:
        - configMapRef:
            name: catalog-config
        readinessProbe:
          httpGet:
            path: /readyz
            port: http
          periodSeconds: 3
YAML

cat > /opt/course/a06/base/service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: catalog
  labels:
    app: catalog
spec:
  selector:
    app: catalog
  ports:
  - name: http
    port: 80
    targetPort: http
YAML

# 3) dev overlay (완성본, 이 문제에서는 적용하지 않는다)
cat > /opt/course/a06/overlays/dev/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: zeta
namePrefix: dev-
configMapGenerator:
- name: catalog-config
  literals:
  - PODINFO_UI_MESSAGE=dev-catalog
  - PODINFO_LEVEL=debug
YAML

# 4) prod overlay (미완성)
cat > /opt/course/a06/overlays/prod/kustomization.yaml <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
# TODO: complete the prod overlay
YAML

# 5) 시작 상태 확인
find /opt/course/a06 -type f | sort
kubectl kustomize /opt/course/a06/overlays/dev >/dev/null && echo "dev overlay 렌더링 OK"
kubectl -n epsilon get all

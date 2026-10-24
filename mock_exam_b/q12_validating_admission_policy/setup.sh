#!/usr/bin/env bash
# b12 — Get a Deployment past a ValidatingAdmissionPolicy · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete validatingadmissionpolicybinding b12-require-team-and-limits-binding --ignore-not-found
kubectl delete validatingadmissionpolicy b12-require-team-and-limits --ignore-not-found
kubectl delete ns callisto --ignore-not-found --wait=true
rm -rf /opt/course/b12

# 1) 네임스페이스(정책 대상 레이블)와 답안 디렉터리
kubectl create ns callisto
kubectl label ns callisto b12-policy=enforced
mkdir -p /opt/course/b12

# 2) 정책과 Binding (team 레이블 + 모든 컨테이너의 cpu/memory limits 요구)
cat <<'YAML' | kubectl apply -f -
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: b12-require-team-and-limits
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments"]
  validations:
  - expression: "has(object.metadata.labels) && 'team' in object.metadata.labels"
    message: "b12: Deployment must carry a 'team' label"
    reason: Forbidden
  - expression: "object.spec.template.spec.containers.all(c, has(c.resources) && has(c.resources.limits) && 'cpu' in c.resources.limits && 'memory' in c.resources.limits)"
    message: "b12: every container needs cpu and memory limits"
    reason: Forbidden
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: b12-require-team-and-limits-binding
spec:
  policyName: b12-require-team-and-limits
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        b12-policy: enforced
YAML

# 3) 거부되는 매니페스트 (team 은 pod template 에만 있고, metrics 컨테이너에는 limits 가 없다)
cat > /opt/course/b12/orders.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders
  namespace: callisto
  labels:
    app: orders
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orders
  template:
    metadata:
      labels:
        app: orders
        team: payments
    spec:
      containers:
      - name: api
        image: nginx:1.27-alpine
        resources:
          requests: {cpu: 50m, memory: 64Mi}
          limits: {cpu: 200m, memory: 128Mi}
      - name: metrics
        image: busybox:1.36
        command: ["sh", "-c", "while true; do sleep 30; done"]
        resources:
          requests: {cpu: 10m, memory: 16Mi}
YAML

# 4) 정책이 실제로 동작하기 시작할 때까지 기다린다 (server dry-run 이 거부되면 준비 완료)
for i in $(seq 1 30); do
  if ! kubectl -n callisto create deployment b12-probe --image=nginx:1.27-alpine \
       --dry-run=server -o name >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

# 5) 시작 상태 확인
kubectl get validatingadmissionpolicy b12-require-team-and-limits
kubectl get validatingadmissionpolicybinding b12-require-team-and-limits-binding
kubectl get ns callisto --show-labels
kubectl -n callisto get deploy

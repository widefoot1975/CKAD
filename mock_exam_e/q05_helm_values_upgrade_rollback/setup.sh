#!/usr/bin/env bash
# e05 — Install, upgrade and roll back a Helm release · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 저장소, 결과 파일
if helm status podinfo -n opal >/dev/null 2>&1; then
  helm uninstall podinfo -n opal --wait
fi
kubectl delete ns opal --ignore-not-found --wait=true
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/e05

# 2) namespace 와 values 파일
kubectl create ns opal
mkdir -p /opt/course/e05
cat > /opt/course/e05/values.yaml <<'YAML'
replicaCount: 2
ui:
  message: "hello from opal"
  color: "#0f766e"
YAML

# 3) 시작 상태 확인: 저장소와 릴리스가 없다
helm repo list 2>/dev/null | grep podinfo || echo "podinfo 저장소 없음 (정상)"
helm list -n opal
cat /opt/course/e05/values.yaml

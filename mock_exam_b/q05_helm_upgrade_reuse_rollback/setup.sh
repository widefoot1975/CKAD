#!/usr/bin/env bash
# b05 — Upgrade and roll back a Helm release without losing values · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 확인
helm version --short

# 1) 이전 실습 흔적 정리
if helm status podinfo -n jupiter >/dev/null 2>&1; then
  helm uninstall podinfo -n jupiter --wait
fi
kubectl delete ns jupiter --ignore-not-found --wait=true
rm -rf /opt/course/b05

# 2) 차트 저장소 (공용, 있으면 갱신만)
helm repo add podinfo https://stefanprodan.github.io/podinfo --force-update
helm repo update podinfo

# 3) 리비전 1: 6.7.0 을 values 파일로 설치
mkdir -p /opt/course/b05
TMPV=$(mktemp)
cat > "$TMPV" <<'VALUES'
replicaCount: 2
ui:
  message: hello from jupiter
VALUES
helm install podinfo podinfo/podinfo --version 6.7.0 -n jupiter --create-namespace -f "$TMPV" --wait
rm -f "$TMPV"

# 4) 리비전 2: 같은 차트 버전에서 색상만 추가
helm upgrade podinfo podinfo/podinfo --version 6.7.0 -n jupiter --reuse-values \
  --set ui.color='#a33c3c' --wait

# 5) 시작 상태 확인: 6.7.0, 리비전 2개
helm -n jupiter history podinfo
kubectl -n jupiter get deploy podinfo -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

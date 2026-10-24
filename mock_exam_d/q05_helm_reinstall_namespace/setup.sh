#!/usr/bin/env bash
# d05 — Move a Helm release to the right namespace · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 두 네임스페이스의 릴리스, 네임스페이스, 저장소, 결과 파일
for ns in owl raven; do
  if helm status podinfo -n "$ns" >/dev/null 2>&1; then
    helm uninstall podinfo -n "$ns" --wait
  fi
done
kubectl delete ns owl raven --ignore-not-found --wait=true
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d05

# 2) 잘못된 설치 만들기: 저장소를 등록하지 않고 --repo 로 직접 받아 namespace owl 에 설치한다
helm install podinfo podinfo --repo https://stefanprodan.github.io/podinfo \
  -n owl --create-namespace --wait --timeout 3m

# 3) 답안 디렉터리
mkdir -p /opt/course/d05

# 4) 시작 상태 확인: 릴리스는 있지만 저장소 podinfo 와 namespace raven 은 없다
helm list -A | grep podinfo
helm repo list 2>/dev/null | grep podinfo || echo "podinfo 저장소 없음 (정상)"
kubectl get ns raven 2>/dev/null || echo "namespace raven 없음 (정상)"

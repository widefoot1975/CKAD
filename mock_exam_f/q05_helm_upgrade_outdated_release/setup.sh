#!/usr/bin/env bash
# f05 — Upgrade the outdated Helm release · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스 두 개, namespace 두 개, 결과 파일
if helm status frontend -n rhine >/dev/null 2>&1; then helm uninstall frontend -n rhine --wait; fi
if helm status backend -n thames >/dev/null 2>&1; then helm uninstall backend -n thames --wait; fi
kubectl delete ns rhine thames --ignore-not-found --wait=true
rm -rf /opt/course/f05

# 2) 차트 저장소 podinfo
helm repo add podinfo https://stefanprodan.github.io/podinfo --force-update
helm repo update podinfo

# 3) 버전을 고정해 두 릴리스를 설치한다
#    frontend (rhine)  : 차트 6.7.1 — 이미 기준 버전
#    backend  (thames) : 차트 6.5.4 — 오래된 버전, 사용자 값 replicaCount=2
helm install frontend podinfo/podinfo --version 6.7.1 -n rhine --create-namespace --wait --timeout 5m
helm install backend podinfo/podinfo --version 6.5.4 -n thames --create-namespace \
  --set replicaCount=2 --wait --timeout 5m

# 4) 답안 디렉터리
mkdir -p /opt/course/f05

# 5) 시작 상태 확인: 두 릴리스 모두 revision 1
helm list -A | grep -E 'NAME|frontend|backend'

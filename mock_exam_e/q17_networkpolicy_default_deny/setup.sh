#!/usr/bin/env bash
# e17 — Default-deny ingress and allow only the frontend · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns zircon --ignore-not-found --wait=true

# 1) namespace, backend 파드와 Service, 클라이언트 파드 두 개 (NetworkPolicy 없음)
kubectl create ns zircon
kubectl -n zircon run backend --image=nginx:1.27-alpine --labels=app=backend --port=80
kubectl -n zircon expose pod backend --name=backend --port=80 --target-port=80
kubectl -n zircon run frontend --image=busybox:1.36 --labels=role=frontend -- sleep 1d
kubectl -n zircon run intruder --image=busybox:1.36 --labels=role=other -- sleep 1d
kubectl -n zircon wait --for=condition=Ready pod/backend pod/frontend pod/intruder --timeout=120s

# 2) 시작 상태 확인: 정책이 없어서 두 클라이언트 모두 접속된다
kubectl -n zircon get pods --show-labels
kubectl -n zircon get netpol
kubectl -n zircon exec frontend -- wget -qO- -T 2 http://backend >/dev/null && echo "frontend → backend: 접속됨" || true
kubectl -n zircon exec intruder -- wget -qO- -T 2 http://backend >/dev/null && echo "intruder → backend: 접속됨 (아직 정책 없음)" || true

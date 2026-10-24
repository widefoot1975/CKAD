#!/usr/bin/env bash
# e15 — Repair a NodePort Service with a wrong targetPort · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns jasper --ignore-not-found --wait=true
rm -rf /opt/course/e15

# 1) namespace 와 앱: http-echo 는 5678 에서 듣는다
kubectl create ns jasper
mkdir -p /opt/course/e15
kubectl -n jasper create deploy api --image=hashicorp/http-echo:1.0 --replicas=2 --port=5678 \
  -- /http-echo -text=jasper-api
kubectl -n jasper rollout status deploy api --timeout=120s

# 2) 고장 내기: NodePort Service 의 targetPort 를 8080 으로 (nodePort 는 자동 배정)
kubectl -n jasper create service nodeport api-svc --tcp=80:8080
kubectl -n jasper set selector svc api-svc app=api

# 3) 시작 상태 확인: 엔드포인트는 있지만 포트가 8080, NodePort 로 curl 하면 실패
kubectl -n jasper get deploy,svc
kubectl -n jasper get endpointslice -l kubernetes.io/service-name=api-svc
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NP=$(kubectl -n jasper get svc api-svc -o jsonpath='{.spec.ports[0].nodePort}')
curl -s -m 3 "http://$NODE:$NP/" || echo "curl $NODE:$NP 실패 (정상 — 이 문제의 시작 상태)"

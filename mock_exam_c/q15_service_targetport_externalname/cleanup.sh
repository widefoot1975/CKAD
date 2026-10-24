#!/usr/bin/env bash
# c15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# 백그라운드로 남은 port-forward 가 있으면 정리
pkill -f 'port-forward.*svc/orders' 2>/dev/null || true
kubectl delete ns yew --ignore-not-found
rm -rf /opt/course/c15

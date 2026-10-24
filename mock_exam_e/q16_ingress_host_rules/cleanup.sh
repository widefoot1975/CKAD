#!/usr/bin/env bash
# e16 — 실습 후 정리 (NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns citrine --ignore-not-found
rm -rf /opt/course/e16

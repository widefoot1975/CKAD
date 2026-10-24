#!/usr/bin/env bash
# b16 — 실습 후 정리
# 실행: bash cleanup.sh
# NGINX Ingress Controller 는 공용 인프라라 지우지 않는다
set -euo pipefail

kubectl delete ns oberon --ignore-not-found
rm -rf /opt/course/b16

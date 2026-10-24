#!/usr/bin/env bash
# f16 — 실습 후 정리
# 실행: bash cleanup.sh
# NGINX Ingress Controller 는 다른 Ingress 문제도 쓰는 공용 설치라 지우지 않는다
set -euo pipefail

kubectl delete ns tagus --ignore-not-found
rm -rf /opt/course/f16

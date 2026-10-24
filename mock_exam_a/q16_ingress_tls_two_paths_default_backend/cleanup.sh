#!/usr/bin/env bash
# a16 — 실습 후 정리
# 실행: bash cleanup.sh
# NGINX Ingress Controller 는 다른 문제도 쓰는 공용 구성요소라 지우지 않는다
set -euo pipefail

kubectl delete ns pi --ignore-not-found
rm -rf /opt/course/a16

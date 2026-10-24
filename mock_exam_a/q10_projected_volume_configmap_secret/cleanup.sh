#!/usr/bin/env bash
# a10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns kappa --ignore-not-found
rm -rf /opt/course/a10

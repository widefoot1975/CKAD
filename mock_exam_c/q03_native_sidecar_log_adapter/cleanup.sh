#!/usr/bin/env bash
# c03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns maple --ignore-not-found
rm -rf /opt/course/c03

#!/usr/bin/env bash
# c12 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns hazel --ignore-not-found
rm -rf /opt/course/c12

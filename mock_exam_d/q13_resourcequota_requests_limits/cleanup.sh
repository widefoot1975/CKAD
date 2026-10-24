#!/usr/bin/env bash
# d13 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns finch --ignore-not-found
rm -rf /opt/course/d13

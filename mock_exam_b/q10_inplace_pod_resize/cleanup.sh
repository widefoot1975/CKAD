#!/usr/bin/env bash
# b10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns io --ignore-not-found
rm -rf /opt/course/b10

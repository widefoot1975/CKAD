#!/usr/bin/env bash
# f11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns indus --ignore-not-found
rm -rf /opt/course/f11

#!/usr/bin/env bash
# f12 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns tigris --ignore-not-found
rm -rf /opt/course/f12

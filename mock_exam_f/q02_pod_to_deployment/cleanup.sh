#!/usr/bin/env bash
# f02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns amazon --ignore-not-found
rm -rf /opt/course/f02

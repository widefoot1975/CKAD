#!/usr/bin/env bash
# b15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns triton --ignore-not-found
rm -rf /opt/course/b15

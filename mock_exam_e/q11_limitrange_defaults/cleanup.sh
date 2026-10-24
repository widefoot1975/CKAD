#!/usr/bin/env bash
# e11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns quartz --ignore-not-found
rm -rf /opt/course/e11

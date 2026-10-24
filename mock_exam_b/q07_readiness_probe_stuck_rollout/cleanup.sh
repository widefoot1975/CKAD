#!/usr/bin/env bash
# b07 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns neptune --ignore-not-found
rm -rf /opt/course/b07

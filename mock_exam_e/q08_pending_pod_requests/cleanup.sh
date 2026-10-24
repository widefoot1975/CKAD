#!/usr/bin/env bash
# e08 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns jade --ignore-not-found
rm -rf /opt/course/e08

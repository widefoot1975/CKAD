#!/usr/bin/env bash
# e13 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns beryl --ignore-not-found
rm -rf /opt/course/e13

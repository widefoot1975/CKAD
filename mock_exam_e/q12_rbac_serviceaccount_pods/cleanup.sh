#!/usr/bin/env bash
# e12 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns agate --ignore-not-found
rm -rf /opt/course/e12

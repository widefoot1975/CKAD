#!/usr/bin/env bash
# f08 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns yukon --ignore-not-found
rm -rf /opt/course/f08

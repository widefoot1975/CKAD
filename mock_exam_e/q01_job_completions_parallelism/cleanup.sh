#!/usr/bin/env bash
# e01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns ruby --ignore-not-found
rm -rf /opt/course/e01

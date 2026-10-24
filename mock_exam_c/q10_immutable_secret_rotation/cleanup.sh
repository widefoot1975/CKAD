#!/usr/bin/env bash
# c10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns spruce --ignore-not-found
rm -rf /opt/course/c10

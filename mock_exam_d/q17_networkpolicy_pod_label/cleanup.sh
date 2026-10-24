#!/usr/bin/env bash
# d17 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns osprey --ignore-not-found
rm -rf /opt/course/d17

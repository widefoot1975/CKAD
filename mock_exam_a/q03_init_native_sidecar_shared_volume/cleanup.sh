#!/usr/bin/env bash
# a03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns beta --ignore-not-found
rm -rf /opt/course/a03

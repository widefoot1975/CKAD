#!/usr/bin/env bash
# e09 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns amber --ignore-not-found
rm -rf /opt/course/e09

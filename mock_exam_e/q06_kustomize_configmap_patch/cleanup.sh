#!/usr/bin/env bash
# e06 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns garnet --ignore-not-found
rm -rf /opt/course/e06

#!/usr/bin/env bash
# d06 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns sparrow --ignore-not-found
rm -rf /opt/course/d06

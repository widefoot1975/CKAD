#!/usr/bin/env bash
# b04 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns mars --ignore-not-found
rm -rf /opt/course/b04

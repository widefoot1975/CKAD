#!/usr/bin/env bash
# a12 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns mu --ignore-not-found
rm -rf /opt/course/a12

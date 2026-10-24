#!/usr/bin/env bash
# b11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns ganymede --ignore-not-found
rm -rf /opt/course/b11

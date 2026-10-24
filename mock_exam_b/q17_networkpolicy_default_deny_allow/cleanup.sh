#!/usr/bin/env bash
# b17 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns ariel miranda charon --ignore-not-found
rm -rf /opt/course/b17

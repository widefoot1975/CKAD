#!/usr/bin/env bash
# f10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns ganges --ignore-not-found
rm -rf /opt/course/f10

#!/usr/bin/env bash
# d02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns falcon --ignore-not-found
rm -rf /opt/course/d02

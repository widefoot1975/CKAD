#!/usr/bin/env bash
# d14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns lark --ignore-not-found
rm -rf /opt/course/d14

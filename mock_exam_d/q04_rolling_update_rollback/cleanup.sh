#!/usr/bin/env bash
# d04 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns heron --ignore-not-found
rm -rf /opt/course/d04

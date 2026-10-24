#!/usr/bin/env bash
# a15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns omicron --ignore-not-found
rm -rf /opt/course/a15

#!/usr/bin/env bash
# a11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns lambda --ignore-not-found
rm -rf /opt/course/a11

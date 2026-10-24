#!/usr/bin/env bash
# b02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns mercury --ignore-not-found
rm -rf /opt/course/b02

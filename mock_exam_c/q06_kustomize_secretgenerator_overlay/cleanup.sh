#!/usr/bin/env bash
# c06 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns willow --ignore-not-found
rm -rf /opt/course/c06

#!/usr/bin/env bash
# b08 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns pluto --ignore-not-found
rm -rf /opt/course/b08

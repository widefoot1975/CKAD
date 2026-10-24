#!/usr/bin/env bash
# d11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns pelican --ignore-not-found
rm -rf /opt/course/d11

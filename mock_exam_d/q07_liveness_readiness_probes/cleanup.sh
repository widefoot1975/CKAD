#!/usr/bin/env bash
# d07 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns kestrel --ignore-not-found

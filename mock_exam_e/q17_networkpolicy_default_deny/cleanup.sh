#!/usr/bin/env bash
# e17 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns zircon --ignore-not-found

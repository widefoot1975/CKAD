#!/usr/bin/env bash
# a13 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns nu --ignore-not-found
rm -rf /opt/course/a13

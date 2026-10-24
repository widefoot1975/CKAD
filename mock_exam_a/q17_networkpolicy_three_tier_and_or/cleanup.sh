#!/usr/bin/env bash
# a17 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns rho sigma --ignore-not-found
rm -rf /opt/course/a17

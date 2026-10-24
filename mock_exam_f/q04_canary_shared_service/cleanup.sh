#!/usr/bin/env bash
# f04 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns danube --ignore-not-found
rm -rf /opt/course/f04

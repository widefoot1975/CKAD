#!/usr/bin/env bash
# d08 — 실습 후 정리
# 실행: bash cleanup.sh
# metrics-server 는 공용 인프라라 지우지 않는다.
set -euo pipefail

kubectl delete ns magpie --ignore-not-found
rm -rf /opt/course/d08

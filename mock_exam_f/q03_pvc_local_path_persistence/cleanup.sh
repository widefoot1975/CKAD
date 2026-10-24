#!/usr/bin/env bash
# f03 — 실습 후 정리
# 실행: bash cleanup.sh
# local-path provisioner 는 다른 문제도 쓰는 공용 설치라 지우지 않는다
set -euo pipefail

kubectl delete ns nile --ignore-not-found --wait=true
rm -rf /opt/course/f03

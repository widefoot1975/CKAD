#!/usr/bin/env bash
# b03 — 실습 후 정리
# 실행: bash cleanup.sh
# local-path provisioner 는 공용 인프라라 지우지 않는다
set -euo pipefail

kubectl delete ns venus --ignore-not-found
rm -rf /opt/course/b03

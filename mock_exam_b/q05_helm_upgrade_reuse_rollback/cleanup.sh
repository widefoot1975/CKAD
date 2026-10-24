#!/usr/bin/env bash
# b05 — 실습 후 정리
# 실행: bash cleanup.sh
# helm 저장소 등록 podinfo 는 공용이라 지우지 않는다
set -euo pipefail

if helm status podinfo -n jupiter >/dev/null 2>&1; then
  helm uninstall podinfo -n jupiter --wait
fi
kubectl delete ns jupiter --ignore-not-found
rm -rf /opt/course/b05

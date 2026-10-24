#!/usr/bin/env bash
# a05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

if helm status inventory -n delta >/dev/null 2>&1; then
  helm uninstall inventory -n delta --wait
fi
kubectl delete ns delta --ignore-not-found
rm -rf /opt/course/a05

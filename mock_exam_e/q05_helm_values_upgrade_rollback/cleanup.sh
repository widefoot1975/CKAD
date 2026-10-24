#!/usr/bin/env bash
# e05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

if helm status podinfo -n opal >/dev/null 2>&1; then
  helm uninstall podinfo -n opal --wait
fi
kubectl delete ns opal --ignore-not-found
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/e05

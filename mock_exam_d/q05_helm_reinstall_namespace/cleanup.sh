#!/usr/bin/env bash
# d05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

for ns in owl raven; do
  if helm status podinfo -n "$ns" >/dev/null 2>&1; then
    helm uninstall podinfo -n "$ns" --wait
  fi
done
kubectl delete ns owl raven --ignore-not-found
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d05

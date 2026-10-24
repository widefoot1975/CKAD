#!/usr/bin/env bash
# f05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

if helm status frontend -n rhine >/dev/null 2>&1; then helm uninstall frontend -n rhine --wait; fi
if helm status backend -n thames >/dev/null 2>&1; then helm uninstall backend -n thames --wait; fi
kubectl delete ns rhine thames --ignore-not-found
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/f05

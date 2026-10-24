#!/usr/bin/env bash
# f14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns elbe --ignore-not-found --wait=true
kubectl delete crd backups.f14.example.com --ignore-not-found
rm -rf /opt/course/f14

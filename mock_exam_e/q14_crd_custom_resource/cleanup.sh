#!/usr/bin/env bash
# e14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns coral --ignore-not-found
kubectl delete crd backups.e14.example.com --ignore-not-found
rm -rf /opt/course/e14

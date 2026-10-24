#!/usr/bin/env bash
# a14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns xi --ignore-not-found
kubectl delete crd queues.a14.example.com --ignore-not-found
rm -rf /opt/course/a14

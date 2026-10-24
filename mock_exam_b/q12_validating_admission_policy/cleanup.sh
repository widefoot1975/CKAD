#!/usr/bin/env bash
# b12 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete validatingadmissionpolicybinding b12-require-team-and-limits-binding --ignore-not-found
kubectl delete validatingadmissionpolicy b12-require-team-and-limits --ignore-not-found
kubectl delete ns callisto --ignore-not-found
rm -rf /opt/course/b12

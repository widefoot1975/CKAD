#!/usr/bin/env bash
# c01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

CT=podman; command -v podman >/dev/null || CT=docker
$CT rm -f c01-web >/dev/null 2>&1 || true
$CT rmi -f localhost/c01-web:1.0.0 >/dev/null 2>&1 || true
kubectl delete ns oak --ignore-not-found
rm -rf /opt/course/c01

#!/usr/bin/env bash
# d01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

for ENG in podman docker; do
  command -v "$ENG" >/dev/null || continue
  "$ENG" rm -f robin-test >/dev/null 2>&1 || true
  "$ENG" rmi -f robin-web:v1 localhost/robin-web:v1 2>/dev/null || true
done
rm -rf /opt/course/d01

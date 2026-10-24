#!/usr/bin/env bash
# b01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

for E in podman docker; do
  if command -v "$E" >/dev/null; then
    "$E" rmi -f b01-app:single b01-app:multi >/dev/null 2>&1 || true
  fi
done
rm -rf /opt/course/b01

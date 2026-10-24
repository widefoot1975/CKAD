#!/usr/bin/env bash
# a01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

CE=$(command -v podman || command -v docker || true)
if [ -n "$CE" ]; then
  "$CE" rm -f orders-api-a01 >/dev/null 2>&1 || true
  "$CE" rmi -f localhost/orders-api:2.1.0 localhost/orders-api:stable 2>/dev/null || true
fi
rm -rf /opt/course/a01

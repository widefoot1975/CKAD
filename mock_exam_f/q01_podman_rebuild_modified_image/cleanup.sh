#!/usr/bin/env bash
# f01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

podman rmi -f localhost/f01-greeter:v2 localhost/f01-greeter:v1 2>/dev/null || true
docker rmi -f localhost/f01-greeter:v2 localhost/f01-greeter:v1 2>/dev/null || true
rm -rf /opt/course/f01

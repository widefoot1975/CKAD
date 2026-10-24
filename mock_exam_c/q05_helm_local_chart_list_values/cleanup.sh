#!/usr/bin/env bash
# c05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# --keep-history 로 남은 릴리스 기록까지 지운다 (옵션 없는 uninstall 은 남은 기록을 완전히 삭제)
helm uninstall inventory -n cedar >/dev/null 2>&1 || true
kubectl delete ns cedar --ignore-not-found
rm -rf /opt/course/c05

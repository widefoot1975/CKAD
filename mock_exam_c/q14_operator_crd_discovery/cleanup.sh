#!/usr/bin/env bash
# c14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# CRD 삭제는 그 CRD 의 커스텀 리소스(클러스터 범위 BackupStore 포함)도 모두 지운다
kubectl delete crd backups.c14.example.com restores.c14.example.com backupstores.c14.example.com \
  backups.c14x.example.com --ignore-not-found
kubectl delete ns rowan alder --ignore-not-found
rm -rf /opt/course/c14

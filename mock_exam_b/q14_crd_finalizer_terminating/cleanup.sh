#!/usr/bin/env bash
# b14 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# finalizer 가 남은 CR 이 있으면 ns/CRD 삭제가 멈추므로 먼저 뗀다
if kubectl get crd backups.b14.example.com >/dev/null 2>&1; then
  for b in $(kubectl get backups.b14.example.com -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" "}{end}'); do
    kubectl -n "${b%%/*}" patch backups.b14.example.com "${b##*/}" --type=merge -p '{"metadata":{"finalizers":null}}' || true
  done
fi
kubectl delete ns deimos --ignore-not-found
kubectl delete crd backups.b14.example.com --ignore-not-found
rm -rf /opt/course/b14

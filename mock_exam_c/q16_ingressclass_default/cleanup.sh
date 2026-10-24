#!/usr/bin/env bash
# c16 — 실습 후 정리
# 실행: bash cleanup.sh
# NGINX Ingress Controller 는 다른 문제도 쓰므로 지우지 않는다. 이 문제가 붙인 default 어노테이션만 뗀다.
set -euo pipefail

kubectl delete ns sequoia --ignore-not-found
kubectl delete ingressclass c16-legacy --ignore-not-found
kubectl annotate ingressclass nginx ingressclass.kubernetes.io/is-default-class- >/dev/null 2>&1 || true
rm -rf /opt/course/c16

#!/usr/bin/env bash
# d16 — 실습 후 정리
# 실행: bash cleanup.sh
# Ingress 컨트롤러(ns nginx-ingress)는 공용 인프라라 지우지 않는다.
set -euo pipefail

kubectl delete ns hawk --ignore-not-found
rm -rf /opt/course/d16

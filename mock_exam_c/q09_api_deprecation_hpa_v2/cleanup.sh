#!/usr/bin/env bash
# c09 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# 문제는 dry-run 만 요구하지만, 실수로 실제 적용했을 경우를 대비해 현재 namespace 의 web-hpa 를 지운다
kubectl delete hpa web-hpa --ignore-not-found
rm -rf /opt/course/c09

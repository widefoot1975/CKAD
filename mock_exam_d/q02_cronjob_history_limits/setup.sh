#!/usr/bin/env bash
# d02 — Schedule a CronJob with history limits · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns falcon --ignore-not-found --wait=true
rm -rf /opt/course/d02

# 1) namespace 와 답안 디렉터리
kubectl create ns falcon
mkdir -p /opt/course/d02

# 2) 시작 상태 확인: CronJob·Job 이 없어야 한다
kubectl -n falcon get cronjob,job

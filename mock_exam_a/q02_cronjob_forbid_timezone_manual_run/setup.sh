#!/usr/bin/env bash
# a02 — CronJob with concurrency, deadlines and a manual run · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns alpha --ignore-not-found --wait=true
rm -rf /opt/course/a02

# 1) 빈 namespace 와 결과 디렉터리
kubectl create ns alpha
mkdir -p /opt/course/a02

# 2) 시작 상태 확인: CronJob, Job 이 하나도 없어야 한다
kubectl -n alpha get cronjob,job

#!/usr/bin/env bash
# e01 — Run a parallel Job and collect its logs · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns ruby --ignore-not-found --wait=true
rm -rf /opt/course/e01

# 1) 빈 namespace 와 결과 파일 디렉터리
kubectl create ns ruby
mkdir -p /opt/course/e01

# 2) 시작 상태 확인: ruby 에는 Job 이 없다
kubectl -n ruby get jobs,pods
ls -ld /opt/course/e01

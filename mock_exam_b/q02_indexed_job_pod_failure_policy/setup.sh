#!/usr/bin/env bash
# b02 — Indexed Job with per-index retries and a pod failure policy · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns mercury --ignore-not-found --wait=true
rm -rf /opt/course/b02

# 1) 네임스페이스와 답안 디렉터리
kubectl create ns mercury
mkdir -p /opt/course/b02

# 2) 작업 스크립트와 샤드 입력 (샤드 2 는 손상됨)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: shard-data
  namespace: mercury
data:
  worker.sh: |
    #!/bin/sh
    # exit 42 = 설정 오류(입력 없음), exit 3 = 손상된 샤드, exit 0 = 성공
    i="${JOB_COMPLETION_INDEX:-}"
    f="/data/shard-$i.txt"
    if [ -z "$i" ] || [ ! -f "$f" ]; then
      echo "config error: no input for index '$i'"
      exit 42
    fi
    if grep -q CORRUPT "$f"; then
      echo "shard $i: corrupt input, giving up on this shard"
      exit 3
    fi
    echo "shard $i: processed $(wc -l < "$f") records"
    sleep 5
  shard-0.txt: |
    order-0001
    order-0002
  shard-1.txt: |
    order-0101
    order-0102
    order-0103
  shard-2.txt: |
    order-0201
    CORRUPT
  shard-3.txt: |
    order-0301
  shard-4.txt: |
    order-0401
    order-0402
YAML

# 3) 시작 상태 확인: ConfigMap 만 있고 Job 은 없다
kubectl -n mercury get cm shard-data
kubectl -n mercury get job 2>/dev/null | grep shard-worker || echo "Job shard-worker 없음 (정상)"

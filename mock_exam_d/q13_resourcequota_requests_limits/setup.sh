#!/usr/bin/env bash
# d13 — Fit a Pod under a ResourceQuota · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns finch --ignore-not-found --wait=true
rm -rf /opt/course/d13

# 1) namespace 와 ResourceQuota finch-quota
kubectl create ns finch
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: finch-quota
  namespace: finch
spec:
  hard:
    pods: "5"
    requests.cpu: 500m
    requests.memory: 256Mi
    limits.cpu: "1"
    limits.memory: 512Mi
YAML
# 쿼터 컨트롤러가 status 를 채울 때까지 기다린다 (그 전에는 파드 생성이 "status unknown for quota" 로 거부된다)
for i in $(seq 1 30); do
  [ -n "$(kubectl -n finch get quota finch-quota -o jsonpath='{.status.hard.pods}' 2>/dev/null)" ] && break
  sleep 2
done

# 2) 쿼터 일부를 이미 쓰고 있는 파드 finch-base (req 200m/128Mi, lim 400m/256Mi)
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: finch-base
  namespace: finch
spec:
  containers:
  - name: base
    image: busybox:1.36
    command: ["sh", "-c", "sleep 86400"]
    resources:
      requests:
        cpu: 200m
        memory: 128Mi
      limits:
        cpu: 400m
        memory: 256Mi
YAML
kubectl -n finch wait pod finch-base --for=condition=Ready --timeout=120s

# 3) 문제에서 고칠 매니페스트 (resources 없음)
mkdir -p /opt/course/d13
cat <<'YAML' > /opt/course/d13/finch-job.yaml
apiVersion: v1
kind: Pod
metadata:
  name: finch-job
  namespace: finch
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
YAML

# 4) 시작 상태 확인: Used requests.cpu 200m, finch-job 없음
kubectl -n finch describe quota finch-quota
kubectl -n finch get pod

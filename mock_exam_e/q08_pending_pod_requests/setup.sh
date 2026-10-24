#!/usr/bin/env bash
# e08 — Find why a pod is stuck in Pending · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns jade --ignore-not-found --wait=true
rm -rf /opt/course/e08

# 1) namespace 와 고장 난 매니페스트: cpu request 가 100m 이 아니라 "100"(100코어)
kubectl create ns jade
mkdir -p /opt/course/e08
cat > /opt/course/e08/report-gen.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: report-gen
  namespace: jade
  labels:
    app: report-gen
spec:
  containers:
  - name: report
    image: busybox:1.36
    command: ["sh", "-c", "echo generating reports; while true; do sleep 3600; done"]
    resources:
      requests:
        cpu: "100"
        memory: 64Mi
YAML
kubectl apply -f /opt/course/e08/report-gen.yaml

# 2) 스케줄러가 FailedScheduling 이벤트를 남길 때까지 기다린다
for i in $(seq 1 30); do
  kubectl -n jade get events --field-selector reason=FailedScheduling --no-headers 2>/dev/null | grep -q . && break
  sleep 2
done

# 3) 시작 상태 확인: Pending, NODE <none>
kubectl -n jade get pod report-gen -o wide

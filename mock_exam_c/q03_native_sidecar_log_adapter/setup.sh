#!/usr/bin/env bash
# c03 — Log adapter as a native sidecar with a startup probe · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns maple --ignore-not-found --wait=true
rm -rf /opt/course/c03
mkdir -p /opt/course/c03

# 1) 레거시 앱: 파일에만 "시각|레벨|메시지" 로그를 쓴다 (stdout 은 비어 있다)
kubectl create ns maple
cat > /opt/course/c03/legacy-app.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
  namespace: maple
  labels:
    app: legacy-app
spec:
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 4)) -eq 0 ]; then LVL=WARN; MSG="slow request $i"; else LVL=INFO; MSG="request $i served"; fi
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)|$LVL|$MSG" >> /var/log/legacy/app.log
        sleep 2
      done
    volumeMounts:
    - name: logs
      mountPath: /var/log/legacy
  volumes:
  - name: logs
    emptyDir: {}
YAML
kubectl apply -f /opt/course/c03/legacy-app.yaml
kubectl -n maple wait --for=condition=Ready pod/legacy-app --timeout=90s
sleep 5

# 2) 시작 상태 확인: 컨테이너 1개, stdout 비어 있음, 파일에는 로그가 쌓임
kubectl -n maple get pod legacy-app
echo "--- kubectl logs (비어 있어야 정상)"; kubectl -n maple logs legacy-app
echo "--- app.log"; kubectl -n maple exec legacy-app -- tail -n 3 /var/log/legacy/app.log

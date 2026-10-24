#!/usr/bin/env bash
# a03 — Init container and native sidecar sharing volumes · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns beta --ignore-not-found --wait=true
rm -rf /opt/course/a03

# 1) 빈 namespace
kubectl create ns beta
mkdir -p /opt/course/a03

# 2) 고장 난 초안: init 순서 뒤바뀜, 사이드카 restartPolicy 없음, mountPath 두 군데 불일치
#    (파일만 만들고 apply 하지 않는다)
cat > /opt/course/a03/log-pipeline.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: log-pipeline
  namespace: beta
spec:
  volumes:
  - name: config
    emptyDir: {}
  - name: logs
    emptyDir: {}
  initContainers:
  - name: log-tailer
    image: busybox:1.36
    command: ["sh", "-c", "touch /var/log/app/app.log; tail -n +1 -F /var/log/app/app.log"]
    volumeMounts:
    - name: logs
      mountPath: /logs
  - name: prepare
    image: busybox:1.36
    command: ["sh", "-c", "echo mode=production > /work/app.conf; echo prepared"]
    volumeMounts:
    - name: config
      mountPath: /config
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo \"$(date +%T) $(cat /etc/app/app.conf)\" >> /var/log/app/app.log; sleep 5; done"]
    volumeMounts:
    - name: config
      mountPath: /etc/app
      readOnly: true
    - name: logs
      mountPath: /var/log/app
YAML

# 3) 시작 상태 확인: 초안 파일은 있고 파드는 없다
ls -l /opt/course/a03/
kubectl -n beta get pod

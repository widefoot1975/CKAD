#!/usr/bin/env bash
# f08 — Debug a container that has no shell · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns yukon --ignore-not-found --wait=true
rm -rf /opt/course/f08

# 1) namespace 와 답안 디렉터리
kubectl create ns yukon
mkdir -p /opt/course/f08

# 2) Pod ledger: init 컨테이너가 무작위 build id 를 emptyDir 에 쓰고,
#    셸이 없는 이미지(http-echo, scratch 기반)의 컨테이너 app 이 그 파일을 /var/run/app 에 마운트한다
#    값은 로그나 매니페스트 어디에도 남지 않는다 — 컨테이너 app 의 파일 시스템에만 있다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ledger
  namespace: yukon
  labels:
    app: ledger
spec:
  initContainers:
  - name: init-build-id
    image: busybox:1.36
    command:
    - sh
    - -c
    - printf 'f08-%s\n' "$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')" > /work/build-id
    volumeMounts:
    - name: work
      mountPath: /work
  containers:
  - name: app
    image: hashicorp/http-echo:1.0
    args: ["-text=ledger", "-listen=:5678"]
    ports:
    - containerPort: 5678
    volumeMounts:
    - name: work
      mountPath: /var/run/app
      readOnly: true
  volumes:
  - name: work
    emptyDir: {}
YAML
kubectl -n yukon wait pod ledger --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: Pod 는 Ready, exec 로 셸을 열 수 없다
kubectl -n yukon get pod ledger
kubectl -n yukon exec ledger -c app -- sh -c 'true' 2>&1 | tail -1 || true

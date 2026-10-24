#!/usr/bin/env bash
# d08 — Find the busiest Pod with kubectl top · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns magpie --ignore-not-found --wait=true
rm -rf /opt/course/d08

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요, 이미 있으면 그대로 둔다)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + 파드 세 개: CPU 를 태우는 worker-1(최대 100m)·worker-2(최대 400m), 노는 worker-3
#    busy loop 에 CPU limit 을 걸어 두어 순위가 매번 같게 나온다 (정답은 이름순 마지막이 아닌 worker-2)
kubectl create ns magpie
for spec in worker-1:100m worker-2:400m; do
  name=${spec%%:*}; cpu=${spec##*:}
  kubectl -n magpie run "$name" --image=busybox:1.36 --labels=app=worker \
    --overrides="{\"spec\":{\"containers\":[{\"name\":\"$name\",\"image\":\"busybox:1.36\",\"command\":[\"sh\",\"-c\",\"while true; do :; done\"],\"resources\":{\"requests\":{\"cpu\":\"50m\"},\"limits\":{\"cpu\":\"$cpu\"}}}]}}"
done
kubectl -n magpie run worker-3 --image=busybox:1.36 --labels=app=worker -- sleep 86400
kubectl -n magpie wait pod --all --for=condition=Ready --timeout=120s

# 3) 답안 디렉터리
mkdir -p /opt/course/d08

# 4) 시작 상태 확인: 첫 수집까지 기다린다 (1분 정도 걸릴 수 있음)
kubectl -n magpie get pods
for i in $(seq 1 30); do
  kubectl top pod -n magpie >/dev/null 2>&1 && break
  sleep 5
done
kubectl top pod -n magpie || echo "아직 메트릭이 없다. 1분 뒤 kubectl top pod -n magpie 로 다시 확인"

#!/usr/bin/env bash
# c11 — Grant cross-namespace ConfigMap read with a RoleBinding · 사전 환경 설정
# 실행: bash setup.sh   (ckad-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns juniper larch --ignore-not-found --wait=true
kubectl delete clusterrole c11-configmap-reader --ignore-not-found
kubectl delete clusterrolebinding config-sync-reader --ignore-not-found
rm -rf /opt/course/c11
mkdir -p /opt/course/c11

# 1) 재사용할 ClusterRole (configmaps 읽기 전용)
cat <<'YAML' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: c11-configmap-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
YAML

# 2) 읽힐 쪽 namespace larch: ConfigMap 2개 + 읽히면 안 되는 Secret
kubectl create ns larch
kubectl -n larch create configmap app-settings --from-literal=mode=prod --from-literal=region=eu-west-1
kubectl -n larch create configmap feature-flags --from-literal=newCheckout=true
kubectl -n larch create secret generic db-pass --from-literal=password=do-not-read

# 3) 읽는 쪽 namespace juniper: SA config-sync 와 그 SA 로 도는 curl 파드
kubectl create ns juniper
kubectl -n juniper create serviceaccount config-sync
kubectl -n juniper create configmap local-only --from-literal=x=1
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sync-agent
  namespace: juniper
spec:
  serviceAccountName: config-sync
  containers:
  - name: agent
    image: curlimages/curl:8.10.1
    command: ["sh", "-c", "while true; do sleep 3600; done"]
YAML
kubectl -n juniper wait --for=condition=Ready pod/sync-agent --timeout=90s

# 4) 시작 상태 확인: 아직 권한 없음
kubectl auth can-i list configmaps -n larch --as=system:serviceaccount:juniper:config-sync || true
kubectl -n larch get rolebinding

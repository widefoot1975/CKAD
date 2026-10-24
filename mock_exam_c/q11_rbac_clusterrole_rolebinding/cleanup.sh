#!/usr/bin/env bash
# c11 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns juniper larch --ignore-not-found
kubectl delete clusterrole c11-configmap-reader --ignore-not-found
# 실수로 같은 이름의 ClusterRoleBinding 을 만들었을 경우까지 정리
kubectl delete clusterrolebinding config-sync-reader --ignore-not-found
rm -rf /opt/course/c11

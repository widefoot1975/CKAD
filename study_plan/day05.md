# 5일차 (D-6) — Helm · Kustomize

[← 4일차](day04.md) · [계획 전체](README.md) · [6일차 →](day06.md)

## 오늘의 목표

- Helm 으로 설치·업그레이드·롤백하고 values 를 잃지 않는 법을 익힙니다.
- Kustomize v5 문법(`labels`, `patches`)으로 overlay 를 만듭니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §3 Helm·Kustomize, 루트 README 의 Helm 4·Bitnami·Kustomize v5 행 |
| 0:15 – 0:41 | 아래 문제 4개 풀기 |
| 0:41 – 0:53 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:53 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D05 | Deployment | Helm 릴리스를 올바른 네임스페이스로 | 7 | 7분 | [Q](../mock_exam_d/q05_helm_reinstall_namespace/question.md) · [S](../mock_exam_d/q05_helm_reinstall_namespace/solution.md) ☐ |
| E05 | Deployment | Helm 설치·업그레이드·롤백 | 7 | 7분 | [Q](../mock_exam_e/q05_helm_values_upgrade_rollback/question.md) · [S](../mock_exam_e/q05_helm_values_upgrade_rollback/solution.md) ☐ |
| D06 | Deployment | Kustomize overlay | 6 | 6분 | [Q](../mock_exam_d/q06_kustomize_overlay/question.md) · [S](../mock_exam_d/q06_kustomize_overlay/solution.md) ☐ |
| E06 | Deployment | Kustomize ConfigMap generator 와 env 패치 | 6 | 6분 | [Q](../mock_exam_e/q06_kustomize_configmap_patch/question.md) · [S](../mock_exam_e/q06_kustomize_configmap_patch/solution.md) ☐ |

합계 26점, 목표 26분.

## 꼭 잡을 것

```bash
helm show values podinfo/podinfo > values.yaml
helm install web podinfo/podinfo -n ns --create-namespace --version 6.x.y -f values.yaml
helm upgrade web podinfo/podinfo -n ns --reuse-values --set replicaCount=3
helm history web -n ns ; helm rollback web 1 -n ns
kubectl kustomize overlays/prod ; kubectl apply -k overlays/prod
```

- Helm 릴리스는 **네임스페이스별**입니다. `helm list` 에 안 보이면 `-A` 로 찾습니다.
- `--reuse-values` 없이 `--set` 만 주면 이전에 준 값이 기본값으로 돌아갑니다.
- Kustomize v5: `commonLabels` → `labels`, `patchesStrategicMerge` → `patches`. generator 로 만든 ConfigMap 이름에는 해시가 붙고, 참조는 kustomize 가 알아서 고칩니다.

## 여유가 있으면

- 심화 [A05 로컬 Helm 차트 렌더링·업그레이드·롤백](../mock_exam_a/q05_helm_local_chart_upgrade_rollback/question.md)
- 심화 [A06 Kustomize prod overlay 완성](../mock_exam_a/q06_kustomize_prod_overlay_generator/question.md)

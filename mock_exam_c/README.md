# mock_exam_c

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 심화 — 문항마다 개념 두세 개를 섞은 여러 단계 작업이고, 각 문항에 함정이 하나씩 있습니다 |
| 응시일 |  |
| 제한 시간 | 120분 (목표 시간 합계 106분, 여유 14분) |
| 실제 소요 |  |
| 점수 | / 100 (합격선 66) |

문제는 영문(`question.md`), 풀이는 한글(`solution.md`)입니다. `solution.md` 맨 앞에 한글 해석이 있으니, 풀이를 보기 전에 영문을 제대로 읽었는지 먼저 대조하세요.

각 문제는 `## Setup` 의 `setup.sh` 로 상황을 만든 뒤, 메타 표의 `Host` 로 `ssh` 해서 풉니다. 실제 시험에서는 지정 호스트가 아닌 곳에서 작업하면 0점이고, 문제를 마치면 `exit` 로 베이스 터미널에 돌아온 뒤 다음 문제의 호스트로 들어갑니다.

## 문항

`목표`는 배점에 비례해 배분한 **시간 예산**입니다 (일반 문항 배점×1분, Observability 배점×1.33분). 걸린 시간과 점수는 각 `question.md` 맨 아래 `## Record` 에만 적고 `python3 scripts/update_progress.py` 를 실행하세요. 이 표의 `실제`·`결과` 와 아래 도메인별 실점이 채워집니다.

| # | 문제 | 도메인 | 배점 | 목표 | 실제 | 결과 | 링크 |
|---|---|---|---|---|---|---|---|
| 01 | Build a labelled image and reuse its config in a Pod | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_podman_oci_labels_configmap/question.md) · [S](q01_podman_oci_labels_configmap/solution.md) |
| 02 | Run an agent on every node and a self-cleaning Job | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_daemonset_toleration_job_ttl/question.md) · [S](q02_daemonset_toleration_job_ttl/solution.md) |
| 03 | Log adapter as a native sidecar with a startup probe | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_native_sidecar_log_adapter/question.md) · [S](q03_native_sidecar_log_adapter/solution.md) |
| 04 | Detect a stalled rollout and undo to a chosen revision | Deployment | 7 | 7분 |  | ☐ | [Q](q04_rollout_deadline_undo_revision/question.md) · [S](q04_rollout_deadline_undo_revision/solution.md) |
| 05 | Install a local Helm chart with list values and keep its history | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_local_chart_list_values/question.md) · [S](q05_helm_local_chart_list_values/solution.md) |
| 06 | Kustomize overlay with a generated Secret | Deployment | 6 | 6분 |  | ☐ | [Q](q06_kustomize_secretgenerator_overlay/question.md) · [S](q06_kustomize_secretgenerator_overlay/solution.md) |
| 07 | Graceful shutdown with preStop and the grace period | Observability | 5 | 7분 |  | ☐ | [Q](q07_graceful_shutdown_prestop/question.md) · [S](q07_graceful_shutdown_prestop/solution.md) |
| 08 | Triage several broken Pods from events | Observability | 5 | 7분 |  | ☐ | [Q](q08_events_triage_broken_pods/question.md) · [S](q08_events_triage_broken_pods/solution.md) |
| 09 | Find preferred API versions and migrate an HPA to v2 | Observability | 5 | 7분 |  | ☐ | [Q](q09_api_deprecation_hpa_v2/question.md) · [S](q09_api_deprecation_hpa_v2/solution.md) |
| 10 | Rotate an immutable Secret | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_immutable_secret_rotation/question.md) · [S](q10_immutable_secret_rotation/solution.md) |
| 11 | Grant cross-namespace ConfigMap read with a RoleBinding | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_rbac_clusterrole_rolebinding/question.md) · [S](q11_rbac_clusterrole_rolebinding/solution.md) |
| 12 | QoS classes under a LimitRange | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_qos_classes_limitrange/question.md) · [S](q12_qos_classes_limitrange/solution.md) |
| 13 | SecurityContext precedence and a read-only root filesystem | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_securitycontext_readonly_rootfs/question.md) · [S](q13_securitycontext_readonly_rootfs/solution.md) |
| 14 | Discover an operator's CRDs and create a custom resource | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_operator_crd_discovery/question.md) · [S](q14_operator_crd_discovery/solution.md) |
| 15 | Repair a Service port and add an ExternalName alias | Networking | 7 | 7분 |  | ☐ | [Q](q15_service_targetport_externalname/question.md) · [S](q15_service_targetport_externalname/solution.md) |
| 16 | Serve an Ingress through the right IngressClass | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingressclass_default/question.md) · [S](q16_ingressclass_default/solution.md) |
| 17 | Repair a NetworkPolicy with three faults | Networking | 6 | 6분 |  | ☐ | [Q](q17_networkpolicy_three_faults/question.md) · [S](q17_networkpolicy_three_faults/solution.md) |
|  | **합계** |  | **100** | **106분** |  |  |  |

## 도메인별 실점

| 도메인 | 비중 | 배점 합 | 목표 시간 | 획득 | 손실 |
|---|---|---|---|---|---|
| Application Design and Build | 20% | 20 | 20분 |  |  |
| Application Deployment | 20% | 20 | 20분 |  |  |
| Application Observability and Maintenance | 15% | 15 | 21분 |  |  |
| Application Environment, Configuration and Security | 25% | 25 | 25분 |  |  |
| Services and Networking | 20% | 20 | 20분 |  |  |

## 회고

**잘한 것**

-

**놓친 것**

-

**시간을 많이 쓴 문항** (목표 대비 초과)

-

**다음 회차까지 할 것**

- [ ]

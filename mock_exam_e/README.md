# mock_exam_e

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 기본 — 한 문항에 한 개념, 2~4단계의 짧은 작업으로 커리큘럼 전 범위를 한 바퀴 돕니다 |
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
| 01 | Run a parallel Job and collect its logs | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_job_completions_parallelism/question.md) · [S](q01_job_completions_parallelism/solution.md) |
| 02 | Run a log agent on every worker node | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_daemonset_log_agent/question.md) · [S](q02_daemonset_log_agent/solution.md) |
| 03 | Tail an application log with a native sidecar | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_native_sidecar_log_tail/question.md) · [S](q03_native_sidecar_log_tail/solution.md) |
| 04 | Switch a Service from blue to green | Deployment | 7 | 7분 |  | ☐ | [Q](q04_blue_green_service_switch/question.md) · [S](q04_blue_green_service_switch/solution.md) |
| 05 | Install, upgrade and roll back a Helm release | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_values_upgrade_rollback/question.md) · [S](q05_helm_values_upgrade_rollback/solution.md) |
| 06 | Kustomize a ConfigMap generator and an env patch | Deployment | 6 | 6분 |  | ☐ | [Q](q06_kustomize_configmap_patch/question.md) · [S](q06_kustomize_configmap_patch/solution.md) |
| 07 | Add startup and liveness probes to a slow app | Observability | 5 | 7분 |  | ☐ | [Q](q07_startup_liveness_probe/question.md) · [S](q07_startup_liveness_probe/solution.md) |
| 08 | Find why a pod is stuck in Pending | Observability | 5 | 7분 |  | ☐ | [Q](q08_pending_pod_requests/question.md) · [S](q08_pending_pod_requests/solution.md) |
| 09 | Repair manifests that use removed API versions | Observability | 5 | 7분 |  | ☐ | [Q](q09_fix_removed_api_versions/question.md) · [S](q09_fix_removed_api_versions/solution.md) |
| 10 | Mount one Secret key as a read-only file | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_secret_volume_key_mode/question.md) · [S](q10_secret_volume_key_mode/solution.md) |
| 11 | Apply default resources with a LimitRange | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_limitrange_defaults/question.md) · [S](q11_limitrange_defaults/solution.md) |
| 12 | Let a ServiceAccount list pods | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_rbac_serviceaccount_pods/question.md) · [S](q12_rbac_serviceaccount_pods/solution.md) |
| 13 | Admit a pod under the restricted Pod Security level | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_pod_security_restricted/question.md) · [S](q13_pod_security_restricted/solution.md) |
| 14 | Create a custom resource from an existing CRD | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_crd_custom_resource/question.md) · [S](q14_crd_custom_resource/solution.md) |
| 15 | Repair a NodePort Service with a wrong targetPort | Networking | 7 | 7분 |  | ☐ | [Q](q15_nodeport_targetport_fix/question.md) · [S](q15_nodeport_targetport_fix/solution.md) |
| 16 | Route two hosts with one Ingress | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingress_host_rules/question.md) · [S](q16_ingress_host_rules/solution.md) |
| 17 | Default-deny ingress and allow only the frontend | Networking | 6 | 6분 |  | ☐ | [Q](q17_networkpolicy_default_deny/question.md) · [S](q17_networkpolicy_default_deny/solution.md) |
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

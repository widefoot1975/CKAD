# mock_exam_b

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 심화 — 여러 개념을 섞은 다단계 과제이고, 문항마다 함정이 하나씩 있습니다 |
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
| 01 | Multi-stage build with a non-root image | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_multistage_dockerfile_nonroot/question.md) · [S](q01_multistage_dockerfile_nonroot/solution.md) |
| 02 | Indexed Job with per-index retries and a pod failure policy | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_indexed_job_pod_failure_policy/question.md) · [S](q02_indexed_job_pod_failure_policy/solution.md) |
| 03 | Memory-backed and generic ephemeral volumes | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_ephemeral_volumes_memory_generic/question.md) · [S](q03_ephemeral_volumes_memory_generic/solution.md) |
| 04 | Canary release behind a shared Service | Deployment | 7 | 7분 |  | ☐ | [Q](q04_canary_deployment_promote/question.md) · [S](q04_canary_deployment_promote/solution.md) |
| 05 | Upgrade and roll back a Helm release without losing values | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_upgrade_reuse_rollback/question.md) · [S](q05_helm_upgrade_reuse_rollback/solution.md) |
| 06 | Kustomize patches with target selectors and labels | Deployment | 6 | 6분 |  | ☐ | [Q](q06_kustomize_patches_target_labels/question.md) · [S](q06_kustomize_patches_target_labels/solution.md) |
| 07 | Unblock a rollout gated by a readiness probe | Observability | 5 | 7분 |  | ☐ | [Q](q07_readiness_probe_stuck_rollout/question.md) · [S](q07_readiness_probe_stuck_rollout/solution.md) |
| 08 | Debug a container that has no shell | Observability | 5 | 7분 |  | ☐ | [Q](q08_debug_distroless_ephemeral/question.md) · [S](q08_debug_distroless_ephemeral/solution.md) |
| 09 | Find a memory hog and an OOMKilled container | Observability | 5 | 7분 |  | ☐ | [Q](q09_top_memory_oomkilled/question.md) · [S](q09_top_memory_oomkilled/solution.md) |
| 10 | Resize a running Pod in place | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_inplace_pod_resize/question.md) · [S](q10_inplace_pod_resize/solution.md) |
| 11 | Projected ServiceAccount token with a custom audience | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_projected_sa_token_audience/question.md) · [S](q11_projected_sa_token_audience/solution.md) |
| 12 | Get a Deployment past a ValidatingAdmissionPolicy | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_validating_admission_policy/question.md) · [S](q12_validating_admission_policy/solution.md) |
| 13 | Non-root Pod with fsGroup and minimal capabilities | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_securitycontext_fsgroup_capabilities/question.md) · [S](q13_securitycontext_fsgroup_capabilities/solution.md) |
| 14 | Custom resources and a stuck finalizer | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_crd_finalizer_terminating/question.md) · [S](q14_crd_finalizer_terminating/solution.md) |
| 15 | StatefulSet pod DNS through a headless Service | Networking | 7 | 7분 |  | ☐ | [Q](q15_statefulset_headless_dns/question.md) · [S](q15_statefulset_headless_dns/solution.md) |
| 16 | Repair an Ingress that serves two hosts | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingress_named_port_pathtype/question.md) · [S](q16_ingress_named_port_pathtype/solution.md) |
| 17 | Open precise paths through a default-deny namespace | Networking | 6 | 6분 |  | ☐ | [Q](q17_networkpolicy_default_deny_allow/question.md) · [S](q17_networkpolicy_default_deny_allow/solution.md) |
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

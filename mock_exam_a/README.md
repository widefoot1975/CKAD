# mock_exam_a

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 심화 — 한 문제에 여러 개념과 단계가 섞이고, 문제마다 함정이 하나 이상 숨어 있습니다 |
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
| 01 | Fix a Dockerfile, build and save an OCI image | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_dockerfile_fix_build_oci_archive/question.md) · [S](q01_dockerfile_fix_build_oci_archive/solution.md) |
| 02 | CronJob with concurrency, deadlines and a manual run | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_cronjob_forbid_timezone_manual_run/question.md) · [S](q02_cronjob_forbid_timezone_manual_run/solution.md) |
| 03 | Init container and native sidecar sharing volumes | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_init_native_sidecar_shared_volume/question.md) · [S](q03_init_native_sidecar_shared_volume/solution.md) |
| 04 | Blue/green switch behind a Service | Deployment | 7 | 7분 |  | ☐ | [Q](q04_blue_green_service_switch/question.md) · [S](q04_blue_green_service_switch/solution.md) |
| 05 | Render, upgrade and roll back a local Helm chart | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_local_chart_upgrade_rollback/question.md) · [S](q05_helm_local_chart_upgrade_rollback/solution.md) |
| 06 | Complete a Kustomize prod overlay | Deployment | 6 | 6분 |  | ☐ | [Q](q06_kustomize_prod_overlay_generator/question.md) · [S](q06_kustomize_prod_overlay_generator/solution.md) |
| 07 | Rescue a slow-starting app with a startupProbe | Observability | 5 | 7분 |  | ☐ | [Q](q07_startup_probe_slow_app/question.md) · [S](q07_startup_probe_slow_app/solution.md) |
| 08 | Debug a CrashLoopBackOff Deployment | Observability | 5 | 7분 |  | ☐ | [Q](q08_crashloop_configmap_key_command/question.md) · [S](q08_crashloop_configmap_key_command/solution.md) |
| 09 | Migrate manifests off removed API versions | Observability | 5 | 7분 |  | ☐ | [Q](q09_migrate_removed_api_versions/question.md) · [S](q09_migrate_removed_api_versions/solution.md) |
| 10 | Projected volume from a ConfigMap and a Secret | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_projected_volume_configmap_secret/question.md) · [S](q10_projected_volume_configmap_secret/solution.md) |
| 11 | ServiceAccount with least-privilege RBAC | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_serviceaccount_rbac_can_i/question.md) · [S](q11_serviceaccount_rbac_can_i/solution.md) |
| 12 | Fit a Deployment into a ResourceQuota and LimitRange | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_quota_limitrange_guaranteed_qos/question.md) · [S](q12_quota_limitrange_guaranteed_qos/solution.md) |
| 13 | Make a Deployment pass Pod Security restricted | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_pod_security_restricted_fix/question.md) · [S](q13_pod_security_restricted_fix/solution.md) |
| 14 | Work with a CRD that has a schema and a scale subresource | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_crd_schema_scale_subresource/question.md) · [S](q14_crd_schema_scale_subresource/solution.md) |
| 15 | Repair a multi-port Service with no endpoints | Networking | 7 | 7분 |  | ☐ | [Q](q15_multiport_service_no_endpoints/question.md) · [S](q15_multiport_service_no_endpoints/solution.md) |
| 16 | TLS Ingress with two paths and a default backend | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingress_tls_two_paths_default_backend/question.md) · [S](q16_ingress_tls_two_paths_default_backend/solution.md) |
| 17 | Three-tier NetworkPolicy across namespaces | Networking | 6 | 6분 |  | ☐ | [Q](q17_networkpolicy_three_tier_and_or/question.md) · [S](q17_networkpolicy_three_tier_and_or/solution.md) |
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

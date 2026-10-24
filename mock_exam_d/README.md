# mock_exam_d

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 기본 — 문항마다 개념 하나를 2~4단계로 빠르게 확인하는 회차 |
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
| 01 | Build and save a container image with Podman | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_podman_build_save_image/question.md) · [S](q01_podman_build_save_image/solution.md) |
| 02 | Schedule a CronJob with history limits | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_cronjob_history_limits/question.md) · [S](q02_cronjob_history_limits/solution.md) |
| 03 | Prepare web content with an init container | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_init_container_emptydir/question.md) · [S](q03_init_container_emptydir/solution.md) |
| 04 | Rolling update and rollback of a Deployment | Deployment | 7 | 7분 |  | ☐ | [Q](q04_rolling_update_rollback/question.md) · [S](q04_rolling_update_rollback/solution.md) |
| 05 | Move a Helm release to the right namespace | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_reinstall_namespace/question.md) · [S](q05_helm_reinstall_namespace/solution.md) |
| 06 | Customize a Deployment with a Kustomize overlay | Deployment | 6 | 6분 |  | ☐ | [Q](q06_kustomize_overlay/question.md) · [S](q06_kustomize_overlay/solution.md) |
| 07 | Add liveness and readiness probes | Observability | 5 | 7분 |  | ☐ | [Q](q07_liveness_readiness_probes/question.md) · [S](q07_liveness_readiness_probes/solution.md) |
| 08 | Find the busiest Pod with kubectl top | Observability | 5 | 7분 |  | ☐ | [Q](q08_top_pod_cpu/question.md) · [S](q08_top_pod_cpu/solution.md) |
| 09 | Read the logs of a crashed container | Observability | 5 | 7분 |  | ☐ | [Q](q09_logs_previous_container/question.md) · [S](q09_logs_previous_container/solution.md) |
| 10 | Configure a Pod from a ConfigMap | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_configmap_file_env/question.md) · [S](q10_configmap_file_env/solution.md) |
| 11 | Inject a Secret with envFrom | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_secret_envfrom/question.md) · [S](q11_secret_envfrom/solution.md) |
| 12 | Run a Deployment with a dedicated ServiceAccount | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_serviceaccount_deployment/question.md) · [S](q12_serviceaccount_deployment/solution.md) |
| 13 | Fit a Pod under a ResourceQuota | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_resourcequota_requests_limits/question.md) · [S](q13_resourcequota_requests_limits/solution.md) |
| 14 | Harden a Pod with a securityContext | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_securitycontext_busybox/question.md) · [S](q14_securitycontext_busybox/solution.md) |
| 15 | Expose a Deployment with a ClusterIP Service | Networking | 7 | 7분 |  | ☐ | [Q](q15_clusterip_service_endpointslice/question.md) · [S](q15_clusterip_service_endpointslice/solution.md) |
| 16 | Route two paths with an Ingress | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingress_two_paths/question.md) · [S](q16_ingress_two_paths/solution.md) |
| 17 | Reach a backend through NetworkPolicies by relabeling a Pod | Networking | 6 | 6분 |  | ☐ | [Q](q17_networkpolicy_pod_label/question.md) · [S](q17_networkpolicy_pod_label/solution.md) |
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

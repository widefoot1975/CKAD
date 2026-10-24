# mock_exam_f

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKAD 커리큘럼 v1.37 비중 반영) |
| 성격 | 기본 — 문항마다 개념 하나, 2~4단계의 짧은 작업으로 기본 명령과 필드를 손에 익히는 세트 |
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
| 01 | Modify a Dockerfile and rebuild the image | Design & Build | 7 | 7분 |  | ☐ | [Q](q01_podman_rebuild_modified_image/question.md) · [S](q01_podman_rebuild_modified_image/solution.md) |
| 02 | Turn a standalone Pod into a Deployment | Design & Build | 7 | 7분 |  | ☐ | [Q](q02_pod_to_deployment/question.md) · [S](q02_pod_to_deployment/solution.md) |
| 03 | Persist data with a PersistentVolumeClaim | Design & Build | 6 | 6분 |  | ☐ | [Q](q03_pvc_local_path_persistence/question.md) · [S](q03_pvc_local_path_persistence/solution.md) |
| 04 | Canary release with replica ratios | Deployment | 7 | 7분 |  | ☐ | [Q](q04_canary_shared_service/question.md) · [S](q04_canary_shared_service/solution.md) |
| 05 | Upgrade the outdated Helm release | Deployment | 7 | 7분 |  | ☐ | [Q](q05_helm_upgrade_outdated_release/question.md) · [S](q05_helm_upgrade_outdated_release/solution.md) |
| 06 | Batch Deployment changes with rollout pause | Deployment | 6 | 6분 |  | ☐ | [Q](q06_rollout_pause_resume/question.md) · [S](q06_rollout_pause_resume/solution.md) |
| 07 | Fix a readiness probe on the wrong port | Observability | 5 | 7분 |  | ☐ | [Q](q07_readiness_probe_wrong_port/question.md) · [S](q07_readiness_probe_wrong_port/solution.md) |
| 08 | Debug a container that has no shell | Observability | 5 | 7분 |  | ☐ | [Q](q08_debug_shellless_container/question.md) · [S](q08_debug_shellless_container/solution.md) |
| 09 | Read logs from a multi-container Pod | Observability | 5 | 7분 |  | ☐ | [Q](q09_multi_container_logs/question.md) · [S](q09_multi_container_logs/solution.md) |
| 10 | Roll out a ConfigMap change and lock it | Env & Security | 5 | 5분 |  | ☐ | [Q](q10_configmap_env_restart_immutable/question.md) · [S](q10_configmap_env_restart_immutable/solution.md) |
| 11 | ServiceAccount token and automount | Env & Security | 5 | 5분 |  | ☐ | [Q](q11_serviceaccount_token_automount/question.md) · [S](q11_serviceaccount_token_automount/solution.md) |
| 12 | Grant a single Linux capability | Env & Security | 5 | 5분 |  | ☐ | [Q](q12_container_capabilities/question.md) · [S](q12_container_capabilities/solution.md) |
| 13 | ResourceQuota blocks Deployment replicas | Env & Security | 5 | 5분 |  | ☐ | [Q](q13_resourcequota_blocks_replicas/question.md) · [S](q13_resourcequota_blocks_replicas/solution.md) |
| 14 | Explore a CRD and create a custom resource | Env & Security | 5 | 5분 |  | ☐ | [Q](q14_crd_explain_custom_resource/question.md) · [S](q14_crd_explain_custom_resource/solution.md) |
| 15 | Service with a wrong selector | Networking | 7 | 7분 |  | ☐ | [Q](q15_service_selector_mismatch/question.md) · [S](q15_service_selector_mismatch/solution.md) |
| 16 | Repair a broken Ingress | Networking | 7 | 7분 |  | ☐ | [Q](q16_ingress_fix_port_and_class/question.md) · [S](q16_ingress_fix_port_and_class/solution.md) |
| 17 | Restrict egress to DNS and one backend | Networking | 6 | 6분 |  | ☐ | [Q](q17_egress_networkpolicy_dns_backend/question.md) · [S](q17_egress_networkpolicy_dns_backend/solution.md) |
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

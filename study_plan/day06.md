# 6일차 (D-5) — probe · 로그 · top · API deprecation

[← 5일차](day05.md) · [계획 전체](README.md) · [7일차 →](day07.md)

## 오늘의 목표

- 세 가지 probe 가 실패할 때 각각 무슨 일이 일어나는지 구분합니다.
- 원인을 좁히는 순서(`describe` → `logs --previous` → `top` → `debug`)를 몸에 붙입니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §4 Application Observability and Maintenance |
| 0:15 – 0:50 | 아래 문제 5개 풀기 |
| 0:50 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D07 | Observability | liveness·readiness probe 추가 | 5 | 7분 | [Q](../mock_exam_d/q07_liveness_readiness_probes/question.md) · [S](../mock_exam_d/q07_liveness_readiness_probes/solution.md) ☐ |
| E07 | Observability | 느린 앱에 startup·liveness probe | 5 | 7분 | [Q](../mock_exam_e/q07_startup_liveness_probe/question.md) · [S](../mock_exam_e/q07_startup_liveness_probe/solution.md) ☐ |
| D08 | Observability | kubectl top 으로 가장 바쁜 파드 | 5 | 7분 | [Q](../mock_exam_d/q08_top_pod_cpu/question.md) · [S](../mock_exam_d/q08_top_pod_cpu/solution.md) ☐ |
| D09 | Observability | 죽은 컨테이너의 로그 읽기 | 5 | 7분 | [Q](../mock_exam_d/q09_logs_previous_container/question.md) · [S](../mock_exam_d/q09_logs_previous_container/solution.md) ☐ |
| E09 | Observability | 제거된 API 버전 매니페스트 고치기 | 5 | 7분 | [Q](../mock_exam_e/q09_fix_removed_api_versions/question.md) · [S](../mock_exam_e/q09_fix_removed_api_versions/solution.md) ☐ |

합계 25점, 목표 35분.

## 꼭 잡을 것

```bash
kubectl describe pod p | tail -20                  # Events 가 맨 아래
kubectl logs p -c c --previous --tail=50
kubectl top pod -A --sort-by=cpu ; kubectl top pod p --containers
kubectl api-versions | grep autoscaling ; kubectl explain hpa | head -3
kubectl debug -it p --image=busybox:1.36 --target=app
```

- `startupProbe` 가 통과하기 전에는 나머지 probe 가 멈춥니다. readiness 실패는 Service 에서 빠질 뿐 재시작하지 않고, liveness 실패만 재시작합니다.
- 종료 코드: 137 SIGKILL(OOM 포함), 143 SIGTERM, 127 명령 없음.
- 제거된 API 는 `no matches for kind` 로 나옵니다. Ingress `networking.k8s.io/v1` 은 `pathType` 이 필수입니다.

## 여유가 있으면

- 심화 [A07 startupProbe 로 느린 앱 살리기](../mock_exam_a/q07_startup_probe_slow_app/question.md)
- 심화 [A08 CrashLoopBackOff Deployment 디버깅](../mock_exam_a/q08_crashloop_configmap_key_command/question.md)

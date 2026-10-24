# 4일차 (D-7) — 배포 전략 (롤링 · blue/green · canary)

[← 3일차](day03.md) · [계획 전체](README.md) · [5일차 →](day05.md)

## 오늘의 목표

- `kubectl rollout` 하위 명령(status·history·undo·pause·resume)을 손에 익힙니다.
- blue/green 은 **Service 셀렉터만**, canary 는 **replicas 비율**로 만든다는 차이를 정리합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §3 Application Deployment 앞부분 (rollout, blue/green, canary) |
| 0:15 – 0:42 | 아래 문제 4개 풀기 |
| 0:42 – 0:54 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:54 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D04 | Deployment | 롤링 업데이트와 롤백 | 7 | 7분 | [Q](../mock_exam_d/q04_rolling_update_rollback/question.md) · [S](../mock_exam_d/q04_rolling_update_rollback/solution.md) ☐ |
| E04 | Deployment | blue → green Service 전환 | 7 | 7분 | [Q](../mock_exam_e/q04_blue_green_service_switch/question.md) · [S](../mock_exam_e/q04_blue_green_service_switch/solution.md) ☐ |
| F04 | Deployment | 레플리카 비율로 canary | 7 | 7분 | [Q](../mock_exam_f/q04_canary_shared_service/question.md) · [S](../mock_exam_f/q04_canary_shared_service/solution.md) ☐ |
| F06 | Deployment | rollout pause 로 변경 묶기 | 6 | 6분 | [Q](../mock_exam_f/q06_rollout_pause_resume/question.md) · [S](../mock_exam_f/q06_rollout_pause_resume/solution.md) ☐ |

합계 27점, 목표 27분.

## 꼭 잡을 것

```bash
kubectl set image deploy/web nginx=nginx:1.27      # 컨테이너이름=이미지
kubectl rollout status deploy web
kubectl rollout history deploy web --revision=3
kubectl rollout undo deploy web --to-revision=2
kubectl rollout pause deploy web ; kubectl rollout resume deploy web
kubectl patch svc web -p '{"spec":{"selector":{"version":"green"}}}'
```

- `set image` 의 가운데는 **컨테이너 이름**입니다. Deployment 이름이 아닙니다.
- canary 는 두 Deployment 에 공통 라벨(`app=web`)을 두고 Service 가 둘 다 잡게 합니다. Service 셀렉터에 `track` 을 넣으면 canary 가 아니라 blue/green 이 됩니다.
- pause 중에 바꾼 것은 resume 할 때 **한 번의 롤아웃**으로 나갑니다.

## 여유가 있으면

- 심화 [A04 Service 뒤의 blue/green 전환](../mock_exam_a/q04_blue_green_service_switch/question.md)
- 심화 [B04 공유 Service 뒤의 canary 와 승격](../mock_exam_b/q04_canary_deployment_promote/question.md)

# 1일차 (D-10) — 시험 형식, 명령형 속도

[← 계획 전체](README.md) · [2일차 →](day02.md)

## 오늘의 목표

- 시험이 어떻게 진행되는지(문제마다 `ssh`, 120분, 66점) 머리에 넣습니다.
- 매니페스트를 처음부터 쓰지 않고 **명령형으로 뼈대를 만드는 손버릇**을 들입니다. 오늘은 비중이 가장 큰 Env & Security(25%)의 기본기로 연습합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | 루트 [README.md](../README.md) `출제 형태`·`시간 예산`, [cheatsheet.md](../cheatsheet.md) §0 ~ §1 |
| 0:15 – 0:35 | 아래 문제 4개 풀기 |
| 0:35 – 0:47 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:47 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D10 | Env & Security | ConfigMap 을 파일과 환경 변수로 주입 | 5 | 5분 | [Q](../mock_exam_d/q10_configmap_file_env/question.md) · [S](../mock_exam_d/q10_configmap_file_env/solution.md) ☐ |
| D11 | Env & Security | Secret 을 envFrom 으로 주입 | 5 | 5분 | [Q](../mock_exam_d/q11_secret_envfrom/question.md) · [S](../mock_exam_d/q11_secret_envfrom/solution.md) ☐ |
| D12 | Env & Security | 전용 ServiceAccount 로 Deployment 실행 | 5 | 5분 | [Q](../mock_exam_d/q12_serviceaccount_deployment/question.md) · [S](../mock_exam_d/q12_serviceaccount_deployment/solution.md) ☐ |
| E11 | Env & Security | LimitRange 로 기본 리소스 적용 | 5 | 5분 | [Q](../mock_exam_e/q11_limitrange_defaults/question.md) · [S](../mock_exam_e/q11_limitrange_defaults/solution.md) ☐ |

합계 20점, 목표 20분.

## 꼭 잡을 것

```bash
export do="--dry-run=client -o yaml"
kubectl create cm app --from-literal=MODE=prod --from-file=app.conf $do > cm.yaml
kubectl create secret generic db --from-literal=user=app $do > secret.yaml
kubectl set env deploy/web --from=secret/db        # envFrom 을 직접 쓰는 것보다 빠르다
kubectl set serviceaccount deploy web builder
kubectl explain pod.spec.containers.envFrom        # 필드 이름이 기억 안 날 때
```

- `$do` 를 `--` 뒤에 쓰면 컨테이너 인자가 되어 **오브젝트가 실제로 만들어집니다.**
- env 로 받은 ConfigMap·Secret 값은 파드를 다시 만들어야 바뀝니다. 볼륨(서브패스 아님)으로 받은 값만 자동 갱신됩니다.
- LimitRange 는 **새로 만드는 파드에만** 기본값을 넣습니다. 기존 파드는 그대로입니다.

## 여유가 있으면

- 심화 [A10 ConfigMap 과 Secret 을 projected 볼륨으로](../mock_exam_a/q10_projected_volume_configmap_secret/question.md)
- 심화 [A11 ServiceAccount 최소 권한 RBAC](../mock_exam_a/q11_serviceaccount_rbac_can_i/question.md)

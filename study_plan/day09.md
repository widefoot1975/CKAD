# 9일차 (D-2) — 시간 재고 푸는 미니 모의고사

[← 8일차](day08.md) · [계획 전체](README.md) · [10일차 →](day10.md)

## 오늘의 목표

실제 시험의 **절반에 조금 못 미치는 분량**(42점, 46분)을 타이머를 켜고 한 번에 풉니다. 아직 풀지 않은 `mock_exam_f` 문제로 골랐고, 다섯 도메인이 모두 들어 있습니다. 오늘 보는 것은 실력보다 **시간 배분과 문제를 넘기는 판단**입니다.

## 규칙

- 타이머 **46분**. 중간에 `solution.md`, 이 저장소의 다른 파일, 검색은 보지 않습니다. 시험처럼 kubernetes.io·helm.sh 문서만 봅니다.
- 문제마다 지정된 호스트로 `ssh` → 풀기 → 확인 → `exit`.
- **3분 안에 실마리가 안 보이면 표시하고 다음 문제**로 넘어갑니다. 끝까지 돌고 나서 표시한 문제로 돌아옵니다.
- 순서는 자유입니다. 시험에서처럼 배점이 크고 자신 있는 문제부터 풉니다.

## 환경 준비 (타이머 켜기 전)

7문제의 환경을 한 클러스터에 **한꺼번에** 만들어 두고 시작합니다. 각 문제 페이지의 Setup 섹션과 같은 스크립트입니다. 저장소를 `ckad-c1` 의 `~/CKAD` 에 받아 두었다고 가정합니다(다른 곳이면 첫 줄만 바꿉니다).

```bash
cd ~/CKAD
bash mock_exam_f/q16_ingress_fix_port_and_class/setup.sh   # 1. Ingress 컨트롤러 설치가 가장 오래 걸리므로 먼저
bash mock_exam_f/q01_podman_rebuild_modified_image/setup.sh   # 2. 베이스 이미지 pull
bash mock_exam_f/q15_service_selector_mismatch/setup.sh
bash mock_exam_f/q17_egress_networkpolicy_dns_backend/setup.sh
bash mock_exam_f/q07_readiness_probe_wrong_port/setup.sh
bash mock_exam_f/q08_debug_shellless_container/setup.sh
bash mock_exam_f/q10_configmap_env_restart_immutable/setup.sh
clear                       # 설정 출력에 답의 실마리가 보이므로 지운다
```

일곱 문제는 서로 다른 네임스페이스(`tagus`, `oder`, `shannon`, `volga`, `yukon`, `ganges`)와 결과 디렉터리(`/opt/course/<문제>`)를 쓰므로 순서를 바꿔도 서로 영향을 주지 않습니다. F16 을 먼저 두는 것은 컨트롤러 파드가 Ready 가 될 시간을 벌기 위해서입니다.

채점까지 끝나면 정리합니다.

```bash
cd ~/CKAD
for q in mock_exam_f/q16_ingress_fix_port_and_class mock_exam_f/q01_podman_rebuild_modified_image mock_exam_f/q15_service_selector_mismatch mock_exam_f/q17_egress_networkpolicy_dns_backend \
         mock_exam_f/q07_readiness_probe_wrong_port mock_exam_f/q08_debug_shellless_container mock_exam_f/q10_configmap_env_restart_immutable; do
  bash $q/cleanup.sh
done
```

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:46 | 아래 7문제 풀기 (타이머) |
| 0:46 – 1:00 | 채점: 각 `solution.md` 의 검증 단계로 맞았는지 확인하고 점수를 적습니다 |

풀이를 꼼꼼히 비교하는 것은 내일 오답 복습 시간에 합니다.

## 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| F15 | Networking | 셀렉터가 틀린 Service | 7 | 7분 | [Q](../mock_exam_f/q15_service_selector_mismatch/question.md) · [S](../mock_exam_f/q15_service_selector_mismatch/solution.md) ☐ |
| F16 | Networking | 고장 난 Ingress 고치기 (포트·클래스) | 7 | 7분 | [Q](../mock_exam_f/q16_ingress_fix_port_and_class/question.md) · [S](../mock_exam_f/q16_ingress_fix_port_and_class/solution.md) ☐ |
| F17 | Networking | DNS 와 백엔드 하나로 egress 제한 | 6 | 6분 | [Q](../mock_exam_f/q17_egress_networkpolicy_dns_backend/question.md) · [S](../mock_exam_f/q17_egress_networkpolicy_dns_backend/solution.md) ☐ |
| F01 | Design & Build | Dockerfile 수정 후 재빌드 | 7 | 7분 | [Q](../mock_exam_f/q01_podman_rebuild_modified_image/question.md) · [S](../mock_exam_f/q01_podman_rebuild_modified_image/solution.md) ☐ |
| F07 | Observability | 잘못된 포트의 readiness probe | 5 | 7분 | [Q](../mock_exam_f/q07_readiness_probe_wrong_port/question.md) · [S](../mock_exam_f/q07_readiness_probe_wrong_port/solution.md) ☐ |
| F08 | Observability | 셸 없는 컨테이너 디버깅 | 5 | 7분 | [Q](../mock_exam_f/q08_debug_shellless_container/question.md) · [S](../mock_exam_f/q08_debug_shellless_container/solution.md) ☐ |
| F10 | Env & Security | ConfigMap 변경 롤아웃과 immutable | 5 | 5분 | [Q](../mock_exam_f/q10_configmap_env_restart_immutable/question.md) · [S](../mock_exam_f/q10_configmap_env_restart_immutable/solution.md) ☐ |

합계 **42점**, 목표 **46분**.

## 결과 기록

| 항목 | 값 |
|---|---|
| 걸린 시간 | 분 |
| 점수 | / 42 |
| 환산 (÷ 0.42) | / 100 — 66 이상이면 합격선 |
| 표시하고 넘긴 문제 | |
| 목표 시간을 가장 많이 넘긴 문제 | |

**목표 시간을 가장 많이 넘긴 문제가 내일 복습할 주제입니다.** 시험장에서도 같은 유형은 뒤로 미룹니다.

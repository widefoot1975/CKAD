# 시험 전 10일 학습 계획 (하루 1시간)

시험 10일 전부터 **하루 1시간씩** 이 저장소만으로 준비하는 계획입니다. 1일차가 D-10, 10일차가 시험 전날(D-1)입니다. 형식은 [CKA 저장소의 학습 계획](https://github.com/widefoot1975/CKA/tree/main/study_plan)과 같습니다.

> 예: 9월 26일에 시작하면 10월 5일이 10일차, 10월 6일이 시험일입니다.

## 계획을 세운 기준

- **여섯 세트를 전부 풀 수는 없습니다.** 102문항의 목표 시간만 더해도 636분이라 10시간을 넘습니다. 그래서 **기본 난이도(D·E·F)** 를 중심으로 약 40문항을 풀고, 심화(A·B·C)는 매일 `여유가 있으면` 항목으로만 둡니다.
- **순서는 명령형 속도 → Design & Build → Deployment → Observability → Env & Security → Networking → 실전 → 정리** 입니다. 비중이 가장 큰 Env & Security(25%)는 1일차(ConfigMap·Secret·SA)와 7일차(보안·리소스)에 나눠 두 번 다룹니다.
- **하루 1시간은 모두 같은 틀로 씁니다.** 읽기 15분, 문제 풀이 20~35분, 풀이 대조와 기록 10~15분입니다.
- **문제는 `question.md` 만 보고 손으로 풉니다.** 다 푼 뒤에 `solution.md` 를 열고, 한글 해석으로 영문을 제대로 읽었는지부터 확인합니다.
- CKAD 저장소에는 CKA 의 `exam_guide.md` 가 없으므로 `읽을 곳` 은 루트 [README.md](../README.md) 와 [cheatsheet.md](../cheatsheet.md) 의 절입니다.

## 일정표

| 일차 | D- | 주제 | 읽을 곳 | 풀 문제 | 배점 |
|---|---|---|---|---|---|
| [1일차](day01.md) | D-10 | 시험 형식, 명령형 속도 | README 출제 형태·시간 예산 · cheatsheet §0 ~ §1 | D10 · D11 · D12 · E11 | 20 |
| [2일차](day02.md) | D-9 | 이미지 빌드 · Job · CronJob | cheatsheet §2 | D01 · D02 · E01 | 21 |
| [3일차](day03.md) | D-8 | 멀티 컨테이너 · 볼륨 · DaemonSet | cheatsheet §2 | D03 · E03 · F03 · E02 | 25 |
| [4일차](day04.md) | D-7 | 배포 전략 (롤링 · blue/green · canary) | cheatsheet §3 | D04 · E04 · F04 · F06 | 27 |
| [5일차](day05.md) | D-6 | Helm · Kustomize | cheatsheet §3 | D05 · E05 · D06 · E06 | 26 |
| [6일차](day06.md) | D-5 | probe · 로그 · top · API deprecation | cheatsheet §4 | D07 · E07 · D08 · D09 · E09 | 25 |
| [7일차](day07.md) | D-4 | 보안과 리소스 (SecurityContext · RBAC · PSA · Quota) | cheatsheet §5 | D13 · D14 · E12 · E13 · F12 | 25 |
| [8일차](day08.md) | D-3 | Services · Ingress · NetworkPolicy | cheatsheet §6 | D15 · D16 · D17 · E17 | 26 |
| [9일차](day09.md) | D-2 | 시간 재고 푸는 미니 모의고사 | — | F15 · F16 · F17 · F01 · F07 · F08 · F10 | 42 |
| [10일차](day10.md) | D-1 | 오답 복습, 당일 준비 | README 2026 변화 · cheatsheet 전체 | 새 문제 없음 | — |

`D10` 은 `mock_exam_d` 의 q10 이라는 뜻입니다.

## 시작 전에 확인할 것

- **연습 클러스터가 있어야 합니다.** v1.35 이상 kubeadm 클러스터에 `kubectl`·`helm`·`podman` 이 있는 호스트(`ckad-c1`)를 기준으로 합니다. 자세한 조건은 루트 README 의 `실습 환경 준비` 를 보세요. NetworkPolicy 문항은 정책을 강제하는 CNI(Calico, Cilium)가 있어야 결과가 맞습니다.
- **killer.sh 시뮬레이터**: CKAD를 등록하면 시뮬레이터 세션 2회가 함께 제공됩니다(세션마다 36시간 이용). 이 계획의 하루 1시간에는 넣지 않았지만, 시간이 나는 주말이나 9일차 전후에 한 번 써 보면 실전 난이도를 가늠할 수 있습니다.

## 매일 끝낼 때 기록할 것

1. 푼 문제의 `question.md` → `## My attempt` 에 입력한 명령 (틀린 것도 그대로)
2. 같은 `question.md` 맨 아래 `## Record` 에 날짜·걸린 분·점수 한 줄, 그리고 `python3 scripts/update_progress.py` 실행
3. 틀린 문제는 `solution.md` 의 `## 오답 원인 / 배운 점`
4. 같은 주제를 두 번 틀리면 저장소 루트 [README.md](../README.md) 의 **반복 오답 목록**에 추가 — 10일차에 이 표를 다시 봅니다.

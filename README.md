# CKAD 모의시험 오답 노트

[CKAD (Certified Kubernetes Application Developer)](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) 준비 과정에서 푼 모의시험을 **회차별 → 문제별**로 정리하는 저장소입니다. 형식은 [CKA 저장소](https://github.com/widefoot1975/CKA)와 같습니다.

- 시험 형식: 실습형(performance-based), **120분**, 합격선 **66%**
- 시험 환경: **Kubernetes v1.37**
- 커리큘럼: [CNCF 공식 curriculum](https://github.com/cncf/curriculum) — **CKAD v1.37** 기준 (2026-10-01 공개)

> 공개 저장소입니다. 실제 시험 문제 원문은 옮기지 않고, 요구사항을 직접 정리한 표현으로만 기록합니다.

시험장에서 쓸 명령은 [cheatsheet.md](cheatsheet.md) 에 모았습니다.

## 출제 범위와 트렌드

공식 커리큘럼(`CKAD_Curriculum_v1.37.pdf`)의 도메인과 비중입니다. v1.37 문서는 v1.35 와 도메인·세부 항목이 같고 버전 번호만 올라갔습니다. **배점 순서가 곧 공부 순서**입니다.

| 도메인 | 비중 | 세부 항목 |
|---|---|---|
| **Application Environment, Configuration and Security** | **25%** | CRD·Operator / 인증·인가·**admission control** / requests·limits·quota / 리소스 요구량 / ConfigMap / Secret / ServiceAccount / SecurityContext·Capabilities |
| **Application Design and Build** | **20%** | 컨테이너 이미지 정의·빌드·수정 / 알맞은 워크로드 선택(Deployment, DaemonSet, CronJob…) / 멀티 컨테이너 패턴(사이드카, init 등) / 영구·임시 볼륨 |
| **Application Deployment** | **20%** | 배포 전략(blue/green, canary) / Deployment 롤링 업데이트 / **Helm** 으로 기존 패키지 배포 / **Kustomize** |
| **Services and Networking** | **20%** | NetworkPolicy 기본 / Service 로 접근 제공·트러블슈팅 / Ingress 규칙으로 노출 |
| **Application Observability and Maintenance** | **15%** | **API deprecation** / probe·health check / 내장 CLI 모니터링 / 컨테이너 로그 / 디버깅 |

### 2026년 기준으로 알아 둘 변화

커리큘럼 문서는 그대로지만 쿠버네티스와 생태계가 바뀌었습니다. 옛 풀이를 그대로 따라 하면 여기서 막힙니다.

| 변화 | 시점 | 이 저장소에서 연습하는 곳 |
|---|---|---|
| **Ingress NGINX 은퇴** — 이후 릴리스·보안 패치 없음. Ingress **API** 자체는 GA 그대로 | 2026-03 | 모든 Ingress 문항은 F5 NGINX Ingress Controller(IngressClass `nginx`)로 실습 |
| CKAD 열람 문서에는 **Gateway API 문서가 없음**(CKA 전용) — 네트워킹은 Ingress 중심 | 2026 | Networking 문항 |
| **Endpoints API deprecated** — `kubectl get ep` 대신 EndpointSlice | v1.33 | 모든 Service 검증을 `get endpointslice -l kubernetes.io/service-name=<svc>` 로 |
| **네이티브 사이드카 GA** — `initContainers` + `restartPolicy: Always` | v1.33 | 멀티 컨테이너 문항 |
| Job `podFailurePolicy`(v1.31), `backoffLimitPerIndex`·`successPolicy`(v1.33) GA | v1.31~1.33 | Job 문항 |
| **In-place Pod resize GA** — `kubectl patch pod --subresource resize` | v1.35 | 리소스 문항 |
| **ValidatingAdmissionPolicy GA**, Pod Security Admission 라벨 | v1.30~ | admission control 문항 |
| SA 토큰 Secret 자동 생성 없음 — `kubectl create token` | v1.24~ | ServiceAccount 문항 |
| Helm 4 출시 (`--atomic` → `--rollback-on-failure` 등) | 2025-11 | Helm 문항 |
| Bitnami 무료 카탈로그 축소 — 공개 차트의 이미지 pull 실패가 흔해짐 | 2025-08~09 | Helm 문항은 podinfo 차트나 로컬 차트로 |
| Kustomize v5 — `commonLabels` → `labels`, `patchesStrategicMerge` → `patches` | kustomize v5 | Kustomize 문항 |

### 출제 형태

- 전 문항이 실습형입니다. 객관식이 없습니다. 보통 15~20문항이 나옵니다.
- 문제마다 지정된 호스트로 `ssh` 해서 풉니다. 그 호스트의 `kubectl` 은 이미 해당 클러스터를 가리킵니다. 지정 호스트가 아닌 곳에서 작업하면 정답을 만들어도 0점이고, 다음 문제로 가기 전에 `exit` 로 베이스 터미널에 돌아옵니다.
- 이미지 빌드 문항은 호스트의 `podman`(또는 `docker`)으로 빌드·태그·`save` 합니다.
- 시험 중 열람 가능한 문서는 **kubernetes.io/docs, kubernetes.io/blog, helm.sh/docs** 입니다. 옵션 이름은 `--help` 가 가장 빠릅니다.
- CKAD는 문항 수에 비해 시간이 빠듯하기로 유명합니다. 배점이 문제마다 표시되니 큰 것부터 풀고, 3분 안에 진입점이 안 보이면 넘어갑니다.

이 저장소의 `question.md` 메타 표 `Host` 행은 이 형식을 따릅니다. 모든 문항이 `ssh ckad-c1` 을 쓰며, 연습 랩에서는 자기 클러스터(kubeconfig 컨텍스트 하나 = 호스트 하나)로 읽으면 됩니다.

### 실습 환경 준비

각 문항의 `setup.sh` 가 필요한 것을 알아서 설치하지만, 클러스터 자체는 아래를 갖추고 있어야 합니다.

- kubeadm 등으로 만든 v1.35 이상 클러스터, `kubectl`·`helm` 이 설정된 호스트
- 이미지 빌드 문항: 호스트에 `podman` 또는 `docker`
- NetworkPolicy 문항: 정책을 강제하는 CNI(Calico, Cilium 등)
- `kubectl top` 문항: setup 이 metrics-server 를 설치합니다(`--kubelet-insecure-tls`)
- Ingress 문항: setup 이 F5 NGINX Ingress Controller 를 설치합니다(NodePort)
- 동적 PVC 문항: setup 이 local-path provisioner 를 설치합니다
- 인터넷 연결(이미지, 매니페스트, podinfo 차트 다운로드)

공용 구성요소(metrics-server, Ingress 컨트롤러, local-path provisioner)는 여러 문항이 같이 쓰므로 `cleanup.sh` 가 지우지 않습니다.

### 시간 예산

120분에 100점이므로 **1점당 1.2분**이 실제 배분입니다. 이 저장소는 여기에 맞춰 문항마다 `목표` 시간을 넣어 두었습니다.

| 구분 | 배분 | 이유 |
|---|---|---|
| 일반 문항 | 배점 × **1분** | 리소스를 만들고 검증하는 작업 |
| Observability (probe·로그·디버깅) | 배점 × **1.33분** | 원인을 좁히는 시간이 더 든다 |
| 합계 | **106분** | 남는 14분은 호스트 이동(`ssh`/`exit`)과 마지막 검증용 |

목표 시간은 **측정값이 아니라 예산**입니다. 이미지 빌드나 Helm 차트 다운로드처럼 벽시계 시간이 예산을 넘는 작업도 있습니다. **그런 문항은 배점 대비 시간이 나쁘다는 신호이므로 시험장에서는 뒤로 미루는 것이 맞습니다.**

풀고 나면 `question.md` 맨 아래 `## Record` 표에 걸린 시간과 점수를 적고 `python3 scripts/update_progress.py` 를 실행하세요. 회차 README의 `실제`·`결과` 칸이 채워집니다.

## 디렉터리 구조

```
.
├── README.md                   # 이 파일 — 출제 트렌드, 진행 현황, 도메인별 자신감, 반복 오답
├── cheatsheet.md               # 시험장에서 쓸 kubectl 단축과 빈출 절차
├── scripts/
│   └── update_progress.py      # question.md 의 풀이 기록으로 README 진행 표를 채운다
├── .gitignore
├── mock_exam_a/                # 모의고사 A — 17문항 100점 (심화)
│   ├── README.md               # 회차 요약: 문항 표, 도메인별 실점, 회고
│   └── q01_… ~ q17_…/
│       ├── question.md         # [영문] 문제 (Setup 안내만 한글) + 내 풀이 기록
│       ├── solution.md         # [한글] 해석 + 풀이
│       ├── setup.sh            # 문제 상황을 만드는 스크립트
│       └── cleanup.sh          # 실습 후 정리 스크립트
├── mock_exam_b/                # 모의고사 B — 17문항 100점 (심화)
├── mock_exam_c/                # 모의고사 C — 17문항 100점 (심화)
├── mock_exam_d/                # 모의고사 D — 17문항 100점 (기본)
├── mock_exam_e/                # 모의고사 E — 17문항 100점 (기본)
└── mock_exam_f/                # 모의고사 F — 17문항 100점 (기본)
```

**모의고사는 난이도가 다른 두 묶음입니다.** **D·E·F(기본)** 는 한 문제에 한 가지 개념만 묻고 단계가 2~4개로 짧아, 처음 풀거나 시험 직전 감을 잡을 때 씁니다. **A·B·C(심화)** 는 한 문제에 여러 단계와 함정이 섞여 있어 실력 점검용입니다. 권장 순서는 D → E → F → A → B → C 입니다.

**모든 세트는 각각 독립된 전 범위 모의고사입니다.** 여섯 세트 모두 공식 도메인 비중(25/20/20/20/15)을 그대로 지키고, 문항 배치도 같습니다.

| 문항 | 도메인 | 배점 |
|---|---|---|
| q01–q03 | Application Design and Build | 7 · 7 · 6 |
| q04–q06 | Application Deployment | 7 · 7 · 6 |
| q07–q09 | Application Observability and Maintenance | 5 · 5 · 5 |
| q10–q14 | Application Environment, Configuration and Security | 5 × 5 |
| q15–q17 | Services and Networking | 7 · 7 · 6 |

## 문제와 풀이를 파일로 나누는 이유

문제 폴더에 `README.md`를 두지 않습니다. GitHub는 폴더를 열면 README를 자동으로 펼치기 때문에, 그 안에 답이 있으면 볼 때마다 스포일러가 됩니다.

| 파일 | 언어 | 내용 |
|---|---|---|
| `question.md` | **영문** | 메타 표 → Setup(스크립트 실행 안내, 한글) → 문제(`## Task`) → 내가 입력한 명령(`## My attempt`) → 풀이 기록(`## Record`) |
| `solution.md` | **한글** | 문제 해석(원문 + 해석) → 모범 풀이 → 검증 → 오답 원인 → 참고 문서 |
| `setup.sh` / `cleanup.sh` | — | 문제 상황 만들기 / 실습 후 정리. Setup 명령은 이 스크립트에만 있습니다 |

**문제를 영문으로 쓰는 이유는 실제 시험이 영문이기 때문입니다.** `solution.md` 맨 앞에 **원문과 한글 해석**을 두었으니, 풀이를 보기 전에 내가 영문을 제대로 읽었는지 먼저 대조하세요.

## 푸는 순서

1. 회차 `README.md` 의 문항 표에서 문제를 고릅니다.
2. `question.md` **만** 엽니다. `## Setup` 의 안내대로 `setup.sh` 를 실행해 문제 상황을 만듭니다.
3. 메타 표의 `Host` 로 `ssh` 해서 직접 풀고, 입력한 명령을 `## My attempt` 에 그대로 붙입니다. **틀린 명령도 지우지 마세요.**
4. `solution.md` 를 엽니다. 한글 해석으로 문제를 제대로 읽었는지 먼저 확인하고, 그다음 모범 풀이와 비교합니다. 틀렸으면 `## 오답 원인 / 배운 점` 을 채웁니다.
5. `question.md` 맨 아래 `## Record` 표에 한 줄을 적습니다(날짜, 걸린 분, 얻은 점수). 다시 풀 때마다 한 줄씩 늘리며, 첫 줄이 모의고사 점수이고 그 아래는 복습입니다.
6. `python3 scripts/update_progress.py` 를 실행하면 회차 README의 `실제`·`결과`·도메인별 실점과 아래 진행 현황·도메인별 손실이 채워집니다. **결과는 `## Record` 에만 적고 README 표는 손으로 고치지 않습니다.**
7. `cleanup.sh` 로 정리하고, 페이지 맨 아래 링크로 다음 문제로 넘어갑니다.

## 새 회차 / 문제 추가하기

```bash
mkdir -p mock_exam_g/q01_<주제_스네이크케이스>
# question.md (영문, 맨 아래 ## Record 표 포함), solution.md (한글), setup.sh, cleanup.sh 를 만들고
# mock_exam_g/README.md 문항 표에 한 줄 추가 (scripts/update_progress.py 의 SETS 에도 g 추가)
```

> `.gitignore` 에 `*.key`, `*.crt`, `*.tar`, `kubeconfig` 등을 넣어 두었습니다. 공개 저장소이므로 인증서·kubeconfig·이미지 아카이브가 실수로 올라가지 않게 막습니다.

## 진행 현황

`응시일`·`실제 소요`·`점수`·`합격` 은 `scripts/update_progress.py` 가 각 문제의 `## Record` 첫 줄로 채웁니다. `회고` 만 손으로 체크합니다.

| 회차 | 문항 | 배점 | 목표 시간 | 응시일 | 실제 소요 | 점수 | 합격(66) | 회고 |
|---|---|---|---|---|---|---|---|---|
| [mock_exam_a](mock_exam_a/) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |
| [mock_exam_b](mock_exam_b/) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |
| [mock_exam_c](mock_exam_c/) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |
| [mock_exam_d](mock_exam_d/) (기본) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |
| [mock_exam_e](mock_exam_e/) (기본) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |
| [mock_exam_f](mock_exam_f/) (기본) | 17 | 100 | 106분 |  |  | / 100 | ☐ | ☐ |

## 도메인별 자신감

도메인별 **손실 점수**(A~F 칸)는 `scripts/update_progress.py` 가 채웁니다. `자신감` 과 `약점 메모` 만 손으로 적고, 이것으로 공부 시간을 어디에 쓸지 결정합니다.

| 도메인 | 비중 | A | B | C | D | E | F | 자신감 | 약점 메모 |
|---|---|---|---|---|---|---|---|---|---|
| Application Design and Build | 20% |  |  |  |  |  |  | ☐☐☐☐☐ |  |
| Application Deployment | 20% |  |  |  |  |  |  | ☐☐☐☐☐ |  |
| Application Observability and Maintenance | 15% |  |  |  |  |  |  | ☐☐☐☐☐ |  |
| Application Environment, Configuration and Security | 25% |  |  |  |  |  |  | ☐☐☐☐☐ |  |
| Services and Networking | 20% |  |  |  |  |  |  | ☐☐☐☐☐ |  |

## 반복 오답 목록

같은 주제를 두 번 이상 틀리면 여기에 올립니다. 시험 전날 이 표만 봅니다.

| 주제 | 틀린 횟수 | 관련 문제 | 해결했나 |
|---|---|---|---|
|  |  |  | ☐ |

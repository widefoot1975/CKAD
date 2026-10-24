# q17 — Default-deny ingress and allow only the frontend

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q17_networkpolicy_default_deny
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `zircon` 에 파드 `backend`(라벨 `app=backend`, nginx 80)와 Service `backend`(80), 클라이언트 파드 `frontend`(라벨 `role=frontend`)와 `intruder`(라벨 `role=other`)가 있다. NetworkPolicy 는 없어서 지금은 두 클라이언트 모두 `backend` 에 접속된다.
NetworkPolicy 를 실제로 집행하는 CNI(Calico, Cilium 등)가 설치되어 있어야 한다. 집행하지 않는 CNI(예: 기본 flannel)에서는 정책을 만들어도 차단되지 않는다.

## Task

In namespace `zircon`, pod `backend` accepts traffic from every pod. Lock the namespace down so
that only the frontend can reach the backend.

1. Create a NetworkPolicy named `default-deny-ingress` in namespace `zircon` that denies all
   incoming traffic to every pod in the namespace.
2. Create a NetworkPolicy named `allow-frontend` in namespace `zircon` that allows pods with label
   `role=frontend` to connect to pods with label `app=backend` on TCP port `80` only.
3. Confirm that `frontend` can fetch `http://backend` and that `intruder` cannot (the request
   must time out).

## My attempt

```bash

```

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q16](../q16_ingress_host_rules/question.md)

# q17 — Three-tier NetworkPolicy across namespaces

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q17_networkpolicy_three_tier_and_or
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `rho` 에는 파드 `frontend`(`app=frontend`)와 `intruder`(`app=other`)가, `sigma` 에는 파드 `api`(`app=api`, Service `api` 80 → 5678), `db`(`app=db`, Service `db` 6379), `impostor`(`app=frontend`)가 있다. NetworkPolicy 는 없어서 지금은 모든 통신이 열려 있다.
NetworkPolicy 를 실제로 강제하는 CNI(Calico, Cilium 등)가 필요하다. flannel 만 있으면 정책을 만들어도 막히지 않는다.

## Task

The application has three tiers: `frontend` in namespace `rho`, and `api` and `db` in
namespace `sigma`. Restrict traffic so that each tier can only be reached by the tier in front
of it. Do not change any labels and do not create policies other than the two below.

1. In namespace `sigma`, create NetworkPolicy `api-allow-frontend` that selects the Pods with
   label `app=api` and allows ingress on TCP port `5678` **only** from Pods with label
   `app=frontend` that run in namespace `rho`.
2. In namespace `sigma`, create NetworkPolicy `db-allow-api` that selects the Pods with label
   `app=db` and allows ingress on TCP port `6379` only from Pods with label `app=api` in
   namespace `sigma`.
3. Test the following connections and write one line per connection, in this order, to
   `/opt/course/a17/results.txt` in the format `<from>-><to>=<allowed|blocked>`:
   - `frontend->api` (Pod `rho/frontend` to `http://api.sigma`)
   - `intruder->api` (Pod `rho/intruder` to `http://api.sigma`)
   - `impostor->api` (Pod `sigma/impostor` to `http://api.sigma`)
   - `api->db` (Pod `sigma/api` to `db.sigma:6379`)
   - `frontend->db` (Pod `rho/frontend` to `db.sigma:6379`)

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

[↑ 문항 목록](../README.md) · [← q16](../q16_ingress_tls_two_paths_default_backend/question.md)

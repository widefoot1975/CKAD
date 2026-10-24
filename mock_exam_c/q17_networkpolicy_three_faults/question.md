# q17 — Repair a NetworkPolicy with three faults

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q17_networkpolicy_three_faults
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `cypress` 에 Pod `api`(Service `api` 80 → 컨테이너 5678), `frontend`, `intruder` 와 NetworkPolicy 두 개(`default-deny-ingress`, `allow-frontend-to-api`)가 있다. 지금은 `frontend` 도 `intruder` 도 `api` 에 닿지 않는다.
NetworkPolicy 를 실제로 강제하는 CNI(Calico, Cilium 등)가 필요하다. 정책 원본은 `/opt/course/c17/allow-frontend-to-api.yaml` 에도 있다.

## Task

In namespace `cypress`, Pod `frontend` must reach Pod `api` through Service `api` on port `80`, but
every request times out. A default-deny policy is in place on purpose, and policy
`allow-frontend-to-api` was meant to open exactly this path, but it contains three faults.

1. Fix NetworkPolicy `allow-frontend-to-api` so that `frontend` can reach `api` via Service `api`.
   Do not delete or change `default-deny-ingress`, and do not create other policies.
2. Do not broaden the policy: it must still admit only Pods labelled like `frontend` that are in a
   namespace selected by its `kubernetes.io/metadata.name` label with the value `cypress` (both
   conditions together), and only on the single TCP port that the `api` container listens on.
   `intruder` must stay blocked.
3. Write the three faults, one per line, to `/opt/course/c17/faults.txt`.
4. Test with `wget -qO- -T 3 http://api` from both Pods and write
   `frontend=<ok|blocked> intruder=<ok|blocked>` to `/opt/course/c17/result.txt`.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_ingressclass_default/question.md)

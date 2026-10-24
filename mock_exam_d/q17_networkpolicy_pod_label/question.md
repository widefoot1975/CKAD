# q17 — Reach a backend through NetworkPolicies by relabeling a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q17_networkpolicy_pod_label
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `osprey` 에 Pod `backend`(nginx, Service `backend` port 80), Pod `frontend`(busybox), NetworkPolicy 4개가 있고, 지금은 `frontend` 에서 `backend` 로 요청하면 시간 초과로 실패한다. `/opt/course/d17/` 는 비어 있다.
NetworkPolicy 를 실제로 적용하는 CNI(Calico, Cilium 등)가 있는 클러스터여야 한다. flannel 만 있으면 정책이 무시되어 처음부터 통신이 된다.

## Task

In namespace `osprey`, Pod `frontend` cannot reach Service `backend`. The NetworkPolicies in the
namespace are approved by the security team and must not be changed.

1. Inspect the NetworkPolicies in namespace `osprey` and find which Pod labels they allow to
   send traffic to the `backend` Pods.
2. Change only the labels of Pod `frontend` (do not recreate it and do not modify, delete or create
   any NetworkPolicy) so that `frontend` can reach Service `backend` on port `80`.
3. Write the label you set, in the form `key=value`, to `/opt/course/d17/label.txt`, and confirm
   that `wget -qO- -T 3 http://backend` from `frontend` now returns the nginx welcome page.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_ingress_two_paths/question.md)

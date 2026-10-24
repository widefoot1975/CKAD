# q17 — Restrict egress to DNS and one backend

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q17_egress_networkpolicy_dns_backend
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `shannon` 에 Pod `client`, `backend`, `other` 와 Service `backend`, `other`(port 80 → 5678)가 있고 NetworkPolicy 는 없다. 지금은 `client` 가 두 Service 모두에 닿는다.
NetworkPolicy 를 실제로 강제하는 CNI(Calico, Cilium 등)가 있어야 결과를 확인할 수 있다. 클러스터 DNS Pod 는 `kube-system` 의 `k8s-app=kube-dns` 라벨이라고 가정한다.

## Task

In namespace `shannon`, Pod `client` must only be able to talk to the backend. Pods `backend` and
`other` are exposed by Services `backend` and `other` on port `80`.

1. Create a NetworkPolicy `client-egress` in namespace `shannon` that applies only to Pod `client`
   and restricts its outgoing traffic to:
   - DNS (port `53`, UDP and TCP) to the cluster DNS Pods (label `k8s-app=kube-dns`) in namespace
     `kube-system`, and
   - the Pods labelled `app=backend`, on the port those Pods listen on.

   Do not restrict incoming traffic.
2. From Pod `client`, confirm that `nslookup backend.shannon.svc.cluster.local` and
   `wget -qO- -T 3 http://backend` succeed, and write the output of the `wget` command to
   `/opt/course/f17/backend.txt`.
3. Confirm that `wget -qO- -T 3 http://other` from Pod `client` now fails.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_ingress_fix_port_and_class/question.md)

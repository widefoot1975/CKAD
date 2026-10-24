# q17 — Open precise paths through a default-deny namespace

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services and Networking (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q17_networkpolicy_default_deny_allow
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ariel` 에 Pod `api`(8080)·`db`(redis 6379), Service `api`·`db` 와 NetworkPolicy `default-deny`(Ingress+Egress 전부 차단)가 있다. namespace `miranda`(레이블 `access=b17-api`)와 `charon`(레이블 없음)에는 각각 Pod `client`(curl)가 있다. 지금은 어느 방향도 통하지 않는다.
NetworkPolicy 를 실제로 집행하는 CNI(Calico, Cilium 등)가 필요하다. flannel 만 있으면 정책이 무시되어 결과가 달라진다. `/opt/course/b17/` 는 비어 있다.

## Task

Namespace `ariel` has a NetworkPolicy `default-deny` that blocks all ingress and egress traffic.
Open only the paths below. Do not modify or delete `default-deny`, and do not change any labels on
Pods or namespaces.

1. Create NetworkPolicy `allow-api-ingress` in `ariel`: Pods with label `app=api` accept incoming
   traffic only from Pods in namespaces labeled `access=b17-api`, and only on TCP port `8080`.
2. Create NetworkPolicy `allow-api-egress` in `ariel`: Pods with label `app=api` may send traffic
   only to the cluster DNS Pods (label `k8s-app=kube-dns` in namespace `kube-system`) on UDP and TCP
   port `53`, and to Pods with label `app=db` in `ariel` on TCP port `6379`.
3. The `api` Pod must actually be able to talk to the `db` Pod:
   `printf 'PING\r\n' | nc -w 2 db 6379` run in Pod `api` must answer `+PONG`. Any additional
   NetworkPolicy you need must have a name starting with `allow-`, and no Pod other than those with
   label `app=api` may reach `db`.
4. Test the four paths below and write the results to `/opt/course/b17/results.txt`, one line each,
   as `<path> ok` or `<path> blocked`:
   `miranda->api` (Pod `client` in `miranda` to `http://api.ariel:8080`),
   `charon->api` (Pod `client` in `charon` to the same URL),
   `api->db` (the `nc` test above), and
   `api->internet` (`wget -T 3 -qO- http://example.com` in Pod `api`).

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

[↑ 문항 목록](../README.md) · [← q16](../q16_ingress_named_port_pathtype/question.md)

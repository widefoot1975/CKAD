# q15 — Repair a Service port and add an ExternalName alias

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q15_service_targetport_externalname
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `yew` 에 Deployment `orders`(replicas 2, `hashicorp/http-echo`, 컨테이너 포트 이름 `http` = 5678)와 Service `orders`(port 80)가 있다. Service 는 파드를 고르고 EndpointSlice 도 있지만 요청은 실패한다. ExternalName Service `orders-db` 는 아직 없다.
외부 DB 이름 `pg-primary.c15.example.net` 은 실제로 존재하지 않아도 된다(CNAME 레코드만 확인한다).

## Task

Clients in namespace `yew` cannot reach Service `orders`, although its EndpointSlice is not empty.
The team also wants a stable in-cluster name for an external database.

1. Without changing Deployment `orders`, fix Service `orders` so that its port `80` reaches the
   Pods. Reference the container port by its **name**, not by number.
2. Write the port number that the EndpointSlice of Service `orders` advertises after the fix to
   `/opt/course/c15/endpointslice-port.txt`.
3. Using `kubectl port-forward` to the **Service** on local port `18081`, fetch `/` and save the
   response body to `/opt/course/c15/port-forward.txt`.
4. Create Service `orders-db` of type `ExternalName` in `yew` that resolves to
   `pg-primary.c15.example.net`.
5. From a temporary Pod with image `busybox:1.36` in `yew`, query the `CNAME` record of
   `orders-db.yew.svc.cluster.local` and save the output to `/opt/course/c15/dns.txt`. The
   temporary Pod must not remain afterwards.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_operator_crd_discovery/question.md) · [q16 →](../q16_ingressclass_default/question.md)

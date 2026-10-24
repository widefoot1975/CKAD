# q16 — Repair an Ingress that serves two hosts

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q16_ingress_named_port_pathtype
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 F5 NGINX Ingress Controller(IngressClass `nginx`)가 설치되어 있고, namespace `oberon` 에 Deployment·Service `shop`, `blog` 와 **잘못 작성된** Ingress `sites` 가 있다. `/opt/course/b16/` 는 비어 있다.
컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 아래처럼 `<노드IP>:<NodePort>` 로 curl 한다. 컨트롤러는 다른 Ingress 문제에서도 쓰므로 정리할 때 `oberon` 만 지운다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -H 'Host: shop.b16.example' http://$NODE:$NP/cart
```

## Task

Ingress `sites` in namespace `oberon` should publish two applications through the Ingress
controller (IngressClass `nginx`): host `shop.b16.example` for Service `shop`, and host
`blog.b16.example` for Service `blog`. Users report errors on both hosts.

1. Using `curl` against the Ingress controller's NodePort, record the HTTP status codes for
   `shop.b16.example/`, `shop.b16.example/cart` and `blog.b16.example/posts/hello` in
   `/opt/course/b16/before.txt`, one line each in the form `<host><path> <code>`.
2. Fix Ingress `sites` so that every path on `shop.b16.example` is served by Service `shop`, and
   path `/posts` and everything below it on `blog.b16.example` is served by Service `blog`. Both
   backends must keep referring to the Service port by name. Do not modify Services or
   Deployments.
3. Requests to `blog.b16.example/` (outside `/posts`) must not reach Service `blog`.
4. Record the same three URLs again in `/opt/course/b16/after.txt` in the same format; all of them
   must return `200`, with the body `shop` or `blog` respectively.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_statefulset_headless_dns/question.md) · [q17 →](../q17_networkpolicy_default_deny_allow/question.md)

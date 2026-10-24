# q16 — TLS Ingress with two paths and a default backend

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q16_ingress_tls_two_paths_default_backend
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 F5 NGINX Ingress Controller(IngressClass `nginx`, NodePort Service `nginx-ingress`)가 있고, `pi` 에는 Service `store-web`, `store-api`, `store-fallback`(모두 80, 응답 `web`/`api`/`fallback`)이 있다. `/opt/course/a16/` 에는 openssl 로 만든 `tls.crt`·`tls.key`(CN `store.a16.test`)가 있다. TLS Secret 과 Ingress 는 없다.
호스트에 `openssl` 이 있어야 한다. 컨트롤러는 NodePort 라 아래처럼 `<노드IP>:<NodePort>` 로 curl 한다(HTTPS 는 `--resolve` 로 SNI 를 맞춘다).

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NPS=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -H 'Host: store.a16.test' http://$NODE:$NP/web
curl -sk --resolve store.a16.test:$NPS:$NODE https://store.a16.test:$NPS/web
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 `pi` 와 `/opt/course/a16` 만 지운다.

## Task

The `store` application in namespace `pi` must be published over HTTPS for host
`store.a16.test`. A certificate and key for this host are stored at `/opt/course/a16/tls.crt`
and `/opt/course/a16/tls.key`.

1. Create a TLS Secret named `store-tls` in namespace `pi` from these two files.
2. Create an Ingress named `store` in namespace `pi` with IngressClass `nginx` that
   - terminates TLS for host `store.a16.test` with Secret `store-tls`,
   - routes host `store.a16.test` path `/web` (type `Prefix`) to Service `store-web` port `80`
     and path `/api` (type `Prefix`) to Service `store-api` port `80`,
   - sends every other request to Service `store-fallback` port `80` with a `defaultBackend`.
3. Using `curl -k` against the HTTPS NodePort of the Ingress controller (with the host name
   resolved to the node, so that SNI is `store.a16.test`), request `/web`, `/api/v1` and
   `/other`. Write the three response bodies in this order, one per line, to
   `/opt/course/a16/curl.txt`.
4. Request `http://store.a16.test/web` through the HTTP NodePort and write only the HTTP status
   code to `/opt/course/a16/http-code.txt`.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_multiport_service_no_endpoints/question.md) · [q17 →](../q17_networkpolicy_three_tier_and_or/question.md)

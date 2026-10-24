# q16 — Route two paths with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q16_ingress_two_paths
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `hawk` 에 Service `shop-svc`(port 80, 응답 `shop`)와 `blog-svc`(port 80, 응답 `blog`)가 있고 Ingress 는 없다. Ingress 컨트롤러는 F5 NGINX Ingress Controller(IngressClass `nginx`, ns `nginx-ingress` 의 NodePort Service `nginx-ingress`)이며 없으면 setup 이 설치한다(`github.com`·`raw.githubusercontent.com` 인터넷 연결 필요).
컨트롤러로 요청을 보내는 방법:

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -H 'Host: hawk.example.com' http://$NODE:$NP/shop
```

## Task

The `hawk` team publishes two applications under one host name.

1. Create an Ingress named `hawk-ingress` in namespace `hawk` with IngressClass `nginx` for host
   `hawk.example.com`.
2. Requests for path `/shop` (path type `Prefix`) must go to Service `shop-svc` on port `80`, and
   requests for path `/blog` (path type `Prefix`) must go to Service `blog-svc` on port `80`.
3. Through the Ingress controller's NodePort, send requests with header `Host: hawk.example.com`
   to `/shop` and `/blog`, and write the responses to `/opt/course/d16/shop.txt` and
   `/opt/course/d16/blog.txt`.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_clusterip_service_endpointslice/question.md) · [q17 →](../q17_networkpolicy_pod_label/question.md)

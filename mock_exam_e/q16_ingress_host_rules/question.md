# q16 — Route two hosts with one Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q16_ingress_host_rules
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 F5 NGINX Ingress Controller(IngressClass `nginx`, ns `nginx-ingress` 의 NodePort Service `nginx-ingress`)가, `citrine` 에는 Service `shop-svc`(80, 응답 `shop`)와 `blog-svc`(80, 응답 `blog`)가 있고 Ingress 는 없다.
컨트롤러 설치 매니페스트를 받아야 하므로 `raw.githubusercontent.com` 과 컨테이너 레지스트리로 인터넷 연결이 필요하다. 컨트롤러는 다른 문제에서도 쓰므로 정리할 때 지우지 않는다. 요청은 아래처럼 `<노드IP>:<NodePort>` 로 보낸다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -H 'Host: shop.citrine.local' http://$NODE:$NP/
```

## Task

Namespace `citrine` runs two web applications behind Services `shop-svc` and `blog-svc`
(both on port `80`). Publish both through one Ingress using host-based rules.

1. Create an Ingress named `gems` in namespace `citrine` with IngressClass `nginx` and these rules:
   - host `shop.citrine.local`, path `/`, path type `Prefix` → Service `shop-svc` port `80`
   - host `blog.citrine.local`, path `/latest`, path type `Exact` → Service `blog-svc` port `80`
2. Send these three requests to the Ingress controller's NodePort and write the three HTTP status
   codes, one per line in this order, to `/opt/course/e16/codes.txt`:
   `Host: shop.citrine.local` path `/cart`; `Host: blog.citrine.local` path `/latest`;
   `Host: blog.citrine.local` path `/latest/2026`.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_nodeport_targetport_fix/question.md) · [q17 →](../q17_networkpolicy_default_deny/question.md)

# q16 — Serve an Ingress through the right IngressClass

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q16_ingressclass_default
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 IngressClass 가 두 개 있다: F5 NGINX Ingress Controller 의 `nginx` 와, 컨트롤러가 없는 `c16-legacy`. 둘 다 기본(default) 클래스가 아니다. `sequoia` 에는 Deployment·Service `menu`(80)와 `ingressClassName` 이 없는 Ingress `menu`(host `menu.c16.local`)가 있고, 이 Ingress 는 어떤 컨트롤러도 처리하지 않는다.
컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 아래처럼 `<노드IP>:<NodePort>` 로 curl 한다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -H 'Host: menu.c16.local' http://$NODE:$NP/
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 지우지 않는다. 다만 이 문제가 `nginx` 클래스에 붙이는 default 어노테이션은 setup·cleanup 이 떼어 낸다.

## Task

Ingress `menu` in namespace `sequoia` returns nothing useful: no controller serves it. The cluster
has two IngressClasses and teams keep forgetting to set a class on new Ingresses.

1. Write every IngressClass in the form `<name> <controller>`, one per line, to
   `/opt/course/c16/classes.txt`.
2. Make Ingress `menu` served by the IngressClass whose controller is actually running, using the
   Ingress field meant for this (not an annotation). `curl` with `Host: menu.c16.local` through the
   controller must return HTTP `200`.
3. Mark IngressClass `nginx` as the cluster's default class with the standard annotation, and make
   sure `c16-legacy` is not a default class.
4. Create Ingress `menu-v2` in `sequoia` **without** specifying any class: host `menu-v2.c16.local`,
   path `/` (type `Prefix`) to Service `menu` port `80`. Write the class it ended up with to
   `/opt/course/c16/v2-class.txt`.
5. Write the HTTP status codes of both hosts to `/opt/course/c16/curl.txt` in the form
   `menu=<code> menu-v2=<code>`.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_service_targetport_externalname/question.md) · [q17 →](../q17_networkpolicy_three_faults/question.md)

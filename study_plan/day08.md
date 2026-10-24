# 8일차 (D-3) — Services · Ingress · NetworkPolicy

[← 7일차](day07.md) · [계획 전체](README.md) · [9일차 →](day09.md)

## 오늘의 목표

- Service 가 안 될 때 보는 순서(셀렉터 → targetPort → Ready)를 고정합니다.
- NetworkPolicy 의 AND·OR 차이와 egress 를 막을 때 DNS 를 여는 것을 익힙니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §6 Services and Networking, 루트 README 의 Ingress NGINX 은퇴·EndpointSlice 행 |
| 0:15 – 0:41 | 아래 문제 4개 풀기 |
| 0:41 – 0:53 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:53 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D15 | Networking | ClusterIP Service 와 EndpointSlice | 7 | 7분 | [Q](../mock_exam_d/q15_clusterip_service_endpointslice/question.md) · [S](../mock_exam_d/q15_clusterip_service_endpointslice/solution.md) ☐ |
| D16 | Networking | Ingress 두 경로 라우팅 | 7 | 7분 | [Q](../mock_exam_d/q16_ingress_two_paths/question.md) · [S](../mock_exam_d/q16_ingress_two_paths/solution.md) ☐ |
| D17 | Networking | 파드 라벨로 NetworkPolicy 통과 | 6 | 6분 | [Q](../mock_exam_d/q17_networkpolicy_pod_label/question.md) · [S](../mock_exam_d/q17_networkpolicy_pod_label/solution.md) ☐ |
| E17 | Networking | default-deny 후 frontend 만 허용 | 6 | 6분 | [Q](../mock_exam_e/q17_networkpolicy_default_deny/question.md) · [S](../mock_exam_e/q17_networkpolicy_default_deny/solution.md) ☐ |

합계 26점, 목표 26분.

## 꼭 잡을 것

```bash
kubectl expose deploy web --port=80 --target-port=8080 --name=web-svc
kubectl get endpointslice -n ns -l kubernetes.io/service-name=web-svc
kubectl create ingress web --class=nginx --rule='shop.example.com/api*=api:80' $do
kubectl run tmp --rm -it --image=curlimages/curl:8.10.1 --restart=Never -- curl -s web-svc.ns:80
```

- Endpoints 는 v1.33 부터 deprecated 입니다. 확인은 EndpointSlice 로 합니다.
- `--rule` 의 경로 끝 `*` 는 `Prefix`, 없으면 `Exact` 입니다. `ingressClassName` 을 빠뜨리면 아무 컨트롤러도 처리하지 않을 수 있습니다.
- 같은 `from` 원소 안의 `namespaceSelector` + `podSelector` 는 **AND**, 원소를 나누면 **OR** 입니다.
- 기존 정책을 고치지 말라는 문제는 **파드 라벨을 바꿔서** 정책에 맞춥니다.

## 여유가 있으면

- 심화 [A16 두 경로와 기본 백엔드가 있는 TLS Ingress](../mock_exam_a/q16_ingress_tls_two_paths_default_backend/question.md)
- 심화 [A17 네임스페이스를 넘는 3계층 NetworkPolicy](../mock_exam_a/q17_networkpolicy_three_tier_and_or/question.md)

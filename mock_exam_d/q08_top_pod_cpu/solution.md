# q08 — Find the busiest Pod with kubectl top · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Someone reports that a Pod in namespace `magpie` is using far more CPU than the others.
>
> 1. Write a single `kubectl` command that shows the Pods of namespace `magpie` sorted by CPU usage
>    (highest first) to `/opt/course/d08/top.sh`.
> 2. Write only the name of the Pod in namespace `magpie` that currently uses the most CPU to
>    `/opt/course/d08/pod.txt`.

**해석**

`magpie` 네임스페이스의 파드 하나가 다른 파드보다 CPU 를 훨씬 많이 쓴다는 보고가 들어왔다.

1. `magpie` 네임스페이스의 파드를 CPU 사용량 순(높은 것부터)으로 보여 주는 `kubectl` 명령 한 줄을
   `/opt/course/d08/top.sh` 에 적는다.
2. 지금 `magpie` 네임스페이스에서 CPU 를 가장 많이 쓰는 파드의 이름만 `/opt/course/d08/pod.txt` 에 적는다.

## 모범 풀이

**1) 명령을 파일로**

```bash
echo 'kubectl top pod -n magpie --sort-by=cpu' > /opt/course/d08/top.sh
bash /opt/course/d08/top.sh
# NAME       CPU(cores)   MEMORY(bytes)
# worker-2   399m         0Mi
# worker-1   100m         0Mi
# worker-3   0m           0Mi
```

`--sort-by` 는 `cpu` 또는 `memory` 만 받고 항상 **내림차순**입니다. 명령을 적는 문제이므로 `echo '...'` 처럼
작은따옴표로 감싸 그대로 저장합니다. `--sort-by=cpu` 를 빼면 이름순으로 나와 오답이 되기 쉽습니다.

**2) 1위 이름만**

```bash
kubectl top pod -n magpie --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > /opt/course/d08/pod.txt
cat /opt/course/d08/pod.txt        # worker-2
```

`kubectl top` 은 metrics-server 가 모은 **현재 사용량**을 보여 줍니다. `kubectl describe` 나 파드 spec 의
`requests`/`limits` 는 예약값·상한일 뿐 실제 사용량이 아닙니다. 컨테이너별로 보고 싶으면 `--containers` 를 붙입니다.

## 검증

```bash
cat /opt/course/d08/top.sh                         # kubectl top pod -n magpie --sort-by=cpu
bash /opt/course/d08/top.sh | sed -n 2p            # 첫 줄이 worker-2
cat /opt/course/d08/pod.txt                        # worker-2
```

`error: Metrics API not available` 이 나오면 metrics-server 가 아직 첫 수집을 못 한 것입니다. 1분쯤 뒤 다시 실행합니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl top pod -n <ns> --sort-by=cpu --no-headers | head -1` — `--sort-by` 는 `cpu`/`memory`, 내림차순.
- **헷갈리는 지점**: `kubectl get pods --sort-by=...` 는 JSONPath 를 받고 사용량을 모릅니다. `top` 의 `--sort-by` 와 헷갈리지 않습니다. `kubectl top` 은 metrics-server(Metrics API) 가 있어야 동작하며, 실습 클러스터에서는 kubelet 인증서 때문에 `--kubelet-insecure-tls` 가 필요할 수 있습니다.

## 참고 문서

- 검색어: `kubectl top`, `resource metrics pipeline`
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/kubectl_top_pod/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q09 →](../q09_logs_previous_container/question.md)

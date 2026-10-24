# q09 — Read logs from a multi-container Pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Pod `shipper` in namespace `mekong` has two containers, `app` and `audit`, which both keep
> writing to standard output.
>
> 1. Write the last `5` log lines of container `audit` to `/opt/course/f09/audit-last5.txt`.
> 2. Write only the log lines that container `app` produced during the last `20` seconds to
>    `/opt/course/f09/app-recent.txt`.
> 3. Write the logs of all containers of the Pod to `/opt/course/f09/all.txt`, with every line
>    prefixed by the Pod and container it came from.

**해석**

`mekong` 네임스페이스의 Pod `shipper` 에는 컨테이너 `app` 과 `audit` 이 있고, 둘 다 계속 표준 출력에 쓴다.

1. 컨테이너 `audit` 의 마지막 로그 `5` 줄을 `/opt/course/f09/audit-last5.txt` 에 적는다.
2. 컨테이너 `app` 이 최근 `20` 초 동안 만든 로그 줄만 `/opt/course/f09/app-recent.txt` 에 적는다.
3. Pod 의 모든 컨테이너 로그를 `/opt/course/f09/all.txt` 에 적되, 줄마다 어느 Pod·컨테이너에서 왔는지 접두어를 붙인다.

## 모범 풀이

**0) 컨테이너 이름 확인**

```bash
kubectl -n mekong get pod shipper -o jsonpath='{.spec.containers[*].name}{"\n"}'
# app audit
kubectl -n mekong logs shipper | head -2
# Defaulted container "app" out of: app, audit
# app: order 1 processed
```

컨테이너가 여러 개인데 `-c` 를 빼면 kubectl 은 첫 번째 컨테이너(또는 `kubectl.kubernetes.io/default-container`
어노테이션의 컨테이너)를 고르고 stderr 에 `Defaulted container` 를 알립니다. 원하는 컨테이너가 아닐 수 있으니
항상 `-c` 를 붙입니다.

**1) audit 의 마지막 5줄**

```bash
kubectl -n mekong logs shipper -c audit --tail=5 > /opt/course/f09/audit-last5.txt
cat /opt/course/f09/audit-last5.txt
# audit: check 8 ok
# ...
# audit: check 12 ok
```

**2) app 의 최근 20초**

```bash
kubectl -n mekong logs shipper -c app --since=20s > /opt/course/f09/app-recent.txt
wc -l < /opt/course/f09/app-recent.txt      # 약 10 (2초마다 한 줄)
```

`--since` 는 상대 시간(`20s`, `5m`, `1h`), `--since-time` 은 RFC3339 절대 시각입니다. 둘 중 하나만 쓸 수
있습니다. `--tail` 과 함께 주면 시간으로 거른 뒤 마지막 N 줄만 남깁니다.

**3) 모든 컨테이너, 출처 접두어**

```bash
kubectl -n mekong logs shipper --all-containers --prefix > /opt/course/f09/all.txt
head -3 /opt/course/f09/all.txt
# [pod/shipper/app] app: order 1 processed
# [pod/shipper/app] app: order 2 processed
# [pod/shipper/app] app: order 3 processed
grep -c '^\[pod/shipper/audit\]' /opt/course/f09/all.txt     # 1 이상
```

`--all-containers` 는 컨테이너별로 차례로 출력합니다(시간순으로 섞이지 않음). 각 줄의 시각이 필요하면
`--timestamps` 를 더합니다. 라벨로 여러 Pod 를 한꺼번에 볼 때는 `kubectl logs -l app=shipper --all-containers --prefix`.

## 검증

```bash
wc -l < /opt/course/f09/audit-last5.txt                 # 5
grep -vc '^audit:' /opt/course/f09/audit-last5.txt      # 0 — audit 줄만
grep -vc '^app:' /opt/course/f09/app-recent.txt         # 0 — app 줄만
wc -l < /opt/course/f09/app-recent.txt                  # 9~11
grep -o '^\[pod/shipper/[a-z]*\]' /opt/course/f09/all.txt | sort | uniq -c
#   NN [pod/shipper/app]
#   NN [pod/shipper/audit]
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 컨테이너 지정 `-c`, 줄 수 `--tail=N`, 시간 `--since=20s`, 전부 `--all-containers --prefix`.
- **헷갈리는 지점**: `-c` 를 빼면 기본 컨테이너 하나만 보여 줍니다. `--since` 와 `--since-time` 은 함께 쓸 수 없고, 죽은 인스턴스의 로그는 `--previous` 입니다.

## 참고 문서

- 검색어: `kubectl logs`, `logging architecture`
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/
- https://kubernetes.io/docs/concepts/cluster-administration/logging/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q10 →](../q10_configmap_env_restart_immutable/question.md)

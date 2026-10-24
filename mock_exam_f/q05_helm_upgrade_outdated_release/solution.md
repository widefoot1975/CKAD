# q05 — Upgrade the outdated Helm release · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Two releases of the chart `podinfo/podinfo` (repository `podinfo` is already added) run in the
> cluster. The platform team requires every release to use chart version `6.7.1`.
>
> 1. Using `helm list -A`, find the release whose chart version is older than `6.7.1`. Write its
>    release name and namespace, separated by a single space, to `/opt/course/f05/outdated.txt`
>    (for example `myrelease myns`).
> 2. Upgrade that release to chart `podinfo/podinfo` version `6.7.1`. The user-supplied value
>    `replicaCount=2` of that release must be kept.
> 3. Write the output of `helm history` for that release to `/opt/course/f05/history.txt`. It must
>    show 2 revisions, the latest one `deployed` with chart `podinfo-6.7.1`.

**해석**

클러스터에 차트 `podinfo/podinfo` 의 릴리스 두 개가 돌고 있다(저장소 `podinfo` 는 이미 추가됨). 플랫폼 팀은
모든 릴리스가 차트 버전 `6.7.1` 을 쓰도록 요구한다.

1. `helm list -A` 로 차트 버전이 `6.7.1` 보다 오래된 릴리스를 찾는다. 그 릴리스 이름과 네임스페이스를 공백
   하나로 구분해 `/opt/course/f05/outdated.txt` 에 적는다(예: `myrelease myns`).
2. 그 릴리스를 차트 `podinfo/podinfo` 버전 `6.7.1` 로 업그레이드한다. 그 릴리스의 사용자 지정 값
   `replicaCount=2` 는 유지되어야 한다.
3. 그 릴리스의 `helm history` 출력을 `/opt/course/f05/history.txt` 에 적는다. 리비전이 2개이고, 마지막
   리비전이 `deployed` 이며 차트가 `podinfo-6.7.1` 이어야 한다.

## 모범 풀이

**1) 오래된 릴리스 찾기**

```bash
helm list -A
# NAME      NAMESPACE  REVISION  UPDATED  STATUS    CHART          APP VERSION
# backend   thames     1         ...      deployed  podinfo-6.5.4  6.5.4
# frontend  rhine      1         ...      deployed  podinfo-6.7.1  6.7.1

echo "backend thames" > /opt/course/f05/outdated.txt
```

`-A`(`--all-namespaces`) 없이 치면 현재 네임스페이스(보통 `default`)의 릴리스만 보여 빈 목록이 나옵니다.
비교할 것은 **CHART** 열의 `podinfo-<차트 버전>` 이고, APP VERSION 은 애플리케이션 버전입니다.

**2) 사용자 값을 유지하며 버전 올리기**

```bash
helm get values backend -n thames
# USER-SUPPLIED VALUES:
# replicaCount: 2

helm upgrade backend podinfo/podinfo --version 6.7.1 -n thames \
  --reset-then-reuse-values --wait
```

`helm upgrade` 에 값 플래그를 하나라도 주면 이전 릴리스의 사용자 값이 버려집니다. 위 명령처럼
값 플래그를 아예 안 주면 이전 사용자 값을 그대로 쓰지만, 의도를 분명히 하려면 플래그를 명시합니다.

| 플래그 | 출발점 | 차트 버전을 바꿀 때 |
|---|---|---|
| `--reuse-values` | 이전 릴리스의 **계산된 전체 값** | 새 차트에 추가된 기본값이 빠져 템플릿 에러가 날 수 있음 |
| `--reset-then-reuse-values` (Helm 3.14+, Helm 4) | **새 차트 기본값** + 이전 사용자 값 | 안전 — 차트 버전 업그레이드에 권장 |
| `--set replicaCount=2` 또는 `-f values.yaml` | 새 차트 기본값 + 이번에 준 값 | 안전 — 값을 직접 다시 준다 |

`--reset-then-reuse-values` 가 기억나지 않으면 `helm get values backend -n thames -o yaml > /tmp/v.yaml`
로 받아 `-f /tmp/v.yaml` 로 넘기면 됩니다. `--version` 을 빼면 저장소의 최신 차트로 올라가 버전 고정이 깨집니다.

**3) 히스토리 저장**

```bash
helm history backend -n thames > /opt/course/f05/history.txt
cat /opt/course/f05/history.txt
# REVISION  UPDATED  STATUS      CHART          APP VERSION  DESCRIPTION
# 1         ...      superseded  podinfo-6.5.4  6.5.4        Install complete
# 2         ...      deployed    podinfo-6.7.1  6.7.1        Upgrade complete
```

## 검증

```bash
cat /opt/course/f05/outdated.txt                     # backend thames
helm list -A | grep -E 'backend|frontend'            # 두 릴리스 모두 podinfo-6.7.1
helm get values backend -n thames                    # replicaCount: 2
kubectl -n thames get deploy
# NAME              READY   UP-TO-DATE   AVAILABLE
# backend-podinfo   2/2     2            2
kubectl -n thames get deploy -o jsonpath='{.items[0].spec.template.spec.containers[0].image}{"\n"}'
# ghcr.io/stefanprodan/podinfo:6.7.1
grep -c podinfo-6.7.1 /opt/course/f05/history.txt   # 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 버전만 올리고 값은 지킬 때 `helm upgrade <rel> <chart> --version X -n <ns> --reset-then-reuse-values`, 확인은 `helm get values` 와 `helm history`.
- **헷갈리는 지점**: `helm list` 는 기본적으로 현재 네임스페이스만 보여 줍니다(`-A` 필수). `--reuse-values` 는 차트 버전이 바뀔 때 새 차트의 새 기본값을 가져오지 않습니다. Helm 4(2025.11)에서도 같은 명령이며 `--atomic` 만 `--rollback-on-failure` 로 바뀌었습니다.

## 참고 문서

시험 중에는 kubernetes.io 문서와 함께 **helm.sh/docs** 도 열람할 수 있습니다.

- 검색어: `helm upgrade`, `helm list`, `helm history`
- https://helm.sh/docs/helm/helm_upgrade/
- https://helm.sh/docs/helm/helm_list/
- https://helm.sh/docs/helm/helm_history/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q06 →](../q06_rollout_pause_resume/question.md)

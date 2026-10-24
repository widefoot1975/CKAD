# q08 — Debug a CrashLoopBackOff Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The Pods of Deployment `billing` in namespace `theta` are in `CrashLoopBackOff`. The
> ConfigMaps `billing-config` and `billing-scripts` are correct and must not be changed.
>
> 1. Before changing anything, save the events of namespace `theta`, sorted by their last
>    timestamp, to `/opt/course/a08/events.txt`.
> 2. Use `describe`, the logs of the previous container instance and the events to find **every**
>    cause of the crash. Write each cause in one line to `/opt/course/a08/cause.txt`.
> 3. Fix the Deployment so that both replicas are `Running` and Ready and stop restarting. The log
>    of each Pod must contain `connected to postgres://billing@db.theta.svc:5432/billing`.
> 4. The environment variable `DB_URL` must not be optional: if its ConfigMap key is missing, the
>    container must not be started at all.

**해석**

`theta` 네임스페이스의 Deployment `billing` 의 Pod 들이 `CrashLoopBackOff` 상태다. ConfigMap `billing-config` 와
`billing-scripts` 는 올바르므로 바꾸면 안 된다.

1. 아무것도 바꾸기 전에 `theta` 네임스페이스의 이벤트를 마지막 타임스탬프 순으로 정렬해 `/opt/course/a08/events.txt` 에 저장한다.
2. `describe`, 이전 컨테이너 인스턴스의 로그, 이벤트를 써서 크래시의 원인을 **모두** 찾는다. 원인마다 한 줄씩
   `/opt/course/a08/cause.txt` 에 쓴다.
3. 두 레플리카가 모두 `Running` · Ready 이고 더 이상 재시작하지 않도록 Deployment 를 고친다. 각 Pod 의 로그에
   `connected to postgres://billing@db.theta.svc:5432/billing` 이 있어야 한다.
4. 환경 변수 `DB_URL` 은 optional 이면 안 된다. ConfigMap 키가 없으면 컨테이너가 아예 시작되지 않아야 한다.

## 모범 풀이

**1) 증거 먼저 저장**

```bash
alias k=kubectl
k -n theta get events --sort-by=.lastTimestamp > /opt/course/a08/events.txt
tail -5 /opt/course/a08/events.txt
# Warning  BackOff  pod/billing-...  Back-off restarting failed container billing in pod ...
```

고친 뒤에는 이벤트가 새 것으로 덮이므로, 문제가 "바꾸기 전에" 라고 하면 그 순서를 지킵니다.

**2) 원인 찾기 — 원인이 두 겹입니다**

```bash
k -n theta get pod -l app=billing
# billing-7c...-abcde   0/1   CrashLoopBackOff   3 (20s ago)   1m
P=$(k -n theta get pod -l app=billing -o jsonpath='{.items[0].metadata.name}')
k -n theta describe pod $P | grep -A6 'Last State'
#     Last State:  Terminated
#       Reason:    Error
#       Exit Code: 2
k -n theta logs $P --previous
# sh: can't open '/script/run.sh': No such file or directory
k -n theta get deploy billing -o jsonpath='{.spec.template.spec.containers[0].command}{"\n"}{.spec.template.spec.containers[0].volumeMounts}{"\n"}'
# ["sh","/script/run.sh"]
# [{"mountPath":"/scripts","name":"scripts"}]          ← /script vs /scripts
```

첫 번째 원인은 명령의 경로 오타입니다. 스크립트는 `/scripts` 에 마운트되는데 명령은 `/script/run.sh` 를 엽니다.
이것만 고치고 끝내면 안 됩니다. 앱이 실제로 실행되면 두 번째 원인이 드러납니다.

```bash
k -n theta patch deploy billing --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/command/1","value":"/scripts/run.sh"}]'
sleep 15; k -n theta logs deploy/billing --previous
# billing starting
# FATAL: DB_URL is empty
k -n theta get deploy billing -o jsonpath='{.spec.template.spec.containers[0].env}{"\n"}'
# [{"name":"DB_URL","valueFrom":{"configMapKeyRef":{"key":"db-url","name":"billing-config","optional":true}}}]
k -n theta get cm billing-config -o jsonpath='{.data}{"\n"}'
# {"database-url":"postgres://billing@db.theta.svc:5432/billing"}     ← 키 이름이 다르다
```

두 번째 원인은 env 가 존재하지 않는 키 `db-url` 을 가리키고, `optional: true` 라서 에러 없이 **빈 값**으로 시작한 것입니다.
앱이 `DB_URL` 이 비었다며 exit 1 로 죽습니다.

```bash
cat > /opt/course/a08/cause.txt <<'EOF'
command runs /script/run.sh but the scripts ConfigMap is mounted at /scripts (sh exit 2: can't open file)
env DB_URL references missing key db-url in ConfigMap billing-config (real key database-url); optional:true made it empty, app exits 1
EOF
```

**3) · 4) 키 이름 고치고 optional 제거**

```bash
k -n theta patch deploy billing --type=json -p='[
 {"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"database-url"},
 {"op":"remove","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/optional"}]'
k -n theta rollout status deploy billing
```

`kubectl edit deploy billing` 로 같은 두 군데를 고쳐도 됩니다. `optional` 의 기본값은 false 이므로 필드를 지우는 것이
"optional 이 아님" 입니다(`optional: false` 로 명시해도 됨).

optional 이 아니면 키가 없을 때 kubelet 이 컨테이너를 **만들지 않고** Pod 를 `CreateContainerConfigError`
(`couldn't find key db-url in ConfigMap theta/billing-config`)로 둡니다. 앱이 엉뚱한 값으로 떠서 늦게 죽는 것보다
원인이 이벤트에 바로 찍히므로 훨씬 빨리 찾을 수 있습니다.

## 검증

```bash
k -n theta get pod -l app=billing
# billing-5d...-aaaaa   1/1   Running   0   40s
# billing-5d...-bbbbb   1/1   Running   0   38s
k -n theta logs -l app=billing --prefix
# [pod/billing-.../billing] billing starting
# [pod/billing-.../billing] connected to postgres://billing@db.theta.svc:5432/billing
k -n theta get deploy billing -o jsonpath='{.spec.template.spec.containers[0].env[0].valueFrom.configMapKeyRef}{"\n"}'
# {"key":"database-url","name":"billing-config"}
k -n theta get cm billing-config -o jsonpath='{.data}{"\n"}'     # 바뀌지 않음
wc -l /opt/course/a08/cause.txt                                   # 2
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 하나 고친 뒤 `logs --previous` 를 **다시** 본다. CrashLoop 원인은 겹겹이 숨어 있을 수 있다.
- **헷갈리는 지점**: 없는 키를 참조하면 optional 이 아닐 때는 `CreateContainerConfigError`(컨테이너 시작 전), `optional: true` 일 때는 빈 값으로 시작해 앱이 죽는 `CrashLoopBackOff` 입니다. Pod 를 직접 지우면 Deployment 가 같은 템플릿으로 다시 만들 뿐이니 항상 Deployment 를 고칩니다.

## 참고 문서

- 검색어: `debug pods`, `configmap configMapKeyRef optional`, `determine reason for pod failure`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
- https://kubernetes.io/docs/concepts/configuration/configmap/#optional-configmaps
- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q09 →](../q09_migrate_removed_api_versions/question.md)

# q12 — QoS classes under a LimitRange · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Namespace `hazel` runs three Pods, `be`, `bu` and `gu`, which were created without any resources.
> A LimitRange `hazel-limits` was added to the namespace afterwards. The Pods must end up in the QoS
> classes their names suggest: `be` BestEffort, `bu` Burstable, `gu` Guaranteed. Keep the Pod names,
> the container name `app` and the image `registry.k8s.io/pause:3.10`.
>
> 1. `bu`: its container requests `100m` CPU and `64Mi` memory and sets no limits of its own.
> 2. `gu`: the owner first asks for `1` CPU and `128Mi` memory with requests equal to limits. Try
>    exactly that and save the API server's rejection message to `/opt/course/c12/rejected.txt`.
>    Then create `gu` with `128Mi` memory and the largest CPU value the namespace allows, still
>    Guaranteed.
> 3. `be` must be BestEffort when you are done.
> 4. Using jsonpath, write `<pod> <qosClass>` for `be`, `bu` and `gu` (in that order) to
>    `/opt/course/c12/qos.txt`, and the limits that the container of `bu` ended up with to
>    `/opt/course/c12/bu-limits.txt`.

**해석**

namespace `hazel` 에 resources 없이 만든 파드 `be`, `bu`, `gu` 가 돈다. 그 뒤에 LimitRange `hazel-limits` 가
namespace 에 추가되었다. 파드는 이름이 암시하는 QoS 클래스가 되어야 한다: `be` 는 BestEffort, `bu` 는 Burstable,
`gu` 는 Guaranteed. 파드 이름, 컨테이너 이름 `app`, 이미지 `registry.k8s.io/pause:3.10` 은 유지한다.

1. `bu`: 컨테이너는 CPU `100m`, 메모리 `64Mi` 를 request 하고 자체 limit 은 두지 않는다.
2. `gu`: 소유자는 먼저 CPU `1`, 메모리 `128Mi` 를 request = limit 으로 요청한다. 정확히 그대로 시도하고 API 서버의
   거부 메시지를 `/opt/course/c12/rejected.txt` 에 저장한다. 그다음 메모리 `128Mi` 와 namespace 가 허용하는 가장 큰
   CPU 값으로, 여전히 Guaranteed 인 `gu` 를 만든다.
3. 작업이 끝났을 때 `be` 는 BestEffort 여야 한다.
4. jsonpath 로 `be`, `bu`, `gu` 순서대로 `<pod> <qosClass>` 를 `/opt/course/c12/qos.txt` 에, `bu` 의 컨테이너가 최종적으로
   갖게 된 limits 를 `/opt/course/c12/bu-limits.txt` 에 쓴다.

## 모범 풀이

**0) LimitRange 부터 읽습니다**

```bash
kubectl -n hazel describe limitrange hazel-limits
# Type       Resource  Min  Max    Default Request  Default Limit  Max Limit/Request Ratio
# Container  cpu       -    500m   500m             500m           -
# Container  memory    -    256Mi  256Mi            256Mi          -
```

`max` 만 적었는데 Default Request / Default Limit 이 채워져 있습니다. LimitRange 의 API 기본값 처리 규칙입니다:
default(limit)가 없으면 **max 로**, defaultRequest 가 없으면 **default 로** 채웁니다. 그래서 이 namespace 에서
resources 없이 **새로** 만든 파드는 cpu 500m / memory 256Mi 의 request = limit 을 받아 Guaranteed 가 됩니다.

**1) bu — 파드를 다시 만든다**

```bash
kubectl -n hazel patch pod bu --subresource resize -p \
  '{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"100m","memory":"64Mi"}}}]}}'
# ... Pod QoS is immutable      ← v1.35 GA 의 in-place resize 도 QoS 클래스는 못 바꾼다
```

```bash
cat > /tmp/bu.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: bu
  namespace: hazel
  labels:
    app: qos-demo
spec:
  containers:
  - name: app
    image: registry.k8s.io/pause:3.10
    resources:
      requests:
        cpu: 100m
        memory: 64Mi
EOF
kubectl replace --force -f /tmp/bu.yaml
kubectl -n hazel get pod bu -o jsonpath='{.spec.containers[0].resources}{"\n"}'
# {"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"64Mi"}}
```

limit 을 주지 않았지만 LimitRange 가 default limit(500m/256Mi)을 **주입**했습니다. request < limit 이므로 Burstable
입니다. 문제의 "자체 limit 은 두지 않는다" 는 매니페스트에 쓰지 않는다는 뜻이고, 결과 limit 은 4번에서 기록합니다.

**2) gu — 먼저 거부를 확인하고, 허용되는 최대값으로**

```bash
cat > /tmp/gu.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gu
  namespace: hazel
  labels:
    app: qos-demo
spec:
  containers:
  - name: app
    image: registry.k8s.io/pause:3.10
    resources:
      requests:
        cpu: "1"
        memory: 128Mi
      limits:
        cpu: "1"
        memory: 128Mi
EOF
kubectl -n hazel delete pod gu
kubectl apply -f /tmp/gu.yaml 2> /opt/course/c12/rejected.txt; cat /opt/course/c12/rejected.txt
# Error from server (Forbidden): error when creating "/tmp/gu.yaml": pods "gu" is forbidden:
#   maximum cpu usage per Container is 500m, but limit is 1

sed -i 's/cpu: "1"/cpu: 500m/' /tmp/gu.yaml
kubectl apply -f /tmp/gu.yaml
```

LimitRanger 는 admission 단계에서 검사하므로 오류는 파드가 생기기 전에 나옵니다(stderr 이므로 `2>`). 허용 최대값은
`max.cpu` = `500m` 입니다. Guaranteed 조건은 **모든 컨테이너의 cpu·memory 모두 request = limit** 입니다.

**3) be — 건드리지 않는 것이 정답**

`be` 는 LimitRange 가 생기기 **전에** 만들어져 BestEffort 상태입니다. LimitRange 는 생성·수정 시점의 admission 에만
적용되고 이미 있는 파드는 바꾸지 않습니다. 만약 `be` 를 다시 만들면 default 가 주입되어 Guaranteed(500m/256Mi)가
되어 버리고, 이 namespace 에서는 BestEffort 파드를 새로 만들 방법이 없습니다. 그대로 둡니다.

**4) 기록**

```bash
kubectl -n hazel get pod be bu gu -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.qosClass}{"\n"}{end}' \
  | tee /opt/course/c12/qos.txt
# be BestEffort
# bu Burstable
# gu Guaranteed
kubectl -n hazel get pod bu -o jsonpath='{.spec.containers[0].resources.limits}' | tee /opt/course/c12/bu-limits.txt; echo
# {"cpu":"500m","memory":"256Mi"}
```

이름을 나열해 `get pod be bu gu` 로 가져오면 출력이 그 순서를 따릅니다.

## 검증

```bash
cat /opt/course/c12/qos.txt                 # be BestEffort / bu Burstable / gu Guaranteed
grep -q 'maximum cpu usage per Container is 500m' /opt/course/c12/rejected.txt && echo ok
cat /opt/course/c12/bu-limits.txt           # {"cpu":"500m","memory":"256Mi"}
kubectl -n hazel get pod gu -o jsonpath='{.spec.containers[0].resources}{"\n"}'
# {"limits":{"cpu":"500m","memory":"128Mi"},"requests":{"cpu":"500m","memory":"128Mi"}}
kubectl -n hazel get pod be -o jsonpath='{.spec.containers[0].resources}{"\n"}'   # {}
kubectl -n hazel get pod -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,C:.spec.containers[0].name
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: QoS 는 Guaranteed(cpu·mem 모두 request=limit) / Burstable(일부만) / BestEffort(아무것도 없음). LimitRange 의 max 만 있어도 default 가 max 로 주입된다.
- **헷갈리는 지점**: LimitRange 는 이미 있는 파드를 바꾸지 않습니다. in-place resize(v1.35 GA)는 QoS 클래스를 바꾸는 변경을 거부하므로 QoS 를 바꾸려면 다시 만들어야 합니다. limit 만 주면 request 가 limit 으로 채워져 Guaranteed 가 됩니다.

## 참고 문서

- 검색어: `pod quality of service`, `limit range`
- https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/
- https://kubernetes.io/docs/concepts/policy/limit-range/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q13 →](../q13_securitycontext_readonly_rootfs/question.md)

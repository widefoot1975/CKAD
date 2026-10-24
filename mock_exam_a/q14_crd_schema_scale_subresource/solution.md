# q14 — Work with a CRD that has a schema and a scale subresource · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A CustomResourceDefinition in the API group `a14.example.com` has been installed in the
> cluster. Work with it without reading its source manifest from disk.
>
> 1. Find the resource of this API group and write one line to `/opt/course/a14/resource.txt`
>    in the format `<plural> <shortname> <kind> <namespaced>` (for example
>    `widgets wd Widget true`).
> 2. Find the allowed values of the field `spec.backend` and the allowed range of
>    `spec.replicas`. Write them to `/opt/course/a14/schema.txt` as two lines:
>    `backend=<value1>,<value2>,...` and `replicas=<min>-<max>`.
> 3. Write `/opt/course/a14/invalid.yaml` with a resource named `broken` in namespace `xi` that
>    uses `backend: kafka` and `replicas: 2`. Try to create it and write the error message to
>    `/opt/course/a14/invalid-error.txt`. The object must not exist afterwards.
> 4. Write `/opt/course/a14/orders.yaml` with a valid resource named `orders` in namespace `xi`
>    using `backend: redis` and `replicas: 2`, and create it.
> 5. Scale `orders` to `4` replicas with `kubectl scale`, so that its `spec.replicas` becomes `4`.

**해석**

API 그룹 `a14.example.com` 의 CustomResourceDefinition 이 클러스터에 설치되어 있다. 디스크의 원본 매니페스트를 읽지 말고 클러스터에서 알아내 작업한다.

1. 이 API 그룹의 리소스를 찾아 `<복수형> <단축이름> <Kind> <네임스페이스 범위 여부>` 형식(예: `widgets wd Widget true`)의 한 줄을
   `/opt/course/a14/resource.txt` 에 쓴다.
2. 필드 `spec.backend` 에 허용되는 값들과 `spec.replicas` 의 허용 범위를 찾는다. `backend=<값1>,<값2>,...` 와
   `replicas=<최솟값>-<최댓값>` 두 줄로 `/opt/course/a14/schema.txt` 에 쓴다.
3. `xi` 네임스페이스에 `backend: kafka`, `replicas: 2` 인 `broken` 리소스를 담은 `/opt/course/a14/invalid.yaml` 을 쓴다. 생성을
   시도하고 에러 메시지를 `/opt/course/a14/invalid-error.txt` 에 쓴다. 그 뒤에 이 객체가 존재하면 안 된다.
4. `xi` 네임스페이스에 `backend: redis`, `replicas: 2` 인 올바른 리소스 `orders` 를 담은 `/opt/course/a14/orders.yaml` 을 쓰고 생성한다.
5. `kubectl scale` 로 `orders` 를 `4` 로 늘려 `spec.replicas` 가 `4` 가 되게 한다.

## 모범 풀이

**1) 리소스 찾기 — api-resources**

```bash
alias k=kubectl
k api-resources --api-group=a14.example.com
# NAME     SHORTNAMES   APIVERSION           NAMESPACED   KIND
# queues   qu           a14.example.com/v1   true         Queue
echo "queues qu Queue true" > /opt/course/a14/resource.txt
```

`--api-group` 으로 걸러야 같은 이름의 다른 리소스와 헷갈리지 않습니다. CRD 이름은 항상 `<plural>.<group>` 이라
`k get crd | grep a14` 로 `queues.a14.example.com` 을 찾는 것도 같은 결과입니다.

**2) 스키마 읽기 — explain + CRD 본문**

```bash
k explain queue.spec
# FIELDS:
#   backend   <string> -required-
#     enum: redis, rabbitmq
#     Message broker that backs the queue.
#   replicas  <integer> -required-
#   ...
k explain queue.spec.backend          # ENUM: redis, rabbitmq
k get crd queues.a14.example.com \
  -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.replicas}{"\n"}'
# {"maximum":10,"minimum":1,"type":"integer"}
printf 'backend=redis,rabbitmq\nreplicas=1-10\n' > /opt/course/a14/schema.txt
```

`kubectl explain` 은 타입·required·enum·설명은 보여 주지만 `minimum`/`maximum` 같은 수치 제약은 보여 주지 않습니다.
범위는 CRD 객체의 `openAPIV3Schema` 를 직접 읽습니다(디스크 파일이 아니라 클러스터의 CRD 이므로 허용된 방법).

**3) 스키마에 막히는 객체**

```bash
cat > /opt/course/a14/invalid.yaml <<'EOF'
apiVersion: a14.example.com/v1
kind: Queue
metadata:
  name: broken
  namespace: xi
spec:
  backend: kafka
  replicas: 2
EOF
k apply -f /opt/course/a14/invalid.yaml 2> /opt/course/a14/invalid-error.txt
cat /opt/course/a14/invalid-error.txt
# The Queue "broken" is invalid: spec.backend: Unsupported value: "kafka": supported values: "redis", "rabbitmq"
k -n xi get queue broken          # Error from server (NotFound)
```

에러는 stderr 로 나오므로 `2>` 로 받습니다. structural schema 검증은 API 서버에서 일어나므로 객체는 저장되지 않습니다.

**4) 올바른 객체**

```bash
sed -e 's/broken/orders/' -e 's/kafka/redis/' /opt/course/a14/invalid.yaml > /opt/course/a14/orders.yaml
k apply -f /opt/course/a14/orders.yaml
k -n xi get qu
# NAME     BACKEND   REPLICAS   AGE
# orders   redis     2          5s
```

**5) scale 서브리소스**

```bash
k -n xi scale queue orders --replicas=4
# queue.a14.example.com/orders scaled
k -n xi get queue orders -o jsonpath='{.spec.replicas}{"\n"}'      # 4
k get --raw /apis/a14.example.com/v1/namespaces/xi/queues/orders/scale
# {"kind":"Scale","apiVersion":"autoscaling/v1",...,"spec":{"replicas":4},"status":{"replicas":0}}
```

`kubectl scale` 은 CRD 에 `subresources.scale` 이 있어야 동작합니다. `specReplicasPath: .spec.replicas` 가 scale 요청을
그 필드로 옮겨 적습니다. 이 리소스를 다루는 컨트롤러(Operator)가 없으므로 `status.replicas` 는 비어 있고, 실제 Pod 도 생기지 않습니다.
같은 scale 서브리소스 덕분에 HPA 도 이 리소스를 대상으로 삼을 수 있습니다.

## 검증

```bash
cat /opt/course/a14/resource.txt /opt/course/a14/schema.txt
grep -q 'Unsupported value' /opt/course/a14/invalid-error.txt && echo "스키마 거부 기록 OK"
k -n xi get queue
# NAME     BACKEND   REPLICAS   AGE
# orders   redis     4          1m        ← broken 은 없다
k get crd queues.a14.example.com -o jsonpath='{.spec.versions[0].subresources}{"\n"}'
# {"scale":{"specReplicasPath":".spec.replicas","statusReplicasPath":".status.replicas"},"status":{}}
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 처음 보는 CRD = `api-resources --api-group=<g>` → `explain <kind>.spec` → 필요하면 `get crd <plural>.<group> -o yaml`.
- **헷갈리는 지점**: `kubectl explain` 에는 min/max 가 나오지 않습니다. `kubectl scale` 이 `the server could not find the requested resource` 로 실패하면 CRD 에 scale 서브리소스가 없는 것입니다. CRD 를 지우면 그 종류의 커스텀 리소스도 모두 지워집니다.

## 참고 문서

- 검색어: `extend the kubernetes api with customresourcedefinitions`, `custom resources`
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
- https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q15 →](../q15_multiport_service_no_endpoints/question.md)

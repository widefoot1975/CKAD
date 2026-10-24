# q09 — Migrate manifests off removed API versions · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The multi-document manifest `/opt/course/a09/legacy.yaml` was written for an old cluster.
> `kubectl apply` fails with it on this cluster. Do not modify `legacy.yaml`.
>
> 1. Find out which API versions used in the file are no longer served by this cluster. Write one
>    line per object to `/opt/course/a09/versions.txt` in the format
>    `<Kind> <old apiVersion> -> <new apiVersion>`.
> 2. Create `/opt/course/a09/current.yaml` that contains all four objects converted to the
>    current stable API versions, keeping their names, namespace and behaviour, including every
>    field whose structure changed between the versions.
> 3. The Ingress rule for path `/` must use path type `Prefix`.
> 4. Apply `/opt/course/a09/current.yaml`. All four objects must exist in namespace `iota`, and
>    `kubectl` must not print any deprecation warning.

**해석**

여러 문서로 된 매니페스트 `/opt/course/a09/legacy.yaml` 은 옛 클러스터용으로 작성되었다. 이 클러스터에서는
`kubectl apply` 가 실패한다. `legacy.yaml` 은 수정하지 않는다.

1. 파일에 쓰인 API 버전 중 이 클러스터가 더 이상 제공하지 않는 것을 찾는다. 객체마다 한 줄씩
   `<Kind> <옛 apiVersion> -> <새 apiVersion>` 형식으로 `/opt/course/a09/versions.txt` 에 쓴다.
2. 네 객체를 모두 현재 stable API 버전으로 바꾼 `/opt/course/a09/current.yaml` 을 만든다. 이름, 네임스페이스, 동작은
   유지하고, 버전 사이에 구조가 바뀐 필드도 모두 반영한다.
3. 경로 `/` 의 Ingress 규칙은 path type `Prefix` 를 쓴다.
4. `/opt/course/a09/current.yaml` 을 적용한다. 네 객체가 모두 `iota` 에 있어야 하고, `kubectl` 이 deprecation 경고를
   하나도 출력하지 않아야 한다.

## 모범 풀이

**1) 무엇이 없어졌는지 클러스터에 묻습니다**

```bash
kubectl apply -f /opt/course/a09/legacy.yaml --dry-run=server
# error: resource mapping not found for name: "web" namespace: "iota" from "/opt/course/a09/legacy.yaml":
#   no matches for kind "Ingress" in version "extensions/v1beta1"
#   ensure CRDs are installed first
# (CronJob, PodDisruptionBudget, HorizontalPodAutoscaler 도 같은 에러)
grep -E '^(apiVersion|kind):' /opt/course/a09/legacy.yaml
kubectl api-resources | grep -E 'ingresses|cronjobs|poddisruptionbudgets|horizontalpodautoscalers'
# cronjobs                  cj     batch/v1                true   CronJob
# horizontalpodautoscalers  hpa    autoscaling/v2          true   HorizontalPodAutoscaler
# ingresses                 ing    networking.k8s.io/v1    true   Ingress
# poddisruptionbudgets      pdb    policy/v1               true   PodDisruptionBudget
```

제거된 버전은 "deprecated 경고" 가 아니라 **`no matches for kind`** 에러로 나옵니다. 경고는 아직 제공되지만 곧 없어질
버전에서만 나옵니다. `kubectl api-resources` 의 APIVERSION 열이 이 클러스터의 선호(stable) 버전입니다.

```bash
cat > /opt/course/a09/versions.txt <<'EOF'
Ingress extensions/v1beta1 -> networking.k8s.io/v1
CronJob batch/v1beta1 -> batch/v1
PodDisruptionBudget policy/v1beta1 -> policy/v1
HorizontalPodAutoscaler autoscaling/v2beta1 -> autoscaling/v2
EOF
```

| 객체 | 옛 버전 | 제거 | 새 버전 | 구조 변화 |
|---|---|---|---|---|
| Ingress | `extensions/v1beta1` (`networking.k8s.io/v1beta1` 도) | 1.22 | `networking.k8s.io/v1` | `serviceName`/`servicePort` → `service.name`/`service.port.number`, `pathType` 필수 |
| CronJob | `batch/v1beta1` | 1.25 | `batch/v1` | 없음 |
| PodDisruptionBudget | `policy/v1beta1` | 1.25 | `policy/v1` | 필드 같음. 빈 selector 가 "아무것도 안 고름" → "네임스페이스 전체" 로 의미 변경 |
| HPA | `autoscaling/v2beta1` (1.25), `v2beta2` (1.26) | | `autoscaling/v2` | `targetAverageUtilization` → `target: {type: Utilization, averageUtilization}` |

새 구조는 `kubectl explain` 으로 확인합니다(시험장에서 가장 빠른 방법).

```bash
kubectl explain ingress.spec.rules.http.paths.backend.service --api-version=networking.k8s.io/v1
kubectl explain hpa.spec.metrics.resource.target --api-version=autoscaling/v2
```

**2) · 3) current.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: iota
spec:
  rules:
  - host: web.iota.local
    http:
      paths:
      - path: /
        pathType: Prefix                 # v1 에서 필수
        backend:
          service:                       # serviceName/servicePort 대신
            name: web
            port:
              number: 80                 # 이름이면 port.name
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup
  namespace: iota
spec:
  schedule: "*/30 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "echo cleanup"]
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web
  namespace: iota
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: web
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web
  namespace: iota
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:                            # targetAverageUtilization: 70 대신
        type: Utilization
        averageUtilization: 70
```

`kubectl convert` 는 별도 플러그인(kubectl-convert)이라 시험장에 없다고 가정하고 손으로 바꿉니다. 바꾼 뒤에는 먼저
`kubectl apply -f current.yaml --dry-run=server` 로 서버 검증을 받아 보면 필드 오타를 적용 전에 잡을 수 있습니다.

**4) 적용**

```bash
kubectl apply -f /opt/course/a09/current.yaml --dry-run=server     # 오류·경고 없음
kubectl apply -f /opt/course/a09/current.yaml
# ingress.networking.k8s.io/web created
# cronjob.batch/cleanup created
# poddisruptionbudget.policy/web created
# horizontalpodautoscaler.autoscaling/web created
```

## 검증

```bash
kubectl -n iota get ingress,cronjob,pdb,hpa
kubectl -n iota get ingress web -o jsonpath='{.spec.rules[0].http.paths[0].pathType} {.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}{"\n"}'
# Prefix web:80
kubectl -n iota get hpa web -o jsonpath='{.spec.metrics[0].resource.target}{"\n"}'
# {"averageUtilization":70,"type":"Utilization"}
kubectl apply -f /opt/course/a09/current.yaml 2>&1 | grep -i warning || echo "경고 없음"
grep -c 'v1beta1\|v2beta1' /opt/course/a09/legacy.yaml    # 4 — legacy.yaml 은 그대로
cat /opt/course/a09/versions.txt
```

HPA 의 TARGETS 가 `<unknown>/70%` 로 보이는 것은 metrics-server 가 없거나 아직 수집 전이기 때문이며 이 문제와 무관합니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 제거된 API = `no matches for kind "X" in version "Y"`. 새 버전은 `kubectl api-resources`, 새 구조는 `kubectl explain --api-version=`.
- **헷갈리는 지점**: apiVersion 만 바꾸면 Ingress 는 `serviceName` 필드 때문에 거부되고(strict 검증 `unknown field`), `pathType` 누락도 거부됩니다. HPA 는 `v2beta2 → v2` 는 구조가 같지만 `v1`(`targetCPUUtilizationPercentage`)·`v2beta1`(`targetAverageUtilization`)에서 올 때는 `target` 블록으로 바꿔야 합니다. 클러스터 안에 이미 저장된 객체는 API 서버가 새 버전으로 읽어 주므로, 손봐야 하는 것은 **파일**(매니페스트, 차트)입니다.

## 참고 문서

- 검색어: `deprecated api migration guide`, `ingress`, `horizontal pod autoscale walkthrough`
- https://kubernetes.io/docs/reference/using-api/deprecation-guide/
- https://kubernetes.io/docs/concepts/services-networking/ingress/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q10 →](../q10_projected_volume_configmap_secret/question.md)

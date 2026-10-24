# q09 — Find preferred API versions and migrate an HPA to v2 · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A team kept an old HorizontalPodAutoscaler manifest, `/opt/course/c09/hpa-v2beta2.yaml`, and it no
> longer applies. Find out which API versions this cluster serves and migrate the manifest.
>
> 1. For `HorizontalPodAutoscaler`, `CronJob`, `PodDisruptionBudget`, `Ingress` and `FlowSchema`,
>    write the **preferred** API version served by this cluster to `/opt/course/c09/preferred.txt`,
>    one line each in the form `<Kind> <group>/<version>`, in that order.
> 2. Write every served version of the `autoscaling` group (as listed by `kubectl api-versions`) to
>    `/opt/course/c09/autoscaling-versions.txt`.
> 3. Run a server-side dry run of the old manifest and save the complete output, including the
>    error, to `/opt/course/c09/old-error.txt`.
> 4. Write `/opt/course/c09/hpa-v2.yaml` using `autoscaling/v2`. Keep every metric and every
>    `behavior` setting of the old manifest, and additionally make scale-down more conservative:
>    add a second scale-down policy of type `Pods` that allows `1` Pod per `60` seconds and make
>    scale-down use the policy that allows the **smallest** change.
> 5. Validate the new manifest with a server-side dry run (nothing may be created) and save the output
>    to `/opt/course/c09/dry-run.txt`.

**해석**

한 팀이 옛 HorizontalPodAutoscaler 매니페스트 `/opt/course/c09/hpa-v2beta2.yaml` 을 갖고 있는데 더 이상 적용되지
않는다. 이 클러스터가 어떤 API 버전을 제공하는지 확인하고 매니페스트를 옮긴다.

1. `HorizontalPodAutoscaler`, `CronJob`, `PodDisruptionBudget`, `Ingress`, `FlowSchema` 에 대해 이 클러스터가
   제공하는 **preferred** API 버전을 `<Kind> <group>/<version>` 형식으로 한 줄씩, 이 순서대로
   `/opt/course/c09/preferred.txt` 에 쓴다.
2. `autoscaling` 그룹이 제공하는 모든 버전(`kubectl api-versions` 에 나오는 그대로)을
   `/opt/course/c09/autoscaling-versions.txt` 에 쓴다.
3. 옛 매니페스트를 서버 쪽 dry-run 으로 실행하고, 오류를 포함한 전체 출력을 `/opt/course/c09/old-error.txt` 에
   저장한다.
4. `autoscaling/v2` 로 `/opt/course/c09/hpa-v2.yaml` 을 쓴다. 옛 매니페스트의 metric 과 `behavior` 설정을 모두
   유지하고, 추가로 scale-down 을 더 보수적으로 만든다: 60초마다 파드 `1` 개를 허용하는 `Pods` 타입의 두 번째
   scale-down 정책을 넣고, scale-down 이 **가장 작은** 변화를 허용하는 정책을 쓰게 한다.
5. 새 매니페스트를 서버 쪽 dry-run 으로 검증하고(아무것도 만들어지면 안 된다) 출력을
   `/opt/course/c09/dry-run.txt` 에 저장한다.

## 모범 풀이

**1) preferred 버전** — `kubectl api-resources` 의 APIVERSION 열이 그 리소스의 preferred 버전입니다.

```bash
kubectl api-resources | grep -E '^(horizontalpodautoscalers|cronjobs|poddisruptionbudgets|ingresses|flowschemas) '
# NAME                       SHORTNAMES  APIVERSION                       NAMESPACED  KIND
# cronjobs                   cj          batch/v1                         true        CronJob
# horizontalpodautoscalers   hpa         autoscaling/v2                   true        HorizontalPodAutoscaler
# ingresses                  ing         networking.k8s.io/v1             true        Ingress
# poddisruptionbudgets       pdb         policy/v1                        true        PodDisruptionBudget
# flowschemas                            flowcontrol.apiserver.k8s.io/v1  false       FlowSchema

cat > /opt/course/c09/preferred.txt <<'EOF'
HorizontalPodAutoscaler autoscaling/v2
CronJob batch/v1
PodDisruptionBudget policy/v1
Ingress networking.k8s.io/v1
FlowSchema flowcontrol.apiserver.k8s.io/v1
EOF
```

다른 확인 방법:

```bash
kubectl explain hpa | head -3                         # GROUP: autoscaling / KIND / VERSION: v2  ← preferred
kubectl get --raw /apis/autoscaling | grep -o '"preferredVersion":{[^}]*}'
# "preferredVersion":{"groupVersion":"autoscaling/v2","version":"v2"}
```

`kubectl explain` 은 `--api-version` 을 주지 않으면 preferred 버전의 스키마를 보여 줍니다. HPA 는 `autoscaling/v1`
도 아직 제공되지만 preferred 는 `v2` 입니다.

**2) autoscaling 그룹의 모든 버전**

```bash
kubectl api-versions | grep '^autoscaling/' | tee /opt/course/c09/autoscaling-versions.txt
# autoscaling/v1
# autoscaling/v2
```

`v2beta1`(1.25 제거)과 `v2beta2`(1.26 제거)는 더 이상 없습니다.

**3) 옛 매니페스트의 오류**

```bash
kubectl apply --dry-run=server -f /opt/course/c09/hpa-v2beta2.yaml > /opt/course/c09/old-error.txt 2>&1
cat /opt/course/c09/old-error.txt
# error: resource mapping not found for name: "web-hpa" namespace: "" from "/opt/course/c09/hpa-v2beta2.yaml":
#   no matches for kind "HorizontalPodAutoscaler" in version "autoscaling/v2beta2"
# ensure CRDs are installed first
```

오류는 stderr 로 나오므로 `2>&1` 이 없으면 파일이 비어 있습니다. **제거된** 버전은 이렇게 "no matches for kind"
로 실패하고, **deprecated 지만 아직 제공되는** 버전은 적용은 되면서 `Warning: ... is deprecated in v1.xx+,
unavailable in v1.yy+` 경고만 나옵니다.

**4) v2 로 변환** — `kubectl convert` 는 별도 플러그인이라 시험 환경에 없다고 보고, 손으로 옮깁니다. 필드는
`kubectl explain` 으로 확인합니다.

```bash
kubectl explain hpa.spec.behavior.scaleDown --api-version=autoscaling/v2
#   policies        <[]HPAScalingPolicy>
#   selectPolicy    <string>   ... Max, Min, Disabled
#   stabilizationWindowSeconds  <integer>
kubectl explain hpa.spec.behavior.scaleDown.policies --api-version=autoscaling/v2
```

`autoscaling/v2beta2` 와 `v2` 의 스키마는 같습니다(v2 는 v2beta2 를 그대로 GA 로 올린 것). 그래서 apiVersion 만
바꾸면 기존 내용은 그대로 유효합니다. 여기에 요구 사항을 더합니다.

```bash
sed 's#autoscaling/v2beta2#autoscaling/v2#' /opt/course/c09/hpa-v2beta2.yaml > /opt/course/c09/hpa-v2.yaml
vi /opt/course/c09/hpa-v2.yaml
```

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  labels:
    app: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 200Mi
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      selectPolicy: Min               # 여러 정책 중 가장 작은 변화를 허용하는 쪽
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 1
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
```

`selectPolicy` 의 기본값은 `Max`(가장 큰 변화를 허용하는 정책)입니다. 정책을 하나 더 넣기만 하면 Percent 50% 와
Pods 1 중 **더 큰 쪽**이 적용되어 오히려 덜 보수적일 수 있습니다. "가장 작은 변화" 는 `selectPolicy: Min` 입니다.

**5) 서버 쪽 dry-run 검증**

```bash
kubectl apply --dry-run=server -f /opt/course/c09/hpa-v2.yaml | tee /opt/course/c09/dry-run.txt
# horizontalpodautoscaler.autoscaling/web-hpa created (server dry run)
kubectl get hpa web-hpa 2>&1 | head -1          # Error from server (NotFound) — 실제로는 안 만들어졌다
```

`--dry-run=client` 는 API 서버의 검증(스키마, admission)을 거치지 않습니다. `--dry-run=server` 는 저장 직전까지
모든 검증을 하고 저장만 하지 않으므로, 버전 이전 검증에는 server 가 맞습니다. scaleTargetRef 의 Deployment `web`
이 없어도 HPA 생성 자체는 검증을 통과합니다.

## 검증

```bash
cat /opt/course/c09/preferred.txt                 # 5줄, 위 순서
cat /opt/course/c09/autoscaling-versions.txt      # autoscaling/v1, autoscaling/v2
grep -q 'no matches for kind' /opt/course/c09/old-error.txt && echo ok
grep -E '^apiVersion|selectPolicy|type: Pods' /opt/course/c09/hpa-v2.yaml
# apiVersion: autoscaling/v2
#       selectPolicy: Min
#       - type: Pods        (scaleDown)
#       - type: Pods        (scaleUp)
#       selectPolicy: Max
cat /opt/course/c09/dry-run.txt                   # ... created (server dry run)
kubectl get hpa -A | grep web-hpa || echo "실제로는 없음 (정상)"
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: preferred 버전은 `kubectl api-resources` 의 APIVERSION 열 또는 `kubectl explain <kind>` 의 VERSION. 다른 버전 스키마는 `kubectl explain ... --api-version=`.
- **헷갈리는 지점**: 제거된 API 는 "no matches for kind" 로 실패하고, deprecated API 는 경고만 나옵니다. HPA behavior 의 `selectPolicy` 기본값은 `Max` 입니다. 대표 제거 시점: Ingress `extensions/v1beta1`·`networking.k8s.io/v1beta1` 1.22, CronJob `batch/v1beta1`·PDB `policy/v1beta1` 1.25, HPA `autoscaling/v2beta2` 1.26, FlowSchema `v1beta3` 1.32.

## 참고 문서

- 검색어: `deprecated API migration guide`, `horizontal pod autoscale behavior`
- https://kubernetes.io/docs/reference/using-api/deprecation-guide/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q10 →](../q10_immutable_secret_rotation/question.md)

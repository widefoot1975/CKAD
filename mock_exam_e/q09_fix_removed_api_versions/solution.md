# q09 — Repair manifests that use removed API versions · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> An old manifest `/opt/course/e09/legacy.yaml` was written for a much older Kubernetes release
> and fails to apply on this v1.37 cluster.
>
> 1. Find the API group/version that this cluster serves for the kinds `Deployment` and `CronJob`
>    and write them to `/opt/course/e09/apis.txt`, one per line in the form `<Kind> <apiVersion>`
>    (for example `Pod v1`).
> 2. Fix `/opt/course/e09/legacy.yaml` in place so that it applies cleanly. Keep all names, labels,
>    images, replica counts and the schedule unchanged, and add any field that the current API
>    version requires.
> 3. Apply the file and confirm that Deployment `ledger` has `2` ready replicas and CronJob
>    `ledger-cleanup` exists in namespace `amber`.

**해석**

오래된 매니페스트 `/opt/course/e09/legacy.yaml` 은 훨씬 예전 Kubernetes 릴리스에 맞춰 작성되어 이
v1.37 클러스터에서는 적용이 실패한다.

1. 이 클러스터가 kind `Deployment` 와 `CronJob` 에 대해 제공하는 API 그룹/버전을 찾아
   `/opt/course/e09/apis.txt` 에 `<Kind> <apiVersion>` 형식(예: `Pod v1`)으로 한 줄에 하나씩 쓴다.
2. `/opt/course/e09/legacy.yaml` 이 문제없이 적용되도록 그 파일 자체를 고친다. 이름, 라벨, 이미지,
   레플리카 수, 스케줄은 바꾸지 않고, 현재 API 버전이 요구하는 필드가 있으면 추가한다.
3. 파일을 적용하고 `amber` 네임스페이스에서 Deployment `ledger` 가 Ready 레플리카 `2` 개이고
   CronJob `ledger-cleanup` 이 존재하는지 확인한다.

## 모범 풀이

**0) 먼저 적용해 보고 에러를 읽습니다**

```bash
kubectl apply -f /opt/course/e09/legacy.yaml
# resource mapping not found for name: "ledger" namespace: "amber" from "/opt/course/e09/legacy.yaml":
#   no matches for kind "Deployment" in version "apps/v1beta1"
# resource mapping not found for name: "ledger-cleanup" ... no matches for kind "CronJob" in version "batch/v1beta1"
```

**삭제된(removed)** API 버전은 `no matches for kind` 로 실패하고, **deprecated** 일 뿐 아직 있는
버전은 적용은 되면서 `Warning: ... is deprecated` 를 출력합니다. 이 파일은 둘 다 삭제된 경우입니다
(`apps/v1beta1` Deployment 는 1.16, `batch/v1beta1` CronJob 은 1.25 에서 제거).

**1) 클러스터가 제공하는 버전 확인**

```bash
kubectl api-resources | grep -E '^(deployments|cronjobs) '
# cronjobs      cj       batch/v1   true   CronJob
# deployments   deploy   apps/v1    true   Deployment
kubectl explain deployment | head -3        # GROUP: apps / VERSION: v1
printf 'Deployment apps/v1\nCronJob batch/v1\n' > /opt/course/e09/apis.txt
```

**2) 파일 고치기**

```yaml
apiVersion: apps/v1                 # apps/v1beta1 → apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: amber
  labels:
    app: ledger
spec:
  replicas: 2
  selector:                         # apps/v1 에서 필수. 예전에는 템플릿 라벨로 기본값이 채워졌다
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
      - name: ledger
        image: nginx:1.27-alpine
---
apiVersion: batch/v1                # batch/v1beta1 → batch/v1 (구조는 같다)
kind: CronJob
metadata:
  name: ledger-cleanup
  namespace: amber
spec:
  schedule: "*/10 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "echo cleaning ledger"]
```

`apps/v1` 은 `spec.selector` 를 **필수**로 바꾸었고, selector 는 템플릿 라벨과 일치해야 합니다. 버전만
바꾸면 `spec.selector: Required value` 로 다시 거부됩니다. 서버로 미리 검사하려면
`kubectl apply --dry-run=server -f legacy.yaml` 를 씁니다. (`kubectl convert` 플러그인도 있지만 시험
환경에는 기본으로 깔려 있지 않습니다.)

**3) 적용과 확인**

```bash
kubectl apply -f /opt/course/e09/legacy.yaml
kubectl -n amber rollout status deploy ledger
kubectl -n amber get deploy,cronjob
```

## 검증

```bash
cat /opt/course/e09/apis.txt
# Deployment apps/v1
# CronJob batch/v1
grep -E '^apiVersion' /opt/course/e09/legacy.yaml
# apiVersion: apps/v1
# apiVersion: batch/v1
kubectl -n amber get deploy ledger
# NAME     READY   UP-TO-DATE   AVAILABLE   AGE
# ledger   2/2     2            2           30s
kubectl -n amber get cronjob ledger-cleanup
# NAME             SCHEDULE       TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
# ledger-cleanup   */10 * * * *   <none>     False     0        <none>          30s
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 삭제된 버전은 `no matches for kind`. `kubectl api-resources` / `kubectl explain` 으로 현재 버전을 찾고, `apps/v1` 은 `selector` 가 필수다.
- **헷갈리는 지점**: deprecated(경고만 남) 와 removed(적용 실패) 를 구분합니다. 자주 나오는 제거 목록: Ingress `extensions/v1beta1`·`networking.k8s.io/v1beta1`(1.22), CronJob `batch/v1beta1`·PDB `policy/v1beta1`(1.25), HPA `autoscaling/v2beta2`(1.26). `kubectl api-versions` 는 그룹/버전 목록만 보여 주고 어떤 kind 가 어디 있는지는 `api-resources` 가 보여 줍니다.

## 참고 문서

- 검색어: `deprecated API migration guide`, `kubectl api-resources`
- https://kubernetes.io/docs/reference/using-api/deprecation-guide/
- https://kubernetes.io/docs/reference/using-api/deprecation-policy/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q10 →](../q10_secret_volume_key_mode/question.md)

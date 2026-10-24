# q14 — Explore a CRD and create a custom resource · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A backup operator is being introduced. Its CustomResourceDefinition in API group `f14.example.com`
> is already installed; the operator itself is not running yet, but the team wants the first backup
> object to be ready.
>
> 1. Using `kubectl api-resources` and `kubectl explain`, find the kind of the resource in API group
>    `f14.example.com` and the fields that are required in its `spec`. Write them to
>    `/opt/course/f14/info.txt` as exactly two lines, listing the required fields in alphabetical
>    order:
>
>    ```
>    kind=<Kind>
>    required=<field>,<field>
>    ```
>
> 2. Create a resource of that kind named `nightly` in namespace `elbe` that backs up the
>    PersistentVolumeClaim `orders-db` every day at `02:00` (cron `0 2 * * *`) and keeps backups for
>    `7` days. Find the field names with `kubectl explain`.

**해석**

백업 operator 를 도입하는 중이다. API 그룹 `f14.example.com` 의 CustomResourceDefinition 은 이미 설치되어 있다.
operator 자체는 아직 돌지 않지만, 팀은 첫 번째 백업 객체를 준비해 두려 한다.

1. `kubectl api-resources` 와 `kubectl explain` 으로 API 그룹 `f14.example.com` 리소스의 kind 와 그 `spec` 의
   필수 필드를 찾는다. 이를 `/opt/course/f14/info.txt` 에 정확히 두 줄로 적되, 필수 필드는 알파벳순으로 적는다:

   ```
   kind=<Kind>
   required=<field>,<field>
   ```

2. 그 kind 의 리소스 `nightly` 를 `elbe` 네임스페이스에 만든다. PersistentVolumeClaim `orders-db` 를 매일
   `02:00`(cron `0 2 * * *`)에 백업하고 백업을 `7` 일 보관하게 한다. 필드 이름은 `kubectl explain` 으로 찾는다.

## 모범 풀이

**1) kind 와 필수 필드 찾기**

```bash
kubectl api-resources --api-group=f14.example.com
# NAME      SHORTNAMES   APIVERSION           NAMESPACED   KIND
# backups   bk           f14.example.com/v1   true         Backup

kubectl explain backups.spec
# GROUP:      f14.example.com
# KIND:       Backup
# VERSION:    v1
#
# FIELD: spec <Object>
#
# DESCRIPTION:
#     Desired backup settings.
#
# FIELDS:
#   retentionDays	<integer>
#     Number of days a backup is kept. Defaults to 3 when omitted.
#
#   schedule	<string> -required-
#     Cron expression that defines when the backup runs, e.g. "30 1 * * *".
#
#   target	<string> -required-
#     Name of the PersistentVolumeClaim in the same namespace to back up.

printf 'kind=Backup\nrequired=schedule,target\n' > /opt/course/f14/info.txt
```

`kubectl explain` 은 CRD 의 `openAPIV3Schema` 를 읽어 `-required-` 표시와 설명을 보여 줍니다. 리소스 이름이
다른 그룹과 겹칠 수 있으면 `kubectl explain backups.spec --api-version=f14.example.com/v1` 로 그룹을 고정합니다.
`kubectl explain backups --recursive` 는 필드 트리 전체를 한 번에 보여 줍니다.

**2) 커스텀 리소스 만들기**

```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: f14.example.com/v1
kind: Backup
metadata:
  name: nightly
  namespace: elbe
spec:
  schedule: "0 2 * * *"
  target: orders-db
  retentionDays: 7
YAML
```

cron 문자열은 `*` 때문에 따옴표로 감쌉니다(YAML 에서 `*` 로 시작하는 값은 alias 로 해석됩니다). 필수 필드를 빼면
`spec.target: Required value` 로, `retentionDays: "7"` 처럼 문자열을 주면 타입 검증으로 거부됩니다.
operator 가 없으므로 객체는 저장만 되고 실제 백업은 일어나지 않습니다.

## 검증

```bash
cat /opt/course/f14/info.txt
# kind=Backup
# required=schedule,target
kubectl -n elbe get bk
# NAME      SCHEDULE    TARGET      RETENTION   AGE
# nightly   0 2 * * *   orders-db   7           10s
kubectl -n elbe get backup nightly -o jsonpath='{.spec}{"\n"}'
# {"retentionDays":7,"schedule":"0 2 * * *","target":"orders-db"}
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 모르는 CRD 는 `kubectl api-resources --api-group=<g>` 로 kind·apiVersion 을, `kubectl explain <plural>.spec` 으로 필드와 `-required-` 를 읽는다.
- **헷갈리는 지점**: `apiVersion` 은 `<group>/<version>`(`f14.example.com/v1`)이고 CRD 이름(`backups.f14.example.com`)이 아닙니다. CRD 를 지우면 그 종류의 모든 커스텀 리소스도 함께 지워집니다.

## 참고 문서

- 검색어: `custom resources`, `extend the kubernetes api with customresourcedefinitions`
- https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q15 →](../q15_service_selector_mismatch/question.md)

# q14 — Create a custom resource from an existing CRD · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A backup operator team has installed a CustomResourceDefinition in API group `e14.example.com`.
> Use it to declare a backup for the `coral` namespace.
>
> 1. Find the kind, the served version and the fields of the custom resource defined in group
>    `e14.example.com`.
> 2. In namespace `coral`, create a resource of that kind named `nightly-db` with
>    `source: postgres-main`, `schedule: "0 2 * * *"` and `retentionDays: 7` in its `spec`.
> 3. Write the output of listing these resources in namespace `coral` (the default `kubectl get`
>    table) to `/opt/course/e14/backups.txt`.

**해석**

백업 오퍼레이터 팀이 API 그룹 `e14.example.com` 에 CustomResourceDefinition 을 설치했다. 이것으로
`coral` 네임스페이스의 백업을 선언한다.

1. 그룹 `e14.example.com` 에 정의된 커스텀 리소스의 kind, 제공(served) 버전, 필드를 찾는다.
2. `coral` 네임스페이스에 그 kind 로 이름 `nightly-db` 인 리소스를 만든다. `spec` 은
   `source: postgres-main`, `schedule: "0 2 * * *"`, `retentionDays: 7` 이다.
3. `coral` 네임스페이스의 이 리소스 목록(기본 `kubectl get` 표)을 `/opt/course/e14/backups.txt` 에 쓴다.

## 모범 풀이

**1) CRD 정보 찾기**

```bash
kubectl get crd | grep e14.example.com
# backups.e14.example.com   2026-10-24T01:00:00Z
kubectl api-resources --api-group=e14.example.com
# NAME      SHORTNAMES   APIVERSION           NAMESPACED   KIND
# backups   bk           e14.example.com/v1   true         Backup
kubectl explain backup.spec
# FIELDS:
#   retentionDays   <integer>
#   schedule        <string>
#   source          <string> -required-
```

CRD 에 OpenAPI 스키마가 있으면 `kubectl explain` 이 일반 리소스처럼 필드를 보여 줍니다.
`apiVersion` 은 `<group>/<version>` 이므로 `e14.example.com/v1` 입니다.

**2) 커스텀 리소스 만들기**

```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: e14.example.com/v1
kind: Backup
metadata:
  name: nightly-db
  namespace: coral
spec:
  source: postgres-main
  schedule: "0 2 * * *"      # 따옴표 필수. 없으면 * 때문에 YAML 파싱 에러
  retentionDays: 7           # 정수. "7" 처럼 문자열이면 스키마 검증 실패
YAML
```

스키마 검증은 API 서버가 합니다. `retentionDays: "7"` 은 `must be of type integer` 로, 범위를 벗어난
값(이 CRD 는 1~30)은 `should be less than or equal to 30` 으로 거부됩니다. 스키마에 없는 필드는
경고와 함께 잘려 나갑니다(pruning).

**3) 목록 기록**

```bash
kubectl -n coral get backups > /opt/course/e14/backups.txt
cat /opt/course/e14/backups.txt
# NAME         SOURCE          SCHEDULE    RETENTION   AGE
# nightly-db   postgres-main   0 2 * * *   7           10s
```

`backups`, `backup`, `bk`, `backups.e14.example.com` 모두 같은 리소스를 가리킵니다. SOURCE 같은 열은 CRD 의
`additionalPrinterColumns` 가 정한 것입니다.

## 검증

```bash
kubectl -n coral get bk nightly-db -o jsonpath='{.apiVersion} {.kind} {.spec.source} {.spec.schedule} {.spec.retentionDays}{"\n"}'
# e14.example.com/v1 Backup postgres-main 0 2 * * * 7
cat /opt/course/e14/backups.txt                 # 헤더 + nightly-db 한 줄
grep -c nightly-db /opt/course/e14/backups.txt  # 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CRD 조사는 `kubectl api-resources --api-group=<g>` → `kubectl explain <kind>.spec`. apiVersion = `<group>/<version>`.
- **헷갈리는 지점**: CRD 이름(`backups.e14.example.com`)은 `<plural>.<group>` 이지 kind 가 아닙니다. 매니페스트의 `kind` 는 `Backup`(단수, 대문자 시작)입니다. cron 문자열처럼 `*` 로 시작하는 값은 따옴표로 감싸야 YAML 이 alias 로 읽지 않습니다.

## 참고 문서

- 검색어: `custom resources`, `extend the kubernetes api with customresourcedefinitions`
- https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q15 →](../q15_nodeport_targetport_fix/question.md)

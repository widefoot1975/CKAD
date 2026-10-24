# q14 — Discover an operator's CRDs and create a custom resource · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> An operator was installed into the cluster by another team. Its CRDs carry the label
> `app.kubernetes.io/part-of=c14-operator`. Find out what it added and use its API.
>
> 1. Write the names of all CRDs that belong to this operator, sorted, one per line, to
>    `/opt/course/c14/crds.txt`.
> 2. Count the `Backup` objects of group `c14.example.com` in all namespaces and write the number to
>    `/opt/course/c14/backup-count.txt`. List them as `<namespace>/<name>`, one per line, in
>    `/opt/course/c14/backups.txt`.
> 3. The `Backup` CRD serves more than one version. Write the version that is used for storage to
>    `/opt/course/c14/storage-version.txt`.
> 4. Create a `Backup` named `inventory-nightly` in namespace `alder` using that storage version.
>    Discover the field names with `kubectl explain`: it must back up the database `inventory`,
>    keep backups for `14` days and run on the cron schedule `30 1 * * *`.

**해석**

다른 팀이 클러스터에 오퍼레이터를 설치했다. 그 CRD 들에는 라벨 `app.kubernetes.io/part-of=c14-operator` 가 붙어
있다. 무엇이 추가됐는지 알아내고 그 API 를 사용한다.

1. 이 오퍼레이터에 속한 모든 CRD 의 이름을 정렬해 한 줄에 하나씩 `/opt/course/c14/crds.txt` 에 쓴다.
2. 모든 namespace 에서 그룹 `c14.example.com` 의 `Backup` 객체 수를 세어 `/opt/course/c14/backup-count.txt` 에 쓴다.
   그것들을 `<namespace>/<name>` 형식으로 한 줄에 하나씩 `/opt/course/c14/backups.txt` 에 나열한다.
3. `Backup` CRD 는 버전을 둘 이상 제공한다. 저장(storage)에 쓰이는 버전을 `/opt/course/c14/storage-version.txt` 에 쓴다.
4. 그 storage 버전으로 namespace `alder` 에 이름이 `inventory-nightly` 인 `Backup` 을 만든다. 필드 이름은
   `kubectl explain` 으로 찾는다: 데이터베이스 `inventory` 를 백업하고, 백업을 `14` 일 보관하며, cron 스케줄
   `30 1 * * *` 로 돌아야 한다.

## 모범 풀이

**1) 라벨로 CRD 찾기**

```bash
kubectl get crd -l app.kubernetes.io/part-of=c14-operator
kubectl get crd -l app.kubernetes.io/part-of=c14-operator -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
  | sort | tee /opt/course/c14/crds.txt
# backups.c14.example.com
# backupstores.c14.example.com
# restores.c14.example.com
```

CRD 이름은 항상 `<plural>.<group>` 입니다. `-o name` 을 쓰면 `customresourcedefinition.apiextensions.k8s.io/` 접두사가
붙으므로 jsonpath(또는 `-o custom-columns=NAME:.metadata.name --no-headers`)로 이름만 뽑습니다.
`kubectl api-resources --api-group=c14.example.com` 은 이 그룹의 리소스·shortName·scope 를 한눈에 보여 줍니다.

**2) 그룹까지 붙여서 세기 — 함정은 이름 충돌**

```bash
kubectl get crd | grep '^backups\.'
# backups.c14.example.com
# backups.c14x.example.com          ← 다른 팀의 CRD 도 plural 이 backups

kubectl get backups.c14.example.com -A
# NAMESPACE   NAME             DATABASE   SCHEDULE    KEEPDAYS
# alder       billing-weekly   billing    0 3 * * 0   30
# rowan       orders-daily     orders     0 2 * * *   7
# rowan       users-daily      users      15 2 * * *  7

kubectl get backups.c14.example.com -A --no-headers | wc -l | tee /opt/course/c14/backup-count.txt    # 3
kubectl get backups.c14.example.com -A \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}' | tee /opt/course/c14/backups.txt
```

`kubectl get backups` 처럼 plural 만 쓰면 같은 이름을 가진 두 그룹 중 하나를 kubectl 이 골라 버립니다(어느 쪽인지
보장되지 않음). 그룹이 명시된 문제에서는 항상 `<plural>.<group>` 으로 씁니다. shortName `bk` 는 `c14.example.com` 에만
있으므로 `kubectl get bk -A` 도 됩니다. 클러스터 범위인 `BackupStore` 는 `-A` 와 상관없이 namespace 가 없습니다.

**3) storage 버전**

```bash
kubectl get crd backups.c14.example.com -o jsonpath='{range .spec.versions[*]}{.name}{" served="}{.served}{" storage="}{.storage}{" deprecated="}{.deprecated}{"\n"}{end}'
# v1alpha1 served=true storage=false deprecated=true
# v1 served=true storage=true deprecated=
kubectl get crd backups.c14.example.com -o jsonpath='{.spec.versions[?(@.storage==true)].name}' | tee /opt/course/c14/storage-version.txt; echo
# v1
```

storage 버전은 CRD 당 정확히 하나이며 etcd 에 저장되는 형식입니다. `.status.storedVersions` 는 지금까지 저장에 쓰인
적이 있는 버전 목록이라 storage 버전과 다를 수 있습니다.

**4) explain 으로 필드를 찾아 CR 만들기**

```bash
kubectl explain backups.spec --api-version=c14.example.com/v1 --recursive
# FIELDS:
#   database   <string> -required-
#   retention  <Object> -required-
#     keepDays <integer> -required-
#   schedule   <string>
kubectl explain backups.spec.retention.keepDays --api-version=c14.example.com/v1
#   Number of days a finished backup is kept (1-30).
```

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: c14.example.com/v1
kind: Backup
metadata:
  name: inventory-nightly
  namespace: alder
spec:
  database: inventory
  schedule: "30 1 * * *"
  retention:
    keepDays: 14
EOF
```

- `keepDays` 는 integer 이므로 `"14"` 처럼 따옴표를 붙이면 `spec.retention.keepDays: Invalid value: "string"` 으로
  거부됩니다. 반대로 cron 문자열은 따옴표로 감싸 두는 것이 안전합니다(`*/5 * * * *` 처럼 `*` 로 시작하면 YAML alias 로 해석되어 오류가 납니다).
- `v1alpha1` 로 만들어도 저장은 되지만 `Warning: c14.example.com/v1alpha1 Backup is deprecated; use c14.example.com/v1`
  이 나옵니다. 문제는 storage 버전(`v1`)을 쓰라고 했습니다.
- 스키마의 `required`·`minimum`·`maximum` 은 API 서버가 검증합니다. 오퍼레이터(컨트롤러)가 없어도 객체는 만들어지고,
  실제 백업 동작만 일어나지 않습니다.

## 검증

```bash
cat /opt/course/c14/crds.txt                  # 3줄
cat /opt/course/c14/backup-count.txt          # 3   (inventory-nightly 를 만들기 전에 센 값)
cat /opt/course/c14/backups.txt               # alder/billing-weekly, rowan/orders-daily, rowan/users-daily
cat /opt/course/c14/storage-version.txt       # v1
kubectl -n alder get backups.c14.example.com inventory-nightly
# NAME                DATABASE    SCHEDULE     KEEPDAYS
# inventory-nightly   inventory   30 1 * * *   14
kubectl -n alder get backups.c14.example.com inventory-nightly -o jsonpath='{.apiVersion}{"\n"}'   # c14.example.com/v1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CRD 는 `kubectl get crd -l <label>`, 인스턴스는 `kubectl get <plural>.<group> -A`. 필드는 `kubectl explain <plural>.spec --api-version=<group>/<version> --recursive`.
- **헷갈리는 지점**: plural 만 쓰면 다른 그룹의 같은 이름 리소스를 셀 수 있습니다. storage 버전은 `.spec.versions[?(@.storage==true)]`, `.status.storedVersions` 와 다릅니다. deprecated 버전으로 만들면 경고만 나오고 성공합니다.

## 참고 문서

- 검색어: `custom resource definitions versioning`, `operator pattern`
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/
- https://kubernetes.io/docs/concepts/extend-kubernetes/operator/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q15 →](../q15_service_targetport_externalname/question.md)

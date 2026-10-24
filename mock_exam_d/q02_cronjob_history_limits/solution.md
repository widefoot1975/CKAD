# q02 — Schedule a CronJob with history limits · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The `falcon` team needs a small report task that runs on a fixed schedule in namespace `falcon`.
>
> 1. Create a CronJob named `falcon-report` in namespace `falcon` that runs every 5 minutes. Its
>    container is named `report`, uses image `busybox:1.36` and runs
>    `sh -c 'date; echo falcon report done'`.
> 2. The CronJob must keep at most `2` successful Jobs and at most `4` failed Jobs in its history,
>    and its Pods must use `restartPolicy: OnFailure`.
> 3. Without waiting for the schedule, create a Job named `falcon-report-manual` from the CronJob,
>    wait until it completes and write its logs to `/opt/course/d02/manual.log`.

**해석**

`falcon` 팀은 `falcon` 네임스페이스에서 정해진 일정으로 도는 작은 리포트 작업이 필요하다.

1. `falcon` 네임스페이스에 5분마다 실행되는 CronJob `falcon-report` 를 만든다. 컨테이너 이름은
   `report`, 이미지는 `busybox:1.36`, 명령은 `sh -c 'date; echo falcon report done'` 이다.
2. CronJob 은 히스토리에 성공한 Job 을 최대 `2` 개, 실패한 Job 을 최대 `4` 개까지 남겨야 하고, 그 파드는
   `restartPolicy: OnFailure` 를 써야 한다.
3. 일정을 기다리지 말고 CronJob 으로부터 Job `falcon-report-manual` 을 만들어 완료될 때까지 기다린 뒤,
   그 로그를 `/opt/course/d02/manual.log` 에 적는다.

## 모범 풀이

**1) 뼈대는 명령형으로 만들고 yaml 로 받습니다**

```bash
export do="--dry-run=client -o yaml"
kubectl -n falcon create cronjob falcon-report --image=busybox:1.36 \
  --schedule='*/5 * * * *' $do -- sh -c 'date; echo falcon report done' > cj.yaml
```

`kubectl create cronjob` 은 컨테이너 이름을 CronJob 이름(`falcon-report`)으로 만들고 `restartPolicy` 는
`OnFailure` 로 넣어 줍니다. 컨테이너 이름은 문제에서 `report` 로 정했으므로 직접 고쳐야 합니다.
`--schedule` 값은 작은따옴표로 감싸야 셸이 `*` 를 파일 이름으로 펼치지 않습니다.

**2) 히스토리 제한과 컨테이너 이름을 고칩니다**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: falcon-report
  namespace: falcon
spec:
  schedule: '*/5 * * * *'
  successfulJobsHistoryLimit: 2      # 기본값 3
  failedJobsHistoryLimit: 4          # 기본값 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: report                 # falcon-report → report
            image: busybox:1.36
            command: ["sh", "-c", "date; echo falcon report done"]
```

```bash
kubectl apply -f cj.yaml
```

두 history limit 은 `spec` 바로 아래(= `jobTemplate` 과 같은 깊이)의 필드입니다. `jobTemplate.spec` 안에
넣으면 Job 의 알 수 없는 필드라 거부되거나 무시됩니다. 기본값이 3 과 1 이라서, 값을 안 넣어도 "어딘가에 숫자가
있는" 것처럼 보이는 것이 함정입니다.

**3) 수동 실행과 로그**

```bash
kubectl -n falcon create job falcon-report-manual --from=cronjob/falcon-report
kubectl -n falcon wait job falcon-report-manual --for=condition=Complete --timeout=60s
kubectl -n falcon logs job/falcon-report-manual > /opt/course/d02/manual.log
```

`--from=cronjob/<이름>` 은 CronJob 의 `jobTemplate` 을 그대로 복사해 Job 을 하나 만듭니다. `logs job/<이름>` 은
그 Job 의 파드 하나를 골라 로그를 보여 줍니다.

## 검증

```bash
kubectl -n falcon get cronjob falcon-report
# NAME            SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
# falcon-report   */5 * * * *   <none>     False     0        <none>          1m
kubectl -n falcon get cronjob falcon-report \
  -o jsonpath='{.spec.successfulJobsHistoryLimit} {.spec.failedJobsHistoryLimit} {.spec.jobTemplate.spec.template.spec.restartPolicy} {.spec.jobTemplate.spec.template.spec.containers[0].name}{"\n"}'
# 2 4 OnFailure report
kubectl -n falcon get job falcon-report-manual       # COMPLETIONS 1/1
cat /opt/course/d02/manual.log
# Sat Oct 24 10:00:00 UTC 2026
# falcon report done
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `successfulJobsHistoryLimit`/`failedJobsHistoryLimit` 은 CronJob `spec` 바로 아래, `restartPolicy` 는 `jobTemplate.spec.template.spec` 아래.
- **헷갈리는 지점**: Job 파드의 `restartPolicy` 는 `Never` 또는 `OnFailure` 만 허용됩니다(`Always` 는 거부). `batch/v1beta1` CronJob 은 1.25 에서 제거되어 지금은 `batch/v1` 만 씁니다. 실패 재시도를 세밀하게 다루려면 GA 된 `podFailurePolicy`(1.31)·`backoffLimitPerIndex`(1.33)를 `jobTemplate.spec` 에 넣습니다.

## 참고 문서

- 검색어: `cronjob`, `running automated tasks with a cronjob`
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
- https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q03 →](../q03_init_container_emptydir/question.md)

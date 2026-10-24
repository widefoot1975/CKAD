# q02 — CronJob with concurrency, deadlines and a manual run · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The reporting team needs a nightly report in namespace `alpha`. Runs must never overlap, and a
> run that cannot start on time must be skipped instead of being started late.
>
> 1. Create a CronJob named `nightly-report` in namespace `alpha` with the schedule `30 2 * * *`,
>    evaluated in the time zone `Asia/Seoul`.
> 2. Configure the CronJob so that:
>    - a new run is skipped while the previous run is still active,
>    - a run that cannot start within `120` seconds of its scheduled time is skipped,
>    - only the last `2` successful Jobs and the last `1` failed Job are kept.
> 3. Each Job created by the CronJob must be terminated when it runs longer than `60` seconds and
>    must not be retried after a failure. Its Pod uses `restartPolicy: Never` and has one container
>    named `report` with image `busybox:1.36` that runs:
>    `sh -c 'echo "report for $(date +%F)"; echo "rows=42"'`
> 4. Without waiting for the schedule, create a Job named `nightly-report-manual` in namespace
>    `alpha` from this CronJob. Wait until it has completed and write its log output to
>    `/opt/course/a02/manual.log`.

**해석**

리포팅 팀이 `alpha` 네임스페이스에 야간 리포트가 필요하다. 실행이 겹치면 안 되고, 제시간에 시작하지 못한
실행은 늦게 시작하지 말고 건너뛰어야 한다.

1. `alpha` 에 CronJob `nightly-report` 를 만든다. 스케줄은 `30 2 * * *` 이고 시간대 `Asia/Seoul` 기준으로 해석한다.
2. CronJob 을 다음과 같이 설정한다.
   - 이전 실행이 아직 돌고 있으면 새 실행을 건너뛴다.
   - 예정 시각으로부터 `120` 초 안에 시작하지 못한 실행은 건너뛴다.
   - 성공한 Job 은 최근 `2` 개, 실패한 Job 은 최근 `1` 개만 남긴다.
3. CronJob 이 만드는 각 Job 은 `60` 초보다 오래 돌면 종료되어야 하고, 실패 후 재시도하면 안 된다. 그 Pod 는
   `restartPolicy: Never` 이고, 이미지 `busybox:1.36` 인 컨테이너 `report` 하나가 다음을 실행한다:
   `sh -c 'echo "report for $(date +%F)"; echo "rows=42"'`
4. 스케줄을 기다리지 않고 이 CronJob 으로부터 `alpha` 에 Job `nightly-report-manual` 을 만든다. 완료될 때까지
   기다린 뒤 그 로그 출력을 `/opt/course/a02/manual.log` 에 쓴다.

## 모범 풀이

**1) 뼈대는 명령형으로, 나머지는 YAML 로**

```bash
alias k=kubectl; export do="--dry-run=client -o yaml"
k -n alpha create cronjob nightly-report --image=busybox:1.36 --schedule='30 2 * * *' $do \
  -- sh -c 'echo "report for $(date +%F)"; echo "rows=42"' > /tmp/a02.yaml
```

`kubectl create cronjob` 에는 시간대·동시 실행·기한·히스토리 플래그가 없습니다. 그리고 생성되는 뼈대에는
함정이 두 개 있습니다. **컨테이너 이름이 CronJob 이름(`nightly-report`)** 으로 들어가고,
**`restartPolicy` 가 `OnFailure`** 로 들어갑니다. 둘 다 문제 요구와 다르므로 고칩니다.

**2) · 3) YAML 완성**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-report
  namespace: alpha
spec:
  schedule: "30 2 * * *"
  timeZone: Asia/Seoul                # CronJob spec 필드 (IANA 이름)
  concurrencyPolicy: Forbid           # 이전 실행이 돌고 있으면 건너뜀
  startingDeadlineSeconds: 120        # 120초 안에 못 띄우면 그 회차는 놓친 것으로 처리
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      activeDeadlineSeconds: 60       # Job 전체 실행 시간 상한 (jobTemplate.spec 위치!)
      backoffLimit: 0                 # 실패해도 재시도 없음
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: report              # 뼈대의 nightly-report 에서 바꾼다
            image: busybox:1.36
            command:
            - sh
            - -c
            - echo "report for $(date +%F)"; echo "rows=42"
```

```bash
k apply -f /tmp/a02.yaml
```

필드 위치가 이 문제의 핵심입니다.

| 요구 | 필드 | 위치 |
|---|---|---|
| 시간대 | `timeZone` | `CronJob.spec` |
| 겹침 금지 | `concurrencyPolicy: Forbid` | `CronJob.spec` (`Allow` 기본, `Replace` 는 이전 실행을 죽이고 새로 시작) |
| 늦은 시작 금지 | `startingDeadlineSeconds` | `CronJob.spec` |
| 히스토리 | `successfulJobsHistoryLimit` / `failedJobsHistoryLimit` | `CronJob.spec` (기본 3 / 1) |
| 60초 제한 | `activeDeadlineSeconds` | `jobTemplate.spec` (Job) |
| 재시도 금지 | `backoffLimit: 0` | `jobTemplate.spec` (기본 6) |

Pod spec 에도 `activeDeadlineSeconds` 필드가 있어서 `template.spec` 에 넣어도 API 가 받아 줍니다. 하지만 그것은
**Pod 하나의** 수명 제한이고, 문제는 **Job** 의 제한을 요구합니다. Job 의 `activeDeadlineSeconds` 에 걸리면 Job 이
`DeadlineExceeded` 로 Failed 가 되고, 이것은 `backoffLimit` 보다 우선합니다.

스케줄 문자열에 `CRON_TZ=Asia/Seoul 30 2 * * *` 처럼 시간대를 넣는 방식은 공식 지원되지 않으며 검증에서
거부됩니다. 반드시 `spec.timeZone` 을 씁니다.

**4) 수동 실행과 로그**

```bash
k -n alpha create job nightly-report-manual --from=cronjob/nightly-report
k -n alpha wait --for=condition=complete job/nightly-report-manual --timeout=60s
k -n alpha logs job/nightly-report-manual > /opt/course/a02/manual.log
cat /opt/course/a02/manual.log
# report for 2026-10-24
# rows=42
```

`--from=cronjob/...` 는 CronJob 의 `jobTemplate` 을 그대로 복사해 Job 을 만듭니다. 그래서 위에서 `jobTemplate`
을 제대로 고쳐 두지 않았다면 수동 Job 에도 같은 오류가 따라옵니다. `wait --for=condition=complete` 로 기다린 뒤
로그를 떠야 출력이 잘리지 않습니다.

## 검증

```bash
k -n alpha get cronjob nightly-report
# NAME             SCHEDULE     TIMEZONE     SUSPEND   ACTIVE   LAST SCHEDULE   AGE
# nightly-report   30 2 * * *   Asia/Seoul   False     0        <none>          1m
k -n alpha get cronjob nightly-report -o jsonpath='{.spec.concurrencyPolicy} {.spec.startingDeadlineSeconds} {.spec.successfulJobsHistoryLimit} {.spec.failedJobsHistoryLimit}{"\n"}'
# Forbid 120 2 1
k -n alpha get cronjob nightly-report -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds} {.spec.jobTemplate.spec.backoffLimit} {.spec.jobTemplate.spec.template.spec.restartPolicy} {.spec.jobTemplate.spec.template.spec.containers[0].name}{"\n"}'
# 60 0 Never report
k -n alpha get job nightly-report-manual
# NAME                    STATUS     COMPLETIONS   DURATION   AGE
# nightly-report-manual   Complete   1/1           4s         30s
cat /opt/course/a02/manual.log    # report for ... / rows=42
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CronJob 정책(`timeZone`, `concurrencyPolicy`, `startingDeadlineSeconds`, history)은 `CronJob.spec`, 실행 제한(`activeDeadlineSeconds`, `backoffLimit`)은 `jobTemplate.spec`.
- **헷갈리는 지점**: `kubectl create cronjob` 뼈대는 컨테이너 이름이 CronJob 이름이고 `restartPolicy: OnFailure` 입니다. `Forbid` 는 "건너뜀", `Replace` 는 "기존 실행을 죽이고 교체" 입니다. 재시도 세부 제어가 필요하면 GA 된 `podFailurePolicy`(v1.31)와 Indexed Job 의 `backoffLimitPerIndex`(v1.33)도 `jobTemplate.spec` 에 들어갑니다.

## 참고 문서

- 검색어: `cronjob`, `cronjob time zones`, `job termination and cleanup`
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
- https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q03 →](../q03_init_native_sidecar_shared_volume/question.md)

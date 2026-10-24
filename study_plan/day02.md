# 2일차 (D-9) — 이미지 빌드 · Job · CronJob

[← 1일차](day01.md) · [계획 전체](README.md) · [3일차 →](day03.md)

## 오늘의 목표

- `podman build`·`tag`·`save` 를 막힘 없이 칠 수 있게 합니다. 이미지 빌드 문항은 거의 매번 나옵니다.
- 끝나야 하는 워크로드(Job)와 주기 워크로드(CronJob)의 필드를 구분합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §2 Application Design and Build |
| 0:15 – 0:36 | 아래 문제 3개 풀기 |
| 0:36 – 0:48 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:48 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D01 | Design & Build | Podman 으로 이미지 빌드·저장 | 7 | 7분 | [Q](../mock_exam_d/q01_podman_build_save_image/question.md) · [S](../mock_exam_d/q01_podman_build_save_image/solution.md) ☐ |
| D02 | Design & Build | history limit 이 있는 CronJob | 7 | 7분 | [Q](../mock_exam_d/q02_cronjob_history_limits/question.md) · [S](../mock_exam_d/q02_cronjob_history_limits/solution.md) ☐ |
| E01 | Design & Build | 병렬 Job 실행과 로그 수집 | 7 | 7분 | [Q](../mock_exam_e/q01_job_completions_parallelism/question.md) · [S](../mock_exam_e/q01_job_completions_parallelism/solution.md) ☐ |

합계 21점, 목표 21분.

## 꼭 잡을 것

```bash
podman build -t app:v1 -f Dockerfile .
podman save -o /opt/course/x/app.tar app:v1                     # docker-archive
podman save --format oci-archive -o app-oci.tar app:v1
kubectl create cronjob hello --image=busybox:1.36 --schedule='*/5 * * * *' $do -- date > cj.yaml
kubectl create job manual-1 --from=cronjob/hello                # CronJob 을 지금 한 번 실행
```

- tar 형식을 문제에서 다시 읽습니다. `docker-archive`(기본)와 `oci-archive` 는 다른 파일입니다.
- Job: `completions`·`parallelism`·`backoffLimit`·`activeDeadlineSeconds`·`ttlSecondsAfterFinished`.
- CronJob: `concurrencyPolicy`, `successfulJobsHistoryLimit`·`failedJobsHistoryLimit`, `timeZone`. 명령형에 없는 필드는 `$do` 로 뽑은 yaml 에 추가합니다.

## 여유가 있으면

- 심화 [A01 Dockerfile 고치고 OCI 이미지로 저장](../mock_exam_a/q01_dockerfile_fix_build_oci_archive/question.md)
- 심화 [A02 concurrency·deadline 이 있는 CronJob](../mock_exam_a/q02_cronjob_forbid_timezone_manual_run/question.md)

# q09 — Find a memory hog and an OOMKilled container

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q09_top_memory_oomkilled
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `titan` 과 `europa` 에 여러 파드가 돌고 있고, 그중 하나의 컨테이너는 메모리 부족으로 이미 한 번 이상 재시작했다. metrics-server 가 설치되어 `kubectl top` 이 동작한다(첫 수집까지 1분쯤 걸릴 수 있다).
metrics-server 는 공용 인프라라 정리할 때 지우지 않는다. `/opt/course/b09/` 는 비어 있다.

## Task

The platform team asks you to review the memory behaviour of the workloads in namespaces `titan`
and `europa`. Pods in other namespaces are out of scope.

1. Using `kubectl top`, find the Pod that currently uses the most memory in these two namespaces
   and write it to `/opt/course/b09/top-memory.txt` in the form `<namespace>/<pod>`.
2. One container in these namespaces has been killed because it ran out of memory. Write it to
   `/opt/course/b09/oomkilled.txt` in the form `<namespace>/<owning-deployment>/<container>`, and
   write its last termination reason and exit code to `/opt/course/b09/last-state.txt` in the form
   `<reason> <exitCode>`.
3. Raise the memory limit of only that container to `128Mi` in its Deployment. Do not change the
   other containers of the Pod.
4. Confirm that the new Pods of that Deployment stay `Running` without restarts.

## My attempt

```bash

```

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q08](../q08_debug_distroless_ephemeral/question.md) · [q10 →](../q10_inplace_pod_resize/question.md)

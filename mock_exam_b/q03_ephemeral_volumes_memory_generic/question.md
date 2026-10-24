# q03 — Memory-backed and generic ephemeral volumes

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q03_ephemeral_volumes_memory_generic
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `venus` 는 비어 있고(Pod·PVC 없음), StorageClass `local-path`(local-path provisioner)가 설치되어 있다. `/opt/course/b03/` 는 비어 있다.
local-path provisioner 는 다른 문제에서도 쓰므로 정리할 때 지우지 않는다. 설치에 GitHub 와 Docker Hub 로 인터넷 연결이 필요하다.

## Task

A rendering job needs a small, fast cache and a larger scratch area. Neither may outlive the Pod.

1. Create a Pod `render` in namespace `venus` with one container `app`, image `busybox:1.36`,
   memory request `64Mi` and memory limit `256Mi`, and the command
   `sh -c 'echo warm > /cache/state; dd if=/dev/zero of=/scratch/blob bs=1M count=50; sleep 3600'`.
2. Mount at `/cache` a volume named `cache` that is backed by RAM and limited to `64Mi`.
3. Mount at `/scratch` a volume named `scratch` whose PersistentVolumeClaim is created and deleted
   together with the Pod: StorageClass `local-path`, access mode `ReadWriteOnce`, `200Mi`.
4. Once the Pod is running, write the output of `df -h /cache /scratch` run inside the container to
   `/opt/course/b03/df.txt`, and write the name of the PVC that was created for the Pod followed by
   the kind and name of its owner to `/opt/course/b03/pvc.txt` in the form `<pvc> <Kind>/<name>`.
5. Delete the Pod and confirm that its PVC is removed as well.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_indexed_job_pod_failure_policy/question.md) · [q04 →](../q04_canary_deployment_promote/question.md)

# q03 — Persist data with a PersistentVolumeClaim

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Application Design and Build (20%) |
| Points | 6 |
| Host | `ssh ckad-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_f/q03_pvc_local_path_persistence
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 local-path provisioner 와 StorageClass `local-path` 가 있고, namespace `nile` 은 비어 있다(PVC·Pod 없음).
프로비저너 매니페스트를 받기 위해 `raw.githubusercontent.com` 으로 인터넷 연결이 필요하다.

## Task

The note-taking Pod in namespace `nile` loses its data whenever it is recreated. Give it storage
that outlives the Pod.

1. Create a PersistentVolumeClaim `notes-pvc` in namespace `nile` with `storageClassName: local-path`,
   access mode `ReadWriteOnce` and a storage request of `100Mi`.
2. Create a Pod `writer` in namespace `nile` (image `busybox:1.36`, command `sleep 3600`) that mounts
   the claim at `/data`. Save the Pod manifest to `/opt/course/f03/writer.yaml`.
3. Write the text `persisted-f03` to `/data/note.txt` inside the Pod. Then delete the Pod, create it
   again from `/opt/course/f03/writer.yaml`, and write the output of `cat /data/note.txt` from the
   new Pod to `/opt/course/f03/after-recreate.txt`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_pod_to_deployment/question.md) · [q04 →](../q04_canary_shared_service/question.md)

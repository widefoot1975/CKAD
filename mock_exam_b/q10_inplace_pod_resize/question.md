# q10 — Resize a running Pod in place

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q10_inplace_pod_resize
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `io` 는 비어 있고(Pod `trader` 없음) `/opt/course/b10/` 도 비어 있다. Pod 생성부터 직접 한다.
in-place resize 는 v1.35 에서 GA 이므로 `kubectl` 과 클러스터가 v1.35 이상이어야 한다(시험 환경은 v1.37).

## Task

A trading component must get more CPU during market hours without being restarted, while a
memory change may restart its container.

1. Create Pod `trader` in namespace `io` with one container `app`, image `nginx:1.27-alpine`,
   requests `cpu: 100m, memory: 64Mi` and limits `cpu: 200m, memory: 128Mi`. Configure the
   container so that a CPU change does not restart it and a memory change restarts it.
2. Without deleting or recreating the Pod, change the CPU to request `300m` and limit `500m`. Write
   the container's restart count afterwards to `/opt/course/b10/after-cpu.txt`.
3. Without deleting or recreating the Pod, change the memory to request `128Mi` and limit `256Mi`.
   Write the container's restart count afterwards to `/opt/course/b10/after-memory.txt`.
4. Write the resources that the kubelet reports as actually applied to the running container (from
   the Pod status, not the spec) to `/opt/course/b10/status-resources.json`.
5. The Pod's QoS class must be the same at the end as at the start.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_top_memory_oomkilled/question.md) · [q11 →](../q11_projected_sa_token_audience/question.md)

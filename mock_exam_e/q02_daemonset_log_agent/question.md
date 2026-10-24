# q02 — Run a log agent on every worker node

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_e/q02_daemonset_log_agent
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `sapphire` 는 비어 있고 DaemonSet 은 없다. `/opt/course/e02/` 디렉터리만 만들어져 있다.
클러스터에는 control-plane 노드(taint `node-role.kubernetes.io/control-plane:NoSchedule`)와 worker 노드가 하나 이상 있다고 가정한다.

## Task

Every worker node needs a small log agent that can read the node's `/var/log` directory.

1. In namespace `sapphire`, create a DaemonSet named `log-agent` with pod label `app=log-agent`.
   Its container `agent` uses image `busybox:1.36` and runs
   `sh -c 'while true; do ls /host/var/log | wc -l; sleep 30; done'`.
2. Mount the node's `/var/log` directory into the container at `/host/var/log`, read-only.
3. The agent must run on worker nodes only (do not add any toleration). Confirm that there is
   exactly one `log-agent` pod per worker node, and write the node names of the `log-agent` pods,
   one per line, to `/opt/course/e02/nodes.txt`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_job_completions_parallelism/question.md) · [q03 →](../q03_native_sidecar_log_tail/question.md)

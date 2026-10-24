# q02 — Run an agent on every node and a self-cleaning Job

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Design and Build (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q02_daemonset_toleration_job_ttl
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `pine` 에는 replicas 2 인 Deployment `node-agent` 가 있다(파드가 어느 노드에 몇 개 뜰지는 스케줄러 마음대로다). DaemonSet 과 Job `db-migrate` 는 아직 없다.
control-plane 노드에 `node-role.kubernetes.io/control-plane:NoSchedule` taint 가 있는 일반적인 kubeadm 클러스터를 가정한다(`kubectl describe nodes | grep Taints` 로 확인).

## Task

Deployment `node-agent` in namespace `pine` collects host metrics, so it must run exactly one Pod on
every node of the cluster, control-plane nodes included. A one-off database migration must also run
once and clean up after itself.

1. Replace Deployment `node-agent` with a DaemonSet `node-agent` in `pine` that keeps the same Pod
   labels, container name, image, command and env. Its Pods must also run on nodes tainted
   `node-role.kubernetes.io/control-plane:NoSchedule`. Delete the Deployment.
2. Write the cluster's node count and the DaemonSet's `desiredNumberScheduled` and `numberReady`
   to `/opt/course/c02/daemonset.txt` in the form `nodes=<n> desired=<n> ready=<n>`.
3. Create Job `db-migrate` in `pine` with image `busybox:1.36` running
   `sh -c 'echo migration start; sleep 5; echo migration done'`, with `backoffLimit: 2`. The Job and
   its Pods must be deleted automatically `120` seconds after the Job finishes.
4. Before the Job disappears, save its log to `/opt/course/c02/migrate.log` (it must contain
   `migration done`).

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

[↑ 문항 목록](../README.md) · [← q01](../q01_podman_oci_labels_configmap/question.md) · [q03 →](../q03_native_sidecar_log_adapter/question.md)

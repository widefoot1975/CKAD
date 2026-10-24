# q11 — ServiceAccount with least-privilege RBAC

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q11_serviceaccount_rbac_can_i
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `lambda` 에는 ServiceAccount `deployer`(`automountServiceAccountToken: false`)만 있고 Role·RoleBinding·Deployment 는 없다. Deployment 초안 `/opt/course/a11/deploy-bot.yaml` 이 있다(아직 적용되지 않음).

## Task

A CI bot in namespace `lambda` must be able to read and create Deployments there, but never
delete them. ServiceAccount `deployer` already exists and must not be modified.

1. Create Role `deployer-role` in namespace `lambda` that allows only the verbs `get`, `list`
   and `create` on `deployments` in the `apps` API group.
2. Bind it to ServiceAccount `deployer` with RoleBinding `deployer-binding`.
3. Using `kubectl auth can-i` while impersonating the ServiceAccount, check the following and
   write the answers (`yes`/`no`), one per line in this order, to `/opt/course/a11/can-i.txt`:
   create deployments in `lambda`; delete deployments in `lambda`; list deployments in
   `kube-system`; list pods in `lambda`.
4. Edit the draft `/opt/course/a11/deploy-bot.yaml` so that the Pods of Deployment `deploy-bot`
   run as ServiceAccount `deployer` and have the API token mounted, by setting
   `automountServiceAccountToken` explicitly in the Pod spec. Apply it.
5. The log of the `deploy-bot` Pod must show `list deployments: 200`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_projected_volume_configmap_secret/question.md) · [q12 →](../q12_quota_limitrange_guaranteed_qos/question.md)

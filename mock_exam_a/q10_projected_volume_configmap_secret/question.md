# q10 — Projected volume from a ConfigMap and a Secret

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q10_projected_volume_configmap_secret
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `kappa` 에는 ConfigMap `gateway-config`(키 `gateway.yaml`, `routes.yaml`, `unused.txt`)와 Secret `gateway-creds`(키 `api-key`, `username`, `password`)만 있다. 파드 `gateway` 는 없다.

## Task

Pod `gateway` in namespace `kappa` must read its configuration and one credential from a single
directory, and its database password from an environment variable.

1. Create Pod `gateway` in namespace `kappa` with image `busybox:1.36` and command
   `sleep 86400`.
2. Mount one **projected** volume named `bundle` read-only at `/etc/gateway` that contains
   exactly these files and nothing else:
   - `/etc/gateway/config/gateway.yaml` from key `gateway.yaml` of ConfigMap `gateway-config`
   - `/etc/gateway/config/routes.yaml` from key `routes.yaml` of ConfigMap `gateway-config`
   - `/etc/gateway/secrets/api-key` from key `api-key` of Secret `gateway-creds`, with file
     mode `0400`
3. Set the environment variable `DB_PASSWORD` from key `password` of Secret `gateway-creds`.
4. Change the value of key `routes.yaml` in ConfigMap `gateway-config` to
   `- /orders -> orders-v2:80`. Without restarting the Pod, wait until
   `/etc/gateway/config/routes.yaml` shows the new value, then write the file's content to
   `/opt/course/a10/routes-after.txt`.
5. Write two lines to `/opt/course/a10/answer.txt`, each `yes` or `no`: line 1, whether the
   file would also have been updated if `routes.yaml` had been mounted with `subPath`; line 2,
   whether `DB_PASSWORD` in the running container changes when the Secret is changed.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_migrate_removed_api_versions/question.md) · [q11 →](../q11_serviceaccount_rbac_can_i/question.md)

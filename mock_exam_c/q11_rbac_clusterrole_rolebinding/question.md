# q11 — Grant cross-namespace ConfigMap read with a RoleBinding

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q11_rbac_clusterrole_rolebinding
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `juniper` 에 ServiceAccount `config-sync` 와 이 SA 로 도는 Pod `sync-agent`(`curlimages/curl`)가 있고, `larch` 에 ConfigMap 2개와 Secret 1개가 있다. ClusterRole `c11-configmap-reader`(configmaps get/list/watch)도 있다.
아직 어떤 바인딩도 없으므로 `config-sync` 는 아무것도 읽을 수 없다.

## Task

ServiceAccount `config-sync` in namespace `juniper` must read the ConfigMaps of namespace `larch`, and
nothing else. The cluster already has ClusterRole `c11-configmap-reader`, which must be reused.

1. Grant the access by binding ClusterRole `c11-configmap-reader` to ServiceAccount
   `juniper:config-sync` with a RoleBinding named `config-sync-reader`. Do not create any new Role,
   ClusterRole or ClusterRoleBinding.
2. Using `kubectl auth can-i` while impersonating the ServiceAccount, write one line per check in
   the form `<check> <yes|no>` to `/opt/course/c11/can-i.txt`, in this order:
   `list-cm-larch`, `get-cm-larch`, `list-cm-juniper`, `list-cm-all-namespaces`,
   `get-secrets-larch`.
3. From inside Pod `sync-agent`, call the API server with the Pod's own ServiceAccount token to list
   ConfigMaps in `larch` and in `juniper`. Write the two HTTP status codes to
   `/opt/course/c11/api.txt` in the form `larch=<code> juniper=<code>`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_immutable_secret_rotation/question.md) · [q12 →](../q12_qos_classes_limitrange/question.md)

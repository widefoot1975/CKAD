# q13 — SecurityContext precedence and a read-only root filesystem

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

이 문제는 **기동하지 못하는 파드**에서 시작한다. `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q13_securitycontext_readonly_rootfs
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `poplar` 의 Pod `secure-web`(컨테이너 `web` = `nginxinc/nginx-unprivileged:1.27-alpine`, `helper` = `busybox:1.36`)은 `web` 이 `readOnlyRootFilesystem: true` 때문에 기동하지 못해 `CrashLoopBackOff` 이다. 매니페스트는 `/opt/course/c13/secure-web.yaml` 에 있다.
pod 수준 securityContext 는 `runAsUser: 1000`, `runAsGroup: 3000`, `runAsNonRoot: true` 이다.

## Task

Pod `secure-web` in namespace `poplar` must run hardened, but container `web` keeps crashing. Its
manifest is `/opt/course/c13/secure-web.yaml`.

1. Keep the Pod-level security context (`runAsUser: 1000`, `runAsGroup: 3000`,
   `runAsNonRoot: true`).
2. Container `web` must run as UID `2000`, overriding the Pod-level user for this container only,
   with `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false` and all capabilities
   dropped. Container `helper` must keep the Pod-level user.
3. Make `web` start while its root filesystem stays read-only, by giving it writable `emptyDir`
   volumes at exactly `/tmp` and `/var/cache/nginx` and nowhere else.
4. Write the output of `id` from `web` and then from `helper` (two lines) to
   `/opt/course/c13/ids.txt`. Write the error that `web` prints for `touch /etc/nginx/probe` to
   `/opt/course/c13/rofs.txt`. Save the `<title>` line of the page that `helper` gets from
   `http://localhost:8080/` to `/opt/course/c13/page.txt`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_qos_classes_limitrange/question.md) · [q14 →](../q14_operator_crd_discovery/question.md)

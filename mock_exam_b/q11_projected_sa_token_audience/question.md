# q11 — Projected ServiceAccount token with a custom audience

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q11_projected_sa_token_audience
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ganymede` 는 비어 있다(ServiceAccount `reporter` 와 Pod `reporter` 없음). `/opt/course/b11/` 도 비어 있다.
JWT 를 풀어 볼 때 노드의 `base64`, `cut`, `tr` (또는 `jq`)를 쓴다.

## Task

A reporting Pod must authenticate to an external secrets service that accepts only Kubernetes
tokens issued for the audience `vault.b11.example`. It must not receive a token for the Kubernetes
API.

1. Create ServiceAccount `reporter` in namespace `ganymede` that does not automatically mount API
   credentials into Pods.
2. Create Pod `reporter` in `ganymede` with image `busybox:1.36`, command `sleep 3600`, using
   ServiceAccount `reporter`. Mount a projected ServiceAccount token with audience
   `vault.b11.example` and a lifetime of `3600` seconds as file `token` in a read-only volume at
   `/var/run/secrets/vault`. Nothing may be mounted at
   `/var/run/secrets/kubernetes.io/serviceaccount`.
3. Write the output of `ls /var/run/secrets` run inside the Pod to `/opt/course/b11/secrets-ls.txt`,
   and the `aud` claim of the mounted token (the audience string only) to `/opt/course/b11/aud.txt`.
4. Create a token for ServiceAccount `reporter` that is valid for 15 minutes, without creating any
   Secret, and save only the token to `/opt/course/b11/token.txt`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_inplace_pod_resize/question.md) · [q12 →](../q12_validating_admission_policy/question.md)

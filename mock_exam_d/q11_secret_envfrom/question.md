# q11 — Inject a Secret with envFrom

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Application Environment, Configuration and Security (25%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_d/q11_secret_envfrom
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `pelican` 만 있고 Secret `pelican-db` 와 Pod `pelican-app` 은 없다. `/opt/course/d11/` 는 비어 있다.

## Task

The `pelican` application expects its database settings as environment variables.

1. Create a generic Secret named `pelican-db` in namespace `pelican` with the keys
   `DB_USER=pelican`, `DB_PASSWORD=p3lican-s3cret` and `DB_HOST=db.pelican.svc`.
2. Create a Pod named `pelican-app` in namespace `pelican` (image `busybox:1.36`, command
   `sleep 3600`) that receives all keys of the Secret as environment variables using `envFrom`.
3. Write the value of `DB_HOST` as seen inside the running container to
   `/opt/course/d11/db-host.txt`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_configmap_file_env/question.md) · [q12 →](../q12_serviceaccount_deployment/question.md)

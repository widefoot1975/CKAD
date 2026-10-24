# q14 — Work with a CRD that has a schema and a scale subresource

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_a/q14_crd_schema_scale_subresource
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 API 그룹 `a14.example.com` 의 CRD 하나(스키마 검증과 scale 서브리소스 포함)가 등록되어 있고, 빈 namespace `xi` 가 있다. 커스텀 리소스는 하나도 없다.

## Task

A CustomResourceDefinition in the API group `a14.example.com` has been installed in the
cluster. Work with it without reading its source manifest from disk.

1. Find the resource of this API group and write one line to `/opt/course/a14/resource.txt`
   in the format `<plural> <shortname> <kind> <namespaced>` (for example
   `widgets wd Widget true`).
2. Find the allowed values of the field `spec.backend` and the allowed range of
   `spec.replicas`. Write them to `/opt/course/a14/schema.txt` as two lines:
   `backend=<value1>,<value2>,...` and `replicas=<min>-<max>`.
3. Write `/opt/course/a14/invalid.yaml` with a resource named `broken` in namespace `xi` that
   uses `backend: kafka` and `replicas: 2`. Try to create it and write the error message to
   `/opt/course/a14/invalid-error.txt`. The object must not exist afterwards.
4. Write `/opt/course/a14/orders.yaml` with a valid resource named `orders` in namespace `xi`
   using `backend: redis` and `replicas: 2`, and create it.
5. Scale `orders` to `4` replicas with `kubectl scale`, so that its `spec.replicas` becomes `4`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_pod_security_restricted_fix/question.md) · [q15 →](../q15_multiport_service_no_endpoints/question.md)

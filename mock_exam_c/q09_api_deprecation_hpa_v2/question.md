# q09 — Find preferred API versions and migrate an HPA to v2

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Application Observability and Maintenance (15%) |
| Points | 5 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q09_api_deprecation_hpa_v2
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/c09/hpa-v2beta2.yaml` 에 옛 `autoscaling/v2beta2` 로 쓰인 HPA `web-hpa`(behavior 포함)가 있다. 클러스터에는 아무 리소스도 만들지 않는다.
이 문제는 파일과 서버 쪽 dry-run 만 쓰므로 실제로 만들어지는 객체가 없다(`metadata.namespace` 가 없어 dry-run 은 현재 컨텍스트의 namespace 로 검증된다).

## Task

A team kept an old HorizontalPodAutoscaler manifest, `/opt/course/c09/hpa-v2beta2.yaml`, and it no
longer applies. Find out which API versions this cluster serves and migrate the manifest.

1. For `HorizontalPodAutoscaler`, `CronJob`, `PodDisruptionBudget`, `Ingress` and `FlowSchema`,
   write the **preferred** API version served by this cluster to `/opt/course/c09/preferred.txt`,
   one line each in the form `<Kind> <group>/<version>`, in that order.
2. Write every served version of the `autoscaling` group (as listed by `kubectl api-versions`) to
   `/opt/course/c09/autoscaling-versions.txt`.
3. Run a server-side dry run of the old manifest and save the complete output, including the
   error, to `/opt/course/c09/old-error.txt`.
4. Write `/opt/course/c09/hpa-v2.yaml` using `autoscaling/v2`. Keep every metric and every
   `behavior` setting of the old manifest, and additionally make scale-down more conservative:
   add a second scale-down policy of type `Pods` that allows `1` Pod per `60` seconds and make
   scale-down use the policy that allows the **smallest** change.
5. Validate the new manifest with a server-side dry run (nothing may be created) and save the output
   to `/opt/course/c09/dry-run.txt`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_events_triage_broken_pods/question.md) · [q10 →](../q10_immutable_secret_rotation/question.md)

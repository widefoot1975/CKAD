# q07 — Graceful shutdown with preStop and the grace period

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q07_graceful_shutdown_prestop
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `aspen` 에 Deployment `checkout`(replicas 2, 컨테이너 `web`, `nginx:1.27-alpine`)과 Service `checkout`(80)이 있다. probe 와 lifecycle hook 은 없고 `terminationGracePeriodSeconds` 는 `15` 로 되어 있다.

## Task

Clients of Service `checkout` in namespace `aspen` see failed requests whenever Pods are replaced.
Make the shutdown of Deployment `checkout` graceful.

1. Add a readiness probe to container `web`: HTTP GET `/` on port `80`, every `2` seconds.
2. Add a `preStop` hook to container `web` that runs `sh -c "sleep 20"`, so the Pod keeps serving
   in-flight requests while it is removed from the Service.
3. Set the termination grace period so that the `preStop` hook always completes and nginx still
   gets `10` more seconds afterwards. Wait for the rollout.
4. Delete one `checkout` Pod and measure how long the deletion takes. Write
   `start=<epoch> end=<epoch> elapsed=<seconds>` to `/opt/course/c07/timing.txt`.
5. About `3` seconds after issuing that deletion, while the Pod is still terminating, save each
   endpoint of Service `checkout` as `<pod> ready=<bool> terminating=<bool>` from its
   EndpointSlice to `/opt/course/c07/endpoints.txt`.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_kustomize_secretgenerator_overlay/question.md) · [q08 →](../q08_events_triage_broken_pods/question.md)

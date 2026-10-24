# q15 — StatefulSet pod DNS through a headless Service

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services and Networking (20%) |
| Points | 7 |
| Host | `ssh ckad-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `ckad-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_b/q15_statefulset_headless_dns
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `triton` 에 StatefulSet `kvstore`(3개, `redis:7.4-alpine`)와 Service `kvstore`(6379)가 있다. 파드 3개는 `Running` 이지만 `kvstore-0.kvstore.triton.svc.cluster.local` 같은 파드별 이름은 풀리지 않는다.
`/opt/course/b15/` 는 비어 있다. 볼륨이 없는 StatefulSet 이라 파드를 다시 만들어도 잃을 데이터는 없다.

## Task

Clients of the key-value store in namespace `triton` must address each replica by a stable DNS
name. The StatefulSet `kvstore` and the Service `kvstore` exist, but the per-pod names do not
resolve.

1. Make every Pod of StatefulSet `kvstore` resolvable as
   `kvstore-<ordinal>.kvstore.triton.svc.cluster.local`.
2. Service `kvstore` must keep its name, its selector and port `6379`, and must not have a cluster
   IP. StatefulSet `kvstore` must keep its name, labels, image and 3 replicas.
3. In `/opt/course/b15/fixes.txt`, write one line per object you had to change, in the form
   `<kind>/<name> <field> <old value> -> <new value>`.
4. From a temporary Pod with image `busybox:1.36`, run `nslookup` for
   `kvstore-0.kvstore.triton.svc.cluster.local` and write the output to
   `/opt/course/b15/pod-dns.txt`. Then run `nslookup` for `kvstore.triton.svc.cluster.local` and
   write the output, which must list the addresses of all 3 Pods, to `/opt/course/b15/svc-dns.txt`.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_crd_finalizer_terminating/question.md) · [q16 →](../q16_ingress_named_port_pathtype/question.md)

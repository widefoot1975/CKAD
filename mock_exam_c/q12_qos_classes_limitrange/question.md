# q12 — QoS classes under a LimitRange

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
B=https://raw.githubusercontent.com/widefoot1975/CKAD/main/mock_exam_c/q12_qos_classes_limitrange
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `hazel` 에 resources 가 전혀 없는 Pod `be`, `bu`, `gu`(이미지 `registry.k8s.io/pause:3.10`, 컨테이너 `app`)가 `Running` 이고, 그 **뒤에** 만들어진 LimitRange `hazel-limits` 가 있다.
세 파드는 지금 모두 BestEffort 이다.

## Task

Namespace `hazel` runs three Pods, `be`, `bu` and `gu`, which were created without any resources.
A LimitRange `hazel-limits` was added to the namespace afterwards. The Pods must end up in the QoS
classes their names suggest: `be` BestEffort, `bu` Burstable, `gu` Guaranteed. Keep the Pod names,
the container name `app` and the image `registry.k8s.io/pause:3.10`.

1. `bu`: its container requests `100m` CPU and `64Mi` memory and sets no limits of its own.
2. `gu`: the owner first asks for `1` CPU and `128Mi` memory with requests equal to limits. Try
   exactly that and save the API server's rejection message to `/opt/course/c12/rejected.txt`.
   Then create `gu` with `128Mi` memory and the largest CPU value the namespace allows, still
   Guaranteed.
3. `be` must be BestEffort when you are done.
4. Using jsonpath, write `<pod> <qosClass>` for `be`, `bu` and `gu` (in that order) to
   `/opt/course/c12/qos.txt`, and the limits that the container of `bu` ended up with to
   `/opt/course/c12/bu-limits.txt`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_rbac_clusterrole_rolebinding/question.md) · [q13 →](../q13_securitycontext_readonly_rootfs/question.md)

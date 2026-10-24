# q12 — Grant a single Linux capability · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> A network troubleshooting Pod must be allowed to change network settings, but nothing else that
> needs extra privileges.
>
> 1. Edit `/opt/course/f12/netadmin.yaml` so that container `tool` drops all Linux capabilities, adds
>    only `NET_ADMIN`, and does not allow privilege escalation. Then create the Pod from that file.
> 2. Inside the running container, run `grep Cap /proc/1/status` and write its output to
>    `/opt/course/f12/caps.txt`.

**해석**

네트워크 점검용 Pod 는 네트워크 설정을 바꿀 수 있어야 하지만, 그 밖에 추가 권한이 필요한 일은 할 수 없어야 한다.

1. `/opt/course/f12/netadmin.yaml` 을 고쳐 컨테이너 `tool` 이 모든 Linux capability 를 버리고 `NET_ADMIN` 만
   추가하며, 권한 상승을 허용하지 않게 한다. 그 파일로 Pod 를 만든다.
2. 실행 중인 컨테이너 안에서 `grep Cap /proc/1/status` 를 실행해 출력을 `/opt/course/f12/caps.txt` 에 적는다.

## 모범 풀이

**1) 컨테이너 securityContext** — capability 는 **컨테이너** 레벨에만 있습니다(Pod 레벨 securityContext 에는 없음).

```yaml
# /opt/course/f12/netadmin.yaml
apiVersion: v1
kind: Pod
metadata:
  name: netadmin
  namespace: tigris
  labels:
    app: netadmin
spec:
  containers:
  - name: tool
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
        add: ["NET_ADMIN"]
```

```bash
kubectl apply -f /opt/course/f12/netadmin.yaml
kubectl -n tigris wait pod netadmin --for=condition=Ready
```

이름은 `CAP_` 접두어 없이 `NET_ADMIN` 으로 씁니다. 런타임은 `drop` 을 먼저 적용하고 `add` 를 더하므로
`drop: ALL` + `add: NET_ADMIN` 이면 남는 것은 `NET_ADMIN` 하나입니다. `allowPrivilegeEscalation: false` 는
프로세스에 `no_new_privs` 를 걸어 setuid 바이너리 등으로 권한이 늘지 못하게 합니다.

**2) 실제 capability 확인**

```bash
kubectl -n tigris exec netadmin -- grep Cap /proc/1/status > /opt/course/f12/caps.txt
cat /opt/course/f12/caps.txt
# CapInh: 0000000000000000
# CapPrm: 0000000000001000
# CapEff: 0000000000001000
# CapBnd: 0000000000001000
# CapAmb: 0000000000000000
```

`0x1000` 은 비트 12, 즉 `CAP_NET_ADMIN`(번호 12)입니다. 노드에 `capsh` 가 있으면 `capsh --decode=0000000000001000`
→ `0x0000000000001000=cap_net_admin` 로 풀어 볼 수 있습니다. 기본 컨테이너는 `CapEff` 가 `00000000a80425fb` 처럼
여러 비트가 켜져 있습니다.

## 검증

```bash
kubectl -n tigris get pod netadmin -o jsonpath='{.spec.containers[0].securityContext}{"\n"}'
# {"allowPrivilegeEscalation":false,"capabilities":{"add":["NET_ADMIN"],"drop":["ALL"]}}
grep CapEff /opt/course/f12/caps.txt                         # CapEff: 0000000000001000
kubectl -n tigris exec netadmin -- ip addr add 10.99.0.1/32 dev lo && echo NET_ADMIN-ok   # 성공
kubectl -n tigris exec netadmin -- chown 1000 /tmp
# chown: /tmp: Operation not permitted                       ← CHOWN 은 버렸다
kubectl -n tigris exec netadmin -- grep NoNewPrivs /proc/1/status   # NoNewPrivs: 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `containers[].securityContext.capabilities: {drop: ["ALL"], add: ["NET_ADMIN"]}` + `allowPrivilegeEscalation: false`, 확인은 `/proc/1/status` 의 `CapEff`.
- **헷갈리는 지점**: capability 는 Pod 레벨 securityContext 에 넣을 수 없습니다(`unknown field`). Pod Security Admission `baseline` 은 `NET_ADMIN` 추가를 금지하고, `restricted` 는 `drop: ALL` 과 `NET_BIND_SERVICE` 만 허용합니다.

## 참고 문서

- 검색어: `security context capabilities`, `pod security standards`
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container
- https://kubernetes.io/docs/concepts/security/pod-security-standards/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q13 →](../q13_resourcequota_blocks_replicas/question.md)

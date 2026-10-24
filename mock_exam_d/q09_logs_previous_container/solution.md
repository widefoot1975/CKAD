# q09 — Read the logs of a crashed container · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Pod `wren-worker` in namespace `wren` keeps restarting. Collect evidence for the developers. Do not
> delete or change the Pod.
>
> 1. From the container instance that terminated most recently (not the one that is currently
>    starting), write the log line that contains `ERROR` to `/opt/course/d09/error.txt`.
> 2. Write the exit code of that terminated instance to `/opt/course/d09/exit-code.txt`.

**해석**

`wren` 네임스페이스의 Pod `wren-worker` 가 계속 재시작한다. 개발자에게 넘길 증거를 모은다. 파드를
지우거나 바꾸지 않는다.

1. 가장 최근에 종료된 컨테이너 인스턴스(지금 시작 중인 것이 아님)의 로그에서 `ERROR` 가 들어 있는 줄을
   `/opt/course/d09/error.txt` 에 적는다.
2. 그 종료된 인스턴스의 종료 코드를 `/opt/course/d09/exit-code.txt` 에 적는다.

## 모범 풀이

**1) 직전 인스턴스의 로그 — `--previous`**

```bash
kubectl -n wren get pod wren-worker
# wren-worker   1/1   Running   3 (5s ago)   1m        ← 새 인스턴스가 막 떠 있는 순간
kubectl -n wren logs wren-worker
# wren-worker 2.3 starting
# reading queue settings                               ← 지금 인스턴스에는 아직 ERROR 가 없다
kubectl -n wren logs wren-worker --previous
# wren-worker 2.3 starting
# reading queue settings
# ERROR: queue redis-queue:6379 unreachable (connection refused)
kubectl -n wren logs wren-worker --previous | grep ERROR > /opt/course/d09/error.txt
```

이 파드는 시작 뒤 몇 초 동안 살아 있다가 에러를 찍고 죽습니다. 그래서 `--previous` 없이 치면 타이밍에 따라 **지금
떠 있는 인스턴스**의 로그(에러 전)만 보입니다. `--previous`(`-p`)는 언제 쳐도 마지막으로 죽은 인스턴스를
가리킵니다. 컨테이너가 여럿이면 `-c <이름>` 을 함께 줍니다.

**2) 종료 코드 — `lastState.terminated`**

```bash
kubectl -n wren get pod wren-worker \
  -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}' > /opt/course/d09/exit-code.txt
cat /opt/course/d09/exit-code.txt        # 3
kubectl -n wren describe pod wren-worker | grep -A4 'Last State'
#     Last State:     Terminated
#       Reason:       Error
#       Exit Code:    3
```

`state` 는 지금 인스턴스, `lastState` 는 직전에 죽은 인스턴스입니다. 0 이 아닌 코드는 앱이 스스로 `exit` 한 값이고
(이 앱은 3), 137 은 SIGKILL(대개 OOMKilled), 143 은 SIGTERM 입니다.

## 검증

```bash
cat /opt/course/d09/error.txt
# ERROR: queue redis-queue:6379 unreachable (connection refused)
cat /opt/course/d09/exit-code.txt          # 3
kubectl -n wren get pod wren-worker        # 그대로 존재, RESTARTS 계속 증가 (수정하지 않았음)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 죽은 인스턴스 로그는 `kubectl logs <pod> --previous`, 종료 코드는 `.status.containerStatuses[*].lastState.terminated.exitCode`.
- **헷갈리는 지점**: CrashLoopBackOff 로 **대기 중**일 때는 `--previous` 없이도 직전 로그가 보여서, 연습 때는 맞고 시험 때는 틀리는 일이 생깁니다. 파드를 지우면 이전 인스턴스 로그도 함께 사라지므로 증거를 먼저 모은 뒤 고칩니다.

## 참고 문서

- 검색어: `debug running pods`, `kubectl logs previous`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q10 →](../q10_configmap_file_env/question.md)

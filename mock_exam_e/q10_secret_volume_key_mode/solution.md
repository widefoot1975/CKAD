# q10 — Mount one Secret key as a read-only file · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> Namespace `pearl` contains Secret `db-creds` with the keys `username`, `password` and `host`.
> A client pod must see only the password, as a file that only its owner can read.
>
> 1. Create a pod named `db-client` in namespace `pearl` with image `busybox:1.36` and command
>    `sleep 3600`.
> 2. Mount Secret `db-creds` into the pod at `/etc/db` so that only key `password` appears, as the
>    file `/etc/db/pass.txt`, with file mode `0400`. The mount must be read-only.
> 3. Write the output of `ls -lL /etc/db` run inside the pod to `/opt/course/e10/files.txt`.

**해석**

`pearl` 네임스페이스에는 키 `username`, `password`, `host` 를 가진 Secret `db-creds` 가 있다. 클라이언트
파드는 비밀번호만, 그것도 소유자만 읽을 수 있는 파일로 봐야 한다.

1. `pearl` 네임스페이스에 이미지 `busybox:1.36`, 명령 `sleep 3600` 으로 파드 `db-client` 를 만든다.
2. Secret `db-creds` 를 파드의 `/etc/db` 에 마운트하되, 키 `password` 만 파일 `/etc/db/pass.txt` 로
   나타나게 하고 파일 모드는 `0400` 으로 한다. 마운트는 읽기 전용이어야 한다.
3. 파드 안에서 실행한 `ls -lL /etc/db` 의 출력을 `/opt/course/e10/files.txt` 에 쓴다.

## 모범 풀이

**1) 파드 뼈대**

```bash
export do="--dry-run=client -o yaml"
kubectl -n pearl run db-client --image=busybox:1.36 $do -- sleep 3600 > /tmp/e10.yaml
```

**2) `items` 로 키 하나만, `defaultMode` 로 권한을**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-client
  namespace: pearl
spec:
  containers:
  - name: db-client
    image: busybox:1.36
    args: ["sleep", "3600"]
    volumeMounts:
    - name: creds
      mountPath: /etc/db
      readOnly: true
  volumes:
  - name: creds
    secret:
      secretName: db-creds
      defaultMode: 0400          # YAML 에서는 8진수로 읽힌다 (JSON 이면 256)
      items:
      - key: password
        path: pass.txt
```

```bash
kubectl apply -f /tmp/e10.yaml
kubectl -n pearl wait --for=condition=Ready pod/db-client
```

`items` 를 쓰면 **나열한 키만** 파일로 생기고 나머지 키(`username`, `host`)는 나타나지 않습니다.
`path` 는 마운트 경로 아래의 상대 파일 이름입니다. 권한은 볼륨 전체에 `defaultMode` 로 주거나 항목별로
`items[].mode` 로 줍니다. `0400` 앞의 `0` 을 빼고 `400` 이라고 쓰면 10진수 400(=8진 0620)이 되어 전혀
다른 권한이 됩니다.

**3) 파일 목록 기록**

```bash
kubectl -n pearl exec db-client -- ls -lL /etc/db > /opt/course/e10/files.txt
cat /opt/course/e10/files.txt
# total 4
# -r--------    1 root     root            12 Oct 24 01:00 pass.txt
```

Secret 볼륨의 파일은 `..data/` 디렉터리를 가리키는 **심볼릭 링크**입니다. `-L` 없이 `ls -l` 하면
`lrwxrwxrwx ... pass.txt -> ..data/pass.txt` 처럼 링크 자체의 권한이 보여 0400 을 확인할 수 없습니다.
`-L` 은 링크를 따라가 실제 파일의 권한을 보여 줍니다.

## 검증

```bash
cat /opt/course/e10/files.txt                    # pass.txt 한 개, -r--------
kubectl -n pearl exec db-client -- ls /etc/db     # pass.txt   (username, host 없음)
kubectl -n pearl exec db-client -- cat /etc/db/pass.txt; echo     # s3cr3t-pearl
kubectl -n pearl get pod db-client -o jsonpath='{.spec.volumes[0].secret}{"\n"}{.spec.containers[0].volumeMounts[0].readOnly}{"\n"}'
# {"defaultMode":256,"items":[{"key":"password","path":"pass.txt"}],"secretName":"db-creds"}
# true
kubectl -n pearl exec db-client -- touch /etc/db/x     # Read-only file system 에러
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 키 하나만 = `secret.items[{key,path}]`, 권한 = `defaultMode: 0400`(YAML 8진). 확인은 `ls -lL`.
- **헷갈리는 지점**: API 에 저장된 값은 10진수라 `-o yaml`/`jsonpath` 로 보면 `256` 으로 나옵니다(0400 과 같은 값). Secret 볼륨은 원래 읽기 전용으로 마운트되지만 문제에서 요구하면 `readOnly: true` 를 명시합니다. `subPath` 로 마운트한 Secret 파일은 Secret 이 바뀌어도 갱신되지 않습니다.

## 참고 문서

- 검색어: `secrets as files from a pod`, `secret volume defaultMode`
- https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q11 →](../q11_limitrange_defaults/question.md)

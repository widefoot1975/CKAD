# q11 — Inject a Secret with envFrom · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The `pelican` application expects its database settings as environment variables.
>
> 1. Create a generic Secret named `pelican-db` in namespace `pelican` with the keys
>    `DB_USER=pelican`, `DB_PASSWORD=p3lican-s3cret` and `DB_HOST=db.pelican.svc`.
> 2. Create a Pod named `pelican-app` in namespace `pelican` (image `busybox:1.36`, command
>    `sleep 3600`) that receives all keys of the Secret as environment variables using `envFrom`.
> 3. Write the value of `DB_HOST` as seen inside the running container to
>    `/opt/course/d11/db-host.txt`.

**해석**

`pelican` 애플리케이션은 데이터베이스 설정을 환경 변수로 받기를 기대한다.

1. `pelican` 네임스페이스에 키 `DB_USER=pelican`, `DB_PASSWORD=p3lican-s3cret`, `DB_HOST=db.pelican.svc`
   를 가진 generic Secret `pelican-db` 를 만든다.
2. `pelican` 네임스페이스에 Pod `pelican-app`(이미지 `busybox:1.36`, 명령 `sleep 3600`)을 만들고, `envFrom`
   으로 Secret 의 모든 키를 환경 변수로 받게 한다.
3. 실행 중인 컨테이너 안에서 본 `DB_HOST` 값을 `/opt/course/d11/db-host.txt` 에 적는다.

## 모범 풀이

**1) Secret**

```bash
kubectl -n pelican create secret generic pelican-db \
  --from-literal=DB_USER=pelican \
  --from-literal=DB_PASSWORD=p3lican-s3cret \
  --from-literal=DB_HOST=db.pelican.svc
```

`create secret generic` 이 값을 base64 로 인코딩해 `data` 에 넣어 줍니다. YAML 로 직접 쓸 때 `data:` 에 평문을
넣으면 디코딩 에러가 나므로 평문은 `stringData:` 에 씁니다.

**2) 파드 — `envFrom.secretRef`**

```bash
export do="--dry-run=client -o yaml"
kubectl -n pelican run pelican-app --image=busybox:1.36 $do --command -- sleep 3600 > pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pelican-app
  namespace: pelican
spec:
  containers:
  - name: pelican-app
    image: busybox:1.36
    command: ["sleep", "3600"]
    envFrom:
    - secretRef:
        name: pelican-db
```

```bash
kubectl apply -f pod.yaml
```

`envFrom` 은 **목록**이라 `- secretRef:` 처럼 대시가 필요합니다. 키 하나만 넣을 때는 `env[].valueFrom.secretKeyRef`
를 쓰고, 모든 키를 한 번에 넣을 때는 `envFrom[].secretRef` 를 씁니다. 키 앞에 접두사를 붙이려면 `prefix:` 를 줍니다.

**3) 컨테이너 안에서 값 확인**

```bash
kubectl -n pelican exec pelican-app -- printenv DB_HOST > /opt/course/d11/db-host.txt
cat /opt/course/d11/db-host.txt        # db.pelican.svc
```

## 검증

```bash
kubectl -n pelican get secret pelican-db -o jsonpath='{.data.DB_PASSWORD}' | base64 -d; echo   # p3lican-s3cret
kubectl -n pelican get pod pelican-app -o jsonpath='{.spec.containers[0].envFrom}{"\n"}'
# [{"secretRef":{"name":"pelican-db"}}]
kubectl -n pelican exec pelican-app -- env | grep ^DB_
# DB_HOST=db.pelican.svc
# DB_PASSWORD=p3lican-s3cret
# DB_USER=pelican
cat /opt/course/d11/db-host.txt        # db.pelican.svc
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 모든 키 → `envFrom: [{secretRef: {name: ...}}]`, 키 하나 → `env[].valueFrom.secretKeyRef`.
- **헷갈리는 지점**: Secret 의 base64 는 인코딩일 뿐 암호화가 아닙니다(etcd 암호화는 별도 설정). 파드가 만들어질 때 Secret 이 없으면 파드는 `CreateContainerConfigError` 로 멈춥니다. Secret 값을 바꿔도 이미 뜬 컨테이너의 환경 변수는 바뀌지 않습니다.

## 참고 문서

- 검색어: `distribute credentials securely using secrets`, `envFrom`
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/
- https://kubernetes.io/docs/concepts/configuration/secret/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q12 →](../q12_serviceaccount_deployment/question.md)

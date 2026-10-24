# q01 — Build a labelled image and reuse its config in a Pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> The team ships a small nginx front page. Its build context is `/opt/course/c01/build/`. The image
> must carry OCI metadata, and the cluster must serve the same nginx configuration without using the
> custom image, which is not in any registry the cluster can pull from.
>
> 1. Edit the `Dockerfile` so the image has the labels `org.opencontainers.image.title=c01-web`,
>    `org.opencontainers.image.version=1.0.0` and `org.opencontainers.image.vendor=c01-team`. Do not
>    add a `HEALTHCHECK`. Build the image as `localhost/c01-web:1.0.0`.
> 2. Run a detached container named `c01-web` from that image, publishing host port `18080` to
>    container port `8080`. Save the response body of `curl -s http://localhost:18080/` to
>    `/opt/course/c01/curl.txt`.
> 3. Using `podman image inspect --format`, write only the value of the label
>    `org.opencontainers.image.version` to `/opt/course/c01/version.txt`, and all labels of the image
>    as JSON to `/opt/course/c01/labels.json`.
> 4. Stop and remove the container, then save the image as an **OCI archive** to
>    `/opt/course/c01/c01-web-oci.tar`.
> 5. In namespace `oak`, create ConfigMap `web-conf` from the file
>    `/opt/course/c01/build/default.conf` (key `default.conf`) and Pod `web` with image
>    `nginx:1.27-alpine` that mounts this ConfigMap so nginx in the Pod returns the same response on
>    port `8080` as the local container did.

**해석**

팀은 작은 nginx 첫 페이지를 배포한다. 빌드 컨텍스트는 `/opt/course/c01/build/` 이다. 이미지에는 OCI
메타데이터가 있어야 하고, 클러스터는 이 커스텀 이미지 없이 같은 nginx 설정을 서비스해야 한다(커스텀
이미지는 클러스터가 pull 할 수 있는 어느 레지스트리에도 없다).

1. `Dockerfile` 을 고쳐 이미지에 `org.opencontainers.image.title=c01-web`,
   `org.opencontainers.image.version=1.0.0`, `org.opencontainers.image.vendor=c01-team` 라벨이 붙게
   한다. `HEALTHCHECK` 는 넣지 않는다. 이미지를 `localhost/c01-web:1.0.0` 으로 빌드한다.
2. 그 이미지로 이름이 `c01-web` 인 컨테이너를 백그라운드로 실행하고, 호스트 포트 `18080` 을 컨테이너 포트
   `8080` 으로 공개한다. `curl -s http://localhost:18080/` 의 응답 본문을 `/opt/course/c01/curl.txt` 에
   저장한다.
3. `podman image inspect --format` 으로 라벨 `org.opencontainers.image.version` 의 값만
   `/opt/course/c01/version.txt` 에, 이미지의 모든 라벨을 JSON 으로 `/opt/course/c01/labels.json` 에 쓴다.
4. 컨테이너를 멈추고 지운 뒤, 이미지를 **OCI 아카이브**로 `/opt/course/c01/c01-web-oci.tar` 에 저장한다.
5. namespace `oak` 에 파일 `/opt/course/c01/build/default.conf` 로 ConfigMap `web-conf`(키 `default.conf`)
   를 만들고, 이미지 `nginx:1.27-alpine` 의 Pod `web` 이 이 ConfigMap 을 마운트해 로컬 컨테이너와 같은
   응답을 포트 `8080` 에서 돌려주게 한다.

## 모범 풀이

**1) LABEL 추가와 빌드**

```bash
cd /opt/course/c01/build
cat Dockerfile
# FROM docker.io/library/nginx:1.27-alpine
# COPY default.conf /etc/nginx/conf.d/default.conf
# EXPOSE 8080

cat >> Dockerfile <<'EOF'
LABEL org.opencontainers.image.title="c01-web" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="c01-team"
EOF

podman build -t localhost/c01-web:1.0.0 .          # docker build -t localhost/c01-web:1.0.0 .
podman images localhost/c01-web
```

`LABEL` 은 한 줄에 여러 개를 줄 수 있고, 값에 점·하이픈이 있으면 따옴표로 감쌉니다. `HEALTHCHECK` 를 넣지
말라는 조건에는 이유가 있습니다. podman 은 기본으로 **OCI 형식** 이미지를 만드는데, OCI 이미지 설정에는
`HEALTHCHECK` 필드가 없어 `HEALTHCHECK is not supported for OCI image format and will be ignored. Must use
docker format` 경고를 내고 버립니다(`--format docker` 로 빌드해야 남습니다). 어차피 쿠버네티스는 이미지의
HEALTHCHECK 를 쓰지 않고 probe 를 씁니다.

`FROM` 에 `docker.io/library/` 를 붙여 둔 것도 함정 회피입니다. podman 은 짧은 이름(`nginx:1.27-alpine`)을
`/etc/containers/registries.conf` 의 short-name 규칙으로 풀기 때문에, 설정에 따라 레지스트리를 묻거나
실패합니다.

**2) 실행과 curl**

```bash
podman run -d --name c01-web -p 18080:8080 localhost/c01-web:1.0.0
# docker run -d --name c01-web -p 18080:8080 localhost/c01-web:1.0.0
curl -s http://localhost:18080/ | tee /opt/course/c01/curl.txt
# c01 web ok
```

`-p 호스트:컨테이너` 순서입니다. `EXPOSE 8080` 은 문서 역할일 뿐 포트를 공개하지 않습니다(`-P` 를 쓸 때만
임의 포트로 공개).

**3) inspect --format 으로 라벨 추출**

```bash
podman image inspect --format '{{index .Labels "org.opencontainers.image.version"}}' \
  localhost/c01-web:1.0.0 > /opt/course/c01/version.txt
podman image inspect --format '{{json .Labels}}' localhost/c01-web:1.0.0 > /opt/course/c01/labels.json
# docker: --format '{{index .Config.Labels "org.opencontainers.image.version"}}' / '{{json .Config.Labels}}'
```

라벨 키에 점이 들어 있어 `{{.Labels.org.opencontainers...}}` 처럼 점 경로로는 꺼낼 수 없습니다. Go 템플릿의
`index` 함수로 키를 문자열로 넘겨야 합니다. `labels.json` 에는 베이스 이미지에서 물려받은 `maintainer`
라벨도 함께 들어 있는 것이 정상입니다.

**4) 정리와 OCI 아카이브**

```bash
podman stop c01-web && podman rm c01-web          # podman rm -f c01-web 도 가능
podman save --format oci-archive -o /opt/course/c01/c01-web-oci.tar localhost/c01-web:1.0.0
```

`podman save` 의 기본 형식은 `docker-archive` 입니다. "OCI 아카이브"라고 하면 `--format oci-archive` 를
반드시 붙입니다. docker 는 이 옵션이 없고 `docker save -o file.tar img` 만 됩니다(docker 25+ 의 save 결과에는
OCI 레이아웃 파일도 함께 들어 있습니다).

**5) 같은 설정을 ConfigMap 으로 클러스터에**

```bash
kubectl create ns oak --dry-run=client -o yaml | kubectl apply -f -    # setup 이 이미 만들었다
kubectl -n oak create configmap web-conf --from-file=/opt/course/c01/build/default.conf
kubectl -n oak run web --image=nginx:1.27-alpine --port=8080 --dry-run=client -o yaml > /tmp/web.yaml
```

`/tmp/web.yaml` 에 볼륨을 넣습니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  namespace: oak
  labels:
    run: web
spec:
  containers:
  - name: web
    image: nginx:1.27-alpine
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: conf
      mountPath: /etc/nginx/conf.d       # 디렉터리째 덮어써 기본 default.conf(80) 를 없앤다
  volumes:
  - name: conf
    configMap:
      name: web-conf
```

```bash
kubectl apply -f /tmp/web.yaml
kubectl -n oak wait --for=condition=Ready pod/web --timeout=60s
```

클러스터 노드는 로컬 podman 저장소의 `localhost/c01-web` 을 볼 수 없습니다(push 하지 않은 이미지라
`ErrImagePull`). 그래서 이미지에 구운 설정을 **ConfigMap 으로 분리**해 공개 베이스 이미지에 꽂습니다.
`mountPath: /etc/nginx/conf.d` 로 디렉터리 전체를 마운트하면 원래 있던 `default.conf`(80 포트)가 가려지고
ConfigMap 의 `default.conf` 하나만 남아, 이미지에서 `COPY` 로 덮어쓴 것과 같은 결과가 됩니다.
`subPath: default.conf` 로 파일 하나만 바꿔도 되지만 subPath 마운트는 ConfigMap 수정이 자동 반영되지 않습니다.

## 검증

```bash
cat /opt/course/c01/curl.txt                 # c01 web ok
cat /opt/course/c01/version.txt              # 1.0.0
cat /opt/course/c01/labels.json              # {"maintainer":"...","org.opencontainers.image.title":"c01-web",...}
podman ps -a --filter name=c01-web           # 아무것도 없음
tar -tf /opt/course/c01/c01-web-oci.tar | head
# blobs/
# blobs/sha256/...
# index.json
# oci-layout
grep -c HEALTHCHECK /opt/course/c01/build/Dockerfile   # 0
kubectl -n oak get cm web-conf -o jsonpath='{.data}' | head -c 80; echo   # {"default.conf":"server {...
kubectl -n oak exec web -- wget -qO- http://localhost:8080/   # c01 web ok
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `podman save` 기본은 docker-archive, OCI 는 `--format oci-archive`. 점이 든 라벨 키는 `{{index .Labels "키"}}`.
- **헷갈리는 지점**: podman 의 inspect 는 `.Labels`, docker 는 `.Config.Labels` 입니다. 로컬에서 빌드한 이미지는 클러스터 노드에 자동으로 생기지 않으므로, 설정을 이미지에 굽는 대신 ConfigMap 으로 꺼내는 것이 CKAD 의 "image vs config" 감각입니다. podman OCI 형식에서는 `HEALTHCHECK`·`SHELL` 같은 docker 전용 지시어가 무시됩니다.

## 참고 문서

- 검색어: `configure pod configmap`, `images`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/docs/concepts/containers/images/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q02 →](../q02_daemonset_toleration_job_ttl/question.md)

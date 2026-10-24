# q02 — Turn a standalone Pod into a Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

**원문**

> In namespace `amazon` the Pod `web` was started by hand. It has to be managed by a Deployment so
> that it is recreated on failure and can be scaled.
>
> 1. Create a Deployment named `web` in namespace `amazon` with `3` replicas. Its Pod template must
>    carry the same labels as Pod `web` and the same container definition (container name, image,
>    port, environment variables and resources). Use these labels as the Deployment's selector.
> 2. Save the Deployment manifest you applied to `/opt/course/f02/web-deploy.yaml`.
> 3. Delete the original Pod `web` and make sure 3 Pods of the Deployment are `Ready`.

**해석**

`amazon` 네임스페이스의 Pod `web` 은 손으로 띄운 것이다. 장애 시 다시 만들어지고 확장할 수 있도록
Deployment 가 관리하게 해야 한다.

1. `amazon` 네임스페이스에 replica `3` 개인 Deployment `web` 을 만든다. Pod 템플릿에는 Pod `web` 과 같은
   라벨과 같은 컨테이너 정의(컨테이너 이름, 이미지, 포트, 환경 변수, 리소스)가 있어야 한다. 이 라벨을
   Deployment 의 selector 로 쓴다.
2. 적용한 Deployment 매니페스트를 `/opt/course/f02/web-deploy.yaml` 로 저장한다.
3. 원래 Pod `web` 을 지우고 Deployment 의 Pod 3개가 `Ready` 인지 확인한다.

## 모범 풀이

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
```

**1) Pod 에서 필요한 부분을 뽑고, Deployment 뼈대를 만듭니다**

```bash
k -n amazon get pod web --show-labels
# web   1/1   Running   0   1m   app=web,tier=frontend
k -n amazon get pod web -o yaml > /tmp/web-pod.yaml          # 원본 보관 (spec.containers 를 옮길 것)

k -n amazon create deploy web --image=nginx:1.27-alpine --replicas=3 $do \
  > /opt/course/f02/web-deploy.yaml
```

`kubectl create deploy` 는 라벨을 `app: web` 하나만 만들고 컨테이너 이름도 이미지 이름(`nginx`)으로
정합니다. 여기서 라벨 두 개와 컨테이너 블록을 Pod 의 것으로 바꿉니다. Pod yaml 의 `spec.containers`
에서 `terminationMessagePath`·`imagePullPolicy` 같은 기본값 필드는 옮겨도 되고 빼도 됩니다.

**2) 매니페스트 완성 — selector, template 라벨, 컨테이너를 Pod 와 맞춥니다**

```yaml
# /opt/course/f02/web-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: amazon
  labels:
    app: web
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      tier: frontend
  template:
    metadata:
      labels:
        app: web
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - name: http
          containerPort: 80
        env:
        - name: GREETING
          value: hello-f02
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
          limits:
            memory: 64Mi
```

```bash
k apply -f /opt/course/f02/web-deploy.yaml
```

`selector.matchLabels` 는 template 라벨의 부분집합이어야 하고, 아니면 `selector does not match template labels`
로 거부됩니다. 또 Deployment 의 selector 는 만든 뒤 바꿀 수 없으니 처음에 정확히 적습니다.

**3) 원래 Pod 삭제**

```bash
k -n amazon delete pod web
k -n amazon rollout status deploy web
```

Deployment 를 먼저 만들어도 단독 Pod `web` 이 ReplicaSet 에 "입양"되지 않습니다. Deployment 가 만든
ReplicaSet 의 selector 에는 `pod-template-hash` 라벨이 추가되는데 단독 Pod 에는 이 라벨이 없기 때문입니다.
그래서 지우기 전에는 같은 라벨의 Pod 가 4개 보이고, 지운 뒤에 3개가 됩니다.

## 검증

```bash
k -n amazon get pod web
# Error from server (NotFound): pods "web" not found
k -n amazon get deploy web
# NAME   READY   UP-TO-DATE   AVAILABLE   AGE
# web    3/3     3            3           1m
k -n amazon get pods -l app=web,tier=frontend
# web-xxxxxxxxx-aaaaa   1/1   Running ...   (3개)
k -n amazon get deploy web -o jsonpath='{.spec.template.spec.containers[0].name} {.spec.template.spec.containers[0].env[0].value} {.spec.template.spec.containers[0].resources}{"\n"}'
# nginx hello-f02 {"limits":{"memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}}
grep -c 'kind: Deployment' /opt/course/f02/web-deploy.yaml    # 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Pod → Deployment 는 `create deploy $do` 로 뼈대를 만들고 `get pod -o yaml` 의 `spec.containers` 와 라벨을 template 에 옮긴다.
- **헷갈리는 지점**: `kubectl create deploy` 가 붙이는 라벨은 `app=<이름>` 하나뿐이라, selector·template 라벨을 둘 다 바꾸지 않으면 원래 라벨과 달라집니다. 단독 Pod 은 `pod-template-hash` 라벨이 없어 ReplicaSet 에 입양되지 않으므로 직접 지워야 합니다.

## 참고 문서

- 검색어: `deployments`, `replicaset`
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

---

[↑ 문항 목록](../README.md) · [← 문제로](question.md) · [다음 문제 q03 →](../q03_pvc_local_path_persistence/question.md)

# 3일차 (D-8) — 멀티 컨테이너 · 볼륨 · DaemonSet

[← 2일차](day02.md) · [계획 전체](README.md) · [4일차 →](day04.md)

## 오늘의 목표

- init 컨테이너, 네이티브 사이드카(`initContainers` + `restartPolicy: Always`)를 yaml 로 바로 쓸 수 있게 합니다.
- emptyDir·PVC 로 컨테이너끼리, 재시작 너머로 데이터를 나누는 방법을 정리합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [cheatsheet.md](../cheatsheet.md) §2 (워크로드 고르기, 네이티브 사이드카, 볼륨), 루트 README `2026년 기준으로 알아 둘 변화` |
| 0:15 – 0:40 | 아래 문제 4개 풀기 |
| 0:40 – 0:52 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:52 – 1:00 | `## Record` 에 기록하고 `python3 scripts/update_progress.py` 실행 |

## 풀 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| D03 | Design & Build | init 컨테이너로 웹 콘텐츠 준비 | 6 | 6분 | [Q](../mock_exam_d/q03_init_container_emptydir/question.md) · [S](../mock_exam_d/q03_init_container_emptydir/solution.md) ☐ |
| E03 | Design & Build | 네이티브 사이드카로 로그 tail | 6 | 6분 | [Q](../mock_exam_e/q03_native_sidecar_log_tail/question.md) · [S](../mock_exam_e/q03_native_sidecar_log_tail/solution.md) ☐ |
| F03 | Design & Build | PVC 로 데이터 영속화 | 6 | 6분 | [Q](../mock_exam_f/q03_pvc_local_path_persistence/question.md) · [S](../mock_exam_f/q03_pvc_local_path_persistence/solution.md) ☐ |
| E02 | Design & Build | 모든 워커에 로그 에이전트(DaemonSet) | 7 | 7분 | [Q](../mock_exam_e/q02_daemonset_log_agent/question.md) · [S](../mock_exam_e/q02_daemonset_log_agent/solution.md) ☐ |

합계 25점, 목표 25분.

## 꼭 잡을 것

```yaml
spec:
  initContainers:
  - name: log-tail                # 네이티브 사이드카: 앱보다 먼저 뜨고 끝까지 같이 산다
    image: busybox:1.36
    restartPolicy: Always
    command: ["sh", "-c", "tail -F /var/log/app/app.log"]
    volumeMounts: [{ name: logs, mountPath: /var/log/app }]
  containers:
  - name: app
    volumeMounts: [{ name: logs, mountPath: /var/log/app }]
  volumes:
  - name: logs
    emptyDir: {}
```

- 네이티브 사이드카는 v1.33 GA 입니다. `containers` 에 두 번째 컨테이너로 넣는 옛 방식은 종료 순서가 보장되지 않습니다.
- DaemonSet 은 명령형이 없습니다. `kubectl create deploy ... $do` 로 뽑고 `kind` 를 바꾼 뒤 `replicas`·`strategy` 를 지웁니다.
- 컨트롤 플레인에도 띄우라는 조건이 있으면 `tolerations` 가 필요합니다.

## 여유가 있으면

- 심화 [A03 init 컨테이너와 네이티브 사이드카가 볼륨 공유](../mock_exam_a/q03_init_native_sidecar_shared_volume/question.md)
- 심화 [B03 메모리 emptyDir 와 generic ephemeral 볼륨](../mock_exam_b/q03_ephemeral_volumes_memory_generic/question.md)

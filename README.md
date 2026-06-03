# Task03_Agent_Failure_Task_Release

## Overview | 프로젝트 개요

This project implements a baseline task reallocation strategy for a multi-UAV system under agent failure conditions using MATLAB simulation.

본 프로젝트는 MATLAB 기반 Multi-UAV 환경에서 Agent Failure 발생 시 Task Release 전략을 적용하여 Mission Continuity를 유지하는 구조를 구현하는 것을 목표로 한다.

When a UAV fails during mission execution, the unfinished task is released and becomes available for future allocation by the remaining UAVs.

UAV가 임무 수행 중 고장나면 해당 UAV가 수행 중이던 Task를 Release하여 남은 UAV들이 이후 재할당할 수 있도록 구현하였다.

---

## Objective | 목표

* Implement Multi-UAV Task Allocation
  다중 UAV 환경에서 Task Allocation 구현

* Simulate UAV movement and task execution
  UAV 이동 및 Task 수행 시뮬레이션

* Simulate Agent Failure events
  Agent Failure 시나리오 구현

* Release unfinished tasks after failure
  Failure 발생 시 미완료 Task Release

* Analyze mission continuity under failure conditions
  Failure 상황에서 Mission Continuity 분석

---

## Current Implementation | 현재 구현 내용

### 1. Multi-UAV Simulation

* 4 UAV agents operating simultaneously

* STL-based UAV rendering

* Independent UAV movement

* 4대의 UAV 동시 운용

* STL 기반 UAV 모델 렌더링

* UAV별 독립 이동 구현

---

### 2. Random Task Generation

* Random task generation in 3D space

* Task visualization using scatter3()

* 3D 공간 내 Random Task 생성

* scatter3() 기반 Task 시각화

---

### 3. Nearest Task Allocation

* Distance-based greedy task allocation

* Each UAV selects the nearest available task

* 거리 기반 Greedy Task Allocation

* UAV별 가장 가까운 Task 선택

Distance Metric:

[
d = ||p_{task} - p_{uav}||
]

---

### 4. UAV Motion Simulation

* Position-based UAV movement

* Direction vector normalization

* Continuous UAV mesh update

* 위치 기반 UAV 이동

* 방향 벡터 정규화

* UAV Mesh 실시간 업데이트

Motion Model:

[
p_{t+1}=p_t+v_t
]

---

### 5. Agent Failure Simulation

* Random UAV failure event

* Failure triggered at a predefined simulation step

* Failed UAV becomes inactive

* Random UAV Failure 발생

* 특정 Simulation Step에서 Failure 발생

* Failure UAV 비활성화

---

### 6. Task Release Strategy

When a UAV fails:

1. Current task is identified
2. Task assignment is removed
3. Task becomes unassigned
4. Remaining UAVs can select the task later

Failure 발생 시:

1. 수행 중인 Task 확인
2. Task Assignment 제거
3. Task를 미할당 상태로 복구
4. 남은 UAV가 향후 재할당 가능

---

## Failure Handling Strategy | Failure 처리 전략

### Baseline Method : Task Release

```text
Agent Failure
        ↓
Task Release
        ↓
Unassigned Task
        ↓
Future Reallocation
```

현재 버전은 Immediate Reallocation을 수행하지 않고, Failure 발생 시 Task를 Release하여 이후 Allocation 과정에서 재선택될 수 있도록 구현하였다.

---

## Limitations | 한계

* Immediate task reassignment is not implemented

* Communication constraints are not considered

* Workload balancing is not considered

* Distributed bidding mechanisms are not implemented

* CBBA is not implemented

* 즉각적인 Task Reallocation 미구현

* Communication Constraint 미반영

* Workload Balancing 미반영

* Distributed Bidding 미구현

* CBBA 미구현

---

## Future Work | 향후 계획

### Task04

Immediate Nearest Reallocation

Failure 발생 시 가장 가까운 UAV에게 즉시 Task 재할당

### Task05

CBBA Reallocation

CBBA 기반 Distributed Task Allocation 구현

### Task06

Communication Constraints

Communication Range 및 Local Information 기반 Allocation 구현

### Task07

Performance Evaluation

* Mission Completion Time
* Reallocation Latency
* Task Completion Rate
* Distance Traveled

성능 지표를 활용한 Reallocation 전략 비교 분석 수행

---

## Development Environment | 개발 환경

* MATLAB
* STL UAV Model
* patch()
* scatter3()
* Multi-UAV Simulation

---

## Project Status | 진행 현황

| Feature                  | Status   |
| ------------------------ | -------- |
| Multi-UAV Simulation     | Complete |
| Random Task Generation   | Complete |
| Nearest Task Allocation  | Complete |
| Agent Failure Simulation | Complete |
| Task Release Strategy    | Complete |
| Immediate Reallocation   | Planned  |
| CBBA Reallocation        | Planned  |
| Performance Evaluation   | Planned  |

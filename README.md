# Task04_Cost_Based_Task_Allocation

# Overview | 프로젝트 개요

## English

This project implements a Cost-Based Task Reallocation strategy for a Multi-UAV system operating under Agent Failure conditions.

Unlike the previous Task03 approach, unfinished tasks are immediately reassigned to surviving UAVs using a cost function that considers both distance and workload.

## 한국어

본 프로젝트는 Agent Failure가 발생한 Multi-UAV 환경에서 Cost-Based Task Reallocation을 수행하는 시스템을 구현한다.

기존 Task03에서는 고장 UAV의 Task를 단순 Release하였지만, Task04에서는 거리와 작업량을 고려한 Cost Function을 이용하여 즉시 재할당을 수행한다.

---

# Objective | 목표

## English

- Multi-UAV Task Allocation
- Queue-Based Task Execution
- Agent Failure Simulation
- Cost-Based Reallocation
- Mission Continuity Improvement

## 한국어

- Multi-UAV Task Allocation 구현
- Queue 기반 임무 수행 구현
- Agent Failure 시나리오 구현
- Cost-Based Reallocation 구현
- Mission Continuity 향상

---

# Current Implementation | 현재 구현 내용

## 1. Multi-UAV Simulation

### English

- 4 UAV agents
- STL-based rendering
- Independent movement

### 한국어

- 4대 UAV 운용
- STL 기반 시각화
- UAV별 독립 이동

---

## 2. Random Task Generation

### English

Random tasks are generated inside a predefined mission area.

### 한국어

사전에 정의된 임무 영역 내부에 Task를 무작위 생성한다.

```matlab
tx = -40 + 80 * rand;
ty = -40 + 80 * rand;
tz = 5;
```

---

## 3. Queue-Based Task Allocation

### English

Tasks are stored in UAV-specific queues.

### 한국어

Task를 UAV별 Queue에 저장하여 순차적으로 수행한다.

Example:

```text
UAV1 : [1 4 7]
UAV2 : [2 5]
UAV3 : [3 8 9]
UAV4 : [6]
```

---

## 4. FIFO Task Execution

### English

The first task in the queue is always executed first.

### 한국어

Queue의 맨 앞 Task부터 수행하는 FIFO 구조를 사용한다.

```matlab
currentTask = uavQueue{i}(1);
```

---

## 5. UAV Motion Simulation

### English

The UAV moves toward its target using a normalized direction vector.

### 한국어

정규화된 방향 벡터를 이용하여 UAV를 목표 지점으로 이동시킨다.

```matlab
direction = target - uavPos{i};
direction = direction / distance;
uavPos{i} = uavPos{i} + speed * direction;
```

---

## 6. Agent Failure Simulation

### English

A random UAV fails at a predefined simulation step.

### 한국어

특정 Simulation Step에서 임의의 UAV가 고장난다.

```matlab
failedUAV = randi([1,numUAV]);
```

---

## 7. Cost-Based Immediate Reallocation

### English

Remaining tasks are immediately reassigned after failure.

### 한국어

고장 UAV의 남은 Task를 즉시 재분배한다.

### Cost Function

Distance Cost:

```matlab
distanceCost = norm(tasks(failedTask,:) - uavPos{k});
```

Workload Cost:

```matlab
workloadCost = 20 * length(uavQueue{k});
```

Total Cost:

```matlab
cost = distanceCost + workloadCost;
```

### 한국어 설명

- Distance Cost : UAV와 Task 사이 거리
- Workload Cost : UAV Queue 길이
- Total Cost : 거리 + 작업량

---

## 8. Reallocation Flow

```text
Agent Failure
      ↓
Extract Remaining Tasks
      ↓
Compute Cost
      ↓
Select Best UAV
      ↓
Append Task To Queue
```

### 한국어

```text
고장 발생
   ↓
잔여 Task 추출
   ↓
Cost 계산
   ↓
최적 UAV 선택
   ↓
Queue 추가
```

---

# Limitations | 한계

## English

- Perfect communication assumed
- No battery constraints
- No task priority
- Centralized allocation

## 한국어

- 통신 제약 미반영
- 배터리 모델 미반영
- Task Priority 미반영
- 중앙집중형 할당 방식

---

# Future Work | 향후 계획

## Task05

CBBA-Based Distributed Task Allocation

CBBA 기반 분산 Task Allocation 구현

## Task06

Communication-Constrained Allocation

통신 범위를 고려한 재할당 구현

## Task07

Performance Evaluation

- Mission Completion Time
- Task Completion Rate
- Distance Traveled
- Reallocation Latency

---

# Development Environment | 개발 환경

- MATLAB
- STL UAV Model
- patch()
- scatter3()
- Cell Array Queue

---

# Project Status | 진행 현황

| Feature | Status |
|----------|----------|
| Multi-UAV Simulation | Complete |
| Queue-Based Allocation | Complete |
| Agent Failure Simulation | Complete |
| Cost-Based Reallocation | Complete |
| Queue Visualization | Complete |
| CBBA Allocation | Planned |
| Communication Constraints | Planned |
| Performance Evaluation | Planned |

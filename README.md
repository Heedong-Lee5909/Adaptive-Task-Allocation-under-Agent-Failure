# Task05_CBBA_Based_Task_Allocation

# Overview | 프로젝트 개요

## English

This project implements a CBBA-inspired Task Allocation framework for a Multi-UAV system operating in dynamic environments.

Unlike Task04, which focused on Cost-Based Reallocation after agent failure, Task05 introduces distributed task allocation concepts through Bid generation, Bundle construction, Conflict Resolution, Consensus, and Adaptive Reallocation.

## 한국어

본 프로젝트는 Multi-UAV 환경에서 CBBA(Consensus-Based Bundle Algorithm) 개념을 기반으로 한 Task Allocation 시스템을 구현한다.

기존 Task04에서는 Agent Failure 이후 Cost-Based Reallocation에 초점을 맞추었지만, Task05에서는 Bid 생성, Bundle 구성, Conflict Resolution, Consensus, Adaptive Reallocation 과정을 포함하는 CBBA 기반 임무 할당 구조를 구현하였다.

---

# Objective | 목표

## English

* Multi-UAV Task Allocation
* CBBA-Inspired Bundle Allocation
* Consensus-Based Conflict Resolution
* Agent Failure Simulation
* Auction-Based Adaptive Reallocation
* Mission Continuity Improvement

## 한국어

* Multi-UAV Task Allocation 구현
* CBBA 기반 Bundle Allocation 구현
* Consensus 기반 Conflict Resolution 구현
* Agent Failure 시나리오 구현
* Auction 기반 Adaptive Reallocation 구현
* Mission Continuity 향상

---

# Current Implementation | 현재 구현 내용

## 1. Multi-UAV Simulation

### English

* 4 UAV agents
* STL-based rendering
* Independent movement

### 한국어

* 4대 UAV 운용
* STL 기반 시각화
* UAV별 독립 이동

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

## 3. Bid Matrix Generation

### English

Each UAV calculates a bid value for every task based on travel distance.

Higher bid values indicate more desirable tasks.

### 한국어

각 UAV는 모든 Task에 대해 Bid 값을 계산한다.

현재 Bid는 UAV와 Task 간의 거리를 기반으로 계산된다.

```matlab
distance = norm(tasks(j,:) - uavPos{i});
bidMatrix(i,j) = reward - distance;
```

---

## 4. Bundle Construction

### English

Each UAV selects the highest-valued tasks and stores them in a local bundle.

### 한국어

각 UAV는 높은 Bid를 가지는 Task를 선택하여 Bundle을 생성한다.

Example:

```text
UAV1 : [5 9 19 15 11]
UAV2 : [7 2 15 8 1]
UAV3 : [17 20 10 16 13]
UAV4 : [3 14 6 18 1]
```

---

## 5. Conflict Detection

### English

Multiple UAVs may select the same task.

Conflict tasks are detected before consensus.

### 한국어

여러 UAV가 동일 Task를 선택하는 경우 Conflict가 발생한다.

Consensus 이전에 Conflict Task를 탐지한다.

Example:

```text
Task 1 claimed by UAV 2 4
Task 15 claimed by UAV 1 2
```

---

## 6. Consensus-Based Conflict Resolution

### English

The UAV with the highest bid wins ownership of the task.

The losing UAV removes the task from its bundle.

### 한국어

가장 높은 Bid를 가진 UAV가 해당 Task를 획득한다.

패배한 UAV는 자신의 Bundle에서 해당 Task를 제거한다.

Example:

```text
Task 15 claimed by UAV 1 2
→ Winner UAV 1
```

---

## 7. Missing Task Recovery

### English

Tasks that are not assigned after consensus are automatically detected and reassigned.

### 한국어

Consensus 이후 할당되지 않은 Task를 탐지하고 자동으로 재할당한다.

Example:

```text
Assigned Tasks
Missing Tasks
```

---

## 8. Queue-Based Task Execution

### English

Tasks are executed sequentially using UAV-specific queues.

### 한국어

각 UAV는 Queue에 저장된 Task를 순차적으로 수행한다.

```matlab
currentTask = uavQueue{i}(1);
```

---

## 9. Agent Failure Simulation

### English

A UAV failure is injected during mission execution.

Remaining tasks are released and become available for reassignment.

### 한국어

Mission 수행 중 UAV Failure를 발생시킨다.

고장 UAV의 잔여 Task는 Release되어 재할당 대상이 된다.

```matlab
failedUAV = randi([1,numUAV]);
```

---

## 10. Auction-Based Adaptive Reallocation

### English

Released tasks are redistributed using a ReBid mechanism.

The reassignment considers the original task bid and the current workload of each UAV.

### 한국어

Release된 Task는 ReBid 기반 경매 방식으로 재할당된다.

재할당 시 원래 Bid 값과 현재 UAV 작업량을 함께 고려한다.

### ReBid Function

```matlab
baseBid = bidMatrix(k,failedTask);

workloadPenalty = 5 * length(uavQueue{k});

reBid = baseBid - workloadPenalty;
```

### 한국어 설명

* Base Bid : 초기 CBBA Bid
* Workload Penalty : 현재 Queue 길이
* ReBid : 재할당 Bid

---

## 11. Reallocation Flow

```text
Agent Failure
      ↓
Release Remaining Tasks
      ↓
Compute ReBid
      ↓
Auction
      ↓
Assign Winner UAV
      ↓
Append Task To Queue
```

### 한국어

```text
고장 발생
      ↓
잔여 Task Release
      ↓
ReBid 계산
      ↓
경매 수행
      ↓
최적 UAV 선정
      ↓
Queue 추가
```

---

# Limitations | 한계

## English

* Simplified CBBA implementation
* Perfect communication assumed
* No battery constraints
* No task priority
* No dynamic bundle rebuilding after failure

## 한국어

* CBBA 단순화 버전 구현
* 통신 제약 미반영
* 배터리 모델 미반영
* Task Priority 미반영
* Failure 이후 Bundle 재구성 미구현

---

# Development Environment | 개발 환경

* MATLAB
* STL UAV Model
* patch()
* scatter3()
* Cell Array Queue

---

# Project Status | 진행 현황

| Feature                    | Status   |
| -------------------------- | -------- |
| Bid Matrix Generation      | Complete |
| Bundle Construction        | Complete |
| Conflict Detection         | Complete |
| Consensus Resolution       | Complete |
| Missing Task Recovery      | Complete |
| Agent Failure Simulation   | Complete |
| Auction-Based Reallocation | Complete |
| CBBA-Inspired Allocation   | Complete |

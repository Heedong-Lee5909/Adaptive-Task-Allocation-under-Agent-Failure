# Adaptive Task Reallocation under Agent Failure

## Overview | 프로젝트 개요

This project focuses on decentralized task allocation for multi-UAV systems under agent failure conditions using MATLAB simulation.

본 프로젝트는 MATLAB 기반 시뮬레이션 환경에서 agent failure 상황에서도 동작 가능한 decentralized multi-UAV task allocation 구조를 구현하는 것을 목표로 한다.

---

## Objective | 목표

### English

* Implement task allocation in multi-agent UAV systems
* Simulate UAV movement and task execution
* Handle agent/task reassignment under failure conditions
* Study resilience and robustness of decentralized coordination

### 한국어

* 다중 UAV 환경에서 task allocation 구현
* UAV 이동 및 task 수행 시뮬레이션
* failure 상황에서 task reassignment 수행
* decentralized coordination의 robustness 분석

---

## Current Implementation | 현재 구현 내용

### 1. 3D UAV Visualization

#### English

* STL-based UAV rendering
* UAV scaling and positioning
* 3D visualization using MATLAB `patch()`

#### 한국어

* STL 기반 UAV 모델 렌더링
* UAV 크기 조정 및 위치 설정
* MATLAB `patch()` 기반 3D 시각화

---

### 2. Random Task Generation

#### English

* Random task node generation
* Task visualization using `scatter3()`

#### 한국어

* Random task 생성
* `scatter3()` 기반 task 시각화

---

### 3. Nearest Task Allocation

#### English

* Greedy nearest-task selection
* Distance-based task assignment

#### 한국어

* nearest-task 기반 greedy allocation
* 거리 기반 task 선택

Distance Metric:

[
d_i = | p_{task,i} - p_{uav} |
]

---

### 4. UAV Motion Simulation

#### English

* Position-based UAV movement
* Direction vector normalization
* Continuous mesh update

#### 한국어

* 위치 기반 UAV 이동
* 방향 벡터 정규화
* UAV mesh 실시간 업데이트

Motion Model:

[
p_{t+1}=p_t+v_t\Delta t
]

---

### 5. Multi-UAV Task Allocation

#### English

* Multi-UAV task execution
* Independent task assignment
* Task completion monitoring
* Task status visualization

#### 한국어

* 다중 UAV 기반 task 수행
* UAV별 독립 task 할당
* Task 완료 여부 관리
* Task 상태 시각화

---

### 6. Agent Failure Simulation

#### English

* Agent failure event generation
* UAV status management
* Failure scenario verification

#### 한국어

* Agent failure 이벤트 생성
* UAV 상태 관리
* Failure 시나리오 검증

---

## Planned Features | 향후 구현 예정

### English

* Adaptive task reassignment after agent failure
* Decentralized task reallocation
* Communication constraints
* Multi-UAV coordination
* Consensus-Based Bundle Algorithm (CBBA)
* Performance evaluation metrics

### 한국어

* Agent failure 이후 adaptive task reassignment
* Decentralized task reallocation
* Communication constraint 적용
* Multi-UAV coordination
* CBBA 기반 task allocation
* 성능 평가 metric 분석

---

## Development Environment | 개발 환경

* MATLAB
* STL UAV Model
* 3D Visualization (`patch`)
* Task Visualization (`scatter3`)

---

## Project Status | 진행 현황

| Feature                   | Status      |
| ------------------------- | ----------- |
| 3D UAV Visualization      | Complete    |
| Random Task Generation    | Complete    |
| Nearest Task Allocation   | Complete    |
| Multi-UAV Simulation      | Complete    |
| Agent Failure Simulation  | Complete    |
| Task Reallocation         | In Progress |
| Communication Constraints | Planned     |
| CBBA                      | Planned     |
| Performance Evaluation    | Planned     |

---

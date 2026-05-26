# Adaptive Task Reallocation under Agent Failure

## Overview | 프로젝트 개요

This project focuses on decentralized task allocation for multi-UAV systems under agent failure conditions using MATLAB simulation.

본 프로젝트는 MATLAB 기반 시뮬레이션 환경에서 agent failure 상황에서도 동작 가능한 decentralized multi-UAV task allocation 구조를 구현하는 것을 목표로 한다.

---

## Objective | 목표

- Implement task allocation in multi-agent UAV systems
- Simulate UAV movement and task execution
- Handle agent/task reassignment under failure conditions
- Study resilience and robustness of decentralized coordination

- 다중 UAV 환경에서 task allocation 구현
- UAV 이동 및 task 수행 시뮬레이션
- failure 상황에서 task reassignment 수행
- decentralized coordination의 robustness 분석

---

## Current Implementation | 현재 구현 내용

### 1. 3D UAV Visualization
- STL-based UAV rendering
- UAV scaling and positioning
- 3D visualization using MATLAB patch()

- STL 기반 UAV 모델 렌더링
- UAV 크기 조정 및 위치 설정
- MATLAB patch() 기반 3D 시각화

---

### 2. Random Task Generation
- Random task node generation
- Task visualization using scatter3()

- random task 생성
- scatter3() 기반 task 시각화

---

### 3. Nearest Task Allocation
- Greedy nearest-task selection
- Distance-based task assignment

- nearest-task 기반 greedy allocation
- 거리 기반 task 선택

Distance metric:

```math
d_i = \|p_{task,i} - p_{uav}\|
```

---

### 4. UAV Motion Simulation
- Position-based UAV movement
- Direction vector normalization
- Continuous mesh update

- 위치 기반 UAV 이동
- 방향 벡터 정규화
- UAV mesh 실시간 업데이트

Motion model:

```math
p_{t+1} = p_t + v_t \Delta t
```

---

## Planned Features | 향후 구현 예정

- Multi-UAV coordination
- Agent failure simulation
- Decentralized task reassignment
- Communication constraints
- Performance evaluation metrics

- 다중 UAV coordination
- agent failure simulation
- decentralized task reassignment
- communication constraint
- 성능 평가 metric 분석

---


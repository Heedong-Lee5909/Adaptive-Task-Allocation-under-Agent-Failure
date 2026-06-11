# Task04_Cost_Based_Task_Allocation

## Overview | 프로젝트 개요

This project implements a Cost-Based Task Reallocation strategy for a Multi-UAV system operating under Agent Failure conditions.

본 프로젝트는 MATLAB 기반 Multi-UAV 환경에서 Agent Failure 발생 시 Cost-Based Task Reallocation을 수행하여 Mission Continuity를 유지하는 구조를 구현하는 것을 목표로 한다.

Unlike the previous Task03 approach, which simply released unfinished tasks after a failure, this version immediately reallocates the failed UAV's remaining tasks to surviving UAVs using a cost function that considers both distance and workload.

기존 Task03에서는 고장 UAV의 미완료 Task를 단순 Release하였지만, Task04에서는 거리 비용(Distance Cost)과 작업량 비용(Workload Cost)을 고려하여 즉시 재할당을 수행한다.

---

# Objective | 목표

- Implement Multi-UAV Task Allocation
- Implement Queue-Based Mission Execution
- Simulate UAV Motion
- Simulate Agent Failure Events
- Implement Cost-Based Immediate Reallocation
- Improve Mission Continuity
- Reduce Task Loss After Failure

---

# System Architecture

```text
Random Task Generation
          ↓
 Initial Task Allocation
          ↓
     UAV Queue
          ↓
     Task Execution
          ↓
     Agent Failure
          ↓
 Cost-Based Reallocation
          ↓
 Mission Continuation
```

---

# Current Implementation | 현재 구현 내용

## 1. Multi-UAV Simulation

Features:

- 4 UAV agents
- Independent UAV motion
- STL-based visualization
- Real-time simulation

Implementation:

- patch()
- scatter3()
- drawnow()

---

## 2. Random Task Generation

Task positions are randomly generated inside the mission area.

```matlab
tx = -40 + 80 * rand;
ty = -40 + 80 * rand;
tz = 5;
```

Task locations are visualized using scatter3().

---

## 3. Queue-Based Task Allocation

Unlike the previous version where a UAV only possessed one task at a time, Task04 introduces a queue structure.

```matlab
uavQueue = cell(numUAV,1);
```

Example:

```text
UAV1 : [1 4 7]
UAV2 : [2 5]
UAV3 : [3 8 9]
UAV4 : [6]
```

The UAV always executes the first task in its queue.

---

## 4. FIFO Task Execution

Tasks are executed in FIFO order.

```text
Queue
 ↓
[3 7 11]
 ↓
Task 3 Complete
 ↓
[7 11]
 ↓
Task 7 Complete
 ↓
[11]
```

MATLAB:

```matlab
currentTask = uavQueue{i}(1);
```

---

## 5. UAV Motion Simulation

The UAV continuously moves toward its assigned target.

Motion Model:

p(t+1) = p(t) + v(t)

Implementation:

```matlab
direction = target - uavPos{i};
direction = direction / distance;

uavPos{i} = uavPos{i} + speed * direction;
```

---

## 6. Agent Failure Simulation

A random UAV is selected before simulation begins.

```matlab
failedUAV = randi([1,numUAV]);
```

Failure occurs at:

```matlab
if simStep == 100
```

Effects:

- UAV becomes inactive
- Remaining tasks remain unfinished
- Queue is extracted
- Tasks are reassigned

---

## 7. Cost-Based Immediate Reallocation

When a UAV fails:

```text
Agent Failure
      ↓
Extract Remaining Tasks
      ↓
Evaluate Cost
      ↓
Select Best UAV
      ↓
Append Task To Queue
```

---

## Cost Function

The allocation decision uses:

Cost = DistanceCost + WorkloadCost

### Distance Cost

Distance from UAV to task.

```matlab
distanceCost = norm(tasks(failedTask,:) - uavPos{k});
```

Mathematically:

Cd = || ptask - puav ||

---

### Workload Cost

Penalty proportional to queue size.

```matlab
workloadCost = 20 * length(uavQueue{k});
```

Meaning:

```text
Queue Length = 0 → Cost = 0
Queue Length = 1 → Cost = 20
Queue Length = 2 → Cost = 40
Queue Length = 3 → Cost = 60
```

This prevents one UAV from receiving all reassigned tasks.

---

### Total Cost

```matlab
cost = distanceCost + workloadCost;
```

The UAV with minimum cost wins the task.

---

## 8. Queue Reallocation Example

Before Failure:

```text
UAV1 : [3 5]
UAV2 : [7]
UAV3 : [9 10 12]
UAV4 : [4 8]
```

Suppose UAV4 fails.

Remaining tasks:

```text
[4 8]
```

Cost is evaluated for all surviving UAVs.

Result:

```text
UAV1 : [3 5 4]
UAV2 : [7]
UAV3 : [9 10 12 8]
```

Mission continues without losing tasks.

---

## 9. Task Visualization

Task State:

Blue:
- Uncompleted

Green:
- Completed

Implementation:

```matlab
taskPlot.CData = colors;
```

---

# Failure Handling Strategy

## Task03

```text
Failure
   ↓
Task Release
   ↓
Future Allocation
```

## Task04

```text
Failure
   ↓
Cost Evaluation
   ↓
Immediate Reallocation
   ↓
Mission Continuation
```

Task04 reduces mission interruption and improves task completion probability.

---

# Limitations | 한계

Current implementation still assumes:

- Perfect communication
- No communication range limitation
- No packet loss
- No battery constraints
- No task priority
- Centralized decision making
- No bidding mechanism

---

# Future Work

## Task05

CBBA-Based Distributed Task Allocation

Features:

- Local bidding
- Consensus process
- Distributed decision making

---

## Task06

Communication-Constrained Reallocation

Features:

- Communication range
- Neighbor discovery
- Local information sharing

---

## Task07

Performance Evaluation

Metrics:

- Mission Completion Time
- Reallocation Latency
- Distance Traveled
- Task Completion Rate
- Workload Balance Index

---

# Development Environment

- MATLAB
- STL UAV Model
- patch()
- scatter3()
- Cell Array Queue Structure

---

# Project Status

| Feature | Status |
|----------|----------|
| Multi-UAV Simulation | Complete |
| Random Task Generation | Complete |
| Queue-Based Allocation | Complete |
| FIFO Task Execution | Complete |
| Agent Failure Simulation | Complete |
| Cost-Based Reallocation | Complete |
| Queue Visualization | Complete |
| CBBA Allocation | Planned |
| Communication Constraints | Planned |
| Performance Evaluation | Planned |

---

# Version History

## Task03

Nearest Task Allocation + Task Release

## Task04

Queue-Based Cost Reallocation

## Task05 (Planned)

CBBA Distributed Allocation

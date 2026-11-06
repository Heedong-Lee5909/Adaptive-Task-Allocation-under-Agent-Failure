# Adaptive Task Allocation under Agent Failure

A MATLAB simulation of a four-UAV team that allocates tasks with the Consensus-Based Bundle Algorithm (CBBA) and reallocates unfinished tasks through an auction when a UAV fails.

<!-- Add demo GIF here: ![Failure and reallocation demo](docs/demo.gif) -->

## Problem

A multi-UAV mission has to answer two questions:

1. How can UAVs agree on who does which task when each one only communicates with its neighbors?
2. When a UAV fails mid-mission, how can its unfinished tasks be handed to the remaining UAVs?

This project simulates both stages in a single mission.

## How It Works

```text
Generate 20 random tasks
        |
        v
Run CBBA until the UAVs agree
  1. Bundle construction
  2. Consensus with neighbors
  3. Release of lost tasks
        |
        v
Execute task paths
        |
        v
UAV fails at step 100
        |
        v
Release its unfinished tasks
        |
        v
Auction each task among surviving UAVs
        |
        v
Continue until all tasks are complete
```

### Initial allocation: CBBA

Each UAV keeps its own local view of the auction:

| Variable | Meaning |
|---|---|
| `y(i,j)` | Highest bid for task `j` known to UAV `i` |
| `z(i,j)` | Winner of task `j` according to UAV `i` (`0` means none) |
| `s(i,m)` | Time of the latest information UAV `i` has from UAV `m` |

**Bundle construction.** Each UAV repeatedly adds the task with the highest marginal score, trying every insertion position in its current path. It can only bid on a task if its score beats the highest bid it knows. A path is scored with a distance-discounted reward:

$$
S(p) = \sum_{j \in p} R \, \lambda^{d_j}
$$

where $R$ is the task reward, $\lambda$ is the discount per meter, and $d_j$ is the distance traveled along the path to reach task $j$.

**Consensus.** UAVs exchange `y`, `z`, and `s` only with neighbors in the communication graph, which is a ring (`1-2-3-4-1`). Conflicts are resolved with the update, reset, and leave rules of Choi et al. (2009).

**Task release.** If a UAV is outbid on a task, it releases that task and every task it added afterward, because those bids depended on the lost task.

The algorithm stops when `y` and `z` stay unchanged for as many iterations as there are UAVs. The script then checks that all UAVs agree on the same winners and that every task has one.

### Failure recovery: auction

At step 100, a randomly selected UAV stops and its unfinished tasks are released. Each surviving UAV bids on each released task, one task at a time:

```matlab
reBid = reward - distanceCost - workloadWeight * workload;
```

Here, `distanceCost` is the UAV's current distance to the task and `workload` is its current queue length. The highest bidder appends the task to the end of its queue.

## Parameters

| Parameter | Value | Description |
|---|---:|---|
| `numUAV` | 4 | Number of UAVs |
| `numTasks` | 20 | Number of tasks |
| `bundleSize` | 5 | Maximum tasks per UAV during CBBA |
| `reward` | 100 | Task reward |
| `lambda` | 0.98 | Discount per meter traveled |
| `speed` | 0.4 | Distance traveled per simulation step (m) |

## Run

**Requirements:** MATLAB. The project was developed with R2026a and needs no additional toolboxes.

1. Clone this repository.
2. Make sure `multirotor.stl` is in the same folder as `Task05_CBBA.m` or on the MATLAB path.
3. Open the `Task05_CBBA` folder in MATLAB.
4. Run:

```matlab
Task05_CBBA
```

The 3D figure shows UAV positions, task status, and each UAV's queue. The Command Window logs CBBA results, reallocation decisions, and task completions.

Task positions and the failed UAV are random, so each run is different.

## Repository Structure

| Folder | Stage |
|---|---|
| `Task04_Cost_Based_Task_Allocation` | Nearest-UAV allocation with cost-based reallocation after failure |
| `Task05_CBBA` | CBBA allocation and auction-based reallocation |

## Limitations

- Message passing is simulated synchronously inside one MATLAB process, with no packet loss or delay.
- The failure is detected immediately and always occurs at step 100.
- Reallocation uses a separate auction rather than rerunning CBBA, and it does not reoptimize existing paths.
- Tasks are static, have equal rewards, and are at the same altitude.
- UAVs follow simple constant-speed motion, with no dynamics, battery, or collision models.

## Reference

H.-L. Choi, L. Brunet, and J. P. How, "Consensus-Based Decentralized Auctions for Robust Task Allocation," *IEEE Transactions on Robotics*, vol. 25, no. 4, pp. 912-926, 2009.

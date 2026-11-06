% =====================================================================
% Task05_CBBA.m
%
% Adaptive Task Reallocation under Agent Failure in a Multi-UAV Environment
%
% Initial Allocation : Consensus-Based Bundle Algorithm (CBBA)
%   - 각 UAV는 자신의 y(승자 Bid), z(승자), s(정보 시각) 정보만 사용
%   - Bundle Construction: 경로 삽입 위치별 한계 점수로 Task 추가
%   - Consensus: 통신 그래프의 이웃과 메시지를 교환해 충돌 해결
%   - 시뮬레이션 내 동기식 메시지 교환이며, 통신 손실/지연은 미반영
%
% Failure Recovery
%   - 고장 UAV의 잔여 Task를 Release
%   - ReBid = reward - 현재 거리 - workloadWeight * Queue 길이 기반 경매
%
% Task04와 seed, failureStep, workloadWeight를 같게 두어 비교
%
% Reference: Choi, Brunet, How, "Consensus-Based Decentralized Auctions
%            for Robust Task Allocation," IEEE T-RO, 2009.
% =====================================================================

%% MATLAB Environment Initialization
% MATLAB 실행 환경 초기화
% clc      : Command Window 내용 삭제
% clear    : Workspace 변수 제거
% close all: 모든 Figure 창 종료

% MATLAB 작업 환경 초기화
clc;        % Command Window 초기화
clear;      % Workspace 변수 제거
close all;  % 모든 Figure 종료

methodName = 'Task05 CBBA + Auction Reallocation';

% UAV 개수
numUAV = 4;

%% 비교 실험 공통 설정 (Task04와 Task05에서 같은 값 사용)
%%seed = 1;              % 같은 값이면 Task 위치와 고장 UAV가 동일
failureStep = 100;     % UAV 고장 발생 Step
workloadWeight = 5;    % 재할당 시 Queue 길이 가중치
%%rng(seed);

% 비교 지표
totalDistance = zeros(numUAV, 1);
numReallocated = 0;

%% Figure 생성
% 시뮬레이션 결과를 시각화하기 위한 3D Figure 생성

% Figure 창 생성
figure;

% 3D 축 생성
ax = axes('XLim', [-50 50], ...   % X축 범위
          'YLim', [-50 50], ...   % Y축 범위
          'ZLim', [0 20]);        % Z축 범위

% 3D 시점 설정
view(3);

% Grid 표시
grid on;

% UAV와 Task를 동시에 표시
hold on;

% 축 라벨
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

% 현재 Simulation Step 표시
stepText = annotation('textbox', ...
    [0.02 0.92 0.2 0.05], ...
    'String', 'Step : 0', ...
    'EdgeColor', 'none', ...
    'FontSize', 14);

% Failure 예정 UAV 표시
failedUAVText = annotation('textbox', ...
    [0.02 0.87 0.2 0.05], ...
    'String', 'failedUAV : 0', ...
    'EdgeColor', 'none', ...
    'FontSize', 14);

queueText = cell(numUAV, 1);

for i = 1:numUAV
    queueText{i} = annotation( ...
        'textbox', ...
        [0.02 0.17-(i-1)*0.05 0.4 0.05], ...
        'String', ['UAV ', num2str(i), ' : []'], ...
        'EdgeColor', 'none', ...
        'FontSize', 10);
end 

% Figure 제목
title(methodName);

%% UAV 설정
% UAV 개수, 모델 크기 및 시각화 설정

% UAV 모델 스케일
scaleFactor = 0.05;

%% STL 파일 읽기 및 UAV 생성

% UAV별 고정 색상 지정
% UAV1 : Red
% UAV2 : Blue
% UAV3 : Green
% UAV4 : Yellow
uavColors = [
    1 0 0;
    0 0 1;
    0 1 0;
    1 1 0];

for i = 1:numUAV

    % STL 파일 읽기
    fv{i} = stlread("multirotor.stl");

    % UAV 모델 중심 계산
    centroid{i} = mean(fv{i}.Points, 1);

    % 모델 중심을 원점으로 이동 후 스케일 적용
    baseVertices{i} = ...
        (fv{i}.Points - centroid{i}) * scaleFactor;

    % UAV 초기 위치 설정
    % 맵의 4개 코너에 배치하여
    % Task Allocation 및 Reallocation 결과를
    % 쉽게 확인할 수 있도록 구성
    uavPos{1} = [-30 -30 5];
    uavPos{2} = [ 30 -30 5];
    uavPos{3} = [-30  30 5];
    uavPos{4} = [ 30  30 5];

    % UAV 초기 위치 반영
    vertices{i} = baseVertices{i} + uavPos{i};

    % UAV Patch 객체 생성
    p{i} = patch('Parent', ax, ...
        'Faces', fv{i}.ConnectivityList, ...
        'Vertices', vertices{i}, ...
        'FaceColor', uavColors(i,:), ...
        'EdgeColor', 'none');

end

% 축 자동 변경 방지
axis(ax, 'manual');

% 광원 추가
camlight;

% 표면 음영 처리
lighting gouraud;

%% Random Task Generation
% 임의 위치에 Task 생성

% 생성할 Task 개수
numTasks = 20;

% Task 좌표 저장 배열
% 각 행 = [x y z]
tasks = zeros(numTasks, 3);

% Random Task 생성
for i = 1:numTasks

    % Random x 좌표
    tx = -40 + 80 * rand;

    % Random y 좌표
    ty = -40 + 80 * rand;

    % Task 고도
    tz = 5;

    % Task 저장
    tasks(i,:) = [tx ty tz];

end

%% Task 시각화

% Task를 파란 점으로 표시
taskPlot = scatter3(tasks(:,1), ...
                    tasks(:,2), ...
                    tasks(:,3), ...
                    100, ...
                    'filled', ...
                    'b');

%% Task 상태 저장
% Task 완료 여부 및 할당 여부 관리

% Task 완료 여부
% false : 미완료
% true  : 완료
taskCompleted = false(numTasks,1);

% Task 할당 여부
% false : 미할당
% true  : 할당됨
taskAssigned = false(numTasks,1);

%% UAV별 현재 Task 저장

% uavTask(i)
% = UAV i가 수행 중인 Task 번호
uavTask = zeros(numUAV,1);

uavQueue = cell(numUAV,1);


%% UAV 이동
% 단순 Kinematic Motion Model 파라미터
% UAV 이동 속도 및 상태 관리

% UAV 이동 속도
speed = 0.4;

% UAV 상태 저장
% true  : 정상
% false : Failure
uavStatus = true(numUAV, 1);

% Simulation Step Counter
simStep = 0;

% Failure 발생 UAV 랜덤 선택
failedUAV = randi([1, numUAV]);

% 화면에 Failure 예정 UAV 표시
failedUAVText.String = ...
    ['failedUAV : ', num2str(failedUAV)];

reward = 100;

% CBBA 파라미터
lambda = 0.98;       % 거리 1 m당 시간 할인율
bundleSize = 5;      % UAV별 최대 Task 수

% 통신 그래프 (Ring: 1-2-3-4-1)
% commGraph(i,k) = 1 이면 UAV i와 k가 직접 통신 가능
commGraph = [0 1 0 1;
             1 0 1 0;
             0 1 0 1;
             1 0 1 0];

[uavBundle, uavQueue, y, z, cbbaIter, cbbaConverged] = runCBBA( ...
    uavPos, tasks, commGraph, reward, lambda, bundleSize);

if ~cbbaConverged
    error('CBBA did not converge within the iteration limit.');
end

fprintf('\n===== Initial Allocation =====\n');
fprintf('Converged in %d iterations\n', cbbaIter);

for i = 1:numUAV
    fprintf('UAV %d Path : %s\n', i, mat2str(uavQueue{i}));
end

% 합의 결과 검증: 모든 UAV의 z가 같고, 모든 Task의 Winner가 존재해야 함
if any(any(z ~= z(1,:))) || any(z(1,:) == 0)
    error('CBBA result is inconsistent or leaves a task unassigned.');
end

taskAssigned(:) = true;


%% Simulation Loop
% 메인 시뮬레이션 루프
% UAV 이동, Failure, Reallocation, Task 완료를 반복 수행

while true

    % Simulation Step 증가
    simStep = simStep + 1;

    % 현재 Step 표시
    stepText.String = ...
        ['Step : ', num2str(simStep)];

    %% Agent Failure Event
% 지정 Step에서 UAV Failure 발생
% 남은 Queue를 Release 후 재할당

    % Step failureStep에서 UAV Failure 발생
    %
    % Failure 처리 과정
    % 1. UAV 비활성화
    % 2. 수행 중 Task 확인
    % 3. Task Release
    % 4. ReBid 경매로 Released Task 재할당
    % 5. 임무 수행  
    if simStep == failureStep

        % UAV Failure 처리
        uavStatus(failedUAV) = false;

        % 고장 UAV 위치
        failPos = uavPos{failedUAV};

        % X 테두리(흰색)
        plot3(ax, failPos(1), failPos(2), failPos(3) + 1, 'x', ...
            'Color', 'w', ...
            'MarkerSize', 25, ...
            'LineWidth', 6);

        % X 본체(빨간색)
        plot3(ax, failPos(1), failPos(2), failPos(3) + 1, 'x', ...
            'Color', 'r', ...
            'MarkerSize', 20, ...
            'LineWidth', 2);

        % 고장 라벨
        text(ax, failPos(1), failPos(2), failPos(3) + 6, ...
            ['UAV ', num2str(failedUAV), ' FAILED'], ...
            'Color', 'r', ...
            'FontSize', 14, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');

        % UAV를 회색으로 변경
        p{failedUAV}.FaceColor = [0.5 0.5 0.5];

        % 상태 문구 표시
        failedUAVText.String = ...
            ['UAV ', num2str(failedUAV), ' FAILED (Step ', num2str(simStep), ')'];
        failedUAVText.Color = 'r';

        failedTasks = uavQueue{failedUAV};

        for n = 1:length(failedTasks)
            taskAssigned(failedTasks(n)) = false;
        end

        uavQueue{failedUAV} = [];

        disp('Failed Tasks')
        disp(failedTasks)

        % Failure 로그 출력
        disp(['UAV ', num2str(failedUAV), ' Failed']);

        for n = 1:length(failedTasks)
            
            failedTask = failedTasks(n);
        
            reBid = -inf(numUAV, 1);
    
            for k = 1:numUAV
    
                %고장 UAV 제외
                if k == failedUAV
                    continue;
                end
    
                %살아있는 UAV만
                if ~uavStatus(k)
                    continue;
                end
    
                distanceCost = norm(tasks(failedTask,:) - uavPos{k});
    
                workload = length(uavQueue{k});

                reBid(k) = reward - distanceCost - workloadWeight * workload;

                fprintf('UAV%d ReBid = %.2f\n', k, reBid(k));

    
            end
    
            [winnerBid, winnerUAV] = max(reBid);

            fprintf( ...
                    'Task %d reassigned to UAV %d (Bid=%.2f)\n',...
                    failedTask,...
                    winnerUAV,...
                    winnerBid);
            
            uavQueue{winnerUAV}(end+1) = failedTask;
            taskAssigned(failedTask) = true;
            numReallocated = numReallocated + 1;

        end
    end

    % 모든 Task 완료 시 종료
    if all(taskCompleted)

        disp('All tasks completed');

        fprintf('\n===== Mission Summary =====\n');
        fprintf('Method            : %s\n', methodName);
        fprintf('Seed              : %d\n', seed);
        fprintf('Failed UAV        : %d (Step %d)\n', failedUAV, failureStep);
        fprintf('Reallocated Tasks : %d\n', numReallocated);
        fprintf('Completed Tasks   : %d / %d\n', sum(taskCompleted), numTasks);
        fprintf('Completion Step   : %d\n', simStep);
        fprintf('Total Distance    : %.1f m\n', sum(totalDistance));
        fprintf('UAV Distance (m)  : %s\n', sprintf('%.1f ', totalDistance));
        break;

    end

    %% UAV별 동작 수행
% 각 UAV의 이동 및 Task 처리

    for i = 1:numUAV

        % Failure UAV는 동작 수행 안 함
        if ~uavStatus(i)
            continue;
        end

        % 현재 UAV가 수행 중인 Task 번호
        if isempty(uavQueue{i})

            currentTask = 0;
        
        else
        
            currentTask = uavQueue{i}(1);
        
        end

        if currentTask == 0
            continue
        end

        % 이미 완료된 Task면 Skip
        if taskCompleted(currentTask)

            uavQueue{i}(1) = [];
        
            continue;
        
        end

        %% 목표 Task 설정
% Queue의 첫 번째 Task를 현재 목표로 사용

        % 현재 UAV 목표 Task
        target = tasks(currentTask,:);

        %% UAV → Task 방향 계산
% 현재 위치와 목표 위치 사이 방향 벡터 계산

        % 이동 방향 벡터 계산
        direction = target - uavPos{i};

        % UAV와 Task 거리 계산
        distance = norm(direction);

        %% Task 완료 여부 확인
% 목표 반경 이내 진입 시 Task 완료 처리

        if distance < 0.2

            % Task 완료 처리
            taskCompleted(currentTask) = true;
            taskAssigned(currentTask) = false;
         
            uavQueue{i}(1) = [];

            % 완료 로그 출력
            disp(['UAV ', num2str(i), ...
                  ' completed Task ', ...
                  num2str(currentTask)]);

        else

            %% UAV 이동
% 단순 Kinematic Motion Model

            % 방향 벡터 정규화
            direction = direction / distance;

            % UAV 위치 업데이트
            uavPos{i} = uavPos{i} + speed * direction;

            % 이동 거리 누적
            totalDistance(i) = totalDistance(i) + speed;

        end

        %% UAV Mesh 업데이트
% UAV 3D 모델 위치 갱신

        % UAV 위치 반영
        newVertices = baseVertices{i} + uavPos{i};

        if isvalid(p{i})

            % UAV 형상 위치 업데이트
            p{i}.Vertices = newVertices;

        end

    end

    %% Task 상태 시각화
% 완료 Task=녹색, 미완료 Task=파란색

    % 완료된 Task Index 추출
    completedIdx = find(taskCompleted);

    % 기본 색상 = 파랑 (미완료)
    colors = repmat([0 0 1], numTasks, 1);

    % 완료된 Task = 초록
    colors(completedIdx,:) = ...
        repmat([0 1 0], length(completedIdx), 1);

    % Task 색상 업데이트
    taskPlot.CData = colors;

    %% 화면 갱신

    for i = 1:numUAV

        if isempty(uavQueue{i})

            queueStr = '[]';

        else

            queueStr = mat2str(uavQueue{i});

        end

        queueText{i}.String = ...
            ['UAV ', num2str(i), ...
            ' Queue : ', queueStr];

    end
    
    drawnow;

end

%% CBBA Local Functions

function [bundle, path, y, z, iter, converged] = runCBBA( ...
    uavPos, tasks, adj, reward, lambda, maxBundle)
% y(i,j) : UAV i가 알고 있는 Task j의 최고 Bid
% z(i,j) : UAV i가 알고 있는 Task j의 Winner (0 = 없음)
% s(i,m) : UAV i가 UAV m의 정보를 마지막으로 갱신한 시각

    numUAV = numel(uavPos);
    numTasks = size(tasks, 1);

    y = zeros(numUAV, numTasks);
    z = zeros(numUAV, numTasks);
    s = zeros(numUAV, numUAV);
    bundle = repmat({zeros(1,0)}, numUAV, 1);
    path = repmat({zeros(1,0)}, numUAV, 1);

    maxIter = 500;
    stableCount = 0;
    converged = false;

    for iter = 1:maxIter

        yPrev = y;
        zPrev = z;

        % Phase 1: 각 UAV가 자기 정보로 Bundle 구성
        for i = 1:numUAV
            [bundle{i}, path{i}, y(i,:), z(i,:)] = buildBundle( ...
                i, uavPos{i}, tasks, bundle{i}, path{i}, ...
                y(i,:), z(i,:), reward, lambda, maxBundle);
        end

        % Phase 2: 이웃 간 메시지 교환 및 충돌 해결
        [y, z, s] = consensusStep(y, z, s, adj, iter);

        % 뺏긴 Task와 그 뒤에 추가한 Task를 Bundle에서 해제
        for i = 1:numUAV
            [bundle{i}, path{i}, y(i,:), z(i,:)] = releaseTasks( ...
                i, bundle{i}, path{i}, y(i,:), z(i,:));
        end

        % 정보가 그래프 전체에 퍼질 동안 변화가 없으면 수렴
        if isequal(y, yPrev) && isequal(z, zPrev)
            stableCount = stableCount + 1;
        else
            stableCount = 0;
        end

        if stableCount >= numUAV
            converged = true;
            return;
        end
    end
end

function [bundle, path, yi, zi] = buildBundle( ...
    i, pos, tasks, bundle, path, yi, zi, reward, lambda, maxBundle)
% 한계 점수가 현재 최고 Bid보다 큰 Task 중 최댓값을 차례로 추가

    while numel(bundle) < maxBundle

        baseScore = pathScore(pos, tasks, path, reward, lambda);
        bestGain = 0;
        bestTask = 0;
        bestPath = [];

        for j = setdiff(1:size(tasks,1), bundle)

            % Task j를 넣을 최적 경로 위치 탐색
            gain = -inf;
            candPath = [];

            for n = 0:numel(path)
                testPath = [path(1:n) j path(n+1:end)];
                testGain = pathScore(pos, tasks, testPath, reward, lambda) ...
                    - baseScore;

                if testGain > gain
                    gain = testGain;
                    candPath = testPath;
                end
            end

            if gain > yi(j) && gain > bestGain
                bestGain = gain;
                bestTask = j;
                bestPath = candPath;
            end
        end

        if bestTask == 0
            break;
        end

        bundle(end+1) = bestTask; %#ok<AGROW>
        path = bestPath;
        yi(bestTask) = bestGain;
        zi(bestTask) = i;
    end
end

function score = pathScore(pos, tasks, path, reward, lambda)
% 시간 할인 보상: 이동 거리가 길수록 Task의 가치가 감소

    score = 0;
    travel = 0;
    current = pos;

    for j = path
        travel = travel + norm(tasks(j,:) - current);
        score = score + reward * lambda^travel;
        current = tasks(j,:);
    end
end

function [y, z, s] = consensusStep(y, z, s, adj, iter)
% Choi et al. (2009) Table 1의 Update / Reset / Leave 규칙

    yOld = y;
    zOld = z;
    sOld = s;
    numUAV = size(y, 1);
    numTasks = size(y, 2);

    for i = 1:numUAV

        neighbors = find(adj(i,:));

        for k = neighbors
            for j = 1:numTasks
                action = consensusRule(i, k, ...
                    y(i,j), z(i,j), yOld(k,j), zOld(k,j), ...
                    sOld(i,:), sOld(k,:));

                if action == 1          % Update
                    y(i,j) = yOld(k,j);
                    z(i,j) = zOld(k,j);
                elseif action == 2      % Reset
                    y(i,j) = 0;
                    z(i,j) = 0;
                end
            end
        end

        % 정보 시각 갱신
        s(i,:) = max([sOld(i,:); sOld(neighbors,:)], [], 1);
        s(i,neighbors) = iter;
        s(i,i) = iter;
    end
end

function action = consensusRule(i, k, yi, zi, yk, zk, si, sk)
% 반환값: 0 = Leave, 1 = Update, 2 = Reset
% i = 수신 UAV, k = 송신 UAV

    action = 0;

    if zk == k                          % 송신자: 내가 Winner
        if zi == i
            if yk > yi, action = 1; end
        elseif zi == k || zi == 0
            action = 1;
        else
            if sk(zi) > si(zi) || yk > yi, action = 1; end
        end

    elseif zk == i                      % 송신자: 수신자가 Winner
        if zi == k
            action = 2;
        elseif zi ~= i && zi ~= 0
            if sk(zi) > si(zi), action = 2; end
        end

    elseif zk ~= 0                      % 송신자: 제3자 m이 Winner
        m = zk;
        if zi == i
            if sk(m) > si(m) && yk > yi, action = 1; end
        elseif zi == k
            if sk(m) > si(k), action = 1; else, action = 2; end
        elseif zi == m || zi == 0
            if sk(m) > si(m), action = 1; end
        else
            n = zi;
            if sk(m) > si(m) && sk(n) > si(n)
                action = 1;
            elseif sk(m) > si(m) && yk > yi
                action = 1;
            elseif sk(n) > si(n) && si(m) > sk(m)
                action = 2;
            end
        end

    else                                % 송신자: Winner 없음
        if zi == k
            action = 1;
        elseif zi ~= i && zi ~= 0
            if sk(zi) > si(zi), action = 1; end
        end
    end
end

function [bundle, path, yi, zi] = releaseTasks(i, bundle, path, yi, zi)
% 처음 뺏긴 Task 이후의 Task는 Bid의 전제가 바뀌므로 모두 해제

    lostAt = find(zi(bundle) ~= i, 1);

    if isempty(lostAt)
        return;
    end

    released = bundle(lostAt:end);
    bundle = bundle(1:lostAt-1);
    path = path(~ismember(path, released));

    for j = released
        if zi(j) == i
            yi(j) = 0;
            zi(j) = 0;
        end
    end
end
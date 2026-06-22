% =====================================================================
% Task05_CBBA_Final.m
%
% Project Summary
% ---------------------------------------------------------------------
% Initial Allocation
%   - CBBA-inspired Bundle Allocation
%   - Distance-based Bid Generation
%
% Conflict Resolution
%   - Winner-Takes-All Consensus
%   - Highest Bid UAV keeps the task
%
% Failure Recovery
%   - Failed UAV releases remaining tasks
%   - Auction-based Reallocation
%   - ReBid = BaseBid - WorkloadPenalty
%
% Mission Objective
%   Adaptive Task Reallocation under Agent Failure
%   in a Multi-UAV Environment
% =====================================================================

% =====================================================
% Task05_CBBA.m
%
%
% Adaptive Task Reallocation under Agent Failure
% using CBBA-like Task Allocation
%
% 주요 단계
% 1. UAV 및 Task 생성
% 2. Bid Matrix 계산
% 3. Bundle 생성
% 4. Consensus 기반 Conflict 해결
% 5. Missing Task Recovery
% 6. Agent Failure Simulation
% 7. Auction-Based Task Reallocation
% 8. Mission Completion
% =====================================================

% =====================================================
% Adaptive Task Reallocation under Agent Failure
%
% Baseline Version
% Multi-UAV + Nearest Task Allocation + Task Release
%
% Failure 발생 시 수행 중이던 Task를 Release하여
% 다른 UAV가 향후 재할당할 수 있도록 구현
% =====================================================

%% MATLAB Environment Initialization
% MATLAB 실행 환경 초기화
% clc      : Command Window 내용 삭제
% clear    : Workspace 변수 제거
% close all: 모든 Figure 창 종료

% MATLAB 작업 환경 초기화
clc;        % Command Window 초기화
clear;      % Workspace 변수 제거
close all;  % 모든 Figure 종료

% UAV 개수
numUAV = 4;

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
        [0.02 0.80-(i-1)*0.05 0.4 0.05], ...
        'String', ['UAV ', num2str(i), ' : []'], ...
        'EdgeColor', 'none', ...
        'FontSize', 10);
end 

% Figure 제목
title('Multi-UAV Task Allocation Simulation');

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

%% Bid Matrix
% CBBA Bid 저장 행렬
% bidMatrix(i,j) = UAV i가 Task j에 대해 계산한 Bid
bidMatrix = zeros(numUAV, numTasks);

uavBundle = cell(numUAV,1);

%% Winner Matrix
% 각 Task에 대한 Winner UAV / Second UAV 저장
winnerBid = zeros(numTasks, 1);
winnerUAV = zeros(numTasks, 1);
secondBid = zeros(numTasks, 1);
secondUAV = zeros(numTasks, 1);


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

uavBundleValue = cell(numUAV, 1);

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

for i = 1:numUAV
    for j = 1:numTasks
        distance = norm(tasks(j,:) - uavPos{i});
        bidMatrix(i,j) = reward - distance;
    end
end

% 각 UAV가 보유할 Bundle 크기
bundleSize = 5;

for i =1:numUAV
    [sortedBid, sortedTask] = ...
        sort(bidMatrix(i,:), 'descend');

    uavBundle{i} = sortedTask(1:bundleSize);
end



disp('===== UAV Bundle Preference =====')

for i = 1:numUAV

    fprintf('\nUAV %d\n', i);

    disp(uavBundle{i});

end

for j = 1:numTasks
    currentBids = bidMatrix(:,j);

    [sortedBids, sortedIdx] = ...
        sort(currentBids, 'descend');

    winnerBid(j) = sortedBids(1);
    winnerUAV(j) = sortedIdx(1);

    secondBid(j) = sortedBids(2);
    secondUAV(j) = sortedIdx(2);

    uavBundleValue{winnerUAV(j)}(end+1) = winnerBid(j);
end

y = zeros(numUAV, numTasks);
z = zeros(numUAV, numTasks);

for i = 1:numUAV
    for j =1:numTasks
        y(i,j) = bidMatrix(i,j);
        z(i,j) = i;
    end
end

conflictThreshold = 5;

fprintf('\n===== CBBA Analysis and Conflict Tasks =====\n');

for j = 1:numTasks

    bidGap = winnerBid(j) - secondBid(j);

    if bidGap < conflictThreshold

        fprintf( ...
            'Task %2d | Winner UAV %d (%.2f) | Second UAV %d (%.2f) | Gap = %.2f\n',...
            j,...
            winnerUAV(j), winnerBid(j),...
            secondUAV(j), secondBid(j),...
            bidGap);
    end

end

fprintf('\n===== Bundle Conflicts =====\n');

for task = 1:numTasks
    ownerList = [];
    for i = 1:numUAV
        if ismember(task, uavBundle{i})
            ownerList(end+1) = i;
        end
    end

    if length(ownerList) > 1
        
        fprintf('Task %d claimed by UAV ',task);
        fprintf('%d ',ownerList);
        fprintf('\n');

        bids = bidMatrix(ownerList, task);

        [~, idx] = max(bids);

        winner = ownerList(idx);

        fprintf(' -> Winner UAV %d\n',winner);

        for k = ownerList
            if k ~=winner
                uavBundle{k}(uavBundle{k}==task) = [];
            end
        end
    end
end

fprintf('\n===== Consensus Result =====\n');

for i = 1:numUAV

    fprintf('\nUAV %d\n',i);

    disp(uavBundle{i});

end

uavQueue = uavBundle;

taskAssigned(:) = false;

for i = 1:numUAV
    taskAssigned(uavQueue{i}) = true;
end

assignedTasks = [];

for i = 1:numUAV
    assignedTasks = [assignedTasks uavBundle{i}];
end

missingTasks = setdiff(1:numTasks, unique(assignedTasks));

if ~isempty(missingTasks)

    fprintf('\nAdding Missing Tasks...\n');

    for m = missingTasks

        [~, bestUAV] = max(bidMatrix(:,m));
    
        uavBundle{bestUAV}(end+1) = m;
    
        % 추가
        uavQueue{bestUAV}(end+1) = m;
    
        fprintf('Task %d added to UAV %d\n',m,bestUAV);
    
    end

end




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

    % Step 100에서 UAV Failure 발생
    %
    % Failure 처리 과정
    % 1. UAV 비활성화
    % 2. 수행 중 Task 확인
    % 3. Task Release
    % 4. 가장 가까운 UAV가 Released Task 재할당
    % 5. 임무 수행  
    if simStep == 100

        % UAV Failure 처리
        uavStatus(failedUAV) = false;

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

                reBid(k) = reward - distance -5*workload;

                fprintf('UAV%d ReBid = %.2f\n', k, reBid(k));

                fprintf('\nTask %d Bid Matrix\n',failedTask);
                disp(bidMatrix(:,failedTask));
    
            end
    
            [winnerBid, winnerUAV] = max(reBid);

            fprintf( ...
                    'Task %d reassigned to UAV %d (Bid=%.2f)\n',...
                    failedTask,...
                    winnerUAV,...
                    winnerBid);
            
            uavQueue{winnerUAV}(end+1) = failedTask;
            taskAssigned(failedTask) = true;

        end
    end

    % 모든 Task 완료 시 종료
    if all(taskCompleted)

        disp('All tasks completed');
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
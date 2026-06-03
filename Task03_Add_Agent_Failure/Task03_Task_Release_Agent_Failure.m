% =====================================================
% Adaptive Task Reallocation under Agent Failure
%
% Baseline Version
% Multi-UAV + Nearest Task Allocation + Task Release
%
% Failure 발생 시 수행 중이던 Task를 Release하여
% 다른 UAV가 향후 재할당할 수 있도록 구현
% =====================================================

% MATLAB 작업 환경 초기화
clc;        % Command Window 초기화
clear;      % Workspace 변수 제거
close all;  % 모든 Figure 종료

%% Figure 생성

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

% Figure 제목
title('Multi-UAV Task Allocation Simulation');

%% UAV 설정

% UAV 개수
numUAV = 4;

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

%% 초기 Task Allocation

% 각 UAV에 가장 가까운 Task 할당
for i = 1:numUAV

    % 최소 거리 초기화
    minDist = inf;

    % 가장 가까운 Task Index
    nearestIdx = -1;

    % 아직 할당되지 않은 Task 탐색
    for j = 1:numTasks

        if ~taskAssigned(j)

            % UAV와 Task 거리 계산
            dist = norm(tasks(j,:) - uavPos{i});

            % 가장 가까운 Task 갱신
            if dist < minDist

                minDist = dist;
                nearestIdx = j;

            end

        end

    end

    % UAV에 Task 할당
    uavTask(i) = nearestIdx;

    % 해당 Task 예약
    taskAssigned(nearestIdx) = true;

end

%% UAV 이동 파라미터

% UAV 이동 속도
speed = 0.2;

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

%% Simulation Loop

while true

    % Simulation Step 증가
    simStep = simStep + 1;

    % 현재 Step 표시
    stepText.String = ...
        ['Step : ', num2str(simStep)];

    %% Agent Failure Event

    % Step 100에서 UAV Failure 발생
    %
    % Failure 처리 과정
    % 1. UAV 비활성화
    % 2. 수행 중 Task 확인
    % 3. Task Release
    % 4. 향후 다른 UAV가 재할당 가능
    if simStep == 100

        % UAV Failure 처리
        uavStatus(failedUAV) = false;

        % Failure UAV가 수행 중인 Task 확인
        failedTask = uavTask(failedUAV);

        if failedTask ~= 0

            % Task Release
            % 다시 미할당 상태로 변경
            taskAssigned(failedTask) = false;

            % Failure UAV에서 Task 제거
            uavTask(failedUAV) = 0;

        end

        % Failure 로그 출력
        disp(['UAV ', num2str(failedUAV), ' Failed']);

    end

    % 모든 Task 완료 시 종료
    if all(taskCompleted)

        disp('All tasks completed');
        break;

    end

    %% UAV별 동작 수행

    for i = 1:numUAV

        % Failure UAV는 동작 수행 안 함
        if ~uavStatus(i)
            continue;
        end

        % 현재 UAV가 수행 중인 Task 번호
        currentTask = uavTask(i);

        % Task 없으면 Skip
        if currentTask == 0
            continue;
        end

        % 이미 완료된 Task면 Skip
        if taskCompleted(currentTask)
            continue;
        end

        %% 목표 Task 설정

        % 현재 UAV 목표 Task
        target = tasks(currentTask,:);

        %% UAV → Task 방향 계산

        % 이동 방향 벡터 계산
        direction = target - uavPos{i};

        % UAV와 Task 거리 계산
        distance = norm(direction);

        %% Task 완료 여부 확인

        if distance < 0.2

            % Task 완료 처리
            taskCompleted(currentTask) = true;

            % 완료 로그 출력
            disp(['UAV ', num2str(i), ...
                  ' completed Task ', ...
                  num2str(currentTask)]);

            %% Nearest Task Reallocation

            % 가장 가까운 미할당 Task 탐색
            minDist = inf;
            newTask = 0;

            for j = 1:numTasks

                if ~taskCompleted(j) && ~taskAssigned(j)

                    dist = norm(tasks(j,:) - uavPos{i});

                    if dist < minDist

                        minDist = dist;
                        newTask = j;

                    end

                end

            end

            %% 새 Task 할당

            if newTask ~= 0

                % UAV에 새 Task 할당
                uavTask(i) = newTask;

                % Task 예약
                taskAssigned(newTask) = true;

            else

                % 수행할 Task 없으면 Idle
                uavTask(i) = 0;

            end

        else

            %% UAV 이동

            % 방향 벡터 정규화
            direction = direction / distance;

            % UAV 위치 업데이트
            uavPos{i} = uavPos{i} + speed * direction;

        end

        %% UAV Mesh 업데이트

        % UAV 위치 반영
        newVertices = baseVertices{i} + uavPos{i};

        if isvalid(p{i})

            % UAV 형상 위치 업데이트
            p{i}.Vertices = newVertices;

        end

    end

    %% Task 상태 시각화

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

    drawnow;

end
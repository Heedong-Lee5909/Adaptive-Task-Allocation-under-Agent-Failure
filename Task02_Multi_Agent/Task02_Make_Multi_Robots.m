% MATLAB 작업 환경 초기화
clc;        % Command Window 초기화
clear;      % Workspace 변수 제거
close all;  % 모든 Figure 종료

%% Figure 생성

% Figure 창 생성
figure;

% 3D 축 생성
ax = axes('XLim', [-10 10], ...   % X축 범위
          'YLim', [-10 10], ...   % Y축 범위
          'ZLim', [0 15]);        % Z축 범위

% 3D 시점 설정
view(3);

% Grid 표시
grid on;

% 여러 객체(UAV + task)를 동시에 유지
hold on;

% 축 라벨
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

% Figure 제목
title('Multi-UAV Task Allocation Simulation');

%% UAV 설정

% UAV 개수
numUAV = 4;

% UAV 모델 스케일
scaleFactor = 0.01;

%% STL 파일 읽기 및 UAV 생성

for i = 1:numUAV

    % STL 파일 읽기
    fv{i} = stlread("multirotor.stl");

    % UAV 모델 중심 계산
    centroid{i} = mean(fv{i}.Points, 1);

    % 모델 중심을 원점으로 이동 후 스케일 적용
    baseVertices{i} = ...
        (fv{i}.Points - centroid{i}) * scaleFactor;

    % UAV 초기 위치 랜덤 생성
    uavPos{i} = [ ...
        randi([-8 8]), ...   % x 위치
        randi([-8 8]), ...   % y 위치
        randi([3 10]) ...    % z 위치
    ];

    % UAV 초기 위치 반영
    vertices{i} = baseVertices{i} + uavPos{i};

    % UAV patch 객체 생성
    p{i} = patch('Parent', ax, ...
        'Faces', fv{i}.ConnectivityList, ...
        'Vertices', vertices{i}, ...
        'FaceColor', rand(1,3), ... % UAV 색상 랜덤 지정
        'EdgeColor', 'none');

end

% 축 자동 변경 방지
axis(ax, 'manual');

% 광원 추가
camlight;

% 표면 음영 처리
lighting gouraud;

%% Random Task Generation

% 생성할 task 개수
numTasks = 20;

% task 좌표 저장 배열
% 각 row = [x y z]
tasks = zeros(numTasks, 3);

% random task 생성
for i = 1:numTasks

    % random x 좌표
    tx = -8 + 16 * rand;

    % random y 좌표
    ty = -8 + 16 * rand;

    % task z 좌표
    tz = 5;

    % task 저장
    tasks(i,:) = [tx ty tz];

end

%% Task 시각화

% task를 파란 점으로 표시
taskPlot = scatter3(tasks(:,1), ...
                    tasks(:,2), ...
                    tasks(:,3), ...
                    100, ...
                    'filled', ...
                    'b');

%% Task 상태 저장

% task 완료 여부 저장
% false : 미완료
% true  : 완료
taskCompleted = false(numTasks,1);

% task 할당 여부 저장
% false : 미할당
% true  : 할당됨
taskAssigned = false(numTasks,1);

%% UAV별 현재 task 저장

% uavTask(i)
% = UAV i가 수행 중인 task index
uavTask = zeros(numUAV,1);

%% 초기 Task Allocation

% 각 UAV마다 nearest task 할당
for i = 1:numUAV

    % 최소 거리 초기화
    minDist = inf;

    % nearest task index 초기화
    nearestIdx = -1;

    % 아직 할당되지 않은 task 탐색
    for j = 1:numTasks

        % task가 아직 할당되지 않았으면
        if ~taskAssigned(j)

            % UAV와 task 거리 계산
            dist = norm(tasks(j,:) - uavPos{i});

            % 더 가까운 task 발견 시 업데이트
            if dist < minDist

                minDist = dist;
                nearestIdx = j;

            end

        end

    end

    % UAV에 task 할당
    uavTask(i) = nearestIdx;

    % 해당 task 예약
    taskAssigned(nearestIdx) = true;

end

%% UAV 이동 파라미터

% UAV 이동 속도
speed = 0.05;

%% Simulation Loop

while true

    % 모든 task 완료 시 종료
    if all(taskCompleted)

        disp('All tasks completed');
        break;

    end

    %% UAV별 동작 수행

    for i = 1:numUAV

        % 현재 UAV의 task index
        currentTask = uavTask(i);

        % UAV가 task를 가지고 있지 않으면 skip
        if currentTask == 0
            continue;
        end

        % 이미 완료된 task면 skip
        if taskCompleted(currentTask)
            continue;
        end

        %% 현재 목표 task 좌표

        target = tasks(currentTask,:);

        %% UAV → target 방향 계산

        % 방향 벡터 계산
        direction = target - uavPos{i};

        % UAV와 target 사이 거리 계산
        distance = norm(direction);

        %% Task 도착 여부 확인

        % 목표 지점 근처 도착 시
        if distance < 0.2

            % task 완료 처리
            taskCompleted(currentTask) = true;

            % 완료 메시지 출력
            disp(['UAV ', num2str(i), ...
                  ' completed Task ', ...
                  num2str(currentTask)]);

            %% 새로운 task 탐색

            % 최소 거리 초기화
            minDist = inf;

            % 새 task index 초기화
            newTask = 0;

            % 아직 완료되지 않았고
            % 아직 할당되지 않은 task 탐색
            for j = 1:numTasks

                if ~taskCompleted(j) && ~taskAssigned(j)

                    % UAV와 task 거리 계산
                    dist = norm(tasks(j,:) - uavPos{i});

                    % 더 가까운 task 발견 시 업데이트
                    if dist < minDist

                        minDist = dist;
                        newTask = j;

                    end

                end

            end

            %% 새 task 할당

            if newTask ~= 0

                % UAV에 새 task 할당
                uavTask(i) = newTask;

                % task 예약 처리
                taskAssigned(newTask) = true;

            else

                % 남은 task 없으면 idle 상태
                uavTask(i) = 0;

            end

        else

            %% 방향 벡터 정규화

            % 단위 방향 벡터 생성
            direction = direction / distance;

            %% UAV 위치 업데이트

            % UAV 이동
            uavPos{i} = uavPos{i} + speed * direction;

        end

        %% UAV mesh 업데이트

        % UAV 새로운 vertex 계산
        newVertices = baseVertices{i} + uavPos{i};

        % patch 객체가 유효하면 업데이트
        if isvalid(p{i})

            % UAV 위치 업데이트
            p{i}.Vertices = newVertices;

        end

    end

    %% 완료된 task 색상 변경

    % 완료된 task index 추출
    completedIdx = find(taskCompleted);

    % 기본 색상 = 파란색
    colors = repmat([0 0 1], numTasks, 1);

    % 완료된 task = 녹색
    colors(completedIdx,:) = ...
        repmat([0 1 0], length(completedIdx), 1);

    % task 색상 업데이트
    taskPlot.CData = colors;

    %% 화면 업데이트

    drawnow;

end
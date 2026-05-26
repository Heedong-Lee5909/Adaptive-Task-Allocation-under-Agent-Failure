% MATLAB 작업 환경 초기화
clc;            % Command Window 내용 삭제
clear;          % Workspace 변수 삭제
close all;      % 열려있는 Figure 모두 닫기

%% Figure 생성

% Figure 창 생성
figure;

% 3D 축 생성 및 축 범위 설정
ax = axes('XLim', [-10 10], ...   % X축 범위
          'YLim', [-10 10], ...   % Y축 범위
          'ZLim', [0 15]);        % Z축 범위

% 3D 시점 설정
view(3);

% Grid 표시
grid on;

% 여러 그래픽 객체(UAV + task)를 동시에 유지하기 위해 hold on 사용
hold on;

% 축 라벨 설정
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

% Figure 제목 설정
title('UAV Task Allocation Simulation');

%% STL 파일 읽기

% STL 파일 읽기
% fv.Points            : vertex 좌표 정보
% fv.ConnectivityList  : 삼각형 mesh 연결 정보
fv = stlread("multirotor.stl");

%% UAV 모델 전처리

% UAV 모델 크기 축소 비율
scaleFactor = 0.01;

% STL 모델 중심 계산
% 모델 중심을 원점으로 이동시키기 위함
centroid = mean(fv.Points, 1);

% 모델 중심을 원점으로 이동 후 스케일 적용
% baseVertices는 UAV의 원본 형상 역할 수행
baseVertices = (fv.Points - centroid) * scaleFactor;

%% UAV 초기 위치 설정

% UAV 초기 위치 [x y z]
uavPos = [-8 0 5];

% UAV를 초기 위치로 이동
vertices = baseVertices + uavPos;

%% UAV 3D 모델 생성

% patch 객체 생성
% Faces    : 삼각형 face 정보
% Vertices : 실제 vertex 좌표
p = patch('Parent', ax, ...
          'Faces', fv.ConnectivityList, ...
          'Vertices', vertices, ...
          'FaceColor', [0.6350 0.0780 0.1840], ...
          'EdgeColor', 'none');

% 축 자동 변경 방지
axis(ax, 'manual');

% 광원 추가
camlight;

% 표면 음영 처리
lighting gouraud;

%% Random Task Generation

% 생성할 task 개수
numTasks = 5;

% task 좌표 저장용 배열
% 각 row = [x y z]
tasks = zeros(numTasks, 3);

% random task 생성
for i = 1:numTasks

    % random x 좌표 생성
    tx = -8 + 16 * rand;

    % random y 좌표 생성
    ty = -8 + 16 * rand;

    % task 높이(z)
    tz = 5;

    % task 좌표 저장
    tasks(i,:) = [tx ty tz];

end

%% Task 시각화

% 파란색 점으로 task 표시
scatter3(tasks(:,1), ...
         tasks(:,2), ...
         tasks(:,3), ...
         100, ...          % marker 크기
         'filled', ...
         'b');             % blue color

%% Task 완료 여부 저장

% false : 미완료
% true  : 완료
taskCompleted = false(numTasks,1);

%% UAV 이동 파라미터

% UAV 이동 속도
speed = 0.05;

%% Simulation Loop

% 모든 task 완료 전까지 반복
while true

    % ---------------------------------
    % 남은 task 탐색
    % ---------------------------------

    % 아직 완료되지 않은 task index 추출
    remainingTasks = find(~taskCompleted);

    % 모든 task 완료 시 simulation 종료
    if isempty(remainingTasks)

        disp('All tasks completed');
        break;

    end

    % ---------------------------------
    % nearest task 탐색
    % ---------------------------------

    % 최소 거리 초기화
    minDist = inf;

    % nearest task index 초기화
    nearestIdx = -1;

    % 남은 task들에 대해 거리 계산
    for i = remainingTasks'

        % UAV와 task 간 Euclidean distance 계산
        dist = norm(tasks(i,:) - uavPos);

        % 현재 task가 더 가까우면 업데이트
        if dist < minDist

            minDist = dist;
            nearestIdx = i;

        end

    end

    %% 현재 목표 task

    target = tasks(nearestIdx,:);

    % ---------------------------------
    % UAV 이동 방향 계산
    % ---------------------------------

    % UAV → target 방향 벡터 계산
    direction = target - uavPos;

    % UAV와 target 사이 거리 계산
    distance = norm(direction);

    % ---------------------------------
    % Task 도착 여부 확인
    % ---------------------------------

    % 목표 지점 근처 도착 시 task 완료 처리
    if distance < 0.2

        taskCompleted(nearestIdx) = true;

        disp(['Task ', num2str(nearestIdx), ' completed']);

    else

        % ---------------------------------
        % 방향 벡터 정규화
        % ---------------------------------

        % 단위 방향 벡터 생성
        direction = direction / distance;

        % ---------------------------------
        % UAV 위치 업데이트
        % ---------------------------------

        % UAV 위치 이동
        uavPos = uavPos + speed * direction;

    end

    % ---------------------------------
    % UAV mesh 업데이트
    % ---------------------------------

    % UAV 새로운 vertex 계산
    newVertices = baseVertices + uavPos;

    % patch 객체가 유효할 경우만 업데이트
    if isvalid(p)

        % UAV 위치 업데이트
        p.Vertices = newVertices;

    end

    % 화면 갱신
    drawnow;

end
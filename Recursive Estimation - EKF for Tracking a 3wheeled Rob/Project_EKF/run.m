function run(designPart)
% run(designPart)
%
% Main function for Extended Kalman Filter programming exercise.
% It is used to simulate the truth model, call the estimator and show the 
% results.
%
% The function is used to obtain the results for both estimator design 
% parts of the programming exercise:
%   designPart==1  -> Part 1
%   designPart==2  -> Part 2


% clear command window, close figures
clc;
close all;


%% Checks
% Check input argument.  designPart has to be either 1 or 2 corresponding
% to the two problem parts.
if nargin<1 || ((designPart~=1) && (designPart~=2))
    error('Wrong input argument.  You have to call run(1) or run(2) corresponding to the estimator design part considered.');
    return;
else
    disp(['Executing ''run'' for estimator design part #',num2str(designPart),'.']);
end;




%% Setup
% Define the physical constants used in the simulation and accessible to 
% the estimator.
knownConst = KnownConstants();

% Define the simulation constants that are used in simulation, but not 
% accessible to the estimator.  
unknownConst = UnknownConstants();

% Set the random number generator state.
% Uncomment to make results reproducable. This setting was used to generate
% the plot in the problem description.
% rand('seed',1);
% randn('seed',1);


%% Simulation
% The function 'Simulator' simulates the robot kinematics and generates
% measurements.
[tm, wheelRadius, loc, input, sense ] = Simulator( unknownConst, knownConst, designPart );

% The length of signals generated by the Simulator
N = size(tm,1);

%% Run the Estimator

% Initialize the estimator.  
estState = [];
posEst = zeros(N,2);
oriEst = zeros(N,1);
radiusEst = zeros(N,1);
posVar = zeros(N,2);
oriVar = zeros(N,1);
radiusVar = zeros(N,1);
[posEst(1,:),oriEst(1),radiusEst(1),posVar(1,:),oriVar(1),radiusVar(1),estState] = ...
    Estimator(estState,zeros(1,2),zeros(1,2),0,knownConst,designPart);

% Call the estimator for each time step.
for n = 2:N
    [posEst(n,:),oriEst(n),radiusEst(n),posVar(n,:),oriVar(n),radiusVar(n),estState] = ...
        Estimator(estState,input(n,:),sense(n,:),tm(n),knownConst,designPart);
end



%% The results
% Plots of the results.

% Calculate the total tracking error.  Basically the 2 norm of the distance
% error.
trackError = [loc(:,1) - posEst(:,1);loc(:,2) - posEst(:,2)];
trackErrorNorm = sqrt(trackError'*trackError/N);

%%%%%
% 2D-tracking plot
%%%%%

% Plot the actual robot position, y vs x, and the estimated robot position
% and orientation as arrows.
figure(1)
plot(loc(:,1),loc(:,2),'b.', posEst(:,1),posEst(:,2),'g.', ...
    loc(1,1),loc(1,2),'r*',loc(end,1),loc(end,2),'ro',posEst(1,1),posEst(1,2),'m*',posEst(end,1),posEst(end,2),'mo');
hold on;
quiver(loc(:,1), loc(:,2), cos(loc(:,3)), sin(loc(:,3)),0.08, 'b');
quiver(posEst(:,1), posEst(:,2), cos(oriEst), sin(oriEst),0.08, 'g');
%
grid;
legend('true','estimate','start true','end true','start est.','end est.');
xlabel('x position');
ylabel('y position');
title(['position tracking error: ',num2str(trackErrorNorm,6),' m']);


%%%%%
% estimation error (incl. standard deviation)
%%%%%

% plot estimation error together with +/- 1 standard deviation
figure(2);
tm_ = tm;%[0;tm];
%
subplot(4,1,1);
plot(tm_,loc(:,1)-posEst(:,1),tm_,sqrt(posVar(:,1)),'r',tm_,-sqrt(posVar(:,1)),'r');
grid;
ylabel('position x (m)');
title('Estimation error with +/- standard deviation');
%
subplot(4,1,2);
plot(tm_,loc(:,2)-posEst(:,2),tm_,sqrt(posVar(:,2)),'r',tm_,-sqrt(posVar(:,2)),'r');
grid;
ylabel('position y (m)');
%
subplot(4,1,3);
plot(tm_,loc(:,3)-oriEst,tm_,sqrt(oriVar),'r',tm_,-sqrt(oriVar),'r');
grid;
ylabel('orientation r (rad)');
%
subplot(4,1,4);
plot(tm_,wheelRadius-radiusEst,tm_,sqrt(radiusVar),'r',tm_,-sqrt(radiusVar),'r');
grid;
xlabel('time (s)');
ylabel('wheel radius W (m)');

return;

    
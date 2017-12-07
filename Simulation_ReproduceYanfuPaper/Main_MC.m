% This is the main function of the MC for the distributed generated system.
% We do not consider CCF in this file.
% This code reproduces Li and Zio (2012) using simulation methods.
% Version history:
% 20170206: Created by ZZ
clear;clc;tic;
%% Data definitions
% For the transformer
lambda_T = 4e-4; % Failure rate for the transformer (y^{-1}), be careful, maybe Li and Zio (2012) made a mistake.
mu_T = 1.3e-2; % Repair rate for the transformer (y^{-1})
% Transform the rates into $h^{-1}$
YEARLYHOUR = 24*365;
% lambda_T = lambda_T/YEARLYHOUR;
% mu_T = mu_T/YEARLYHOUR;
GU_state_T = 5000; % Power received at each transformer
N_T = 1;
N_T_0 = N_T; % Intial number of working transformer
% For the solar generator
lambda_S = 5e-4; % Failure rate for the Solar Generator (h^{-1})
mu_S = 1.3e-2; % Repair rate for the Solar Generator (h^{-1})
N_S = 5; % Number of SG units
N_S_0 = N_S;  % Intial number of working SG units
GU_state_S = [8.25,24,40.5,56.25,72]; % States of the power genrated by each SG unit.
p_state_S = [.59,.13,.10,.08,.10]; % State probability of the power genrated by each SG unit
% For the wind generator
lambda_W = 5e-4; % Failure rate for the Wind Generator (h^{-1})
mu_W = 1.3e-2; % Repair rate for the Wind Generator (h^{-1})
N_W = 5; % Number of WG units
N_W_0 = N_W;  % Intial number of working WG units
GU_state_W = [2.85,36,69,100.5,133.5]; % States of the power genrated by each WG unit
% IMPORTANT NOTE: THE LAST ELEMENT OF p_state_W IS MADE SINCE THE ORIGINAL
% DATA IN LI AND ZIO (2012) IS WRONG.
p_state_W = [.39,.47,.12,.011,.009]; % State probability of the power genrated by each WG unit
% For the EV
GU_state_EV = [-125,0,125]; % States of the power genrated by the EV
p_state_EV = [.13,.83,.04]; % State probability of the power genrated by the EV
% For the load
% IMPORTANT NOTE: THE LAST ELEMENT OF p_state_load  IS MADE SINCE THE ORIGINAL
% DATA IN LI AND ZIO (2012) IS WRONG.
p_state_load = [.044,.137,.174,.131,.161,.124,.110,.088,.029,.002];
load_state = [2045,2408,2773,3136,3500,3864,4227,4591,4955,5318];
%% Simulate the system trajectory
N_YEAR = 1;
T = YEARLYHOUR*N_YEAR; % Evaluate 1 years
samplesize = 1e4;
ENS = zeros(samplesize,1); % Energy Not Supplied
LOL = zeros(samplesize,1); % Loss of Load
t_start = 0;
t_end = T;
for i = 1:samplesize
    fprintf('%d / %d\n',i,samplesize);
    [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
        N_S_0,N_S,lambda_S,mu_S,....
        N_W_0,N_W,lambda_W,mu_W,...
        GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
        load_state,p_state_load);
    ENS(i) = -1*(temp_M<0)*temp_M'; % calculate ENS
    LOL(i) = sum(temp_M<0); % calculate LOL
end
EENS = mean(ENS)/N_YEAR % calculate EENS, yearly
LOLE = mean(LOL)/N_YEAR % calculate LOL, yearly
toc
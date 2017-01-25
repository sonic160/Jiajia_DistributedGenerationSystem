% This is to simulate the process of the load, supply and margin in a given
% interval.
% Virsion history:
% 20170123, Created by ZZ
function [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
    N_S_0,N_S,lambda_S,mu_S,....
    N_W_0,N_W,lambda_W,mu_W,...
    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
    load_state,p_state_load)
% Simulate the available components
[temp_t,temp_n_working_T] = GenerateTrajectoryBDPointwise(t_start,t_end,N_T_0,N_T,lambda_T,mu_T); % Available transformers
[~,temp_n_working_S] = GenerateTrajectoryBDPointwise(t_start,t_end,N_S_0,N_S,lambda_S,mu_S); % Available SGs
[~,temp_n_working_W] = GenerateTrajectoryBDPointwise(t_start,t_end,N_W_0,N_W,lambda_W,mu_W); % Available WGs
% Simulate the GU for SG and WG
[~,temp_GU_S] = GenerateTrajectoryDGPointwise(t_start,t_end,GU_state_S,p_state_S); % GU for the SG
[~,temp_GU_W] = GenerateTrajectoryDGPointwise(t_start,t_end,GU_state_W,p_state_W); % GU for the WG
% Calculate the GU for the for sectors
temp_G_T = GU_state_T*temp_n_working_T;
temp_G_S = temp_GU_S.*temp_n_working_S;
temp_G_W = temp_GU_W.*temp_n_working_W;
[~,temp_G_EV] = GenerateTrajectoryDGPointwise(t_start,t_end,GU_state_EV,p_state_EV); % G for the EV
% Calculate the margin
temp_G = temp_G_T + temp_G_S + temp_G_W + temp_G_EV; % Sum the capacities
[~,temp_L] = GenerateTrajectoryDGPointwise(t_start,t_end,load_state,p_state_load); % Simulate load profile
% For storage
temp_M = temp_G-temp_L;
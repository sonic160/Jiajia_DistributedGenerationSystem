% This is the main function of the case study on the DG, based on Li and
% Zio (2012).
% Version history:
% 20170123b Modified by ZZ
% Changes:
% - Add how to calculate the PNS and PNS caused by disasters.
% 20170123, Modified by ZZ
% Changes:
% - The repair rates are modified to be dependent on the disasters, by
% introducting t_disaster, a vector of influence time of the disasters.
% 20170117, Modified by ZZ
% Changes: 
% - The units of failure and repair rates of the transformer is modified from h-1 to be y-1.
% - The model is modified to contain 5 transformers.
% 20170114, Created by ZZ
clear; clc
%% Data definitions
% For the transformer
lambda_T = 4e-3; % Failure rate for the transformer (y^{-1}), be careful, maybe Li and Zio (2012) made a mistake.
mu_T = 1.3e-2; % Repair rate for the transformer (y^{-1})
% Transform the rates into $h^{-1}$
YEARLYHOUR = 24*365;
lambda_T = lambda_T/YEARLYHOUR;
% mu_T = mu_T/YEARLYHOUR;
GU_state_T = 5000; % Power received at each transformer
N_T = 1;
% For the solar generator
lambda_S = 5e-4; % Failure rate for the Solar Generator (h^{-1})
mu_S = 1.3e-2; % Repair rate for the Solar Generator (h^{-1})
N_S = 5; % Number of SG units
GU_state_S = [8.25,24,40.5,56.25,72]; % States of the power genrated by each SG unit.
p_state_S = [.59,.13,.10,.08,.10]; % State probability of the power genrated by each SG unit
% For the wind generator
lambda_W = 5e-4; % Failure rate for the Wind Generator (h^{-1})
mu_W = 1.3e-2; % Repair rate for the Wind Generator (h^{-1})
N_W = 5; % Number of WG units
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
% For the natural disasters
lambda_CCF = [.001,.01,.1]; % Two disasters, rate in $y^{-1}$
% Transform the rates into $h^{-1}$
lambda_CCF = lambda_CCF/YEARLYHOUR;
%% Simulate the system trajectory
% Simulate the CCF caused by the natural disasters
T = YEARLYHOUR*30; % Evaluate 5 years
% Simulate the arrival times of the disasters
CCF = Generate_t_CCF(0,T,lambda_CCF);
t_CCF = ceil(CCF(1:end,1)); % Round to the floor
I_CCF = CCF(1:end,2);
n_CCF = length(t_CCF); % Get the number of natural disasters in the time interval consiered
% Set initial values for G, L and M
G = zeros(1,T+1);
L = zeros(1,T+1);
M = zeros(1,T+1);
% Simulate the trajectory piecewisely: conditioned on the disasters, the
% trajectory evolves 'smoothly', but 'jumps' at the time when the disasters
% arrive
if n_CCF < 3 % No CCF occurs
    for i = 1:n_CCF-1
        % Duration before the next disaster
        t_start = t_CCF(i);
        t_end = t_CCF(i+1);
        [N_T_0,N_S_0,N_W_0] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
        [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
            N_S_0,N_S,lambda_S,mu_S,....
            N_W_0,N_W,lambda_W,mu_W,...
            GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
            load_state,p_state_load); % Simulate the process of load, supply and margin
        G(t_start+1:t_end) = temp_G(1:end-1);
        L(t_start+1:t_end) = temp_L(1:end-1);
        M(t_start+1:t_end) = temp_M(1:end-1);
    end
else % At least one CCF
    for i = 1:n_CCF-1
        if i == 1 % The first period, before the CCF
            % Duration before the next disaster
            t_start = t_CCF(i);
            t_end = t_CCF(i+1);
            [N_T_0,N_S_0,N_W_0] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
            [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                N_S_0,N_S,lambda_S,mu_S,....
                N_W_0,N_W,lambda_W,mu_W,...
                GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                load_state,p_state_load); % Simulate the process of load, supply and margin
            G(t_start+1:t_end) = temp_G(1:end-1);
            L(t_start+1:t_end) = temp_L(1:end-1);
            M(t_start+1:t_end) = temp_M(1:end-1);
        else % Period after the CCF: for the first t_disaster, use the dependent repair rate
            % Duration before the next disaster
            t_start = t_CCF(i);
            temp_t_end = t_CCF(i+1);
            [N_T_0,N_S_0,N_W_0,t_disaster,mu_T_d,mu_S_d,mu_W_d] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
            t_end = t_start + t_disaster;
            if t_end > temp_t_end
                t_end = temp_t_end;
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                    N_S_0,N_S,lambda_S,mu_S,....
                    N_W_0,N_W,lambda_W,mu_W,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
            else
                % Affected process
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T_d,....
                    N_S_0,N_S,lambda_S,mu_S_d,....
                    N_W_0,N_W,lambda_W,mu_W_d,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
                % Normal process
                t_start = t_end;
                t_end = temp_t_end;
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                    N_S_0,N_S,lambda_S,mu_S,....
                    N_W_0,N_W,lambda_W,mu_W,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
            end
        end
    end    
end
% Store the last element
G(end) = temp_G(end);
L(end) = temp_L(end);
M(end) = temp_M(end);
%% Post processing
% Calculate Power Not Supplied (PNS)
PNS = (M<0)*M';
PNS_CCF = 0;
if n_CCF < 3 % No CCF occurs
    PNS_CCF = 0;
else
    for i = 1:n_CCF-1
        index = t_CCF(i)+1;
        for j = index:t_CCF(end)+1;
            if M(j)>-500
                temp_index = j;
                PNS_CCF = PNS_CCF + sum(M(index:temp_index-1));
                break;
            end    
        end
    end
end
% Figuring
t = 0:T;
figure
plot(t,M,'k-')
xlabel('t (h)')
ylabel('Margin (MW)')
figure
plot(t,G,'-b')
xlabel('t (h)')
ylabel('Supplied power (MW)')
figure
plot(t,L,'r-')
xlabel('t (h)')
ylabel('Load (MW)')
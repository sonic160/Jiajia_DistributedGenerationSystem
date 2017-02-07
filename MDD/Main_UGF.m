% This code reproduces Li and Zio (2012) using UGF methods.
% Version history:
% 20170206: Created by ZZ
clear;clc;tic;
%% Data definitions
YEARLYHOUR = 24*365;
% For the transformer
lambda_T = 4e-4; % Failure rate for the transformer (y^{-1}), be careful, maybe Li and Zio (2012) made a mistake.
mu_T = 1.3e-2; % Repair rate for the transformer (y^{-1})
p_steady_T = mu_T/(mu_T+lambda_T);
GU_state_T = 5000; % Power received at each transformer
N_T_state = [0,1]; % States of the transformer 
p_N_T_state = binopdf(N_T_state,N_T_state(end),p_steady_T);
% For the solar generator
lambda_S = 5e-4; % Failure rate for the Solar Generator (h^{-1})
mu_S = 1.3e-2; % Repair rate for the Solar Generator (h^{-1})
p_steady_S = mu_S/(mu_S+lambda_S);
N_S = 5; % Number of SG units
N_S_state = 0:N_S;
p_S_state = binopdf(N_S_state,N_S,p_steady_S);
GU_state_S = [8.25,24,40.5,56.25,72]; % States of the power genrated by each SG unit.
p_GU_state_S = [.59,.13,.10,.08,.10]; % State probability of the power genrated by each SG unit
% For the wind generator
lambda_W = 5e-4; % Failure rate for the Wind Generator (h^{-1})
mu_W = 1.3e-2; % Repair rate for the Wind Generator (h^{-1})
p_steady_W = mu_W/(mu_W+lambda_W);
N_W = 5; % Number of WG units
N_W_state = 0:N_W;
p_W_state = binopdf(N_W_state,N_W,p_steady_W);
GU_state_W = [2.85,36,69,100.5,133.5]; % States of the power genrated by each WG unit
% IMPORTANT NOTE: THE LAST ELEMENT OF p_state_W IS MADE SINCE THE ORIGINAL
% DATA IN LI AND ZIO (2012) IS WRONG.
p_GU_state_W = [.39,.47,.12,.011,.009]; % State probability of the power genrated by each WG unit
% For the EV
GU_state_EV = [-125,0,125]; % States of the power genrated by the EV
p_state_EV = [.13,.83,.04]; % State probability of the power genrated by the EV
% For the load
% IMPORTANT NOTE: THE LAST ELEMENT OF p_state_load  IS MADE SINCE THE ORIGINAL
% DATA IN LI AND ZIO (2012) IS WRONG.
p_state_load = [.044,.137,.174,.131,.161,.124,.110,.088,.029,.002];
load_state = [2045,2408,2773,3136,3500,3864,4227,4591,4955,5318];
%% State enumeration
% Alocate memory
StateNumber_N_T = length(N_T_state);
StateNumber_N_S = length(N_S_state);
StateNumber_N_W = length(N_W_state);
StateNumber_GU_state_S = length(GU_state_S);
StateNumber_GU_state_W = length(GU_state_W);
StateNumber_GU_state_EV = length(GU_state_EV);
StateNumber_load_state = length(load_state);
StateNumber_total = StateNumber_N_T*StateNumber_N_S*StateNumber_N_W*StateNumber_GU_state_S*StateNumber_GU_state_W*StateNumber_GU_state_EV*StateNumber_load_state;
M = zeros(StateNumber_total,1); % Total states for the margins
P_M = zeros(StateNumber_total,1); % Probabilities for each margin state
index = 0;
% Start enumeration
for a = 1:StateNumber_N_T
    N_T = N_T_state(a); % Value of N_T
    P_N_T = p_N_T_state(a); % the associated probability
    for b = 1:StateNumber_GU_state_EV
        GU_EV = GU_state_EV(b); % Value of GU_EV
        P_GU_EV = p_state_EV(b); % the associated probability
        for c = 1:StateNumber_GU_state_S
            GU_S = GU_state_S(c); % Value of GU_S
            P_GU_S = p_GU_state_S(c);  % the associated probability
            for d = 1:StateNumber_GU_state_W
                GU_W = GU_state_W(d); % Value of GU_W
                P_GU_W = p_GU_state_W(d); % the associated probability
                for f = 1:StateNumber_N_S
                    N_S = N_S_state(f); % Value of N_S
                    P_N_S = p_S_state(f);
                    for i = 1:StateNumber_N_W
                        N_W = N_W_state(i); % Value of N_W
                        P_N_W = p_W_state(i);
                        for j = 1:StateNumber_load_state
                            L = load_state(j); % Value of the load
                            P_L = p_state_load(j);
                            % Calculate the index
                            index = index +1;
%                             fprintf('%d / %d\n',index,StateNumber_total);
                            M(index) = N_T*GU_state_T + N_S*GU_S + N_W*GU_W + GU_EV - L;
                            P_M(index) = P_N_T*P_GU_EV*P_GU_S*P_GU_W*P_N_S*P_N_W*P_L;
                        end
                    end
                end
            end
        end
    end
end
toc;
EENS = -transpose(M<0)*(M.*P_M)*YEARLYHOUR % calculate EENG, yearly
LOLE = transpose(M<0)*P_M*YEARLYHOUR % calculate LOLE, yearly
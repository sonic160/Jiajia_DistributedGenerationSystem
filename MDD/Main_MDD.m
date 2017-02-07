% This is the main function of the MC for the distributed generated system.
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
M_negative = zeros(StateNumber_total,1); % Total states for the margins
P_M_negtive = zeros(StateNumber_total,1); % Probabilities for each margin state
index = 0;
% Start enumeration
M_parent_0 = 0;
count_add = 0;
count_multiply = 0;
for a = 1:StateNumber_N_T
    N_T = N_T_state(a); % Value of N_T
    P_N_T = p_N_T_state(a); % the associated probability
    for b = 1:StateNumber_load_state
        L_cur = load_state(b); % Value of the load
        M_cur = M_parent_0 + GU_state_T*N_T - L_cur;
        count_add = count_add + 2;
        count_multiply = count_multiply + 1;
        M_parent_1 = M_cur;
        for i = 1:StateNumber_GU_state_EV
            GU_EV = GU_state_EV(i); % Value of GU_EV
            P_GU_EV = p_state_EV(i); % the associated probability
            M_cur = M_parent_1 + GU_EV;
            count_add = count_add + 1;
            if M_cur > 0
                continue;
            else
                P_L = p_state_load(b);
                M_parent_2 = M_cur;
                for c = 1:StateNumber_N_S
                    N_S = N_S_state(c); % Value of N_S
                    P_N_S = p_S_state(c);
                    for d = 1:StateNumber_GU_state_S
                        GU_S = GU_state_S(d); % Value of GU_S
                        P_GU_S = p_GU_state_S(d);  % the associated probability
                        M_cur = M_parent_2 + GU_S*N_S;
                        count_add = count_add + 1;
                        count_multiply = count_multiply + 1;
                        if M_cur > 0
                            continue;
                        else
                            M_parent_3 = M_cur;
                            for e = 1:StateNumber_N_W
                                N_W = N_W_state(e); % Value of N_W
                                P_N_W = p_W_state(e);
                                for f = 1:StateNumber_GU_state_W
                                    GU_W = GU_state_W(f); % Value of GU_W
                                    P_GU_W = p_GU_state_W(f); % the associated probability
                                    M_cur = M_parent_3 + GU_W*N_W;
                                    count_add = count_add + 1;
                                    count_multiply = count_multiply + 1;
                                    if M_cur > 0
                                        continue;
                                    else
                                        index = index +1;
                                        M_negative(index) = M_cur;
                                        P_M_negtive(index) = P_N_T*P_GU_EV*P_GU_S*P_GU_W*P_N_S*P_N_W*P_L;
                                        count_multiply = count_multiply + 6;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
toc;
EENS = -transpose(M_negative<0)*(M_negative.*P_M_negtive)*YEARLYHOUR % calculate EENG, yearly
LOLE = transpose(M_negative<0)*P_M_negtive*YEARLYHOUR % calculate LOLE, yearly
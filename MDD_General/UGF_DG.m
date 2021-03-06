function [EENS,LOLE] = UGF_DG(p_steady_T,p_steady_S,p_steady_W)
%% Data definitions
% For the transformer
GU_state_T = 5000; % Power received at each transformer
N_T_state = [0,1]; % States of the transformer 
p_N_T_state = binopdf(N_T_state,N_T_state(end),p_steady_T);
% For the solar generator
N_S = 5; % Number of SG units
N_S_state = 0:N_S;
p_S_state = binopdf(N_S_state,N_S,p_steady_S);
GU_state_S = [8.25,24,40.5,56.25,72]; % States of the power genrated by each SG unit.
p_GU_state_S = [.59,.13,.10,.08,.10]; % State probability of the power genrated by each SG unit
% For the wind generator
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
%% Alocate memory
StateNumber_N_T = length(N_T_state);
StateNumber_N_S = length(N_S_state);
StateNumber_N_W = length(N_W_state);
StateNumber_GU_state_S = length(GU_state_S);
StateNumber_GU_state_W = length(GU_state_W);
StateNumber_GU_state_EV = length(GU_state_EV);
StateNumber_load_state = length(load_state);
%% MDD calculation
% Cal M_cur = G_T - L, using MDD
% MDD for GU_T
node_G_T.n = StateNumber_N_T;
node_G_T.value = N_T_state*GU_state_T;
node_G_T.p = p_N_T_state;
% MDD for load
node_L.n = StateNumber_load_state;
[node_L.value,I_L] = sort(-load_state);
node_L.p = p_state_load(I_L);
% Calculate the MDD for M_cur
node_M_cur = NodeAddReduce(node_G_T,node_L);
% MDD of G_EV
node_G_EV.n = StateNumber_GU_state_EV;
node_G_EV.value = GU_state_EV;
node_G_EV.p = p_state_EV;
% Calculate the MDD for M_cur, adding EV
node_M_cur = NodeAddReduce(node_M_cur,node_G_EV);
% MDD of GU_S
node_GU_S.n = StateNumber_GU_state_S;
node_GU_S.value = GU_state_S;
node_GU_S.p = p_GU_state_S;
% MDD of N_S
node_N_S.n = StateNumber_N_S;
node_N_S.value = N_S_state;
node_N_S.p = p_S_state;
% Calulate MDD of GS = N_S*GU_S
node_GS = NodeMulReduce(node_N_S,node_GU_S);
% Calculate MDD of M_cur, adding GS
node_M_cur = NodeAddReduce(node_M_cur,node_GS);
% MDD of N_W
node_N_W.n = StateNumber_N_W;
node_N_W.value = N_W_state;
node_N_W.p = p_W_state;
% MDD of GU_W
node_GU_W.n = StateNumber_GU_state_W;
node_GU_W.value = GU_state_W;
node_GU_W.p = p_GU_state_W;
% Calculate MDD of GW
node_GW = NodeMulReduce(node_N_W,node_GU_W);
% Calculate MDD of M_cur, adding GW
node_M_cur = NodeAddReduce(node_M_cur,node_GW);
%% Calculate EENS and LOLE
M_negative = node_M_cur.value; % Total states for the margins
P_M_negtive = node_M_cur.p; % Probabilities for each margin state
EENS = -1*(M_negative<0)*transpose(M_negative.*P_M_negtive); % calculate EENG, yearly
LOLE = (M_negative<0)*P_M_negtive'; % calculate LOLE, yearly
end

function node_out = NodeAddReduce(node_P,node_C)
node_out = NodeAdd(node_P,node_C);
node_out = NodeRemoveRep(node_out);
end

function node_out = NodeMulReduce(node_P,node_C)
node_out = NodeMul(node_P,node_C);
node_out = NodeRemoveRep(node_out);
end
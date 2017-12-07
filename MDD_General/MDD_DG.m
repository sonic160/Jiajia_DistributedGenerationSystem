function [EENS,LOLE] = MDD_DG(p_steady_T,p_steady_S,p_steady_W)
EENS = [0,0];
LOLE = [0,0];
v_th_margin = 0;
v_group_margin = 0;
v_th_EG = 5e-2;
v_group_EG_L = 0;
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
node_M_cur = NodeAdd(node_G_T,node_L);
node_M_cur = NodeRemoveRep(node_M_cur);
% MDD of G_EV
node_G_EV.n = StateNumber_GU_state_EV;
node_G_EV.value = GU_state_EV;
node_G_EV.p = p_state_EV;
% Calculate the MDD for M_cur, adding EV
node_M_cur = NodeAddReduce(node_M_cur,node_G_EV,v_th_margin,v_group_margin);
% MDD of GU_S
node_GU_S.n = StateNumber_GU_state_S;
node_GU_S.value = GU_state_S;
node_GU_S.p = p_GU_state_S;
% MDD of N_S
node_N_S.n = StateNumber_N_S;
node_N_S.value = N_S_state;
node_N_S.p = p_S_state;
%% Upper bound for EENS and LOLE
% Calulate MDD of GS = N_S*GU_S
node_GS = NodeMulReduce(node_N_S,node_GU_S,v_th_EG,v_group_EG_L);
% Calculate MDD of M_cur, adding GS
node_M_cur_L = NodeAddReduce(node_M_cur,node_GS,v_th_margin,v_group_margin);
% MDD of N_W
node_N_W.n = StateNumber_N_W;
node_N_W.value = N_W_state;
node_N_W.p = p_W_state;
% MDD of GU_W
node_GU_W.n = StateNumber_GU_state_W;
node_GU_W.value = GU_state_W;
node_GU_W.p = p_GU_state_W;
% Calculate MDD of GW
node_GW = NodeMulReduce(node_N_W,node_GU_W,v_th_EG,v_group_EG_L);
% Calculate MDD of M_cur, adding GW
node_M_cur_L = NodeAddReduce(node_M_cur_L,node_GW,v_th_margin,v_group_margin);
% Calculate EENS and LOLE
M_negative = node_M_cur_L.value; % Total states for the margins
P_M_negtive = node_M_cur_L.p; % Probabilities for each margin state
EENS(1) = -1*(M_negative<0)*transpose(M_negative.*P_M_negtive); % calculate EENG, yearly
LOLE(1) = (M_negative<0)*P_M_negtive'; % calculate LOLE, yearly
%% Lower bound for EENS and LOLE
% Calulate MDD of GS = N_S*GU_S
node_GS = NodeMul(node_N_S,node_GU_S);
node_GS = NodeJudgement_p_U(node_GS,v_th_EG);
node_GS = NodeRemoveRep(node_GS);
% Calculate MDD of M_cur, adding GS
node_M_cur_U = NodeAddReduce(node_M_cur,node_GS,v_th_margin,v_group_margin);
% Calculate MDD of GW
node_GW = NodeMul(node_N_W,node_GU_W);
node_GW = NodeJudgement_p_U(node_GW,v_th_EG);
node_GW = NodeRemoveRep(node_GW);
% Calculate MDD of M_cur, adding GW
node_M_cur_U = NodeAddReduce(node_M_cur_U,node_GW,v_th_margin,v_group_margin);
% Calculate EENS and LOLE
M_negative = node_M_cur_U.value; % Total states for the margins
P_M_negtive = node_M_cur_U.p; % Probabilities for each margin state
EENS(2) = -1*(M_negative<0)*transpose(M_negative.*P_M_negtive); % calculate EENG, yearly
LOLE(2) = (M_negative<0)*P_M_negtive'; % calculate LOLE, yearly
end

function node_out = NodeAddReduce(node_P,node_C,v_th,v_group)
node_out = NodeAdd(node_P,node_C);
node_out = NodeJudgement_value(node_out,v_th,v_group);
node_out = NodeRemoveRep(node_out);
end

function node_out = NodeMulReduce(node_P,node_C,v_th,v_group)
node_out = NodeMul(node_P,node_C);
node_out = NodeJudgement_p(node_out,v_th,v_group);
node_out = NodeRemoveRep(node_out);
end

% handle_criterion: return 1, when we need to keep this branch
function node_out = NodeJudgement_p_U(node_in,v_th_EG)
node_out = node_in;
value = node_in.value;
p = node_in.p;
index = 0;
I = zeros(node_out.n,1);
for i = 1: node_in.n
    if  p(i) - v_th_EG > 0
        continue;
    else
        index = index +1;
        I(index) = i;
    end
end
I = I(1:index);
value_group = max(value(I));
% value_group = sum(value(I).*p(I))/sum(p(I));
value(I) = value_group;
node_out.value = value;
% Sort value_out in ascending order, and adjust p_out accordingly
[value,I] = sort(value);
p_out = p(I);
% Record the output node
node_out.value = value;
node_out.p = p_out;
end

% handle_criterion: return 1, when we need to keep this branch
function node_out = NodeJudgement_p(node_in,v_th,value_group)
node_out = node_in;
value = node_in.value;
p = node_in.p;
value_out = value;
for i = 1: node_in.n
    if p(i) - v_th > 0
        continue;
    else
        value_out(i) = value_group;
    end
end
% Sort value_out in ascending order, and adjust p_out accordingly
[value_out,I] = sort(value_out);
p_out = p(I);
% Record the output node
node_out.value = value_out;
node_out.p = p_out;
end

% handle_criterion: return 1, when we need to keep this branch
function node_out = NodeJudgement_value(node_in,v_th,value_group)
node_out = node_in;
value = node_in.value;
value_out = value;
p_out = node_in.p;
for i = 1: node_in.n
    if value(i) - v_th < 0
        continue;
    else
        value_out(i) = value_group;
    end
end
% Sort value_out in ascending order, and adjust p_out accordingly
[value_out,I] = sort(value_out);
p_out = p_out(I);
% Record the output node
node_out.value = value_out;
node_out.p = p_out;
end


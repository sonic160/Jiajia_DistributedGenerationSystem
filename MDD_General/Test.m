clear; clc;
%% Test case 1
% % Define parent node
% node_P.n = 2;
% node_P.value = [1,2];
% node_P.p = [.6,.4];
% % Define child node
% node_C.n = 2;
% node_C.value = [2,1];
% node_C.p = [.3,.7];
% node_out_Mul = NodeMul(node_P,node_C);
% node_out_Add = NodeAdd(node_P,node_C);
%% Test case 2
% Define parent node
node_P.n = 3;
node_P.value = [0,1,2];
node_P.p = [.2,.2,.6];
% Define child node
node_C.n = 4;
node_C.value = [1,2,3,4];
node_C.p = [.2,.3,.3,.2];
node_out_Mul = NodeMul(node_P,node_C);
node_out_Add = NodeAdd(node_P,node_C);
% node_out_Add = NodeJudgement_value(node_out_Add,5);
node_out_Add = NodeRemoveRep(node_out_Add);
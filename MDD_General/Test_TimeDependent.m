clear; clc; 
%% Data definitions
% For the transformer
lambda_T = 4e-4; % Failure rate for the transformer (y^{-1}), be careful, maybe Li and Zio (2012) made a mistake.
mu_T = 1.3e-2; % Repair rate for the transformer (y^{-1})
% For the solar generator
lambda_S = 5e-4; % Failure rate for the Solar Generator (h^{-1})
mu_S = 1.3e-2; % Repair rate for the Solar Generator (h^{-1})
% For the wind generator
lambda_W = 5e-4; % Failure rate for the Wind Generator (h^{-1})
mu_W = 1.3e-2; % Repair rate for the Wind Generator (h^{-1})
p_steady_W = mu_W/(mu_W+lambda_W);
% Calculate the probabilities
T = 24*365;
t = 1:T;
p_T = mu_T/(mu_T+lambda_T)+lambda_T/(mu_T+lambda_T)*exp(-1*(mu_T+lambda_T).*t);
p_S = mu_S/(mu_S+lambda_S)+lambda_S/(mu_S+lambda_S)*exp(-1*(mu_S+lambda_S).*t);
p_W = mu_W/(mu_W+lambda_W)+lambda_W/(mu_W+lambda_W)*exp(-1*(mu_W+lambda_W).*t);
%% Run simulation
EENS_UGF = 0;
LOLE_UGF = 0;
tic;
for i = 1:T
    fprintf('%d/%d\n',i,T+1)
    [temp_EENS,temp_LOLE] = DirectEnumeration(p_T(i),p_S(i),p_W(i));
    EENS_UGF = EENS_UGF + temp_EENS;
    LOLE_UGF = LOLE_UGF + temp_LOLE;
end
T_UGF = toc;
tic;
EENS_MDD = 0;
LOLE_MDD = 0;
for i = 1:T
    fprintf('%d/%d\n',i,T)
    [temp_EENS,temp_LOLE] = MDD_DG(p_T(i),p_S(i),p_W(i));
    EENS_MDD = EENS_MDD + temp_EENS;
    LOLE_MDD = LOLE_MDD + temp_LOLE;
end
T_MDD = toc;
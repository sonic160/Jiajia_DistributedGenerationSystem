clear; clc;
%% Data definitions
% For the transformer
lambda_T = 4e-4; % Failure rate for the transformer (y^{-1}), be careful, maybe Li and Zio (2012) made a mistake.
mu_T = 1.3e-2; % Repair rate for the transformer (y^{-1})
p_steady_T = mu_T/(mu_T+lambda_T);
% For the solar generator
lambda_S = 5e-4; % Failure rate for the Solar Generator (h^{-1})
mu_S = 1.3e-2; % Repair rate for the Solar Generator (h^{-1})
p_steady_S = mu_S/(mu_S+lambda_S);
% For the wind generator
lambda_W = 5e-4; % Failure rate for the Wind Generator (h^{-1})
mu_W = 1.3e-2; % Repair rate for the Wind Generator (h^{-1})
p_steady_W = mu_W/(mu_W+lambda_W);
%% Run simulation
[EENS,LOLE] = UGF(p_steady_T,p_steady_S,p_steady_W)
[EENS,LOLE] = MDD(p_steady_T,p_steady_S,p_steady_W)
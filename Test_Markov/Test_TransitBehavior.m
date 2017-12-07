% This is to investigate the transit behaviors of the components
clear; clc;
lambda_T = 4e-4;
mu_T = 1.3e-2;
t = linspace(0,8376,1e3);
A = mu_T/(mu_T+lambda_T)+lambda_T/(mu_T+lambda_T)*exp(-1*(mu_T+lambda_T).*t);
figure
plot(t,A);
lambda_S = 5e-4;
mu_S = 1.3e-2;
A = mu_S/(mu_S+lambda_S)+lambda_S/(mu_S+lambda_S)*exp(-1*(mu_S+lambda_S).*t);
figure
plot(t,A);

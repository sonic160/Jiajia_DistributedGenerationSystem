% This is to evaluate the damage caused by the disasters
% History:
% 20170123 - Modified by ZZ
% Changes: Add t_damage to model the dependece of repair rates on
% disasters.
% 20170118 - Modified by ZZ
% Changes: Modified to model the 5-transformer system
% 20170113 - Created by ZZ
function [N_T_0,N_S_0,N_W_0,t_disaster,mu_T_d,mu_S_d,mu_W_d] = Damage(I_CCF,mu_T,mu_S,mu_W)
N_T_0 = 1;
N_S_0 = 5;
N_W_0 = 5;
t_disaster = 0;
mu_T_d = mu_T;
mu_S_d = mu_S;
mu_W_d = mu_W;
switch I_CCF
    case 1 % The most severe disaster
        N_T_0 = 0;
        N_S_0 = 0;
        N_W_0 = 0;
        t_disaster = 30*24; % Influece of one week
        mu_T_d = mu_T/10;
        mu_S_d = mu_S/10;
        mu_W_d = mu_W/10;
    case 2 % Medium severity
        N_T_0 = 0;
        N_S_0 = 1;
        N_W_0 = 1;
        t_disaster = 15*24; % Influece of 3 days
        mu_T_d = mu_T/5;
        mu_S_d = mu_S/5;
        mu_W_d = mu_W/5;
    case 3 % The lowest severity
        N_T_0 = 0;
        N_S_0 = 3;
        N_W_0 = 3;
        t_disaster = 7*24; % Influece of one day
        mu_T_d = mu_T/5;
        mu_S_d = mu_S/5;
        mu_W_d = mu_W/5;
    otherwise % Default: I_CCF = 0: the initial moment
        return;
end
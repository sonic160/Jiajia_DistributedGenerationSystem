% This is the main function of the MC for the distributed generated system.
% Version history:
% 20170123: Created by ZZ
clear; clc;tic;
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
%% Monte Carlo
samplesize = 3e3;
PNS = zeros(samplesize,1);
PNS_CCF = zeros(samplesize,1);
for i = 1:samplesize
    disp([num2str(i) '/' num2str(samplesize) 'th iterations'])
    [G,L,M] = Simulate_MC(T,n_CCF,t_CCF,I_CCF,mu_T,mu_S,mu_W,...
        N_T,lambda_T,N_S,lambda_S,N_W,lambda_W,GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
        load_state,p_state_load);
    temp_PNS = (M<0)*M';
    temp_PNS_CCF = 0;
    if n_CCF < 3 % No CCF occurs
        temp_PNS_CCF = 0;
    else
        for j = 1:n_CCF-1
            index = t_CCF(j)+1;
            for k = index:t_CCF(end)+1;
                if M(k)>-500
                    temp_index = k;
                    temp_PNS_CCF = temp_PNS_CCF + sum(M(index:temp_index-1));
                    break;
                end    
            end
        end
    end
    PNS(i) = temp_PNS;
    PNS_CCF(i) = temp_PNS_CCF;
end
EENS = PNS/T;
EENS_CCF = PNS_CCF/T;
EENS_Normal = EENS - EENS_CCF;
figure 
h1 = histogram(EENS);
hold on
h2 = histogram(EENS_Normal);
xlabel('EENS (kW/h)')
ylabel('Counts')
legend('Developed methods','Without disruptive events')
toc
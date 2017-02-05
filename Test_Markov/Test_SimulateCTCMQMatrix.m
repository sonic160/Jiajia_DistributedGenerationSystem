% This is to test how to simulate a CTMC using Q matrix
% Test case: labmda = .1, mu = .2, test availability
clear; clc;
S = [1,2,3]; % state space
pi = [1,0,0]; % initial distribution
lambda = .1;
mu = 1;
n_t = 10;
time = linspace(0,15,n_t);
P_1_sim = zeros(size(time));
P_2_sim = zeros(size(time));
P_3_sim = zeros(size(time));
%% Simulate system availability
Q = [-2*lambda,2*lambda,0;...
    mu,-(mu+lambda),lambda;...
    0,2*mu,-2*mu];
[a,P] = CalculatePEmbedded(Q);
NS = 5e5;
for j = 1:n_t
    count_1 = 0;
    count_2 = 0;
    count_3 = 0;
    fprintf('%d / %d interations\n',j,n_t);
    for i = 1:NS
        [t,y] = SimulateCTMCEmbedded(a,P,pi,time(j));
        if y(end) == 1  
            count_1 = count_1 + 1;
        else if y(end) == 2
                count_2 = count_2 + 1;
            else
                count_3 = count_3 + 1;
            end
        end
    end
    P_1_sim(j) = count_1/NS;
    P_2_sim(j) = count_2/NS;
    P_3_sim(j) = count_3/NS;
end
%% Calculate sys aval using component avai
A_comp = mu/(mu+lambda)+lambda/(mu+lambda)*exp(-1*(mu+lambda).*time);
P_1 = A_comp.*A_comp;
P_2 = 2*A_comp.*(1-A_comp);
P_3 = (1-A_comp).^2;
figure
subplot(1,3,1)
plot(time,P_1,'k-d',time,P_1_sim,'r-o')
subplot(1,3,2)
plot(time,P_2,'k-d',time,P_2_sim,'r-o')
subplot(1,3,3)
plot(time,P_3,'k-d',time,P_3_sim,'r-o')
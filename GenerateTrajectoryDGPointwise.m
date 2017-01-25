% This is to simulate a trajectory of a the power generated by each DG in
% [t_start, t_end)
% Outputs: t - t measured at a pointwise scale.
%          GU - Power generation for a single DG at each t.
% Version history: 20170112, Created by ZZ
function [t,GU] = GenerateTrajectoryDGPointwise(t_start,t_end,state,p)
t = t_start:t_end; % Pointwised time
GU = zeros(size(t));
n_t = length(t);
cum_p = cumsum(p);
for i = 1:n_t
    u = rand;
    inx = find((u-cum_p)<0,1,'first');
    GU(i) = state(inx);
end
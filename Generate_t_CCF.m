% This is to simulate a series of CCF in [0,T], each CCF is characterized
% by its rate $\lambda_i$.
% Output: t_CCF: a vector, [0,t_CCF_1, \cdots, t_CCF_2, T]
% Version history: 20170113, Created by ZZ
function CCF = Generate_t_CCF(t_start,t_end,lambda_CCF)
n_CCFEvent = length(lambda_CCF); % Number of CCF events
t = t_start; % t is the 'current time';
i = 1; % Index of the arrived CCF event
CCF = [t_start,0]; % The first element in CCF: t=t_start, index of the event: 0
t_next_CCF = zeros(n_CCFEvent,1); % Initial values for the time of the next CCFs
while 1
    for j = 1:n_CCFEvent % Generate the next attack times for all the CCF events
        t_next_CCF(j) = GenerateNextEvent(t,lambda_CCF(j));
    end
    [t,I] = min(t_next_CCF); % Choose whatever happens first
    if t < t_end % Continue iteration
        % Record the event and continue
        i = i + 1;
        CCF(i,1:end) = [t,I];
    else % End the function
        i = i + 1; 
        CCF(i,1:end) = [t_end,0];
        return;
    end            
end

% This is to simulate the occurrence time of the jth CCF event, in absolute time scale.
function t_next_event = GenerateNextEvent(t_start,lambda)
t_next = exprnd(1/lambda); % Event time: relative scale
t_next_event = t_start + t_next; % Absolute scale

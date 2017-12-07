% This is to simulate a trajectory of a pure birth and death process in
% [t_start, t_end)
% Outputs: t - t measured at a pointwise scale.
%          state - state at each t.
% Version history: 20170112, Created by ZZ
function [t,state] = GenerateTrajectoryBDPointwise(t_start,t_end,state_t_start,state_norm,lambda,mu)
t = t_start:t_end; % Pointwised time
state = zeros(size(t)); % Initial values for the states
state_trajectory = GenerateTrajectoryBD(t_start,t_end,state_t_start,state_norm,lambda,mu); % Generate the jump time and values
t_jump = state_trajectory(:,1);
state_jump = state_trajectory(:,2);
n = length(t_jump); % Number of jumps
for i = 1:n-1
    index_L = floor(t_jump(i))-t_start+1;
    index_H = floor(t_jump(i+1))-t_start;
    state(index_L:index_H) = state_jump(i);
end
state(end) = state_jump(end);

%% This is to simulate a trajectory of a pure birth and death process in
% [t_start, t_end)
% Output: state_trajectory is a matrix of [t_jump,state_jump], where t_jump
% is the time of the event, while state_jump is the state after the event.
% The first row of state_trajectory is always [t_start,state_t_start] and
% last row always [t_end,state at t_end]
% Version history: 20170112, Created by ZZ
function state_trajectory = GenerateTrajectoryBD(t_start,t_end,state_t_start,state_norm,lambda,mu)
t = t_start; % t is the 'current time';
state_cur = state_t_start; % Current state
state_trajectory = [t_start,state_cur]; % Initial states
i = 1; % Index of the current event
while 1
    if state_cur == state_norm % For the highest state: directly simulate failure time
        t = GenerateNextEvent(t,lambda); % Generate next failure
        if t < t_end % Continue iteration
            % Record the event and continue
            i = i + 1; 
            state_cur = state_cur - 1; 
            state_trajectory(i,1:2) = [t,state_cur];
        else % End the function
            i = i + 1; 
            state_trajectory(i,1:2) = [t_end,state_cur];
            return
        end
    else if state_cur == 0 % For the lowest state: directly simulate repaire time
            t = GenerateNextEvent(t,mu); % Generate next repair
            if t < t_end % Continue iteration
                % Record the event and continue
                i = i + 1; 
                state_cur = state_cur + 1;
                state_trajectory(i,1:2) = [t,state_cur];
            else % End the function
                i = i + 1; 
                state_trajectory(i,1:2) = [t_end,state_cur];
                return;
            end
        else % Simulate failure and repaire time, and then use the one that occurs first
            t_f = GenerateNextEvent(t,lambda); % Generate next failure
            t_r = GenerateNextEvent(t,mu); % Generate next repair
            t = min(t_f,t_r); % Choose whatever happens first
            if t < t_end % Continue iteration
                if t == t_f % failure occurs first
                    % Record the event and continue
                    i = i + 1; 
                    state_cur = state_cur - 1;
                    state_trajectory(i,1:2) = [t,state_cur];                    
                else % repair occurs first
                    i = i + 1; 
                    state_cur = state_cur + 1;
                    state_trajectory(i,1:2) = [t,state_cur];                       
                end
            else % End the function
                i = i + 1; 
                state_trajectory(i,1:2) = [t_end,state_cur];
                return;
            end            
        end
    end
end

% This is to simulate the occurrence time of the next event
% (failure/repair), in absolute time scale.
function t_next_event = GenerateNextEvent(t_start,lambda)
t_next = exprnd(1/lambda); % Event time: relative scale
t_next_event = t_start + t_next; % Absolute scale
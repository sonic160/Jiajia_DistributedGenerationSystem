% This is the subfunc for evaluate the G,L and M at each iteration of MC.
% Version history:
% 20170123: Created by ZZ
function [G,L,M] = Simulate_MC(T,n_CCF,t_CCF,I_CCF,mu_T,mu_S,mu_W,...
    N_T,lambda_T,N_S,lambda_S,N_W,lambda_W,GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
    load_state,p_state_load)
% Set initial values for G, L and M
G = zeros(1,T+1);
L = zeros(1,T+1);
M = zeros(1,T+1);
% Simulate the trajectory piecewisely: conditioned on the disasters, the
% trajectory evolves 'smoothly', but 'jumps' at the time when the disasters
% arrive
if n_CCF < 3 % No CCF occurs
    for i = 1:n_CCF-1
        % Duration before the next disaster
        t_start = t_CCF(i);
        t_end = t_CCF(i+1);
        [N_T_0,N_S_0,N_W_0] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
        [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
            N_S_0,N_S,lambda_S,mu_S,....
            N_W_0,N_W,lambda_W,mu_W,...
            GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
            load_state,p_state_load); % Simulate the process of load, supply and margin
        G(t_start+1:t_end) = temp_G(1:end-1);
        L(t_start+1:t_end) = temp_L(1:end-1);
        M(t_start+1:t_end) = temp_M(1:end-1);
    end
else % At least one CCF
    for i = 1:n_CCF-1
        if i == 1 % The first period, before the CCF
            % Duration before the next disaster
            t_start = t_CCF(i);
            t_end = t_CCF(i+1);
            [N_T_0,N_S_0,N_W_0] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
            [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                N_S_0,N_S,lambda_S,mu_S,....
                N_W_0,N_W,lambda_W,mu_W,...
                GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                load_state,p_state_load); % Simulate the process of load, supply and margin
            G(t_start+1:t_end) = temp_G(1:end-1);
            L(t_start+1:t_end) = temp_L(1:end-1);
            M(t_start+1:t_end) = temp_M(1:end-1);
        else % Period after the CCF: for the first t_disaster, use the dependent repair rate
            % Duration before the next disaster
            t_start = t_CCF(i);
            temp_t_end = t_CCF(i+1);
            [N_T_0,N_S_0,N_W_0,t_disaster,mu_T_d,mu_S_d,mu_W_d] = Damage(I_CCF(i),mu_T,mu_S,mu_W);
            t_end = t_start + t_disaster;
            if t_end > temp_t_end
                t_end = temp_t_end;
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                    N_S_0,N_S,lambda_S,mu_S,....
                    N_W_0,N_W,lambda_W,mu_W,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
            else
                % Affected process
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T_d,....
                    N_S_0,N_S,lambda_S,mu_S_d,....
                    N_W_0,N_W,lambda_W,mu_W_d,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
                % Normal process
                t_start = t_end;
                t_end = temp_t_end;
                [temp_G,temp_L,temp_M] = SimulateGLM(t_start,t_end,N_T_0,N_T,lambda_T,mu_T,....
                    N_S_0,N_S,lambda_S,mu_S,....
                    N_W_0,N_W,lambda_W,mu_W,...
                    GU_state_T,GU_state_S,p_state_S,GU_state_W,p_state_W,GU_state_EV,p_state_EV,...
                    load_state,p_state_load); % Simulate the process of load, supply and margin
                G(t_start+1:t_end) = temp_G(1:end-1);
                L(t_start+1:t_end) = temp_L(1:end-1);
                M(t_start+1:t_end) = temp_M(1:end-1);
            end
        end
    end    
end
% Store the last element
G(end) = temp_G(end);
L(end) = temp_L(end);
M(end) = temp_M(end);
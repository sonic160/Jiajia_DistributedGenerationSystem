function node_out = NodeAdd(node_P,node_C,v_judge,p_cutoff)
switch nargin 
    case 2 % if no judgement nodes nor cutoff is considered
        node_out = NodeAddOriginal(node_P,node_C);
    case 3 % if there are judgement nodes but no cutoff probabilities
        node_out = NodeAddJudgement(node_P,node_C,v_judge);
    case 4 % both are considered
        
    otherwise % return error
        error('Input error');
end

%% Consider judgement nodes: when value_cur >= v_judge, drop the current branch
function node_out = NodeAddJudgement(node_P,node_C,v_judge)
% Parameter definitions
n_P = node_P.n; % Number of branches of the parent node
value_P = node_P.value; % Values of each branch
p_P = node_P.p; % Probability of each branch
n_C = node_C.n; % Number of branches of the child node
value_C = node_C.value; % Values of each branch
p_C = node_C.p; % Probability of each branch
% Allocate initial memory for the output node
n_out = n_P*n_C;
value_out = zeros(1,n_out); % row vector
p_out = zeros(1,n_out); % row vector
index = 0; % record the actual number of branches in the output node, after combining repetive branches
% Construct the output node
for i = 1:n_P % loop for each branch of the parent node
    value_cur_P = value_P(i);
    p_cur_P = p_P(i);
    if IsStop(value_cur_P,v_judge) == 1
        continue;
    end
    for j = 1:n_C % loop for the child node
        value_cur = value_cur_P+value_C(j); % candidate value for the output branch
        if IsStop(value_cur,v_judge) == 1
            continue;
        end
        p_cur =  p_cur_P*p_C(j);
        [flag,index_rep] = IsRepetive(value_cur,value_out,index);
        if flag == 1
            p_out(index_rep) = p_out(index_rep) + p_cur; % accumulate the corresponding probability
        else
            index = index + 1;
            p_out(index) = p_cur;
            value_out(index) = value_cur;
        end
    end
end
% Record the output node
node_out.n = index;
node_out.value = value_out(1:index);
node_out.p = p_out(1:index);
return;

%% Original operation: no judgement nodes nor cutoff
function node_out = NodeAddOriginal(node_P,node_C)
% Parameter definitions
n_P = node_P.n; % Number of branches of the parent node
value_P = node_P.value; % Values of each branch
p_P = node_P.p; % Probability of each branch
n_C = node_C.n; % Number of branches of the child node
value_C = node_C.value; % Values of each branch
p_C = node_C.p; % Probability of each branch
% Allocate initial memory for the output node
n_out = n_P*n_C;
value_out = zeros(1,n_out); % row vector
p_out = zeros(1,n_out); % row vector
index = 0; % record the actual number of branches in the output node, after combining repetive branches
% Construct the output node
for i = 1:n_P % loop for each branch of the parent node
    value_cur_P = value_P(i);
    p_cur_P = p_P(i);
    for j = 1:n_C % loop for the child node
        value_cur = value_cur_P+value_C(j); % candidate value for the output branch
        p_cur =  p_cur_P*p_C(j);
        [flag,index_rep] = IsRepetive(value_cur,value_out,index);
        if flag == 1
            p_out(index_rep) = p_out(index_rep) + p_cur; % accumulate the corresponding probability
        else
            index = index + 1;
            p_out(index) = p_cur;
            value_out(index) = value_cur;
        end
    end
end
% Record the output node
node_out.n = index;
node_out.value = value_out(1:index);
node_out.p = p_out(1:index);
return;

%% Test if the output branch is repetive
function [flag,index_rep] = IsRepetive(value_cur,value_out,index)
flag = 0;
index_rep = 0;
if index == 0 % if no branch is recorded
    flag = 0;
else
    for k = index:-1:1 % check from the end of value_out
        if value_out(k) == value_cur
            flag = 1;
            index_rep = k;
            break;
        else
            flag = 0;
        end
    end
end
return

%% Test if the output branch should be terminated due to value_cur >= v_judge
function flag = IsStop(value_cur,v_judge)
    if value_cur - v_judge < 0
        flag = 0;
    else
        flag = 1;
    end
return
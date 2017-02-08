function node_out = NodeAdd(node_P,node_C)
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
        index = index + 1;
        value_out(index) = value_cur_P+value_C(j); % candidate value for the output branch        
        p_out(index) =  p_cur_P*p_C(j);        
    end
end
% Sort value_out in ascending order, and adjust p_out accordingly
[value_out,I] = sort(value_out);
p_out = p_out(I);
% Record the output node
node_out.n = index;
node_out.value = value_out;
node_out.p = p_out;
return
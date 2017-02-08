% Remove repetive branches
% Ensure that values are sorted in ascending order
function node_out = NodeRemoveRep(node_in)
n = node_in.n;
value = node_in.value;
p = node_in.p;
value_out = value;
p_out = p;
index = 1;
if n == 1 % if there is only one element
    node_out = node_in;
else
    for i = 2:n % check from the second element
        if value(i) == value(i-1) 
            p_out(index) = p_out(index)+p(i);
        else % unique element
            index = index +1;
            value_out(index) = value(i);
            p_out(index) = p(i);
        end
    end
end
value_out = value_out(1:index);
p_out = p_out(1:index);
node_out.n = index;
node_out.value = value_out;
node_out.p = p_out;
end
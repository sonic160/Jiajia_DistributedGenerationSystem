% Discard branches where v>=v_th
function node_out = NodeJudgement_value(node_in,v_th)
n = node_in.n;
value = node_in.value;
p = node_in.p;
index = 0;
value_out = value;
p_out = p;
for i = 1:n
    if value(i) < v_th
        index = index + 1;
    else
        break;
    end
end
value_out = value_out(1:index);
p_out = p_out(1:index);
node_out.n = index;
node_out.value = value_out;
node_out.p = p_out;
end


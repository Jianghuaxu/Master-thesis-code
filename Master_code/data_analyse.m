function Cost = data_analyse(costs)

% incase idle: cell_reslection_with_TAU
cost_temp1.messages = 0;
%cost_temp1.bytes = 0;
temp1 = struct2cell(costs.cell_reselection_with_TAU);
for i = 1:length(temp1)
    cost_temp1.messages = cost_temp1.messages+temp1{i}.MME_cost.messages;
    %cost_temp1.bytes = cost_temp1.bytes + temp1{i}.MME_cost.bytes;
end
Cost.cell_reselection_with_TAU.messages = cost_temp1.messages;
%Cost.cell_reselection_with_TAU.bytes = cost_temp1.bytes;

% % incase idle: periodic TAU
% cost_temp2.messages = 0;
% cost_temp2.bytes = 0;
% temp2 = struct2cell(costs.periodic_TAU);
% for i = 1:length(temp2)
%     cost_temp2.messages = cost_temp2.messages+temp2{i}.MME_cost.messages;
%     cost_temp2.bytes = cost_temp2.bytes + temp2{i}.MME_cost.bytes;
% end
% Cost.periodic_TAU.messages = cost_temp2.messages;
% Cost.periodic_TAU.bytes = cost_temp2.bytes;
% 
% % incase active: handover_with_TAU
% cost_temp3.messages = 0;
% cost_temp3.bytes = 0;
% temp3 = struct2cell(costs.handover_with_TAU);
% for i = 1:length(temp3)
%     cost_temp3.messages = cost_temp3.messages+temp3{i}.MME_cost.messages;
%     cost_temp3.bytes = cost_temp3.bytes + temp3{i}.MME_cost.bytes;
% end
% Cost.handover_with_TAU.messages = cost_temp3.messages;
% Cost.handover_with_TAU.bytes = cost_temp3.bytes;

% incase paging
cost_temp1.UE_requests = 0;
temp1 = struct2cell(costs.cell_reselection_with_TAU);
for i = 1:length(temp1)
    cost_temp1.UE_requests = cost_temp1.UE_requests + temp1{i}.UE_requests;
end
Cost.UE_requests = cost_temp1.UE_requests;
end


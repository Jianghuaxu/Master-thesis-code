for i = 1:10
    temp11 = 0;
    temp12 = 0;
    temp13 = 0;
    temp21 = 0;
    temp22 = 0;
    temp23 = 0;
    temp31 = 0;
    temp32 = 0;
    temp33 = 0;
    for j = 1:numTimesteps1_500
        temp11=temp12+Cost_Mixed(i).cell_reselection_with_TAU.(['time_', num2str(j)]).MME_cost.messages;
        temp12=temp12+Cost_Mixed(i).periodic_TAU.(['time_', num2str(j)]).MME_cost.messages;
        temp13=temp13+Cost_Mixed(i).paging.(['time_', num2str(j)]).MME_cost.messages;
        temp21=temp21+Cost_Mixed(i).cell_reselection_with_TAU.(['time_', num2str(j)]).MME_cost.bytes;
        temp22=temp22+Cost_Mixed(i).periodic_TAU.(['time_', num2str(j)]).MME_cost.bytes;
        temp23=temp23+Cost_Mixed(i).paging.(['time_', num2str(j)]).MME_cost.bytes;
    end   
    Cost_for_Mixed2.(['time_', num2str(i)]) = [temp11, temp12, temp13; temp21, temp22, temp23];
%     TAU_times_Mixed2(i) = temp11;
%     TAU_times_DB2(i) = temp12;
end
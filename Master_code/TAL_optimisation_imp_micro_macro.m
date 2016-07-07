%function [type, N, direction_temp] = TAL_optimisation(car_state, mobility, i, j)
function [type, N, TAL_size,direction_temp] = TAL_optimisation_imp_micro_macro(mobility_current, N_xy_micro, N_xy_macro, paging_rate, TAL_scheme,history_length)
Nx = N_xy_micro(1);                 Nx2 = N_xy_micro(2);
Nx_macro = N_xy_macro(1);     Nx2_macro = N_xy_macro(2);

    %% first step to take it calculating my(TA residential time index)
    %mobility_current = mobility.(car_state.(['time_',num2str(i)]){j}).(['time_',num2str(i)]);
    
    lambda = 1/paging_rate; sigma_tau=1; sigma_paging=1;
    % here we define a new parameter history_length
    % this indicates how long the history information is used to update
    %history_length = 4;

    % from the history information we could get several important
    % information
    
    % first important information we need is TA-residence-time ?(my)
    % TA-residence-time keep updated everytime a TAL-allocation is made,
    % one things to remind is that the residence-time in current TA is not
    % included, cause UE is still staying in current TA
   % my = (length(mobility_current.TAI_history(:,1))-1)/sum(mobility_current.TAI_history(1:end-1,2));
    % a small update must be considered, since we do not use real car speed
    % , purely with help of this kind of cell_based speed, is sometimes not
    % accurate, the small update here is: let the TAL_history whose residence time is less than
    % 10 deleted!
    temp = mobility_current.TAI_history;
    
    
    my = (length(temp(:,1))-1)/sum(temp(1:end-1,2));
   
    % TAL optimisation for 3 different TAL_schemes are different 
    % 'Mixed' ist the most complex one, firstly TAL_type should be decided
    % according to their history_information
  
    switch TAL_scheme
        case 'Mixed'
            %% new distribution method should be used as follows:
            % we now consider time spend in each direction change,
            % residence time begins to influnce Type_distribution and
            % posibilities for our random-walk model!
            
            % first step: analyse TAI_history
            % residence time spend in each direction is listed as: [t1, t2, t3, t4, t5, t6]
            % 6 possibilities is listed as: [p1, p2, p3, p4, p5, p6]
            % 6 residence times is listed parallel to 6 possibilities 
            temp_directions = mobility_current.directions';
            
            %% update history_information 
            % some history_information makes no sense, for example: the
            % residence time in one cell less than 10 seconds could be
            % regarded as harmful for the destionation prediction
            idx = find(temp(:,2)<4);
            temp_length = length(temp);
            if length(temp_directions)>1 && length(idx)~=temp_length
                for j = 1:length(idx)
                    m = idx(j)-j+1;
                    if m ~= temp_length-j+1
                        temp(m,:) = [];
                        temp_directions(m) = [];
                        if m~=1
                            temp_directions(m-1) = temp(m-1,1)-temp(m,1);
                        end
                    end
                end
            end   
            
            for i = 2:length(temp)
                    temp_directions(i-1,2) = 0.5*(temp(i-1, 2)+...
                        temp(i,2));
            end 
            
            % considere the case at the border between Urban & rural region
            temp_directions(find(abs(temp_directions(:,1))>500),:)=[];
            
            % history length we considered would also play a roll
            if length(temp_directions)>history_length 
               temp_directions = temp_directions(end-history_length+1:end,:);
            end
            
            %% start to construct new_history_information, all included in "six_directions"
            six_directions1(:,1)=[1, -Nx2, -Nx, -1, Nx2,Nx];
            six_directions=six_directions1;
            for i = 1: 6
                six_directions(i,2) = sum(temp_directions(find(temp_directions(:,1)==six_directions1(i,1)),2));
            end
            
            six_directions2(:,1) = [1, -Nx2_macro, -Nx_macro, -1, Nx2_macro, Nx_macro];
            for i = 1: 6
                six_directions(i,2) = six_directions(i,2)+sum(temp_directions(find(temp_directions(:,1)==six_directions2(i,1)),2));
            end
            
            % if directions recorded in the history_information is not
            % included in these 6 direction, then this rare
            % history-information would be deleted 
            if sum(six_directions(:,2))== 0
                N = 1;
                type = 'linear';
                direction_temp = [1,1];
                TAL_size = 1;
                return;
            end    
            
            % after get residence time for each of the 6 directions, we
            % start to make classification
            % classification method:
            % 1, find out the direcition with longest residence time
            % 2, compare with each other, if difference to high, then
            % linear form TAL scheme is distributed, otherwise we would use
            % small-cone 
            % the difference limit is defined as: 4 times!!!
            
            % we assign each direction with a specific possibility value
            % based on the history_residence_TAI_plus_time 
            % but before that, we assign each direction with a "basic p"!
            six_directions(:,3) = 0.3/6;
            % then each p would be updated
            temp = sum(six_directions(:,2));
            for i = 1:6
                six_directions(i,3) = six_directions(i,3)+0.7*six_directions(i,2)/temp;
            end
            
            p_call = lambda/(lambda + my);
            six_directions(:,3) = (1-p_call)*six_directions(:,3);
            
            % next step would be real TAL form classification 
            % first the most probable direction would be selected: temp_1 
            % then its  nearst neighbor with higher possibility: temp_2
            % finally its big_neighbor with higher possibility : temp_3
            temp_1 = find(six_directions(:,3)==max(six_directions(:,3)));
            if length(temp_1) >1
                temp_1 = temp_1(1);
            end
            
           switch temp_1
               case 1
                   neigh_11 = 6; neigh_12 = 2;
                   neigh_21 = 5; neigh_22 = 3;
               case 2
                   neigh_11 = 1; neigh_12 = 3;
                   neigh_21 = 6; neigh_22 = 4;
               case 3
                   neigh_11 = 2; neigh_12 = 4;
                   neigh_21 = 1; neigh_22 = 5;
               case 4
                   neigh_11 = 3; neigh_12 = 5;
                   neigh_21 = 2; neigh_22 = 6;
               case 5
                   neigh_11 = 4; neigh_12 = 6;
                   neigh_21 = 3; neigh_22 = 1;
               case 6
                   neigh_11 = 5; neigh_12 = 1;
                   neigh_21 = 4; neigh_22 = 2;
           end
           if six_directions(neigh_11,3)<six_directions(neigh_12,3)
               temp_21 = neigh_12;
               temp_22 = neigh_11;
           else
               temp_21 = neigh_11;
               temp_22 = neigh_12;
           end
           if six_directions(neigh_21,3) < six_directions(neigh_22,3)
               temp_3 = neigh_22;
           else
               temp_3 = neigh_21;
           end
           
%             
            if length(temp_directions(:,1))==1
                type = 'linear';
                p_index = [temp_1];
            else
                if 4*six_directions(temp_3,3) < six_directions(temp_1,3) 
                    if 2*six_directions(temp_22,3)<six_directions(temp_21,3) 
                        type ='conical';
                        p_index = [temp_1, temp_21];
                    else
                        type = 'big cone';
                        p_index = [temp_21, temp_22];
                    end
                else
                    type = 'big cone';
                    if six_directions(temp_22,3)> six_directions(temp_3,3)
                        p_index = [temp_21, temp_22];
                    else
                        p_index = [temp_1, temp_3];
                    end
                end
            end
            clear direction_temp
            direction_temp(:,1) = six_directions1(p_index,1);
            direction_temp(:,2) = six_directions2(p_index,1);
            %% once the type is decided, then here N which makes cost lowest is calculated.
            switch type
                case 'linear'
                    n = 16;
                    cost = zeros(16);
                    for i = 1:n
                      temp = i;
                      cost(i)  = get_cost_imp(lambda, my, sigma_tau, sigma_paging ,i,temp,type, six_directions, p_index, p_call);
                    end
                    %plot(1:n, cost);
                    N = find(cost == min(cost(:,1)));
                    TAL_size = 1:N;
                case 'conical'
                    n=5;
                    cost = zeros(15);
                    P_equilibrium_temp = zeros(15,15);
                    N_row = zeros(15,1);
                    for i = 1:n
                        for j = 1:i
                            temp = i*(i-1)/2+j;
                             [cost(temp), N_row(temp), P_equilibrium_temp(temp,1:temp)] = get_cost_imp(lambda, my, sigma_tau, sigma_paging ,i,temp, type,six_directions, p_index, p_call);
                        end
                    end
                    %plot(1:n, cost);
                    N = find(cost == min(cost(:,1)),1);
                    TAL_size = P_equilibrium_temp(N,1:N);
                    N = N_row(N);
                case 'big cone'
                    n=4;
                    cost = zeros(16,1);
                    P_equilibrium_temp = zeros(16);
                    N_row = zeros(16,1);
                    for i = 1:n
                        for j = 1:(2*i-1);
                            temp = (i-1)*(i-1)+j;
                            [cost(temp), N_row(temp),P_equilibrium_temp(temp, 1:temp)] = get_cost_imp(lambda, my, sigma_tau, sigma_paging ,i,temp, type, six_directions, p_index, p_call);
                        end
                    end
                    %plot(1:n, cost);
                    N = find(cost == min(cost(:,1)),1);
                    TAL_size = P_equilibrium_temp(N,1:N);
                    N = N_row(N);
            end

            
        %%    
        case 'Distance-based TAL'
            p_linear=0;
            p_conical_left=0;
            p_conical_right=0;
            n=10;
            cost = zeros(n);
            direction_temp = 0;
            type = 'circular';
            for i = 1:n
                cost(i) =get_cost(lambda, my, sigma_tau, sigma_paging, i, type, p_linear, p_conical_left, p_conical_right);
            end
            %plot(1:n, cost);
            N = find(cost == min(cost(:,1)),1);
            %%
        case 'Movement-based TAL'
            
    end
    
end
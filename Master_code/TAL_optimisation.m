%function [type, N, direction_temp] = TAL_optimisation(car_state, mobility, i, j)
function [type, N, direction_temp] = TAL_optimisation(mobility_current, paging_rate, Nx, Nx2, TAL_scheme,history_length)
    %%first step to take it calculating my(TA residential time index)
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
    my = (length(mobility_current.TAI_history(:,1))-1)/sum(mobility_current.TAI_history(1:end-1,2));
    
    % TAL optimisation for 3 different TAL_schemes are different 
    % 'Mixed' ist the most complex one, firstly TAL_type should be decided
    % according to their history_information
  
    switch TAL_scheme
        case 'Mixed'
            %% now TAL_type should be decided according to
            % history_information_directions
            % directions == 1-------- --------------------> type = 'linear', e.g. initialized
            % directions == 2(adjacent) --------------------> type = 'conical'
            % directions == others ------------------------> type = 'circular'
            len_direction= length(mobility_current.directions);
            % decision is made here
            if len_direction>= history_length
                direction_num = numel(unique(mobility_current.directions(end-history_length+1:end)));
                if direction_num == 1
                    % incase UE only drives along one direction, then the longer UE
                    % goes, then more probable UE goes in this direction later. 
                    type = 'linear';
                    p_linear = 0.6 + 0.1*history_length;
                    direction_temp = mobility_current.directions(end);
                elseif direction_num == 2
                    direction_temp(1,1) = mobility_current.directions(end);
                    direction_temp(1,2) = 1;
                    direction_temp(2,2) = 0;
                    for i = 2: history_length
                        if mobility_current.directions(end-i+1) ~= direction_temp(1,1);
                            direction_temp(2,1) = mobility_current.directions(end-i+1);
                            direction_temp(2,2) = direction_temp(2,2) +1;
                        else
                            direction_temp(1,2) = direction_temp(1,2) +1; 
                        end
                    end
                    temp_direction_angle = abs(direction_temp(1,1)-direction_temp(2,1));
                    if ismember(temp_direction_angle, [1,2, Nx, Nx-1, Nx2, Nx2+1]);
                        type = 'conical';
                        p_conical_left = 0.8*(max(direction_temp(1,2), direction_temp(2,2)))/history_length;
                        p_conical_right = 0.8*(min(direction_temp(1,2),direction_temp(2,2)))/history_length;
                    else
                        type = 'circular';
                    end
                else
                    type = 'circular';
                    direction_temp = 0;
                end
            else
                direction_num = numel(unique(mobility_current.directions));
                if direction_num == 1
                    type = 'linear';
                    p_linear = 0.1 + 0.1*len_direction;
                    direction_temp = mobility_current.directions(end);
                elseif direction_num == 2
                    direction_temp(1,1) = mobility_current.directions(end);
                    direction_temp(1,2) = 1;
                    direction_temp(2,2) = 0;
                    for i = 2: len_direction
                        if mobility_current.directions(end-i+1) ~= direction_temp(1,1);
                            direction_temp(2,1) = mobility_current.directions(end-i+1);
                            direction_temp(2,2) = direction_temp(2,2) +1;
                        else
                            direction_temp(1,2) = direction_temp(1,2) +1; 
                        end
                    end
                    temp_direction_angle = abs(direction_temp(1,1)-direction_temp(2,1));
                    if ismember(temp_direction_angle, [1, Nx, Nx-1, Nx2, Nx2+1]);
                        type = 'conical';
                        p_conical_left = 0.8*(max(direction_temp(1,2), direction_temp(2,2)))/len_direction;
                        p_conical_right = 0.8*(min(direction_temp(1,2),direction_temp(2,2)))/len_direction;
                    elseif direction_temp(1,1) == -direction_temp(2,1)
                        type = 'ping_pong';
                    else
                        type = 'circular';
                    end
                else
                    type = 'circular';
                    direction_temp = 0;
                end
            end
            
            
            
            
            %% once the type is decided, then here N which makes cost lowest is calculated.
            switch type
                case 'linear'
                    p_conical_left =0;
                    p_conical_right = 0;
                    n = 10;
                    cost = zeros(n);
                    for i = 1:n
                      cost(i)  = get_cost(lambda, my, sigma_tau, sigma_paging, i, type, p_linear, p_conical_left, p_conical_right);
                    end
                   % plot(1:n, cost);
                    N = find(cost == min(cost(:,1)),1);
                case 'conical'
                    p_linear=0;
                    n=10;
                     cost = zeros(n);
                    for i = 1:n
                       cost(i) = get_cost(lambda, my, sigma_tau, sigma_paging, i, type, p_linear, p_conical_left, p_conical_right);
                    end
                    %plot(1:n, cost);
                    N = find(cost == min(cost(:,1)),1);
                case 'circular'
                    p_linear=0;
                    p_conical_left=0;
                    p_conical_right=0;
                    n=10;
                     cost = zeros(n);
                    for i = 1:n
                        cost(i) = get_cost(lambda, my, sigma_tau, sigma_paging, i, type, p_linear, p_conical_left, p_conical_right);
                    end
                    %plot(1:n, cost);
                    N = find(cost == min(cost(:,1)),1);
                case 'ping_pong'
                    N = 2;
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
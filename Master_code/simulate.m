function [mobility,costs, Scheme_number_count] = simulate(mobility, car_state, numTimesteps, Nx, Nx2, Ny, Ny2,paging_rate, TAL_scheme_num, history_length)
%
%
%
%
%
%
%
%
%
%
%


% define a struct data, "costs", which stores all the cost for each time
% interval, during each time interval individual costs for different network
% entities, like eNB, S-GW, P-GW and MME are also stored, costs include two
% parameters: messages_persecond(we just use messages to represent) and
% bytes
%%                                    Part - Simulation Initialization 
%costs initialization
for i = 1:numTimesteps
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).UE_requests = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).UE_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).UE_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).eNB_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).eNB_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).MME_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).MME_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).PGW_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).PGW_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).SGW_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).SGW_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).PCRF_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).PCRF_cost.bytes = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).total_cost.messages = 0;
    costs.cell_reselection_with_TAU.(['time_', int2str(i)]).total_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).UE_requests = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).UE_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).UE_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).eNB_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).eNB_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).MME_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).MME_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).PGW_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).PGW_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).SGW_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).SGW_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).PCRF_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).PCRF_cost.bytes = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).total_cost.messages = 0;
    costs.periodic_TAU.(['time_', int2str(i)]).total_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).UE_requests = 0;
    costs.paging.(['time_', int2str(i)]).UE_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).UE_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).eNB_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).eNB_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).MME_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).MME_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).PGW_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).PGW_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).SGW_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).SGW_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).PCRF_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).PCRF_cost.bytes = 0;
    costs.paging.(['time_', int2str(i)]).total_cost.messages = 0;
    costs.paging.(['time_', int2str(i)]).total_cost.bytes = 0;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    New Function Added for analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scheme_number_count.linear = [];
Scheme_number_count.conical = [];
Scheme_number_count.circular = [];
Scheme_number_count.ping_pong = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine the active/idle ratio
disp('                                ');
active_idle_ratio = 0;
disp('                                ');
% determine paging rate(obeys poisson porcess, paging_rate=1/lambda) for UE in idle state
% determine period for periodic TAU for UE in idle state
period = 20;
disp('                                ');
% determine TAL scheme: 
disp('TAL_scheme 1: Movement-based TAL ');
disp('TAL_scheme 2: Distance-based TAL');
disp('TAL_scheme 3:  Mixed');
switch TAL_scheme_num
    case 1
        TAL_scheme = 'Movement-based TAL';
    case 2
        TAL_scheme = 'Distance-based TAL';
    case 3
        TAL_scheme = 'Mixed';
end
disp('                                ');
%%                                                       Part - Simulation 

% go through all existent cars in time stemp i;
for i = 1:length(car_state)
    for j = 1: length(car_state{i}) 
        % judge if car firstly enters, then several parameters should be
        % assigned
        % get current mobility of each user and mobility from last time
        % stemp
        mobility_current = mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]);
        if i ~= 1
            mobility_last = mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i-1)]);
        else 
            mobility_last = [];
        end
        if ~ isstruct(mobility_last) || i==1
           %%                                         Part - Initial Attachment   
           
           % for new comers, default TAL should be assigned
            mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAL = mobility_current.TAI;
            
            % for new comers, we need to initialize several "history
            % information", for example: TA residential time % a new
            % parameter--directions            
            mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).directions = [];
            
            mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAI_history(1,1) = mobility_current.TAI;
            mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAI_history(1,2) = 1;
            
            mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAU_times = 0;
            % for new comers, a car_state would be assigned, and this car state would be not changed 
            % until the car leaves
            if rand(1)< active_idle_ratio
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).state = 1; % 1 represent active
            else
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).state = 0; % 0 represent idle
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).timer = 1; % a timer to tigger periodic TAU is initialized 
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).call_timer = 1; % a timer to trigger a call, which is poisson process
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .call_timer_count = poissrnd(paging_rate); % first poisson value should be initialized
            end
            
        else
         %%                                             Part -  Main Part 
         
            % judge if car is in active or idle state
            if mobility_last.state == 1 % UE belongs to active users
           %%                                            Part - Active UE
           
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .state = mobility_last.state;
               % in active state, only handover would cause TAU
                if ~ ismember(mobility_current.TAI, mobility_last.TAL)
                    % TAI changed brings a new direction to UE's history
                    % information
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions = mobility_last.directions;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions(end+1) = mobility_last.TAI-mobility_current.TAI;
                    
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end+1,1) = mobility_current.TAI; 
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = 1; 
                    
                    mobility_temp = mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]);
                    %% TAL_reassignment process
                    % before assign the TAL to the UE, TAL shape Type and
                    % how large should be decided and so TAL optimisation should be conducted.                    
                    [Type, N, direction_history] = TAL_optimisation(mobility_temp, paging_rate, Nx, Nx2, TAL_scheme,history_length);
                    % then we use the optimized parameter to distribute
                    % proper TAs to it. 
                    %% add the distribution type and N into history information for better analyse
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAL_type = Type;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAL_N = N;
                    %%
                    TAL = TAL_scheme_assign(mobility, car_state, i, j, Nx,Ny, Nx2, Ny2, TAL_scheme, ...
                        Type, N, direction_history);
                    %mobility = TAL_assign(mobility, car_state, i, j);
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .TAL= TAL;
                    % Cost calculation for handover with TAU 
                    cost_type = 'handover_with_TAU';
                    costs = cost_calculation (costs, i, cost_type);
                    
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times +1;
                    
                elseif mobility_current.TAI == mobility_last.TAI
                    %parameter-direction is not changed, while
                    %parameter-TAIs with its timer would be changed
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                         .directions = mobility_last.directions;
                     
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = mobility_last.TAI_history(end,2)+1;
                     
                    % TAL assignment keeps not changed
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAL = mobility_last.TAL;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times ;
                else
                    % TAI changed brings a new direction to UE's history
                    % information
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions = mobility_last.directions;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions(end+1) = mobility_last.TAI-mobility_current.TAI;
                    
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end+1,1) = mobility_current.TAI;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = 1;
                    
                    % TAL assignment keeps not changed
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                         .TAL = mobility_last.TAL;
                     
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times;
                end

            else % UE belongs to idle users.
                %%                                        Part - Idle Paging
                
                % we regard paging as a non-overlapping procedure with TAU
                % here if this car at this moment should be paged would be judged
                % we adopt poisson process when handling with call_pattern 
                if mobility_last.call_timer == mobility_last.call_timer_count-1;
                    % got paged, a new poisson value for paging should be
                    % new created and cost is going to be calculated also
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .call_timer_count = poissrnd(paging_rate);
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .call_timer = 1;
                    cost_type = 'paging';
                    eNBs_num_in_same_TAL = length(mobility_last.TAL);
                    costs = cost_calculation (costs, i, cost_type, eNBs_num_in_same_TAL);
                else
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .call_timer = mobility_last.call_timer +1;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .call_timer_count = mobility_last.call_timer_count;
                end
                mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                .state = mobility_last.state;
                %%                                        Part - Idle  TAU
                
                % now cell reselection with TAU would be judged if conditions satisfy
                if ~ ismember(mobility_current.TAI, mobility_last.TAL)
                    % TAI changed brings a new direction to UE's history
                    % information
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions = mobility_last.directions;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions(end+1) = mobility_last.TAI-mobility_current.TAI;
                    
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end+1,1) = mobility_current.TAI;  
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = 1;
                    
                    mobility_temp = mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]);
                    %% cell reselection
                    % before assign the TAL to the UE, TAL shape Type and
                    % how large should be decided and so TAL optimisation should be conducted.                    
                    [Type, N, direction_history] = TAL_optimisation(mobility_temp, paging_rate, Nx, Nx2, TAL_scheme, history_length);
                    % then we use the optimized parameter to distributed
                     Scheme_number_count.(Type)(end+1) = N;
                    TAL = TAL_scheme_assign(mobility, car_state, i, j, Nx,Ny, Nx2, Ny2, TAL_scheme, ...
                        Type, N, direction_history);
                     %% add the distribution type and N into history information for better analyse
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAL_type = Type;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)]).TAL_N = N;
                    %%
                    %mobility = TAL_assign(mobility, car_state, i, j);
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .TAL= TAL;
                    % cost calculation, it is an independent process, once
                    % there is a TAU/Paging, a new costs would be
                    % calculated. 
                    cost_type = 'cell_reselection_with_TAU';
                    costs = cost_calculation (costs, i, cost_type);
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times +1;
                    %% cell reselection with TAU would reset timer to 0
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                             .timer = 0;
                elseif mobility_current.TAI == mobility_last.TAI
                    %parameter-direction is not changed, while
                    %parameter-TAIs with its timer would be changed
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                         .directions = mobility_last.directions;
                     
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = mobility_last.TAI_history(end,2)+1;
                
                    % TAL assignment keeps not changed
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                         .TAL = mobility_last.TAL;
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times ;
                     
                    % TAI is not changed, only thing to do is judge if
                    % timer expires
                     if mobility_last.timer == period
                         cost_type = 'periodic_TAU';
                         costs = cost_calculation (costs, i, cost_type);
                         mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                             .timer = 0; % after periodic TAU timer reset to 0
                     else
                         mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                             .timer = mobility_last.timer +1;
                     end
                else                  
                    % TAI changed brings a new direction to UE's history
                    % information
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions = mobility_last.directions;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                        .directions(end+1) = mobility_last.TAI-mobility_current.TAI;
                    
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history = mobility_last.TAI_history;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end+1,1) = mobility_current.TAI;
                    mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAI_history(end,2) = 1;
                    % TAL assignment keeps not changed
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                         .TAL = mobility_last.TAL;
                     mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                    .TAU_times = mobility_last.TAU_times ;
                     
                    % TAL is not changed, only thing to do is judge if
                    % timer expires
                     if mobility_last.timer == period
                         cost_type = 'periodic_TAU';
                         costs = cost_calculation (costs, i, cost_type);
                         mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                             .timer = 0; % after periodic TAU timer reset to 0
                     else
                         mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])...
                             .timer = mobility_last.timer +1;
                     end
                end        
            end
        end      
    end
end
end
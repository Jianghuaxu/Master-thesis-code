function [Cost, n,P_equilibrium_temp] = get_cost_imp(lambda, my, sigma_tau, sigma_paging,n, temp, type, six_directions,p_index, p_call)
%the way toward optimisation
%        Step 1: get the equibilium probability
%        Step 2: get the expected number of TAUs triggered by a state
%        transition
%        Step 3: get the expected number of TAUs during the call inter-arrival time tc 
%        and number of Paging 
%        Step 4: get the whole cost

%given parameter essential for optimisation
% n, ?tau,?paging, Npaging=n(n+1)/2, 
% and cell-residence-time(exponential distribution): ?/lambda
% and call-pattern(poisson process): ?/my
% and p_left, p_right, which are got from history information of each UE

%P = getMarkovTransitionProbability(n,type, p_linear, p_conical_left, p_conical_right, p_call)

%Step 1


%if there will be more 1 TA in the TAL, then we make a difference between 3 types of TAL schape
if temp>1
    P = getMarkovTransitionProbability_imp(n,type, six_directions, p_index, p_call);
    P_equilibrium = [P' - eye(size(P')); ones(1,size(P',2))] \ [zeros(size(P',1),1); 1];
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%                                   further optimisation                     %%%%%%%%%%%%%%

    P_temp = P_equilibrium;
    P_equilibrium_temp = zeros(temp,1);
    for i = 1:temp
        temp1 = find(P_temp()==max(P_temp),1);
        P_equilibrium_temp(i) = temp1;
        P_temp(temp1) = 0;
    end

    P_equilibrium_temp = sort(P_equilibrium_temp);
    P_new = P(P_equilibrium_temp, P_equilibrium_temp);
    for i = 1:temp
        P_new(i,1) = 1-sum(P_new(i,2:end));
    end
    P_equilibrium_new = [P_new' - eye(size(P_new')); ones(1,size(P_new',2))] \ [zeros(size(P_new',1),1); 1];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    P_new = 1;
    P_equilibrium_new = 1;
    P_temp = 1;
    P_equilibrium_temp = 1;
end

%Step 2
Ntau_st = sum(P_equilibrium_new.*P_new(:,1));

%Step 3
Ntau_during_call = (lambda+my)*Ntau_st/lambda;


%Step 4
Cost = Ntau_during_call * sigma_tau +temp*sigma_paging;
end
function Cost = get_cost(lambda, my, sigma_tau, sigma_paging, n, type, p_linear, p_conical_left, p_conical_right)
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
p_call = lambda/(lambda + my);
p_conical_left = (1-p_call)*p_conical_left;
p_conical_right = (1-p_call)*p_conical_right;
p_linear = (1-p_call)*p_linear;

%if there will be more 1 TA in the TAL, then we make a difference between 3 types of TAL schape
if n>1
    P = getMarkovTransitionProbability(n,type, p_linear, p_conical_left, p_conical_right, p_call);
    P_equilibrium = [P' - eye(size(P')); ones(1,size(P',2))] \ [zeros(size(P',1),1); 1];
else
    P = 1;
    P_equilibrium = 1;
end

%Step 2
Ntau_st = sum(P_equilibrium.*P(:,1));

%Step 3
Ntau_during_call = (lambda+my)*Ntau_st/lambda;
switch type
    case 'linear'
        Npaging = n;
    case 'circular'
        Npaging = 3*n^2+3*n+1;
    case 'conical'
        Npaging = n*(n+1)/2;
    case 'big cone'
        Npaging = n*n;
end

%Step 4
Cost = Ntau_during_call * sigma_tau +Npaging*sigma_paging;
end
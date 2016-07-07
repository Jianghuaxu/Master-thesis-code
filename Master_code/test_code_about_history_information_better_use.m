for i = 1:50
    for j = 1: length(car_state{i})
        mobility_current = mobility_4.(['Car_',int2str(car_state{i}(j))]).(['time_',int2str(i)])
        if ~isempty(mobility_current.directions)
            [type, N, direction_temp] = TAL_optimisation_simp(mobility_current, paging_rate, TAL_scheme,history_length)
        end
    end
end
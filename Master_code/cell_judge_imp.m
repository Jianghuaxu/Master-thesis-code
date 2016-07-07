function TAL = cell_judge_imp(cell_for_judge, column, TAL, new_cells_up, Cell_num_cal, TAI_for_judge, TAL_size)
if  cell_for_judge<=Cell_num_cal && cell_for_judge>0 && ismember(TAI_for_judge, TAL_size)
    cell_pos = cell_num_transition(cell_for_judge, new_cells_up);
    if cell_pos(1) == column
        TAL(end+1) = cell_for_judge;
    end
end
end
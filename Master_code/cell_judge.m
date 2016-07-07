function TAL = cell_judge(cell_for_judge, column, TAL, new_cells_up, Cell_num_cal, TAL_size)
if  cell_for_judge<=Cell_num_cal && cell_for_judge>0
    cell_pos = cell_num_transition(cell_for_judge, new_cells_up);
    if cell_pos(1) == column
        TAL(end+1) = cell_for_judge;
    end
end
end
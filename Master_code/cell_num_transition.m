function a = cell_num_transition(cell_num, new_cells_up)
    len=length(new_cells_up);
    for i = 1:len
        if new_cells_up(i)==cell_num 
            a(1)=i;
            a(2) =1;
        elseif new_cells_up(i)<cell_num 
            if i == len
                a(1) = len;
                a(2) = cell_num-new_cells_up(i)+1;
            elseif new_cells_up(i+1)>cell_num
                a(1)=i;
                a(2) = cell_num-new_cells_up(i)+1;
        else
            i = i+1;
        end
    end
end
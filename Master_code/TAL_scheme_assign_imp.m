function TAL =TAL_scheme_assign_imp(mobility, car_state, i, j, Nx,Ny, Nx2, Ny2, TAL_scheme, Type, N, direction_history,TAL_size)
current_TAI = mobility.(['Car_',int2str(car_state{i}(j))]).(['time_',num2str(i)]).TAI;
if N == 1
    TAL = current_TAI;
    return
else
    N= N-1;
end

%% prepatation work
% we list firstly border cells & initialisation of border cells
cells_right = [];
cells_up = [];
if Ny == Ny2
    cells_right = (Nx*Ny+Nx2*(Ny2-1)+1):(Nx*Ny+Nx2*Ny2);
    for i = 2: Ny
        cells_up(end+1)=(i-1)*(Nx+Nx2)+1;
    end
    for i = 1:(Ny2-1)
        cells_up(end+1) = i*Nx+(i-1)*Nx2+1;
    end
else
    cells_right = (Nx*(Ny-1)+Nx2*Ny2+1):(Nx*Ny+Nx2*Ny2);
    for i = 2: (Ny-1)
        cells_up(end+1)=(i-1)*(Nx+Nx2)+1;
    end
    for i = 1:Ny2
        cells_up(end+1) = i*Nx+(i-1)*Nx2+1;
    end
end
% we make all together as follows:
new_cells_up = [1, cells_up,cells_right(1) ];
new_cells_up = sort(new_cells_up);
Cell_num_cal = Nx*Ny+ Nx2*Ny2;
  
%% now different TAL_scheme should be considered 
switch TAL_scheme
    case 'Movement-based TAL '
        mobility_last = mobility.(car_state.(['time_',num2str(i)]){j}).(['time_',num2str(i-1)]);
        mobility.(car_state.(['time_',num2str(i)]){j}).(['time_',num2str(i)]).TAL = mobility_last.TAL;
        
    case 'Distance-based TAL'
        %% circular shape TAL distribution is made here
        % firstly we would be make sure how the random_walk_model probabilities 
        % ist. we cound the 6 directions from north one in a clock-direction and 
        % p = [p1, p2, p3, p4, p5, p6]
        TAL(1) = current_TAI;
        current_cell_pos = cell_num_transition(TAL(end), new_cells_up);
        p1 = 1; p4 = -1;
        if Nx ~= Nx2
            p2 = 1-Nx; p3 = -Nx; p5 = -p2; p6 = -p3;
        else
            if mode(current_cell_pos(1), 2)==0
                p2 = -Nx; p3 = p2-1; p6 = -p2; p5 = p6-1;
            else
                p2 = 1-Nx; p3 = p2-1; p6 = Nx+1; p5 = p6-1;
            end
        end
        
        % start to distribute circular TAs one ring by one ring 
        for i = 1:N
            % we start to add cells in the both vertical directions (p1, p4);
            % in each direction, we have i cells
            temp = current_TAI - p1*i;
            TAL = cell_judge(temp, current_cell_pos(1), TAL,new_cells_up, Cell_num_cal);
            temp = current_TAI - p4*i;
            TAL = cell_judge(temp, current_cell_pos(1), TAL,new_cells_up, Cell_num_cal);
            % then we start with the TAs right side of the main vertical
            % direction, in the right/left side, we have i columns of TAs
            if i >= 2
                for j = 1:i-1
                basis_cell(1) = current_TAI - p2*j;
                basis_cell(2) = current_TAI - p3*j;
                basis_cell(3) = current_TAI - p5*j;
                basis_cell(4) = current_TAI - p6*j;
                temp = basis_cell(1)-i+j;
                TAL = cell_judge(temp, current_cell_pos(1)+j, TAL, new_cells_up, Cell_num_cal);
                temp = basis_cell(2)+i-j;
                TAL = cell_judge(temp, current_cell_pos(1)+j, TAL, new_cells_up, Cell_num_cal);
                temp = basis_cell(3) +i-j;
                TAL = cell_judge(temp, current_cell_pos(1)-j, TAL, new_cells_up, Cell_num_cal);
                temp = basis_cell(4) -i+j;
                TAL = cell_judge(temp, current_cell_pos(1)-j, TAL, new_cells_up, Cell_num_cal);
                end
            end
            % now we distribute the column_cells, which is farest from the central
            % vertical direction. 
            % feature for this two colums: 1,we have i cells in each left/right
            % column. 2, all are new to be distributed
            Basis_cell(1) = current_TAI- p2*i;
            TAL = cell_judge(Basis_cell(1), current_cell_pos(1)+i, TAL, new_cells_up, Cell_num_cal);
            Basis_cell(2) = current_TAI-p3*i;
            TAL = cell_judge(Basis_cell(2), current_cell_pos(1)+i, TAL, new_cells_up, Cell_num_cal);    
            Basis_cell(3) = current_TAI - p5*i;
            TAL = cell_judge(Basis_cell(3), current_cell_pos(1)-i, TAL, new_cells_up, Cell_num_cal);
            Basis_cell(4) = current_TAI - p6*i;
            TAL = cell_judge(Basis_cell(4), current_cell_pos(1)-i, TAL, new_cells_up, Cell_num_cal);

            cell_diference = abs(Basis_cell(1)-Basis_cell(2));
            if cell_diference ~= 1
                for k = 1:(cell_diference-1)
                    temp = min(Basis_cell(1), Basis_cell(2))+k;
                    TAL = cell_judge(temp, current_cell_pos(1)+i, TAL, new_cells_up, Cell_num_cal);
                end
            end
            cell_diference2 = abs(Basis_cell(3)-Basis_cell(4));
            if cell_diference2 ~= 1
                for k = 1:(cell_diference2-1)
                    temp = min(Basis_cell(3), Basis_cell(4))+k;
                    TAL = cell_judge(temp, current_cell_pos(1)-i, TAL, new_cells_up, Cell_num_cal);
                end
            end
        end
        
    case 'Mixed'
        % once defined cells in border, we could not judge if the
        % distributed cells is out of border!
        switch Type
            case 'linear'
                TAL(1) = current_TAI;
            % firstly we need to decide the reference position(current_TAI); 
                current_TAI_pos = cell_num_transition(current_TAI, new_cells_up);

                % we need another reference direction, which depends on the
                % direction_history, ref_direction together with current_TAI_pos, we could
                % know column number of every distributed cell

                if direction_history ==1 || direction_history == -1
                    ref_direction = 0;
                elseif direction_history> 1
                    ref_direction = -1;
                else
                    ref_direction = 1;
                end

                 for i = 1:N
                    cell_in_direction = current_TAI - direction_history*i;
                    TAL = cell_judge(cell_in_direction, ref_direction*i+current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal);
                 end
                

            %for case conical, there exists 6 possibilities of the combination
            % we treat these 6 possibilities separately
            case 'conical'
            %%
            TAL(1) = current_TAI;
            % firstly we need to decide the reference position(current_TAI); 
            current_TAI_pos = cell_num_transition(current_TAI, new_cells_up);

            % we need another reference direction, which depends on the
            % direction_history, ref_direction together with current_TAI_pos, we could
            % know column number of every distributed cell
            for i = 1:2
                if direction_history(i,1) ==1 || direction_history(i,1) == -1
                    ref_direction(i) = 0;
                elseif direction_history(i,1)> 1
                    ref_direction(i) = -1;
                else
                    ref_direction(i) = 1;
                end
            end

            for i = 1:N
            cell_in_direction_1 = current_TAI - direction_history(1,1)*i;
            TAI_for_judge = i*(i+1)*0.5+1;
            TAL = cell_judge_imp(cell_in_direction_1, ref_direction(1)*i+current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal, TAI_for_judge, TAL_size);
            cell_in_direction_2 = current_TAI-direction_history(2,1)*i;   
            TAI_for_judge = (i+1)*(i+2)*0.5;
            TAL = cell_judge_imp(cell_in_direction_2, ref_direction(2)*i+current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal, TAI_for_judge,TAL_size);


                % if cells on the edge is not on border cells,
                % then we now distribute cells between two
                % edges of conical shape to TAL, here we have 3
                % possibilities
               % we devide between two adjacent directions on the same side, and
               % adjacent directions, which include one in the vertical direction.
               temp = abs(direction_history(1,1)-direction_history(2,1));
               if temp ==1
                   %% case adjacent directions, all are on the same side
                   if i >=2
                        for j = 2:i
                            temp_1 = current_TAI - direction_history(1,1)*j;
                            temp_2 =  current_TAI-direction_history(2,1)*j;
                            for k = 1: j-1
                                if temp_1 < temp_2 
                                    temp = temp_1+k;
                                    TAI_for_judge =  i*(i+1)*0.5+1+k;
                                else
                                    temp = temp_2 +k;
                                    TAI_for_judge =  (i+1)*(i+2)*0.5 -k;
                                end
                                if ~ismember(temp, TAL)
                                    TAL = cell_judge_imp(temp, ref_direction(1)*i+current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal, TAI_for_judge,TAL_size);

                                end
                            end
                        end
                   end

               else  
                   %% case adjacent directions, which include one in the vertical direction
                   if abs(direction_history(1,1))==1
                       temp_3 = direction_history(2,1);
                       temp_4 = direction_history(1,1);
                       ref_direction(3) = ref_direction(2);
                       TAI_for_judge_ref = i*(i+1)/2+1;
                       TAI_for_judge_ref2 = 1;
                   else
                       temp_3 = direction_history(1,1);
                       temp_4 = direction_history(2,1);
                       ref_direction(3) = ref_direction(1);
                       TAI_for_judge_ref = (i+1)*(i+2)/2;
                       TAI_for_judge_ref2 = -1;
                   end
                   if i >=2
                        m = i:-1:2;
                        for j = 1:i-1    
                             TAI_for_judge = TAI_for_judge_ref+TAI_for_judge_ref2*j;
                             temp_5 = current_TAI- temp_3*j;
                             temp_6 = temp_5-temp_4*(m(j)-1);
                             TAL = cell_judge_imp(temp_6, ref_direction(3)*j+current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal,TAI_for_judge, TAL_size);
                        end
                   end                               
               end
            end
            case 'big cone'
                %%
                %%
            TAL = [];
            for i = 1:(N+1)
                for j = 1:(N+1)
                    if i <=j
                        TAI_for_judge_ref(i,j) = j*j-i+1;
                    else
                        TAI_for_judge_ref(i,j) = (i-1)*(i-1)+j;
                     end
                end
            end
            % firstly we need to decide the reference position(current_TAI); 
            current_TAI_pos = cell_num_transition(current_TAI, new_cells_up);

            % we need another reference direction, which depends on the
            % direction_history, ref_direction together with current_TAI_pos, we could
            % know column number of every distributed cell
            for i = 1:2
                if direction_history(i,1) ==1 || direction_history(i,1) == -1
                    ref_direction(i) = 0;
                elseif direction_history(i,1)> 1
                    ref_direction(i) = -1;
                else
                    ref_direction(i) = 1;
                end
            end
            
            for i = 0:N
                cell_in_direction_2_base = current_TAI-direction_history(1,1)*N - direction_history(2,1)*i;
                TAI_for_judge = TAI_for_judge_ref(end,i+1);
                TAL = cell_judge_imp(cell_in_direction_2_base, ref_direction(1)*N+ref_direction(2)*i+...
                    current_TAI_pos(1), TAL, new_cells_up, Cell_num_cal, TAI_for_judge,TAL_size);
                for j = 1:N
                    cell_temp = cell_in_direction_2_base + direction_history(1,1)*j;
                    TAI_for_judge = TAI_for_judge_ref(end-j,i+1);
                    TAL = cell_judge_imp(cell_temp, -ref_direction(1)*j+current_TAI_pos(1)+ref_direction(1)*N+...
                        ref_direction(2)*i, TAL, new_cells_up, Cell_num_cal, TAI_for_judge,TAL_size);
                end
            end 
        end
    end
end
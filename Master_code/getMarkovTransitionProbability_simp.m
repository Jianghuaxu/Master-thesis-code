function P = getMarkovTransitionProbability_simp(n,type, six_directions, p_index, p_call)
%meaning of n: 
% 1, in the linear case: number of cells in the line
% 2, in the conical case:  number of cells in border line 
% 3, in the circular case: number of rings in the circle 

switch type
    case 'linear'
        %initiate the Markov Transition Probability matrix(nxn)
        P = p_call*eye(n,n);
        p_temp1 = six_directions(p_index, 3);
        p_temp2 = six_directions(find(six_directions(:,1) == -six_directions(p_index,1)),3);
        p_temp3 =1-p_call-p_temp1;
        p_temp4 = p_temp3-p_temp2;
        for i = 1:n
            if i == 1
                P(i,1) = P(i,1)+p_temp3;
                P(i,2) = p_temp1;
            elseif i ==n
                P(i,1) =P(i,1)+ p_temp1 + p_temp4;
                P(i, i-1) = P(i,i-1)+p_temp2;
            elseif i<n && i>1
                P(i,i-1) = p_temp2;
                P(i, i+1) = p_temp1;
                P(i,1) = P(i,1)+p_temp4;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%Work ended hier am Mittwoch%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'circular'
       %initiate the Markov Transition Probability matrix
        P = p_call*eye(3*n^2+3*n+1);
        p_circular = (1-p_call)/6;
        %In circular, we adopt symmtric random walk model
        %so p_circular is the same for all 6 directions
        
        %for this case, we divide the whole circular into 3 parts 
        % part 1: Number_ring = 0, only 1 single cell existent, which doesn't need to 
        %            consider, cause in this small snapshots we assume
        %            number of the cells is more than 1!
        % part 2: Number_ring = 1, totally 7 cells existent
        % part 3: 1<Number_ring=n, totally 3n^2+3n+1 cells existent
        
        %okay! let's start construct the whole project
        
        %firstly we consider part 2, which is very simple
        if n==1
            for j = 1:6
                P(1,j+1)= P(1, j+1)+p_circular;
                P(j+1,1) = P(j+1,1)+4*p_circular;
                if j==1
                    P(j+1,6+1) = p_circular;
                    P(j+1, j+2) = p_circular;
                elseif j == 6
                    P(j+1,j) = p_circular;
                    P(j+1, 2) = p_circular;
                else
                    P(j+1, j) = p_circular;
                    P(j+1, j+2) = p_circular;
                end
            end
       
        
        %then we consider the most hardest case: part 3
        else
            for j = 1:6
                temp = 2*j+6;
                P(1,j+1)= P(1, j+1)+p_circular;
                P(j+1,1) = P(j+1,1)+p_circular;
                P(j+1, temp)=p_circular;
                if j==1
                    P(j+1,6+1) = p_circular;
                    P(j+1, j+2) = p_circular;
                    P(j+1, temp+1) = p_circular;
                    P(j+1, temp-1+12) = p_circular;
                elseif j == 6
                    P(j+1,j) = p_circular;
                    P(j+1, 2) = p_circular;
                    P(j+1, temp+1) = p_circular;
                    P(j+1, temp-1) = p_circular;
                else
                    P(j+1, j) = p_circular;
                    P(j+1, j+2) = p_circular;
                    P(j+1, temp+1) = p_circular;
                    P(j+1, temp-1) = p_circular;
                end
                
            end

            for i= 2:n %i represents ring serial number
                for j = 1:6 % j represents each cell in 6 directions
                    for k = 1:i % i represents cells between 2 directions
                           temp_i = 3*(i-1)^2+3*(i-1)+i*(j-1)+k+1;
                           temp_i_plus = 3*i^2+3*i+(i+1)*(j-1)+k+1;
                           temp_i_minus = 3*(i-2)^2+3*(i-2)+(i-1)*(j-1)+k+1;
                        if k==1
                            %here we consider cells along the original 6
                            %directions
                            P(temp_i, temp_i_minus) = p_circular;
                            P(temp_i, temp_i+1) = p_circular;
                            if i==n
                                P(temp_i, 1) = P(temp_i, 1)+3*p_circular;
                                if j==1
                                    P(temp_i, temp_i-1+6*i) = p_circular;
                                else
                                    P(temp_i, temp_i-1) = p_circular;
                                end
                             else
                                P(temp_i, temp_i_plus) = p_circular;
                                P(temp_i, temp_i_plus+1) = p_circular;
                                if j==1
                                    P(temp_i, temp_i-1+6*i) = p_circular;
                                    P(temp_i, temp_i_plus-1+6*1) = p_circular;
                                else
                                     P(temp_i, temp_i-1) = p_circular;
                                     P(temp_i, temp_i_plus-1) = p_circular;
                                end
                            end
 
                        else
                            %here we consider cells right in the 
                            %right side of each 6 directions
                            P(temp_i, temp_i-1) = p_circular;                            
                            P(temp_i, temp_i_minus-1)=p_circular;
                            if i==n
                                P(temp_i, 1) = P(temp_i,1)+2*p_circular;
                            else
                                 P(temp_i, temp_i_plus) = p_circular;
                                 P(temp_i, temp_i_plus+1) = p_circular;
                            end
                            if k==i && j==6
                               P(temp_i, temp_i_minus-6*(i-1)) = p_circular;
                               P(temp_i, temp_i+1-6*i) = p_circular;
                            else
                                P(temp_i, temp_i_minus) = p_circular;
                                P(temp_i, temp_i+1) = p_circular;
                            end
                        end
                    end
                end
            end
        end
        
    case 'conical'
        %initiate the Markov Transition Probability matrix
        P = p_call*eye(0.5*n*(n+1),0.5*n*(n+1));
        % now it's important to get the neighbor-probabilities arount two
        % edges based on these two edges
        
        
        
        if p_index(1)<p_index(2) 
            if p_index(1) == 1 && p_index(2) == 6
                a= [5,4,3,2];
            else
                for i = 1:4
                temp = p_index(2)+i;
                    if temp<7
                        a(i) = temp;
                    else
                        a(i)=mod(temp,6);  
                    end
                end
            end 
        else
            if p_index(1) == 6 && p_index(2) == 1
                a = [5,4,3,2];
            else
                for i = 1:4
                    temp = p_index(1)+i;
                    if temp<7
                        a(i) = temp;
                    else
                        a(i) = mod(temp,6);  
                    end
                end
            end
            a= fliplr(a);
        end
        
        
        
        % until now we got:
        % p_east = a(1); p_north_east = a(2);
        % p_north_west = a(3); p_west = a(4); 
        
        
        %divide the whole matrix into three small parts
        %part 1: first row
        %part 2: rows between the first & last row
        %part 3: last row

        %part 1 corresponds to the S1
        temp = 0;
        for i = 1:4
            temp = temp + six_directions(a(i),3);
        end
        P(1,1) = P(1,1)+temp;
        P(1,2) = six_directions(p_index(1),3);
        P(1,3) = six_directions(p_index(2),3);
        
        
        
        %part 3 corresponds to the last row, which has n elements
        for j = 1:n
            P(0.5*n*(n-1)+j,1) = six_directions(p_index(1),3) + six_directions(p_index(2),3);
            if j == 1
                P(0.5*n*(n-1)+j,1) = P(0.5*n*(n-1)+j,1) + six_directions(a(3),3)+...
                    six_directions(a(4),3);
                P(0.5*n*(n-1)+j,0.5*(n-1)*(n-2)+j) =P(0.5*n*(n-1)+j,0.5*(n-1)*(n-2)+j)+ ...
                    six_directions(a(2),3);
                P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j+1) =  P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j+1) +...
                    six_directions(a(1),3);
            elseif j == n
                P(0.5*n*(n-1)+j,1) = P(0.5*n*(n-1)+j,1) + six_directions(a(1),3)+...
                    six_directions(a(2),3);
                P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j-1) = P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j-1)+...
                    six_directions(a(4),3);
                P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j-1) = P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j-1)+...
                    six_directions(a(3),3);
            elseif j<n && j>1
                P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j-1) = P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j-1)+...
                    six_directions(a(4),3);
                P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j+1) = P(0.5*n*(n-1)+j, 0.5*n*(n-1)+j+1)+...
                    six_directions(a(1),3);
                P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j-1) = P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j-1)+...
                    six_directions(a(3),3);
                P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j) =P(0.5*n*(n-1)+j, 0.5*(n-1)*(n-2)+j)+...
                    six_directions(a(2),3);
            end
        end

        %part 2 corresponds other rows between first and last row
        %part 2 exists if there are more than 2 rows in this matrix
        for i = 2:(n-1)
            for j = 1:i
                P(0.5*i*(i-1)+j,0.5*(i+1)*i+j) = six_directions(p_index(1),3);
                P(0.5*i*(i-1)+j,0.5*(i+1)*i+j+1) = six_directions(p_index(2),3);
                if j == 1
                    P(0.5*i*(i-1)+j,1) = P(0.5*i*(i-1)+j,1) + six_directions(a(3),3)+...
                    six_directions(a(4),3);
                    P(0.5*i*(i-1)+j,0.5*(i-1)*(i-2)+j) = P(0.5*i*(i-1)+j,0.5*(i-1)*(i-2)+j)+...
                        six_directions(a(2),3);
                    P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j+1) =P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j+1)+ ...
                        six_directions(a(1),3);
                elseif j == i
                    P(0.5*i*(i-1)+j,1) = P(0.5*i*(i-1)+j,1) + six_directions(a(1),3)+...
                    six_directions(a(2),3);
                    P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j-1) =  P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j-1)+...
                        six_directions(a(4),3);
                    P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j-1) =  P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j-1)+...
                        six_directions(a(3),3);
                elseif j<i && j>1
                    P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j-1) = P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j-1)+...
                        six_directions(a(4),3);
                    P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j+1) = P(0.5*i*(i-1)+j, 0.5*i*(i-1)+j+1)+...
                        six_directions(a(1),3);
                    P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j-1) = P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j-1)+...
                        six_directions(a(3),3);
                    P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j) =  P(0.5*i*(i-1)+j, 0.5*(i-1)*(i-2)+j)+...
                        six_directions(a(2),3);
                end
            end
        end
        
    case 'big cone'
        
    %% initiate the Markov Transition Probability matrix
        P = p_call*eye(n*n,n*n);
        % now it's important to get the neighbor-probabilities arount two
        % edges based on these two edges
        
        
        
        if p_index(1)<p_index(2) 
            if p_index(1) == 1 && p_index(2) == 5
                a= [6,4,3,2];
            elseif p_index(1) == 2 && p_index(2) == 6
                a= [1,5,4,3];
            else
                a(1) = p_index(2)-1;
                for i = 2:4
                temp = p_index(2)+i-1;
                    if temp<7
                        a(i) = temp;
                    else
                        a(i)=mod(temp,6);  
                    end
                end
            end 
        else
            if p_index(1) == 6 && p_index(2) == 2
                a = [5,4,3,1];
            elseif p_index(1) == 5 && p_index(2) == 1
                a = [4,3,2,6];
            else
                a(4) = p_index(1)-1;
                for i = 1:3
                    temp = p_index(1)+i;
                    if temp<7
                        a(i) = temp;
                    else
                        a(i) = mod(temp,6);  
                    end
                end
            end
            a= fliplr(a);
        end
        
        
        
        % until now we got:
        % p_south = a(1); p_east = a(2);
        % p_north = a(3); p_west = a(4); 
        
        
        %divide the whole matrix into three small parts
        %part 1: first row
        %part 2: rows between the first & last row
        %part 3: last row

        %part 1 corresponds to the S1
        temp = 0;
        for i = 2:4
            temp = temp + six_directions(a(i),3);
        end
        P(1,1) = P(1,1)+temp;
        P(1,2) = six_directions(p_index(1),3);
        P(1,3) = six_directions(a(1),3);
        P(1,4) = six_directions(p_index(2),3);
        
        
        
        %part 3 corresponds to the last row, which has 2n-1 elements
        for j = 1:n
            P((n-1)*(n-1)+j,1) = six_directions(p_index(1),3) + six_directions(a(1),3);
            if j == 1
                P((n-1)*(n-1)+j,1) = P((n-1)*(n-1)+j,1) + six_directions(a(3),3)+...
                    six_directions(a(4),3);
                P((n-1)*(n-1)+j,(n-2)*(n-2)+j) =P((n-1)*(n-1)+j,(n-2)*(n-2)+j)+ ...
                    six_directions(a(2),3);
                P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1) =  P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1) +...
                    six_directions(p_index(2),3);
            elseif j == n
                P((n-1)*(n-1)+j,1) = P((n-1)*(n-1)+j,1) + six_directions(p_index(2),3);
                P((n-1)*(n-1)+j, (n-1)*(n-1)+j-1) = P((n-1)*(n-1)+j, (n-1)*(n-1)+j-1)+...
                    six_directions(a(4),3);
                P((n-1)*(n-1)+j, (n-2)*(n-2)+j-1) = P((n-1)*(n-1)+j, (n-2)*(n-2)+j-1)+...
                    six_directions(a(3),3);
                P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1) = P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1) +...
                    six_directions(a(2),3);
            elseif j<n && j>1
                P((n-1)*(n-1)+j, (n-1)*(n-1)+j-1) = P((n-1)*(n-1)+j, (n-1)*(n-1)+j-1)+...
                    six_directions(a(4),3);
                P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1) = P((n-1)*(n-1)+j, (n-1)*(n-1)+j+1)+...
                    six_directions(p_index(1),3);
                P((n-1)*(n-1)+j, (n-2)*(n-2)+j-1) = P((n-1)*(n-1)+j, (n-2)*(n-2)+j-1)+...
                    six_directions(a(3),3);
                P((n-1)*(n-1)+j, (n-2)*(n-2)+j) =P((n-1)*(n-1)+j, (n-2)*(n-2)+j)+...
                    six_directions(a(2),3);
            end
        end
        
        for j = 1:n-1
            P((n-1)*(n-1)+n+j,1) =P((n-1)*(n-1)+n+j,1)+ six_directions(a(1),3) +...
                six_directions(p_index(2),3);
            if j == n-1
                P((n-1)*(n-1)+n+j,1) = P((n-1)*(n-1)+n+j,1) + six_directions(a(2),3)+...
                   six_directions(a(3),3) ;
                P((n-1)*(n-1)+n+j, (n-1)*(n-1)+n+j-1) = P((n-1)*(n-1)+n+j, ...
                    (n-1)*(n-1)+n+j-1)+six_directions(p_index(1),3);
                P((n-1)*(n-1)+n+j, (n-1)*(n-1)) = P((n-1)*(n-1)+n+j, (n-1)*(n-1))+...
                    six_directions(a(4),3);
            else
                P((n-1)*(n-1)+n+j, (n-1)*(n-1)+n+j-1) = P((n-1)*(n-1)+n+j, ...
                    (n-1)*(n-1)+n+j-1)+ six_directions(p_index(1),3);
                P((n-1)*(n-1)+n+j, (n-1)*(n-1)+n+j+1) = P((n-1)*(n-1)+n+j, ...
                    (n-1)*(n-1)+n+j+1)+ six_directions(a(2),3);
                P((n-1)*(n-1)+n+j, (n-2)*(n-2)+(n-1)+j-1) = P((n-1)*(n-1)+n+j,...
                    (n-2)*(n-2)+(n-1)+j-1)+ six_directions(a(4),3);
                P((n-1)*(n-1)+n+j, (n-2)*(n-2)+(n-1)+j) =P((n-1)*(n-1)+n+j, ...
                    (n-2)*(n-2)+(n-1)+j)+ six_directions(a(3),3);
            end
        end
        

        %part 2 corresponds other rows between first and last row
        %part 2 exists if there are more than 2 rows in this matrix
        for i = 2:(n-1)
            for j = 1:i
                P((i-1)*(i-1)+j,i*i+j) = six_directions(p_index(1),3);
                P((i-1)*(i-1)+j,i*i+j+1) = six_directions(a(1),3);
                if j == 1
                    P((i-1)*(i-1)+j,1) = P((i-1)*(i-1)+j,1) + six_directions(a(3),3)+...
                    six_directions(a(4),3);
                    P((i-1)*(i-1)+j,(i-2)*(i-2)+j) = P((i-1)*(i-1)+j, (i-2)*(i-2)+j)+...
                        six_directions(a(2),3);
                    P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1) =P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1)+...
                        six_directions(p_index(2),3);
                elseif j == i
                    P((i-1)*(i-1)+j,i*i+j+2) = P((i-1)*(i-1)+j,i*i+j+2)+...
                        six_directions(p_index(2),3);
                    P((i-1)*(i-1)+j, (i-1)*(i-1)+j-1) =  P((i-1)*(i-1)+j, (i-1)*(i-1)+j-1)+ ...
                        six_directions(a(4),3);
                    P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1) =  P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1)+ ...
                        six_directions(a(2),3);
                    P((i-1)*(i-1)+j, (i-2)*(i-2)+j-1) =  P((i-1)*(i-1)+j, (i-2)*(i-2)+j-1)+ ...
                        six_directions(a(3),3);                    
                elseif j<i && j>1
                    P((i-1)*(i-1)+j, (i-1)*(i-1)+j-1) = P((i-1)*(i-1)+j, (i-1)*(i-1)+j-1)+...
                        six_directions(a(4),3);
                    P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1) = P((i-1)*(i-1)+j, (i-1)*(i-1)+j+1)+ ...
                        six_directions(p_index(2),3);
                    P((i-1)*(i-1)+j, (i-2)*(i-2)+j-1) = P((i-1)*(i-1)+j, (i-2)*(i-2)+j-1)+...
                        six_directions(a(3),3);
                    P((i-1)*(i-1)+j, (i-2)*(i-2)+j) =  P((i-1)*(i-1)+j, (i-2)*(i-2)+j)+...
                        six_directions(a(2),3);
                end
            end
            for j = 1:(i-1)
                P((i-1)*(i-1)+i+j,(i-1)*(i-1)+i+j-1) = P((i-1)*(i-1)+i+j,(i-1)*(i-1)+i+j-1)+...
                    six_directions(p_index(1),3);
                P((i-1)*(i-1)+i+j, i*i+i+1+j) = P((i-1)*(i-1)+i+j, i*i+i+1+j)+...
                    six_directions(a(1),3);
                P((i-1)*(i-1)+i+j, i*i+i+2+j) = P((i-1)*(i-1)+i+j, i*i+i+2+j)+...
                    six_directions(p_index(2),3);
                if j == i-1
                    P((i-1)*(i-1)+i+j, 1) = P((i-1)*(i-1)+i+j, 1) + six_directions(a(2),3)+...
                        six_directions(a(3),3);
                    P((i-1)*(i-1)+i+j, (i-1)*(i-1)) = P((i-1)*(i-1)+i+j, (i-1)*(i-1))+...
                        six_directions(a(4),3);
                else
                     P((i-1)*(i-1)+i+j, (i-1)*(i-1)+i+j+1) = P((i-1)*(i-1)+i+j, (i-1)*(i-1)+i+j+1)+...
                         six_directions(a(2),3);
                     P((i-1)*(i-1)+i+j, (i-2)*(i-2)+i-2+j) = P((i-1)*(i-1)+i+j, (i-2)*(i-2)+i-2+j)+...
                         six_directions(a(4),3);
                     P((i-1)*(i-1)+i+j, (i-2)*(i-2)+i-1+j) = P((i-1)*(i-1)+i+j, (i-2)*(i-2)+i-1+j)+...
                         six_directions(a(3),3);
                end
            end
        end

end
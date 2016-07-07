function [mobility,Car_state] = getCarMobility_new (numTimesteps,...
   numVehiclesPerTimestep, vehiclesArray, TA_num, TA_radius)
%create new vehicles = timestemp + vehicles

newVehicles(:, [2:4, 6:(length(vehiclesArray(1,:)) +2)]) = vehiclesArray;
temp = 1;
for i = 1:numTimesteps
    newVehicles(temp:(temp+numVehiclesPerTimestep...
        (i)-1),1) = i*ones(numVehiclesPerTimestep(i),1);
    temp = temp + numVehiclesPerTimestep(i); 
end

%assign each geo location with a specific TA ID
TA_radius_y = 2*TA_radius/sqrt(3);
for i = 1:length(newVehicles)
    for j = 1: length(TA_num)
        delta_x = abs(newVehicles(i, 3)-TA_num(j,2));
        delta_y = abs(newVehicles(i, 4)-TA_num(j,3));
        if delta_x >TA_radius || delta_y > TA_radius_y
            continue;
        elseif (TA_radius_y - delta_y)*sqrt(3)<=delta_x
            continue;
        else
            newVehicles(i, 5) = TA_num(j, 1);
        end
    end
end

% clean all UE with its location out of our whole limited region in cologne
newVehicles(find(newVehicles(:,5)==0),:) = [];    

% the number of cars in this region could also be changed, here for
% example reduce the number of cars to one half
% carID_num = unique(newVehicles(:,2));
% carID_discarded = carID_num(500:end);
% newVehicles_discarded = newVehicles;
% for i = 1:length(carID_discarded)
%      newVehicles_discarded(find(newVehicles_discarded(:,2)==carID_discarded(i)),:)=[];
% end


% variable 'numVehiclesPerTimestep' has to be changed accordingly.
last_num = newVehicles(end,1);
numVehiclesPerTimestep_new = zeros(last_num,1);
for i = 1:last_num
    numVehiclesPerTimestep_new(i) = length(find(newVehicles(:,1)==i));
end

%sort newVehicles according to car_id
carID_num = unique(newVehicles(:,2));
temp = 1;
for i = 1: length(carID_num)
    carID_position = find (newVehicles(:,2) == carID_num(i));
    newVehicles_sort(temp:(temp+length(carID_position)-1),:)...
        = newVehicles(carID_position,:);
    temp = temp + length(carID_position);
end

%rename the car_id into char format like: Car_1,
%Car_2, .... Car_n, and construct a struct format mobility data
carID_char = cell(length(carID_num),1);
for i = 1:length(carID_num)
    carID_char{i} = ['Car_', int2str(i)];
    for j = 1:numTimesteps
        mobility.( carID_char{i} ).(['time_', int2str(j)]) = [];
    end
end

for i = 1: length(carID_num)
    idx = find(newVehicles_sort(:,2) == carID_num(i));
    carID_char{i} = ['Car_', int2str(i)];
    for j = 1: length(idx)
        timeID_char=cell(length(idx),1);
        timeID_char{j} = ['time_',int2str(newVehicles_sort(idx(j),1))];
        mobility.(carID_char{i}).(timeID_char{j}).coordinate = newVehicles_sort(idx(j), [3,4]);
        mobility.(carID_char{i}).(timeID_char{j}).TAI = newVehicles_sort(idx(j), 5);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).speed =...
%         newVehicles_sort(idx(j), 6);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).angleDegree =...
%         newVehicles_sort(idx(j), 7);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).angleRad =...
%         newVehicles_sort(idx(j), 8);
        mobility.(carID_char{i}).(timeID_char{j}).state = 0;
    end
end

% get a struct data, so that we could know, at which time, which cars exist.
% temp = 1;
% for i = 1:numTimesteps
%     temp_new = numVehiclesPerTimesteps_new(i);
%     temp_char = cell(temp_new,1);
%     for a = 1: temp_new
%         idx(a) = find(carID_num(:) == newVehicles(temp,2));
%         temp_char(a) = carID_char(idx(a));
%         temp = temp +1;
%     end
%     car_state.(['time_', int2str(i)]) = temp_char';
% end

% % a new data struct for car_state would be made here
temp = 1;
Car_state = cell(numTimesteps,1);
idx=[];
for i = 1: numTimesteps
    for j = 1:numVehiclesPerTimestep_new(i)
        idx(j) = find(carID_num(:) == newVehicles(temp,2));
        temp = temp+1;
    end
    Car_state{i} = idx';
    idx = [];
end


end

function [mobility, car_state,newVehicles_sort, newVehicles] = getCarMobility (numTimesteps,...
   numVehiclesPerTimestep, vehicles, TA_scheme, TA_radius_x)
%create new vehicles = timestemp + vehicles
newVehicles(:, [2:4, 6:(length(vehicles(1,:)) +2)]) = vehicles;
temp = 1;
for i = 1 : numTimesteps
    newVehicles([temp:(temp+numVehiclesPerTimestep...
        (i)-1)],1) = i*ones(numVehiclesPerTimestep(i),1);
    temp = temp + numVehiclesPerTimestep(i); 
end

%sort newVehicles according to car_id
carID_num = unique(vehicles(:,1));
car_acount = length(carID_num);
temp = 1;
for i = 1: length(carID_num)
    carID_position = find (newVehicles(:,2) == carID_num(i));
    newVehicles_sort([temp:(temp+length(carID_position)-1)],:)...
        = newVehicles(carID_position,:);
    temp = temp + length(carID_position);
end


%assign each geo location with a specific TA ID
TA_radius_y = 2*TA_radius_x/sqrt(3);
for i = 1:length(newVehicles_sort)
    for j = 1: length(TA_scheme)
        delta_x = abs(newVehicles_sort(i, 3)-TA_scheme(j,2));
        delta_y = abs(newVehicles_sort(i, 4)-TA_scheme(j,3));
        if delta_x >TA_radius_x || delta_y > TA_radius_y
            continue;
        elseif (TA_radius_y - delta_y)*sqrt(3)<=delta_x
            continue;
        else
            newVehicles_sort(i, 5) = TA_scheme(j, 1);
        end
    end
end
temp_rows = find(newVehicles_sort(:,5)==0);
newVehicles_sort(temp_rows,:) = [];


%rename the car_id into char format like: Car_1,
%Car_2, .... Car_n, and construct a struct format mobility data
for i = 1:length(carID_num)
    for j = 1:numTimesteps
        carID_char{i}= ['Car_', num2str(i)];
        time_id = ['time_', num2str(j)];
        mobility.(carID_char{i}).(time_id) = [];
    end
end

for i = 1: length(carID_num)
    idx = find(newVehicles_sort(:,2) == carID_num(i));
    for j = 1: length(idx)
        mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).coordinate =...
        newVehicles_sort(idx(j), [3,4]);
        mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).TAI =...
        newVehicles_sort(idx(j), 5);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).speed =...
%         newVehicles_sort(idx(j), 6);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).angleDegree =...
%         newVehicles_sort(idx(j), 7);
%         mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).angleRad =...
%         newVehicles_sort(idx(j), 8);
        mobility.(carID_char{i}).(['time_',num2str(newVehicles_sort(idx(j),1))]).state =...
        0;
    end
end

% %get a struct data, so that we could know, at which time, which cars exist.
% temp = 1;
% for i = 1:numTimesteps
%     for a = 1: numVehiclesPerTimestep(i)
%         for j = 1: length(carID_num)
%              idx = find(carID_num(:) == newVehicles(temp,2));
%         end
%         temp_char(a) = carID_char(idx);
%         temp = temp +1;
%         car_state.(['time_', num2str(i)]) = temp_char';
%     end
% end
% a new data struct for car_state would be made here
temp = 1;
Car_state = cell(numTimesteps,1);
for i = 1: numTimesteps
    temp_new = numVehiclesPerTimesteps_new(i);
    for j = 1:temp_new
        idx(j) = find(carID_num(:) == newVehicles(temp,2));
        temp = temp+1;
    end
    Car_state{i} = idx;
end



end

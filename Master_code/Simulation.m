clc
clear
load Parameter_for_3600
load vehiclesArray1_500





% %-------------------------------------------------------------------%
% % %get city geografic coordinates in form [Lat_max, Lon_min, Lat_min, Lon_max]
% city_geo_coordinate    = [max(vehiclesArray(:,2)),...
%     min(vehiclesArray(:,3)), min(vehiclesArray(:,2)), max(vehiclesArray(:,3))];
% % please input how big the cell_size should be
% TA_radius                    = input('please enter the radius of the TA:  ');
% obj                               = devideTA(city_geo_coordinate, TA_radius);
% [TA_num,TA_acount,Nx, Ny,Nx2, Ny2]   = obj.getTA;


% 
% 
% fprintf('The whole city is devided into %d TAs', TA_acount);

%-------------------------------------------------------------------%
%get mobility in format: mobility.Car_ID.time_ID.[coordinate, TAI, TAL, TAI_history]
[mobility, Car_state] = getCarMobility_new (numTimesteps1_7199,...
   numVehiclesPerTimestep1_7199, vehiclesArray1_7199, TA_num, TA_radius);
disp(' mobility is got in format : mobility.Car_ID.time_ID.[coordinate, TAI]')

%-------------------------------------------------------------------%
%using the mobility and car_state, we could now simulate all these things
%to implement different TAL schemes and then compare them through costs and
%process time. time could be obtained by using (tic; t = toc;)
% sensitivity test for paging_rate

clear Mobility costs Scheme_number_count Mobility_DB costs_DB Scheme_number_count_DB
[Mobility_Mixed,costs_mixed, Scheme_number_count_mixed] = simulate(mobility, Car_state, numTimesteps1_7199, Nx, Nx2, Ny, Ny2,1000,3, 2);
[Mobility_DB,costs_DB, Scheme_number_count_DB] = simulate(mobility, Car_state, numTimesteps1_7199, Nx, Nx2, Ny, Ny2,1000,2, 2);



     
    


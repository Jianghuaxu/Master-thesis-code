clc;
clear;
load Parameter_for_3600;
load numVehiclesPerTimestep1_3600;
load vehiclesArray1_3600;


% %-------------------------------------------------------------------%
% %get city geografic coordinates in form [Lat_max, Lon_min, Lat_min, Lon_max]
% city_geo_coordinate    = [max(vehiclesArray(:,2)),...
%     min(vehiclesArray(:,3)), min(vehiclesArray(:,2)), max(vehiclesArray(:,3))];
%% firstly a new Micro_cell_topology is designed

TA_radius                                = input('please enter the radius of the TA:  ');
obj_micro                                = devideTA(city_geo_coordinate_new, TA_radius);
[TA_num_micro,TA_acount_micro,Nx_micro, Ny_micro,Nx2_micro, Ny2_micro]   = obj_micro.getTA;

% now Macro_cell_topology is designed
TA_radius_macro = 2*TA_radius;
temp_coor = city_geo_coordinate_new;
temp_coor(1) = temp_coor(1) - TA_radius;
temp_coor(2) = temp_coor(2) + TA_radius/sqrt(3);
city_geo_coordinate_for_macro = temp_coor;
obj_macro                               = devideTA(city_geo_coordinate_for_macro, TA_radius_macro);
[TA_num_macro,TA_acount_macro,Nx_macro, Ny_macro,Nx2_macro, Ny2_macro]   = obj_macro.getTA;
TA_num_macro(:,1) = TA_num_macro(:,1)+1000;

N_xy_micro = [Nx_micro, Nx2_micro, Ny_micro, Ny2_micro];
N_xy_macro = [Nx_macro, Nx2_macro, Ny_macro, Ny2_macro];

% 
% 
% fprintf('The whole city is devided into %d TAs', TA_acount);

%-------------------------------------------------------------------%
%get mobility in format: mobility.Car_ID.time_ID.[coordinate, TAI, TAL, TAI_history]
Areas = [1001:1010];
numTimesteps1_500 = 500;
[mobility_500, car_state_500, newVehicles_sort] = getCarMobility_micro_macro (numTimesteps1_500,...
   numVehiclesPerTimestep1_500, vehiclesArray1_500, TA_num_micro, TA_num_macro, TA_radius, TA_radius_macro,Areas);

Areas = [1001:1010];
numTimesteps1_3600 = 3600;
[mobility_3600, car_state_3600] = getCarMobility_micro_macro (numTimesteps1_3600,...
   numVehiclesPerTimestep1_3600, vehiclesArray1_3600, TA_num_micro, TA_num_macro, TA_radius, TA_radius_macro,Areas);



numTimesteps1_3600 = 3600;
[mobility_3600, car_state_3600] = getCarMobility_half (numTimesteps1_3600,...
   numVehiclesPerTimestep1_3600, vehiclesArray1_3600, TA_num_micro, TA_radius);

numTimesteps1_3600 = 3600;
[mobility_3600_macro, car_state_3600_macro] = getCarMobility_micro_macro (numTimesteps1_3600,...
   numVehiclesPerTimestep1_3600, vehiclesArray1_3600, TA_num_new, TA_radius, Areas);

numTimesteps1_7199 = 7199;
[mobility_7199, car_state_7199] = getCarMobility_half (numTimesteps1_7199,...
   numVehiclesPerTimestep1_7199, vehiclesArray1_7199, TA_num_new, TA_radius);


%-------------------------------------------------------------------%
%using the mobility and car_state, we could now simulate all these things
%to implement different TAL schemes and then compare them through costs and
%process time. time could be obtained by using (tic; t = toc;)
% sensitivity test for paging_rate
Nx = Nx_micro; Nx2 = Nx2_micro;
Ny = Ny_micro;  Ny2 = Ny2_micro;
[Mobility_3600_imp, Cost_3600_imp, Scheme_number_count_imp] = simulate_imp(mobility_3600, car_state_3600, numTimesteps1_3600, Nx, Nx2, Ny, Ny2,500, 3, 4);
[Mobility_3600_ori, Cost_3600_ori, Scheme_number_count_ori] = simulate(mobility_3600, car_state_3600, numTimesteps1_3600, Nx, Nx2, Ny, Ny2,500, 3, 4);
[Mobility_3600_simp, Cost_3600_simp, Scheme_number_count_simp] = simulate_simp(mobility_3600, car_state_3600, numTimesteps1_3600, Nx, Nx2, Ny, Ny2,500, 3, 4);
[Mobility_3600_cir, Cost_3600_cir, Scheme_number_count_cir] = simulate(mobility_3600, car_state_3600, numTimesteps1_3600, Nx, Nx2, Ny, Ny2,500, 2, 4);


[Mobility_3600_2, Cost_3600_2] = simulate_micro_macro(mobility_3600, car_state_3600, numTimesteps1_3600, N_xy_micro, N_xy_macro,500, 3, 4);

    


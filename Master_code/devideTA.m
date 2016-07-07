classdef devideTA
 
    %city_geo_coordinates is in form of [x1, y1, x2, y2];
    properties(Access = public)
        city_geo_coordinate;
        cell_radius_x;
        mobility;
        car_acount;
    end
    properties(Dependent)
        cell_radius_y;
        city_geo_ref_point;
        TA;
    end
    
    methods
        
        %firstly define constructor for this class
         function obj = devideTA(city_geo_coordinate,...
                 cell_rad)
             if nargin == 2
                 obj.city_geo_coordinate = city_geo_coordinate;
                 obj.cell_radius_x = cell_rad;
             end
         end
        
         %degine dependent properties 1
        function cell_radius_y = get.cell_radius_y(obj)
            cell_radius_y = 3*(obj.cell_radius_x)/sqrt(3);
        end
          %degine dependent properties 2
        function city_geo_ref_point = get.city_geo_ref_point(obj)
              city_geo_ref_point = [(obj.city_geo_coordinate(1)-...
              obj.cell_radius_x), (obj.city_geo_coordinate(2)+obj.cell_radius_y)];
        end  
        
        %function getTA for designing Tracking Area
        %according to geo coordinates  
        function [TA_num, TA_acount, Nx, Ny, Nx2, Ny2]= getTA(obj)
          Nx = ceil((obj.city_geo_coordinate(1)-obj.city_geo_coordinate(3)+...
              obj.cell_radius_x)/(2*obj.cell_radius_x));
          Ny = ceil((obj.city_geo_coordinate(4)-obj.city_geo_coordinate(2)+...
              obj.cell_radius_y)/(2*obj.cell_radius_y));
          Nx2 = ceil((obj.city_geo_ref_point(1)-obj.city_geo_coordinate(3)+...
              obj.cell_radius_x)/(2*obj.cell_radius_x));
          Ny2 =  ceil((obj.city_geo_coordinate(4)-obj.city_geo_ref_point(2)+...
              obj.cell_radius_y)/(2*obj.cell_radius_y));
          
          TA_acount = Nx*Ny+Nx2*Ny2;
          
          %all data are stored in double format
          TA_num = zeros(TA_acount,3);
          for x = 1:Nx
              for y = 1:Ny
                  temp = (y-1)*(Nx+Nx2)+x;
                  TA_num(temp,1) = temp;
                  TA_num(temp, 2) = obj.city_geo_coordinate(1)...
                   - 2*obj.cell_radius_x*(x-1);
                  TA_num(temp, 3) = obj.city_geo_coordinate(2)...
                   + 2*obj.cell_radius_y*(y-1);
              end
          end
%             for y = 1: Ny
%               for x = 1: Nx
%                   TA_num(temp2,1) = temp2;
%                   TA_num(temp2,2) = obj.city_geo_coordinate(1)...
%                   - 2*obj.cell_radius_x*(x-1);
%                   TA_num(temp2,3)= obj.city_geo_coordinate(2)...
%                   + 2*obj.cell_radius_y*(y-1);
%                    if(mod(temp2,Nx) ~= 0 || tmp(end) == temp2) 
%                        temp2 = temp2 +1;
%                    else
%                        tmp(end +1) = temp2;
%                        temp2 = temp2+Nx2;
%                    end
%               end
%                temp2 = temp2+1;
%             end
            %continue
            
%             for y = 1: Ny2
%               for x = 1: Nx2
%                   idx = tmp(y+1)+x;
%                   TA_num(idx,1) = idx;
%                   TA_num(idx,2) = obj.city_geo_ref_point(1)...
%                   - 2*obj.cell_radius_x*(x-1);
%                   TA_num(idx,3)= obj.city_geo_ref_point(2)...
%                   + 2*obj.cell_radius_y*(y-1);
%               end
%              end 
            for x = 1:Nx2
              for y = 1:Ny2
                  temp = (y-1)*Nx2+y*Nx+x;
                  TA_num(temp,1) = temp;
                  TA_num(temp, 2) = obj.city_geo_ref_point(1)...
                   - 2*obj.cell_radius_x*(x-1);
                  TA_num(temp, 3) = obj.city_geo_ref_point(2)...
                   + 2*obj.cell_radius_y*(y-1);
              end
          end
        end
    end
end
 



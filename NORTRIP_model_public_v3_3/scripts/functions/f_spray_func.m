function [f_spray] = f_spray_func(R_0_spray,V_veh,V_ref_spray,V_thresh_spray,a_spray,water_spray_flag)

%Set common constants
%road_dust_set_constants_v2

f_spray=0;
if water_spray_flag && V_ref_spray>V_thresh_spray,
    f_spray=R_0_spray*(max(0,(V_veh-V_thresh_spray))/(V_ref_spray-V_thresh_spray))^a_spray;    
end
    
end


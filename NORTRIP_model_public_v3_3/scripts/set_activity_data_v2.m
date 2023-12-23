%==========================================================================
%NORTRIP model
%SUBROUTINE: set_activity_data_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby  and Ingrid Sundvor (bde@nilu.no)
%DESCRIPTION: Determines if road maintenance activities are undertaken
%==========================================================================

%Set common constants
%road_dust_set_constants_v2

%Internal variables
M_salting_0(1:num_salt)=0;
g_road_wetting_0=0;
g_road_0_data(1:num_moisture,1)=mean(g_road_data(1:num_moisture,max(min_time,ti-1),:,ro),3);
M_sanding_0=0;
t_ploughing_0=0;
t_cleaning_0=0;

%--------------------------------------------------------------------------
%Automatically add salt
%--------------------------------------------------------------------------
if auto_salting_flag,
    if auto_salting_flag==1,
        M_salting_0(1:num_salt)=0;
        g_road_wetting_0=0;
    elseif auto_salting_flag==2,
        M_salting_0(1:num_salt)=activity_data(M_salting_index(1:num_salt),ti,ro);
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);        
    end
    if ti==min_time,
        last_salting_time(ro)=date_data(datenum_index,min_time);
    end
    
    %Check temperature within range within the given delay time
    check_day=min(max_time,round(ti+dt*check_salting_day*24));
    salt_temperature_flag=0;
    for i=ti:check_day,
        if meteo_data(T_a_index,i,ro)>min_temp_salt&&meteo_data(T_a_index,i,ro)<max_temp_salt,
            salt_temperature_flag=1;
        end
    end
    %Check precipitation within range within +/- 1/2 the given delay time
    %check_day_min=max(min_time,round(ti-dt*check_salting_day*24/2));
    %check_day_max=min(max_time,round(ti+dt*check_salting_day*24/2));
    %check_day_min=ti;
    check_day_min=max(min_time,round(ti-dt*check_salting_day*24));
    check_day_max=min(max_time,round(ti+dt*check_salting_day*24));
    salt_precip_flag=0;
    for i=check_day_min:check_day_max,
        if meteo_data(Rain_precip_index,i,ro)+meteo_data(Snow_precip_index,i,ro)>precip_rule_salt,
            salt_precip_flag=1;
        end
    end
    %salt_precip_flag=1;

    check_day_min=ti;
    check_day_max=min(max_time,round(ti+dt*check_salting_day*24));
    salt_RH_flag=0;
    for i=check_day_min:check_day_max,
        if meteo_data(RH_index,i,ro)>RH_rule_salt,
            salt_RH_flag=1;
        end
    end

    if (date_data(hour_index,ti)==salting_hour(1)||date_data(hour_index,ti)==salting_hour(2))&&salt_temperature_flag...
            &&(salt_precip_flag||salt_RH_flag)&&(date_data(datenum_index,ti)-last_salting_time(ro))>=delay_salting_day,
       activity_data(M_salting_index(1),ti,ro)=M_salting_0(1)+salt_mass*salt_type_distribution;
       activity_data(M_salting_index(2),ti,ro)=M_salting_0(2)+salt_mass*(1-salt_type_distribution);       
       last_salting_time(ro)=date_data(datenum_index,ti);
       if sum(g_road_0_data(1:num_moisture))<g_salting_rule&&salt_dilution~=0,
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0+salt_mass*(1-salt_dilution)/salt_dilution*1e-3;
       else
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
       end
    else
       activity_data(M_salting_index(1),ti,ro)=M_salting_0(1);       
       activity_data(M_salting_index(2),ti,ro)=M_salting_0(2);       
       activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
    end

end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Automatically add sand
%--------------------------------------------------------------------------
if auto_sanding_flag,
    if auto_sanding_flag==1,
        M_sanding_0=0;
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);
    elseif auto_sanding_flag==2,
        M_sanding_0=activity_data(M_sanding_index,ti,ro);
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);        
    end
    
    if ti==min_time,
        last_sanding_time(ro)=date_data(datenum_index,min_time);      
    end
    
    %Check temperature within range within the given delay time
    check_day=min(max_time,round(ti+dt*check_sanding_day*24));
    sand_temperature_flag=0;
    for i=ti:check_day,
        if meteo_data(T_a_index,i,ro)>min_temp_sand&&meteo_data(T_a_index,i,ro)<max_temp_sand,
            sand_temperature_flag=1;
        end
    end
    
    %Check precipitation within range within +/- the given delay time
    check_day_min=max(min_time,round(ti-dt*check_sanding_day*24));
    check_day_max=min(max_time,round(ti+dt*check_sanding_day*24));
    sand_precip_flag=0;
    for i=check_day_min:check_day_max,
        if meteo_data(Rain_precip_index,i,ro)+meteo_data(Snow_precip_index,i,ro)>precip_rule_sand,
            sand_precip_flag=1;
        end
    end

    check_day_min=ti;
    check_day_max=min(max_time,round(ti+dt*check_sanding_day*24));
    sand_RH_flag=0;
    for i=check_day_min:check_day_max,
        if meteo_data(RH_index,i,ro)>RH_rule_sand,
            sand_RH_flag=1;
        end
    end

    if (date_data(hour_index,ti)==sanding_hour(1)||date_data(hour_index,ti)==sanding_hour(2))&&sand_temperature_flag...
            &&(sand_precip_flag||sand_RH_flag)&&(date_data(datenum_index,ti)-last_sanding_time(ro))>=delay_sanding_day,
       activity_data(M_sanding_index,ti,ro)=M_sanding_0+sand_mass;
       last_sanding_time(ro)=date_data(datenum_index,ti);
       if sum(g_road_0_data(snow_ice_index))>g_sanding_rule&&sand_dilution~=0,
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0+sand_mass/sand_dilution*1e-3;
       else
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
       end
    else
       activity_data(M_sanding_index,ti,ro)=0;       
       activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
    end

end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Automatically carry out ploughng based on previous hours
%--------------------------------------------------------------------------
plough_temp(1:num_moisture)=0;
if auto_ploughing_flag&&use_ploughing_data_flag,
    if auto_ploughing_flag==1,
        t_ploughing_0=0;
    elseif auto_ploughing_flag==2,
        t_ploughing_0=activity_data(t_ploughing_index,ti,ro);
    end

    if ti==min_time,
        time_since_last_ploughing(ro)=0;
    end
    
    plough_temp=mean(g_road_data(1:num_moisture,max(min_time,ti-1),1:num_track,ro),3);
    plough_moisture_flag=0;
    for m=1:num_moisture,
        if plough_temp(m)>ploughing_thresh(m),
            plough_moisture_flag=1;
        end
    end
    
    if plough_moisture_flag&&(time_since_last_ploughing(ro)>=delay_ploughing_hour),
        activity_data(t_ploughing_index,ti,ro)=t_ploughing_0+1;
        time_since_last_ploughing(ro)=0;
    else
        activity_data(t_ploughing_index,ti,ro)=t_ploughing_0;
        time_since_last_ploughing(ro)=time_since_last_ploughing(ro)+dt;
    end

end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Automatically carry out cleaning based on salting activity
%--------------------------------------------------------------------------
if auto_cleaning_flag&&use_cleaning_data_flag,
    
    if auto_cleaning_flag==1,
        t_cleaning_0=0;
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);
    elseif auto_cleaning_flag==2,
        t_cleaning_0=activity_data(t_cleaning_index,ti,ro);
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);        
    end

    if ti==min_time,
        time_since_last_cleaning(ro)=0;
    end

    if clean_with_salting,
        if sum(activity_data(M_salting_index(1:num_salt),ti,ro),1)>0,
            cleaning_allowed=1;
        else
            cleaning_allowed=0;
        end
    else
        cleaning_allowed=1;
    end
    
    %Check month
    if start_month_cleaning<=end_month_cleaning,
        if date_data(month_index,ti)>=start_month_cleaning&&date_data(month_index,ti)<=end_month_cleaning,
            cleaning_allowed=cleaning_allowed*1;
        else
            cleaning_allowed=0;
        end
    else
        if date_data(month_index,ti)>=start_month_cleaning||date_data(month_index,ti)<=end_month_cleaning,
            cleaning_allowed=cleaning_allowed*1;
        else
            cleaning_allowed=0;
        end
    end
    
    if (time_since_last_cleaning(ro)>=delay_cleaning_hour&&meteo_data(T_a_index,ti,ro)>min_temp_cleaning&&cleaning_allowed),
        activity_data(t_cleaning_index,ti,ro)=t_cleaning_0+efficiency_of_cleaning;
        time_since_last_cleaning(ro)=0;
        activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0+wetting_with_cleaning;
    else
        activity_data(t_cleaning_index,ti,ro)=t_cleaning_0;
        time_since_last_cleaning(ro)=time_since_last_cleaning(ro)+dt;
        activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
    end

end

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Automatically add second salt for binding
%--------------------------------------------------------------------------
if auto_binding_flag,
    if auto_binding_flag==1,
        M_salting_0(2)=0;
        g_road_wetting_0=0;
    elseif auto_binding_flag==2,
        M_salting_0(2)=activity_data(M_salting_index(2),ti,ro);
        g_road_wetting_0=activity_data(g_road_wetting_index,ti,ro);        
    end
    if ti==min_time,
        last_binding_time(ro)=date_data(datenum_index,min_time);
    end
    
    %Start with no binding allowed
    binding_allowed=0;
    
    %Check temperature within range within the given delay time
    check_day=min(max_time,round(ti+dt*check_binding_day*24));
    for i=ti:check_day,
        if meteo_data(T_a_index,i,ro)>min_temp_binding&&meteo_data(T_a_index,i,ro)<max_temp_binding,
            binding_allowed=1;
        end
    end
    %Check precipitation within range within +/- the given delay time
    check_day_min=max(min_time,round(ti-dt*check_binding_day*24));
    check_day_max=min(max_time,round(ti+dt*check_binding_day*24));
    for i=check_day_min:check_day_max,
        if meteo_data(Rain_precip_index,i,ro)+meteo_data(Snow_precip_index,i,ro)>precip_rule_binding,
        	binding_allowed=0;
        end
    end

    %Check month
    if start_month_binding<=end_month_binding,
        if date_data(month_index,ti)>=start_month_binding&&date_data(month_index,ti)<=end_month_binding,
            binding_allowed=binding_allowed*1;
        else
            binding_allowed=0;
        end
    else
        if date_data(month_index,ti)>=start_month_binding||date_data(month_index,ti)<=end_month_binding,
            binding_allowed=binding_allowed*1;
        else
            binding_allowed=0;
        end
    end
    
    %Check current surface conditions
    if sum(g_road_0_data(1:num_moisture))>g_binding_rule,
        binding_allowed=0;
    end
    
    check_day_min=ti;
    check_day_max=min(max_time,round(ti+dt*check_binding_day*24));
    binding_RH_flag=0;
    for i=check_day_min:check_day_max,
        if meteo_data(RH_index,i,ro)>RH_rule_binding,
            binding_RH_flag=1;
        end
    end
    
    if (date_data(hour_index,ti)==binding_hour(1)||date_data(hour_index,ti)==binding_hour(2))...
            &&(date_data(datenum_index,ti)-last_binding_time(ro))>=delay_binding_day...
            &&binding_RH_flag&&binding_allowed,
       
       activity_data(M_salting_index(2),ti,ro)=M_salting_0(2)+binding_mass;       
       last_binding_time(ro)=date_data(datenum_index,ti);
       
       if binding_dilution~=0,
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0+binding_mass*(1-binding_dilution)/binding_dilution*1e-3;
       else
           activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
       end
       
    else
       activity_data(M_salting_index(2),ti,ro)=M_salting_0(2);       
       activity_data(g_road_wetting_index,ti,ro)=g_road_wetting_0;
    end

end
%--------------------------------------------------------------------------


%Converts the input data (old variable structure) to the new variable
%structure
ro=1;

clear  date_data traffic_data meteo_data airquality_data activity_data f_conc f_dis

date_data(1:num_date_index,1:n_date,1:n_roads)=nodata;
traffic_data(1:num_traffic_index,1:n_date,1:n_roads)=nodata;
meteo_data(1:num_meteo_index,1:n_date,1:n_roads)=nodata;
activity_data(1:num_activity_index,1:n_date,1:n_roads)=nodata;
activity_data_input(1:num_activity_index,1:n_date,1:n_roads)=nodata;
%airquality_data(1:num_airquality_index,1:n_date,1:n_roads)=nodata;
f_conc(1:n_date,1:n_roads)=nodata;
f_dis(1:n_date,1:n_roads)=nodata;

date_data(year_index,1:n_date)=year;
date_data(month_index,1:n_date)=month;
date_data(day_index,1:n_date)=day;
date_data(hour_index,1:n_date)=hour;
date_data(minute_index,1:n_date)=minute;
date_data(datenum_index,1:n_date)=date_num;
clear year month day hour minute date_num

for ro=1:n_roads,
    traffic_data(N_total_index,1:n_date,ro)=N_total(1:n_date);
    traffic_data(N_v_index(1:num_veh),1:n_date,ro)=N_v(1:num_veh,1:n_date);
    traffic_data(V_veh_index(1:num_veh),1:n_date,ro)=V_veh(1:num_veh,1:n_date);
    for t=1:num_tyre,
        traffic_data(N_t_v_index(t,1:num_veh),1:n_date,ro)=N(t,1:num_veh,1:n_date);
    end
    
    meteo_data(T_a_index,1:n_date,ro)=T_a(1:n_date);
    meteo_data(T2_a_index,1:n_date,ro)=T2_a(1:n_date);
    meteo_data(FF_index,1:n_date,ro)=FF(1:n_date);
    meteo_data(DD_index,1:n_date,ro)=DD(1:n_date);
    meteo_data(RH_index,1:n_date,ro)=RH(1:n_date);
    meteo_data(Rain_precip_index,1:n_date,ro)=Rain(1:n_date);
    meteo_data(Snow_precip_index,1:n_date,ro)=Snow(1:n_date);
    meteo_data(short_rad_in_index,1:n_date,ro)=short_rad_in(1:n_date);
    meteo_data(long_rad_in_index,1:n_date,ro)=long_rad_in(1:n_date);
    meteo_data(cloud_cover_index,1:n_date,ro)=cloud_cover(1:n_date);
    meteo_data(short_rad_in_clearsky_index,1:n_date,ro)=nodata;
    meteo_data(road_temperature_obs_input_index,1:n_date,ro)=road_temperature_obs(1:n_date);
    meteo_data(road_wetness_obs_input_index,1:n_date,ro)=road_wetness_obs(1:n_date);
    meteo_data(T_dewpoint_index,1:n_date,ro)=T_dewpoint(1:n_date);
    meteo_data(pressure_index,1:n_date,ro)=Pressure_a(1:n_date);
    meteo_data(T_sub_input_index,1:n_date,ro)=T_sub(1:n_date);

    activity_data(M_sanding_index,1:n_date,ro)=M_sanding(1:n_date);
    activity_data(t_ploughing_index,1:n_date,ro)=t_ploughing(1:n_date);
    activity_data(t_cleaning_index,1:n_date,ro)=t_cleaning(1:n_date);
    activity_data(g_road_wetting_index,1:n_date,ro)=g_road_wetting(1:n_date);
    activity_data(M_salting_index(1),1:n_date,ro)=M_salting(1,1:n_date);
    activity_data(M_salting_index(2),1:n_date,ro)=M_salting(2,1:n_date);
    activity_data(M_fugitive_index,1:n_date,ro)=M_fugitive(1:n_date);
    
    f_dis(1:n_date,1:n_roads)=f_dis_input(1:n_date);
end

activity_data_input=activity_data;

clear T_a T2_a FF DD RH Rain Snow short_rad_in long_rad_in cloud_cover
clear road_temperature_obs road_wetness_obs T_sub T_dewpoint Pressure_a
clear M_sanding M_salting t_ploughing t_cleaning g_road_wetting M_fugitive
clear N_total N_v N V_veh
clear f_dis_input


    clear M_road_data M_road_bin_data M_road_balance_data M_road_bin_balance_data
    clear WR_time_data road_salt_data 
    clear C_data C_bin_data E_road_data E_road_bin_data 
    clear road_meteo_data g_road_balance_data g_road_data 
    clear f_q f_q_obs
    
    %Initialise forecast missing if forecast mode is used
    road_temperature_forecast_missing=[];

    %Initialise all arrays except the input data arrays
    M_road_data(1:num_source_all,1:num_size,1:n_date,1:num_track,1:n_roads)=0;   
    M_road_bin_data(1:num_source_all,1:num_size,1:n_date,1:num_track,1:n_roads)=0;   
    M_road_bin_balance_data(1:num_source_all,1:num_size,1:num_dustbalance,1:n_date,1:num_track,1:n_roads)=0;
    M_road_balance_data(1:num_source_all,1:num_size,1:num_dustbalance,1:n_date,1:num_track,1:n_roads)=0;
    WR_time_data(1:num_wear,1:n_date,1:num_track,1:n_roads)=0;
    road_salt_data(1:num_saltdata,1:num_salt,1:n_date,1:num_track,1:n_roads)=0;
    C_bin_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=0;
    C_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=0;
    E_road_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=0;
    E_road_bin_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=0;
    road_meteo_data(1:num_road_meteo,1:n_date,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,1:num_moistbalance,1:n_date,1:num_track,1:n_roads)=0;
    %WHY IS THIS +2 ???
    g_road_data(1:num_moisture+2,1:n_date,1:num_track,1:n_roads)=0;
    f_q(1:num_source_all,1:n_date,1:num_track,1:n_roads)=1;
    f_q_obs(1:n_date,1:num_track,1:n_roads)=nodata;
    
    %Mass balance data, is in size bins
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_wear_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_dustspray_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_dustspray_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_dustdrainage_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_windblown_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_suspension_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_cleaning_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_dustploughing_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_crushing_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,S_crushing_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_abrasion_index,min_time:max_time,1:num_track,1:n_roads)=0;
    M_road_bin_balance_data(1:num_source_all,1:num_size,P_depo_index,min_time:max_time,1:num_track,1:n_roads)=0;
    %M_road_bin_balance_data(1:num_source,1:num_size,P_allother_index,min_time:max_time,1:num_track,1:n_roads)=0;

    %Emission data
    E_road_data(1:num_source_all,1:num_size,E_direct_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_data(1:num_source_all,1:num_size,E_suspension_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_data(1:num_source_all,1:num_size,E_windblown_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_data(1:num_source_all,1:num_size,E_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_bin_data(1:num_source_all,1:num_size,E_direct_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_bin_data(1:num_source_all,1:num_size,E_suspension_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_bin_data(1:num_source_all,1:num_size,E_windblown_index,min_time:max_time,1:num_track,1:n_roads)=0;
    E_road_bin_data(1:num_source_all,1:num_size,E_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    
    %Concentration data
    C_data(1:num_source_all,1:num_size,C_direct_index,min_time:max_time,1:num_track,1:n_roads)=0;
    C_data(1:num_source_all,1:num_size,C_suspension_index,min_time:max_time,1:num_track,1:n_roads)=0;
    C_data(1:num_source_all,1:num_size,C_windblown_index,min_time:max_time,1:num_track,1:n_roads)=0;
    C_data(1:num_source_all,1:num_size,C_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    
    %Road salt data
    road_salt_data(RH_salt_index,1:num_salt,min_time:max_time,1:num_track,1:n_roads)=0;
    road_salt_data(melt_temperature_salt_index,1:num_salt,min_time:max_time,1:num_track,1:n_roads)=0;
    road_salt_data(dissolved_ratio_index,1:num_salt,min_time:max_time,1:num_track,1:n_roads)=0;

    %Road meteorological data
    road_meteo_data(T_s_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(T_melt_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(r_aero_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(r_aero_notraffic_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(RH_s_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(RH_salt_final_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(L_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(H_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(G_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(G_sub_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(evap_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(evap_pot_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(rad_net_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(short_rad_net_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(short_rad_net_clearsky_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(long_rad_net_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(long_rad_out_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(H_traffic_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(T_sub_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(road_temperature_obs_index,min_time:max_time,1:num_track,1:n_roads)=0;
    road_meteo_data(road_wetness_obs_index,min_time:max_time,1:num_track,1:n_roads)=0;

    %Road moisture mass balance production and sink data
    g_road_balance_data(1:num_moisture,S_melt_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_melt_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_freeze_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_evap_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,S_evap_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,S_drainage_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,S_spray_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,R_spray_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_spray_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,S_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_total_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_precip_index,min_time:max_time,1:num_track,1:n_roads)=0;
    g_road_balance_data(1:num_moisture,P_roadwetting_index,min_time:max_time,1:num_track,1:n_roads)=0;
    
    %Road moisture data
    g_road_data(1:num_moisture,min_time:max_time,1:num_track,1:n_roads)=0;

    %Initial mass loading values with road
    ti=min_time;
    t=su;
    for ro=1:n_roads,
    for tr=1:num_track,
    for s=1:num_source,
    for x=1:num_size,
        M_road_data(s,x,ti,tr,ro)=M_road_init(s,tr).*f_PM(s,x,t);
    end
    end
    end
    end
    
    %Initial surface moisture
    ti=min_time;
    for ro=1:n_roads,
    for tr=1:num_track,
    for m=1:num_moisture,
        g_road_data(m,ti,tr,ro)=g_road_init(m,tr);
    end
    end
    end

    %Initialise surface temperature and humidity
    ti=min_time;
    for ro=1:n_roads,
    for tr=1:num_track,
        road_meteo_data(T_s_index,ti,tr,ro)=meteo_data(T_a_index,ti,ro);
        road_meteo_data(RH_s_index,ti,tr,ro)=meteo_data(RH_index,ti,ro);
        road_meteo_data(T_sub_index,ti,tr,ro)=meteo_data(T_a_index,ti,ro);
    end
    end

    M_road_0_data(1:num_source,1:num_size)=nodata;
    for x=1:num_size,
        M_road_0_data(1:num_source,x)=M_road_data(1:num_source,x,max(min_time,ti-1),tr,ro);
    end
    
    %Convert initial road mass to binned road mass
    ti=min_time;
    for ro=1:n_roads,
    for tr=1:num_track,
    for s=1:num_source,
    for x=1:num_size-1,
        M_road_bin_data(s,x,ti,tr,ro)=M_road_data(s,x,ti,tr,ro)-M_road_data(s,x+1,ti,tr,ro);
    end
    x=num_size;
        M_road_bin_data(s,x,ti,tr,ro)=M_road_data(s,x,ti,tr,ro);
    end
    end
    end

    %Set observed surface temperature as road_meteo_data
    for ro=1:n_roads,
    for tr=1:num_track,
        road_meteo_data(road_temperature_obs_index,min_time:max_time,tr,ro)...
            =meteo_data(road_temperature_obs_input_index,min_time:max_time,ro);
        road_meteo_data(road_wetness_obs_index,min_time:max_time,tr,ro)...
            = meteo_data(road_wetness_obs_input_index,min_time:max_time,ro);
    end
    end

    %Initialise exhaust emission into pm_25 and all tracks.
    %Is redistributed later to tracks
    x=pm_25;
    if exhaust_EF_available&&exhaust_flag,
     for ti=min_time:max_time,
     for tr=1:num_track,
     for v=1:num_veh,
        E_road_bin_data(exhaust_index,x,E_total_index,ti,tr,ro)=...
        E_road_bin_data(exhaust_index,x,E_total_index,ti,tr,ro)...
        +traffic_data(N_v_index(v),ti,ro).*exhaust_EF(v);
     end
     end
     end
    elseif EP_emis_available&&exhaust_flag
      for tr=1:num_track,
    	E_road_bin_data(exhaust_index,x,E_total_index,min_time:max_time,tr,ro)=...
            EP_emis(min_time:max_time);
      end
    end
        

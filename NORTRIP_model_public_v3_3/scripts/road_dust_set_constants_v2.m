%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_set_constants_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Set common constants used in the model
%==========================================================================

%Number of roads. To be set by user but set here anyway
    n_roads=1;
%vehicle clases
    he=1;li=2;num_veh=2;
%tyre type
    st=1;wi=2;su=3;num_tyre=3;
%Salt type
    na=1;mg=2;cma=3;ca=4;pfo=5;
    %num_salt=2;
    %na_type=1;mg_type=2;cma_type=3;
%Dust type
    %sus=1;sand=2;sussand=3;num_dust=3;
%Moisture type
    water_index=1;snow_index=2;ice_index=3;rime_index=4;frost_index=5;num_moisture=3;
    snow_ice_index=[snow_index ice_index];
%road mass index
    %dust(sus)=1;dust(sand)=2;dust(sussand)=3;salt_index(1)=4;salt(2)=5;num_mass=5;
%Size fraction index
    pm_all=1;pm_200=2;pm_10=3;pm_25=4;num_size=4;pm_course=5;
    pm_sus=[pm_200 pm_10 pm_25];
%Direct wear source index
    %roadwear=1;tyrewear=2;brakewear=3;num_wear=3;
%Source index
    road_index=1;tyre_index=2;brake_index=3;sand_index=4;depo_index=5;fugitive_index=6;exhaust_index=7;salt_index(1)=8;salt_index(2)=9;
    total_dust_index=10;
    crushing_index=11;abrasion_index=12;%These two used to index f_PM_dir and f_PM only
    num_wear=3;
    num_dust=7;
    num_salt=2;
    num_source=9;
    num_source_all=10;
    num_source_all_extra=12;
    dust_index=1:7;
    dust_noexhaust_index=1:6;
    wear_index=1:3;
    all_source_index=1:num_source;
    all_source_noexhaust_index=[dust_noexhaust_index,salt_index];
    
%Strings defining the plot and save averaging output types
    av_str={'hour','day','dailycycle','halfday','weekdays','dayrun','week','month'};

%Set the new indexes.
    %date data indexing
    i=0;
    i=i+1;year_index=i;
    i=i+1;month_index=i;
    i=i+1;day_index=i;
    i=i+1;hour_index=i;
    i=i+1;minute_index=i;
    i=i+1;datenum_index=i;
    num_date_index=i;
    
    %Traffic data indexing
    i=0;
    i=i+1;N_total_index=i;
    i=i+1;N_v_index(he)=i;
    i=i+1;N_v_index(li)=i;
    i=i+1;N_t_v_index(st,he)=i;
    i=i+1;N_t_v_index(wi,he)=i;
    i=i+1;N_t_v_index(su,he)=i;
    i=i+1;N_t_v_index(st,li)=i;
    i=i+1;N_t_v_index(wi,li)=i;
    i=i+1;N_t_v_index(su,li)=i;
    i=i+1;V_veh_index(he)=i;
    i=i+1;V_veh_index(li)=i;
    num_traffic_index=i;
    
    
    %Meteo indexes
    i=0;
    i=i+1;T_a_index=i;
    i=i+1;T2_a_index=i;
    i=i+1;FF_index=i;
    i=i+1;DD_index=i;
    i=i+1;RH_index=i;
    i=i+1;Rain_precip_index=i;
    i=i+1;Snow_precip_index=i;
    i=i+1;short_rad_in_index=i;
    i=i+1;long_rad_in_index=i;
    i=i+1;short_rad_in_clearsky_index=i;
    i=i+1;cloud_cover_index=i;
    i=i+1;road_temperature_obs_input_index=i;
    i=i+1;road_wetness_obs_input_index=i;
    i=i+1;pressure_index=i;
    i=i+1;T_dewpoint_index=i;
    i=i+1;T_sub_input_index=i;
    num_meteo_index=i;

    %Activity indexes
    i=0;
    i=i+1;M_sanding_index=i;
    i=i+1;t_ploughing_index=i;
    i=i+1;t_cleaning_index=i;
    i=i+1;g_road_wetting_index=i;
    i=i+1;M_salting_index(1)=i;
    i=i+1;M_salting_index(2)=i;
    i=i+1;M_fugitive_index=i;
    num_activity_index=i;
    
    %num_airquality_index=i;
    
    %Dust balance indexes
    i=0;
    i=i+1;S_dusttotal_index=i;
    i=i+1;P_dusttotal_index=i;
    i=i+1;P_wear_index=i;
    i=i+1;S_dustspray_index=i;
    i=i+1;P_dustspray_index=i;
    i=i+1;S_dustdrainage_index=i;
    i=i+1;S_suspension_index=i;
    i=i+1;S_windblown_index=i;
    i=i+1;S_cleaning_index=i;
    i=i+1;P_cleaning_index=i;
    i=i+1;S_dustploughing_index=i;
    i=i+1;P_crushing_index=i;
    i=i+1;S_crushing_index=i;
    i=i+1;P_abrasion_index=i;
    i=i+1;P_depo_index=i;
    %i=i+1;P_allother_index=i;
    num_dustbalance=i;
    
    %Salt solution indexes
    i=0;
    i=i+1;RH_salt_index=i;
    i=i+1;melt_temperature_salt_index=i;
    i=i+1;dissolved_ratio_index=i;
    num_saltdata=i;

    %Dust process emission indexes
    i=0;
    i=i+1;E_direct_index=i;
    i=i+1;E_suspension_index=i;
    i=i+1;E_windblown_index=i;
    i=i+1;E_total_index=i;

    %Dust process concentration indexes
    i=0;
    i=i+1;C_direct_index=i;
    i=i+1;C_suspension_index=i;
    i=i+1;C_windblown_index=i;
    i=i+1;C_total_index=i;
    num_process=i;

    %Road meteorological data
    i=0;
    i=i+1;T_s_index=i;
    i=i+1;T_melt_index=i;
    i=i+1;r_aero_index=i;
    i=i+1;r_aero_notraffic_index=i;
    i=i+1;RH_s_index=i;
    i=i+1;RH_salt_final_index=i;
    i=i+1;L_index=i;
    i=i+1;H_index=i;
    i=i+1;G_index=i;
    i=i+1;G_sub_index=i;
    i=i+1;evap_index=i;
    i=i+1;evap_pot_index=i;
    i=i+1;rad_net_index=i;
    i=i+1;short_rad_net_index=i;
    i=i+1;long_rad_net_index=i;
    i=i+1;long_rad_out_index=i;
    i=i+1;H_traffic_index=i;
    i=i+1;road_temperature_obs_index=i;
    i=i+1;road_wetness_obs_index=i;
    i=i+1;T_sub_index=i;
    i=i+1;short_rad_net_clearsky_index=i;
    i=i+1;T_s_dewpoint_index=i;
    num_road_meteo=i;

    %Road moisture mass balance production and sink data
    i=0;
    i=i+1;S_melt_index=i;
    i=i+1;P_melt_index=i;
    i=i+1;P_freeze_index=i;
    i=i+1;S_freeze_index=i;
    i=i+1;P_evap_index=i;
    i=i+1;S_evap_index=i;
    i=i+1;S_drainage_index=i;
    i=i+1;S_spray_index=i;
    i=i+1;R_spray_index=i;
    i=i+1;P_spray_index=i;
    i=i+1;S_total_index=i;
    i=i+1;P_total_index=i;
    i=i+1;P_precip_index=i;
    i=i+1;P_roadwetting_index=i;
    i=i+1;S_drainage_tau_index=i;
    i=i+1;R_drainage_index=i;
    num_moistbalance=i;
    
    %Air quality indexes. Not used in the matlab version but read in from
    %the fortran output
    i=0;
    i=i+1;PM10_obs_index=i;
    i=i+1;PM10_bg_index=i;
    i=i+1;PM10_net_index=i;
    i=i+1;PM25_obs_index=i;
    i=i+1;PM25_bg_index=i;
    i=i+1;PM25_net_index=i;
    i=i+1;NOX_obs_index=i;
    i=i+1;NOX_bg_index=i;
    i=i+1;NOX_net_index=i;
    i=i+1;NOX_emis_index=i;
    i=i+1;EP_emis_index=i;
    i=i+1;f_conc_index=i;
    num_airquality_index=i;
    PM_obs_index(pm_10)=PM10_obs_index;
    PM_obs_index(pm_25)=PM25_obs_index;
    PM_bg_index(pm_10)=PM10_bg_index;
    PM_bg_index(pm_25)=PM25_bg_index;
    PM_net_index(pm_10)=PM10_net_index;
    PM_net_index(pm_25)=PM25_net_index;

    %Efficiency indexes
    ploughing_eff_index=1;
    cleaning_eff_index=2;
    drainage_eff_index=3;
    spraying_eff_index=4;
    
    %Number of 'tracks' on the road. Number set by user
    alltrack_type=1;outtrack_type=2;intrack_type=3;shoulder_type=4;kerb_type=5;
    num_track_max=5;
    
%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_surface_wetness
%VERSION: 2, 27.06.2012
%AUTHOR: Bruce Rolstad Denby and Ingrid Sundvor (bde@nilu.no)
%DESCRIPTION: Subroutine for calculating surface moisture and retention
%==========================================================================

%Set mimimum allowable total surface wetness (avoid division by 0)
surface_moisture_min=1e-6;

%Set common constants
%road_dust_set_constants_v2

%--------------------------------------------------------------------------
%Fixed parameters
%--------------------------------------------------------------------------
dz_snow_albedo=3;   %Depth of snow required before implementing snow albedo mm.w.e.
Z_CLOUD=100;        %Only used when no global radiation is available
z0t=z0/10;          %Defines the rougness length for temperature relative to that for momentum
length_veh(li)=5;   %Vehicle lengths used to calculate the vehicle heat flux
length_veh(he)=15;

%drainage_type=2;    %Selects the method for calculating drainage. 1 is exponential decay, 2 is instantaneous
retain_water_by_snow=1; %Decides if water is allowed to drain off normally when snow is present
b_factor=1/(1000*b_road_lanes*f_track(tr)); %Coverts g/km to g/m^2
%--------------------------------------------------------------------------
%Dimmension time dependent variables at the first time step
%--------------------------------------------------------------------------

    %Local arrays and variables
    clear g_road_0_data S_melt_temp g_road_fraction R_evaporation
    g_road_0_data(1:num_moisture)=nodata;
    S_melt_temp=nodata;
    g_road_fraction(1:num_moisture)=nodata;
    M2_road_salt_0(1:num_salt)=nodata;
    g_road_temp=nodata;
    R_evaporation(1:num_moisture)=0;
    R_ploughing(1:num_moisture)=0;
    R_road_drainage(1:num_moisture)=0;
    R_spray(1:num_moisture)=0;
    R_drainage(1:num_moisture)=0;
    melt_temperature_salt_temp=nodata;
    RH_salt_temp=nodata;
    M_road_dissolved_ratio_temp=nodata;
    T_s_0=nodata;
    RH_s_0=nodata;
    short_rad_net_temp=nodata;
    g_road_drainable_withrain=nodata;
    g_road_drainable_min_temp=nodata;
    g_road_total=nodata;
    g_ratio_road=nodata;
    g_ratio_brake=nodata;
    g_ratio_binder=0;
    g_ratio_obs=0;
    g_road_sprayable=0;
    
%--------------------------------------------------------------------------

%Set initial values for the time step
%--------------------------------------------------------------------------
g_road_0_data(1:num_moisture,1)=g_road_data(1:num_moisture,max(min_time,ti-1),tr,ro)+surface_moisture_min*0.5;
T_s_0=road_meteo_data(T_s_index,max(min_time,ti-1),tr,ro);
RH_s_0=road_meteo_data(RH_s_index,max(min_time,ti-1),tr,ro);
M2_road_salt_0(1:num_salt)=sum(M_road_bin_data(salt_index,1:num_size,max(min_time,ti-1),tr,ro),2)*b_factor;

%Set precipitation production term
%This assumes that the rain is in mm for the given dt period
%--------------------------------------------------------------------------
g_road_balance_data(water_index,P_precip_index,ti,tr,ro)=meteo_data(Rain_precip_index,ti,ro)/dt;
g_road_balance_data(snow_index,P_precip_index,ti,tr,ro)=meteo_data(Snow_precip_index,ti,ro)/dt;
g_road_balance_data(ice_index,P_precip_index,ti,tr,ro)=0;

%Sub surface temperature given as weighted sum of surface temperatures
%when use_subsurface_flag=2
%More realistic than using the air temperature
%--------------------------------------------------------------------------
if (ti>min_time&&use_subsurface_flag==2),
    road_meteo_data(T_sub_index,ti,tr,ro)=...
     road_meteo_data(T_sub_index,max(1,ti-1),tr,ro)*(1.-dt/sub_surf_average_time)...
    +road_meteo_data(T_s_index,max(1,ti-1),tr,ro)*dt/sub_surf_average_time;
end

%Ploughing road sinks rate
%--------------------------------------------------------------------------
R_ploughing(1:num_moisture)=-log(1-h_ploughing_moisture(1:num_moisture)+.0001)/dt*activity_data(t_ploughing_index,ti,ro)*use_ploughing_data_flag;
%--------------------------------------------------------------------------

%Wetting production
%--------------------------------------------------------------------------
g_road_balance_data(water_index,P_roadwetting_index,ti,tr,ro)=activity_data(g_road_wetting_index,ti,ro)/dt*use_wetting_data_flag;
%--------------------------------------------------------------------------

%Evaporation
%--------------------------------------------------------------------------
%Calculate aerodynamic resistance
road_meteo_data(r_aero_index,ti,tr,ro)...
    =r_aero_func(meteo_data(FF_index,ti,ro),z_FF,z_T,z0,z0t,traffic_data(V_veh_index,ti,ro),traffic_data(N_v_index,ti,ro)/n_lanes,num_veh,a_traffic);
road_meteo_data(r_aero_notraffic_index,ti,tr,ro)...
    =r_aero_func(meteo_data(FF_index,ti,ro),z_FF,z_T,z0,z0t,traffic_data(V_veh_index,ti,ro)*0,traffic_data(N_v_index,ti,ro)/n_lanes*0,num_veh,a_traffic);
if use_traffic_turb_flag==0,
    road_meteo_data(r_aero_index,ti,tr,ro)=road_meteo_data(r_aero_notraffic_index,ti,tr,:);
end

%Calculate the traffic induced heat flux (W/m2).
road_meteo_data(H_traffic_index,ti,tr,ro)=0;
if use_traffic_turb_flag,
    for v=1:num_veh,
    road_meteo_data(H_traffic_index,ti,tr,ro)=road_meteo_data(H_traffic_index,ti,tr,ro)...
        +H_veh(v)*min(1,length_veh(v)/traffic_data(V_veh_index(v),ti,ro)*traffic_data(N_v_index(v),ti,ro)/(n_lanes*1000));
    end
end

%Set surface relative humidity
if surface_humidity_flag==1,
    road_meteo_data(RH_s_index,ti,tr,ro)=(min(1,sum(g_road_0_data(1:num_moisture))/g_road_evaporation_thresh))*100;
elseif surface_humidity_flag==2,
    road_meteo_data(RH_s_index,ti,tr,ro)=(1-exp(-sum(g_road_0_data(1:num_moisture))/g_road_evaporation_thresh*4))*100;
else
    road_meteo_data(RH_s_index,ti,tr,ro)=100;
end

%Calculate evaporation energy balance including melt of snow and ice
if evaporation_flag,
    short_rad_net_temp=road_meteo_data(short_rad_net_index,ti,tr,ro);
    %Adjust net radiation if snow is present on the road
    if g_road_0_data(snow_index)>dz_snow_albedo,
        short_rad_net_temp=road_meteo_data(short_rad_net_index,ti,tr,ro)*(1-albedo_snow)/(1-albedo_road);
    end

    [road_meteo_data(T_s_index,ti,tr,ro)...
    ,road_meteo_data(T_melt_index,ti,tr,ro)...
    ,road_meteo_data(RH_salt_final_index,ti,tr,ro)...
    ,road_meteo_data(RH_s_index,ti,tr,ro)...
    ,road_salt_data(dissolved_ratio_index,:,ti,tr,ro)...
    ,road_meteo_data(evap_index,ti,tr,ro)...
    ,road_meteo_data(evap_pot_index,ti,tr,ro)...
    ,S_melt_temp...
    ,g_road_balance_data(ice_index,P_freeze_index,ti,tr,ro)...
    ,road_meteo_data(H_index,ti,tr,ro)...
    ,road_meteo_data(L_index,ti,tr,ro)...
    ,road_meteo_data(G_index,ti,tr,ro)...
    ,road_meteo_data(long_rad_out_index,ti,tr,ro)...
    ,road_meteo_data(long_rad_net_index,ti,tr,ro)...
    ,road_meteo_data(rad_net_index,ti,tr,ro)...
    ,road_meteo_data(G_sub_index,ti,tr,ro)]...
    = Surface_energy_model_4_func...
    (short_rad_net_temp...
    ,meteo_data(long_rad_in_index,ti,ro)...
	,road_meteo_data(H_traffic_index,ti,tr,ro)...
	,road_meteo_data(r_aero_index,ti,tr,ro)...
	,meteo_data(T_a_index,ti,ro)...
	,T_s_0...
	,road_meteo_data(T_sub_index,ti,tr,ro)...
	,meteo_data(RH_index,ti,ro)...
	,road_meteo_data(RH_s_index,ti,tr,ro)...
	,RH_s_0...
	,meteo_data(pressure_index,ti,ro)...
	,dzs...
	,dt...
	,g_road_0_data(water_index)...
	,g_road_0_data(ice_index)+g_road_0_data(snow_index)...
	,g_road_evaporation_thresh...
    ,M2_road_salt_0...
    ,salt_type...
	,sub_surf_param...
	,surface_humidity_flag...
	,use_subsurface_flag...
    ,use_salt_humidity_flag);
    
    %Because does not differentiate between snow and ice resdistribute the
    %melting between snow and ice    
    g_road_balance_data(snow_ice_index,S_melt_index,ti,tr,ro)...
        =g_road_balance_data(snow_ice_index,S_melt_index,ti,tr,ro)...
        +S_melt_temp*g_road_0_data(snow_ice_index,1)./sum(g_road_0_data(snow_ice_index));
        
end

%Calculate surface dewpoint temperature
road_meteo_data(T_s_dewpoint_index,ti,tr,ro)...
    =dewpoint_from_RH_func(road_meteo_data(T_s_index,ti,tr,ro)...
    ,road_meteo_data(RH_s_index,ti,tr,ro));

meteo_data(T_dewpoint_index,ti,ro)...
        =dewpoint_from_RH_func(meteo_data(T_a_index,ti,ro)...
        ,meteo_data(RH_index,ti,ro));

%Set the evaporation/condensation rates
%Distribute evaporation between water and ice according to the share of water and ice
%Distribute the condensation between water and ice according to temperature
g_road_fraction(1:num_moisture,1)=g_road_0_data(1:num_moisture,1)/sum(g_road_0_data(1:num_moisture));
if road_meteo_data(evap_index,ti,tr,ro)>0, %Evaporation
    R_evaporation(1:num_moisture)=road_meteo_data(evap_index,ti,tr,ro)./g_road_0_data(1:num_moisture).*g_road_fraction(1:num_moisture);
    g_road_balance_data(1:num_moisture,P_evap_index,ti,tr,ro)=0;
else %Condensation
    if road_meteo_data(T_s_index,ti,tr,ro)>=road_meteo_data(T_melt_index,ti,tr,ro),%Condensation to water
        g_road_balance_data(water_index,P_evap_index,ti,tr,ro)=-road_meteo_data(evap_index,ti,tr,ro);
        g_road_balance_data(snow_index,P_evap_index,ti,tr,ro)=0;
        g_road_balance_data(ice_index,P_evap_index,ti,tr,ro)=0;
        elseif (evaporation_flag==2)
            %Condensation to snow. Hoar frost is more like snow than ice from melting
            g_road_balance_data(snow_index,P_evap_index,ti,tr,ro)=-road_meteo_data(evap_index,ti,tr,ro);
            g_road_balance_data(water_index,P_evap_index,ti,tr,ro)=0;
            g_road_balance_data(ice_index,P_evap_index,ti,tr,ro)=0;
        elseif evaporation_flag==1
         %Condensation only to ice (not snow)
        g_road_balance_data(snow_index,P_evap_index,ti,tr,ro)=0;
        g_road_balance_data(water_index,P_evap_index,ti,tr,ro)=0;
        g_road_balance_data(ice_index,P_evap_index,ti,tr,ro)=-road_meteo_data(evap_index,ti,tr,ro);
    end
    R_evaporation(1:num_moisture)=0;
end
g_road_balance_data(1:num_moisture,S_evap_index,ti,tr,ro)=R_evaporation(1:num_moisture).*g_road_0_data(1:num_moisture);
%--------------------------------------------------------------------------
    
%Set drainage rates
%--------------------------------------------------------------------------
%This drainage type reduces exponentially according to a time scale
%Should only be used when the model is run at much shorter time scales than
%1 hour, e.g. 5 - 10 minutes
%Needs to be reviewed and updated
if drainage_type_flag==1,
    %Exponential drainage based on time scale tau_road_drainage
    g_road_water_drainable=max(0,g_road_0_data(water_index)-g_road_drainable_min);
    g_road_drainable_withrain=max(0,meteo_data(Rain_precip_index,ti,ro)+g_road_0_data(water_index)-g_road_drainable_min);

    if g_road_drainable_withrain>0,
        R_drainage(water_index)=1/tau_road_drainage;
    else
        R_drainage(water_index)=0;
    end
    %Diagnostic only. Not correct mathematically
    g_road_balance_data(water_index,S_drainage_tau_index,ti,tr,ro)= g_road_drainable_withrain*R_drainage(water_index);
end

if drainage_type_flag==2,
    R_drainage(water_index)=0;
    g_road_balance_data(water_index,S_drainage_tau_index,ti,tr,ro)= 0;
end

if drainage_type_flag==3,
    %Combined drainage, first instantaneous removal to g_road_drainable_min
    %Then exponential drainage based on time scale tau_road_drainage to g_road_drainable_thresh
    %Only do this part if the level is below g_road_drainable_min, otherwise use the instantaneous 
    g_road_water_drainable=max(0,g_road_0_data(water_index)-g_road_drainable_thresh);
    g_road_drainable_withrain=max(0,meteo_data(Rain_precip_index,ti,ro)+g_road_0_data(water_index)-g_road_drainable_min);

    if g_road_drainable_withrain==0 && g_road_water_drainable>0,
        R_drainage(water_index)=1/tau_road_drainage;
    else
        R_drainage(water_index)=0;
    end
    %Diagnostic only. Not correct mathematically
    g_road_balance_data(water_index,S_drainage_tau_index,ti,tr,ro)= g_road_water_drainable*R_drainage(water_index);
end

%Set the drainage rate to be used in the dust/sult module
g_road_balance_data(water_index,R_drainage_index,ti,tr,ro)=R_drainage(water_index);

%--------------------------------------------------------------------------

%Splash and spray sinks and production. Also for snow but not defined yet
%--------------------------------------------------------------------------
clear R_spray
R_spray(1:num_moisture)=0;
for m=1:num_moisture,
    g_road_sprayable=max(0,g_road_0_data(m)-g_road_sprayable_min(m));
    if g_road_sprayable>0&&water_spray_flag,
    for v=1:num_veh,
        R_spray(m)= R_spray(m)+traffic_data(N_v_index(v),ti,ro)/n_lanes*veh_track(tr)...
            *f_spray_func(R_0_spray(v,m),traffic_data(V_veh_index(v),ti,ro),...
            V_ref_spray(m),V_thresh_spray(m),a_spray(m),water_spray_flag);
    end
    %Adjust according to minimum
    R_spray(m)=R_spray(m).*g_road_sprayable./(g_road_0_data(m)+surface_moisture_min);
    end
    g_road_balance_data(m,S_spray_index,ti,tr,ro)=R_spray(m).*g_road_0_data(m);
    g_road_balance_data(m,R_spray_index,ti,tr,ro)=R_spray(m);
end
%--------------------------------------------------------------------------

%Add production terms
%--------------------------------------------------------------------------
g_road_balance_data(1:num_moisture,P_total_index,ti,tr,ro)...
    =g_road_balance_data(1:num_moisture,P_precip_index,ti,tr,ro)...
    +g_road_balance_data(1:num_moisture,P_evap_index,ti,tr,ro)...
    +g_road_balance_data(1:num_moisture,P_roadwetting_index,ti,tr,ro);
%--------------------------------------------------------------------------

%Add sink rate terms
%--------------------------------------------------------------------------
R_total(1:num_moisture)=R_evaporation(1:num_moisture)+R_drainage(1:num_moisture)+R_spray(1:num_moisture)+R_ploughing(1:num_moisture);
%--------------------------------------------------------------------------

%Calculate change in water and snow
%--------------------------------------------------------------------------
for m=1:num_moisture,
    g_road_data(m,ti,tr,ro)=mass_balance_func(g_road_0_data(m),g_road_balance_data(m,P_total_index,ti,tr,ro),R_total(m),dt);
end
%--------------------------------------------------------------------------

%Recalculate spray and evaporation diagnostics based on average moisture
%--------------------------------------------------------------------------
for m=1:num_moisture,
    g_road_balance_data(m,S_spray_index,ti,tr,ro)=R_spray(m).*(g_road_data(m,ti,tr,ro)+g_road_0_data(m))/2;
    g_road_balance_data(m,S_evap_index,ti,tr,ro)=R_evaporation(m).*(g_road_data(m,ti,tr,ro)+g_road_0_data(m))/2;
end

%Remove and add snow melt after the rest of the calculations
%--------------------------------------------------------------------------
%Can't melt more ice or snow than there is
for m=snow_ice_index,
    g_road_balance_data(m,S_melt_index,ti,tr,ro)=min(g_road_data(m,ti,tr,ro)/dt,g_road_balance_data(m,S_melt_index,ti,tr,ro));
end
%Sink of melt is the same as production of water
g_road_balance_data(water_index,P_melt_index,ti,tr,ro)=sum(g_road_balance_data(snow_ice_index,S_melt_index,ti,tr,ro),1);
for m=1:num_moisture,
    g_road_data(m,ti,tr,ro)=max(0,g_road_data(m,ti,tr,ro)-g_road_balance_data(m,S_melt_index,ti,tr,ro)*dt);
    g_road_data(m,ti,tr,ro)=g_road_data(m,ti,tr,ro)+g_road_balance_data(m,P_melt_index,ti,tr,ro)*dt;
end

%Remove water through drainage for drainage_type_flag=2 or 3
%--------------------------------------------------------------------------
g_road_water_drainable=0;
if drainage_type_flag==2||drainage_type_flag==3,
    if retain_water_by_snow,
        g_road_drainable_min_temp=max(g_road_drainable_min,g_road_data(snow_index,ti,tr,ro));
    else
        g_road_drainable_min_temp=g_road_drainable_min;
    end
    g_road_water_drainable=max(0,g_road_data(water_index,ti,tr,ro)-g_road_drainable_min_temp);
    g_road_data(water_index,ti,tr,ro)=min(g_road_data(water_index,ti,tr,ro),g_road_drainable_min_temp);
    g_road_balance_data(water_index,S_drainage_index,ti,tr,ro)= g_road_water_drainable/dt;
end

%Freeze after the rest of the calculations
%--------------------------------------------------------------------------
%Limit the amount of freezing to the amount of available water
g_road_balance_data(ice_index,P_freeze_index,ti,tr,ro)=min(g_road_data(water_index,ti,tr,ro),g_road_balance_data(ice_index,P_freeze_index,ti,tr,ro)*dt)/dt;
g_road_balance_data(water_index,S_freeze_index,ti,tr,ro)=g_road_balance_data(ice_index,P_freeze_index,ti,tr,ro);
g_road_data(water_index,ti,tr,ro)=g_road_data(water_index,ti,tr,ro)-g_road_balance_data(water_index,S_freeze_index,ti,tr,ro);
g_road_data(ice_index,ti,tr,ro)=g_road_data(ice_index,ti,tr,ro)+g_road_balance_data(ice_index,P_freeze_index,ti,tr,ro);

%Set moisture content to be always>=0. Avoiding round off errors
%--------------------------------------------------------------------------
for m=1:num_moisture,
    g_road_data(m,ti,tr,ro)=max(0,g_road_data(m,ti,tr,ro)); 
end

%Calculate inhibition/retention factors
%--------------------------------------------------------------------------
g_road_total=sum(g_road_data(1:num_moisture,ti,tr,ro));
g_ratio_road=(g_road_total-g_retention_min(road_index))...
    /(g_retention_thresh(road_index)-g_retention_min(road_index));
g_ratio_brake=(g_road_data(water_index,ti,tr,ro)-g_retention_min(brake_index))...
    /(g_retention_thresh(brake_index)-g_retention_min(brake_index));
g_ratio_binder=(M2_road_salt_0(2)-g_retention_min(salt_index(2)))...
    /(g_retention_thresh(salt_index(2))-g_retention_min(salt_index(2)));
if retention_flag==1,
    f_q(1:num_source,ti,tr,ro)=max(0,min(1,1-g_ratio_road));
    f_q(1:num_source,ti,tr,ro)=max(0,min(1,1-g_ratio_binder)).*f_q(1:num_source,ti,tr,ro);
    f_q(brake_index,ti,tr,ro)=max(0,min(1,1-g_ratio_brake));
    %f_q(sand_index,ti,tr,ro)=max(0,min(1,1-g_ratio_road));
elseif retention_flag==2,
    f_q(1:num_source,ti,tr,ro)=exp(-2*max(0,g_ratio_road));
    f_q(1:num_source,ti,tr,ro)=exp(-2*max(0,g_ratio_binder)).*f_q(1:num_source,ti,tr,ro);
    f_q(brake_index,ti,tr,ro)=exp(-2*max(0,g_ratio_brake));
    %f_q(sand_index,ti,tr,ro)=exp(-2*max(0,g_ratio_road));
else
    f_q(1:num_source,ti,tr,ro)=1.;
end

%Set observed retention parameter if available
if road_wetness_obs_available&&road_wetness_obs_in_mm,
    g_ratio_obs=(meteo_data(road_wetness_obs_input_index,ti,ro)-g_retention_min(road_index))...
        /(g_retention_thresh(road_index)-g_retention_min(road_index));
    if meteo_data(road_wetness_obs_input_index,ti,ro)==nodata,
        f_q_obs(ti,tr,ro)=1;%No data then the road is dry
    elseif retention_flag==1,
        f_q_obs(ti,tr,ro)=max(0,min(1,1-g_ratio_obs));
    elseif retention_flag==2,
        f_q_obs(ti,tr,ro)=exp(-2*max(0,g_ratio_obs));
    else
        f_q_obs(ti,tr,ro)=1;
    end
end
if road_wetness_obs_available&&road_wetness_obs_in_mm==0,
    %f_q_obs=1-(road_wetness_obs-min(road_wetness_obs))./(max(road_wetness_obs)-min(road_wetness_obs));
    middle_max_road_wetness_obs=(max_road_wetness_obs-min_road_wetness_obs)/2;
    if observed_moisture_cutoff_value==0,
        observed_moisture_cutoff_value_temp=middle_max_road_wetness_obs;
    else
        observed_moisture_cutoff_value_temp=observed_moisture_cutoff_value;
    end
    if road_meteo_data(road_wetness_obs_index,ti,tr,ro)==nodata,
        f_q_obs(ti,tr,ro)=1;%No data then dry road
    elseif road_meteo_data(road_wetness_obs_index,ti,tr,ro)<observed_moisture_cutoff_value_temp,
        f_q_obs(ti,tr,ro)=1;
    else
        f_q_obs(ti,tr,ro)=0;
    end
end

%Set retention based on observed wetness if required
if use_obs_retention_flag&&road_wetness_obs_available&&retention_flag~=0
        f_q(1:num_source,ti,tr,ro)=f_q_obs(ti,tr,ro);
        f_q(brake_index,ti,tr,ro)=1;%No retention for brakes when using observed moisture
        f_q(exhaust_index,ti,tr,ro)=1;%No retention for exhaust when using observed moisture        
end

%--------------------------------------------------------------------------



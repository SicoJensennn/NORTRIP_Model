%==========================================================================
%NORTRIP model
%SUBROUTINE: save_road_dust_results_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Saves results from the NORTRIP model in excel
%==========================================================================
av=plot_type_flag;
%av=8;
warning('off');

%If only want to save hourly values then set av=1
if save_average_flag==0, av=1;end

%Specify no data value for output. NaN, does not write values to sheets
no_val=NaN;
if save_type_flag==4,
    no_val=-999;
end
%Unless otherwise specified output for PM10
x=pm_10;
x_load=pm_200;
x2=pm_25;

%Unless otherwise specified output for road 1 and track
ro=1;
tr=1;

%Set up temporary files for use in saving
clear road_meteo_data_temp C_data_temp E_road_data_temp M_road_data_temp M_road_balance_data_temp
clear WR_time_data_temp road_salt_data_temp
clear g_road_data_temp g_road_balance_data_temp 
clear f_q_temp f_q_obs_temp f_conc_temp
clear meteo_data_temp traffic_data_temp activity_data_temp date_num
road_meteo_data_temp(1:num_road_meteo,1:n_date)=0;
C_data_temp(1:num_source_all,1:num_size,1:num_process,1:n_date)=0;
E_road_data_temp(1:num_source_all,1:num_size,1:num_process,1:n_date)=0;
M_road_data_temp(1:num_source_all,1:num_size,1:n_date)=0;   
M_road_balance_data_temp(1:num_source_all,1:num_size,1:num_dustbalance,1:n_date)=0;
WR_time_data_temp(1:num_wear,1:n_date)=0;
road_salt_data_temp(1:num_saltdata,1:num_salt,1:n_date)=0;
g_road_balance_data_temp(1:num_moisture,1:num_moistbalance,1:n_date)=0;
g_road_data_temp(1:num_moisture+2,1:n_date)=0;
f_q_temp(1:num_source_all,1:n_date)=0;
f_q_obs_temp(1:n_date)=0;

meteo_data_temp(1:num_meteo_index,1:n_date)=0;
traffic_data_temp(1:num_traffic_index,1:n_date)=0;
activity_data_temp(1:num_activity_index,1:n_date)=0;
f_conc_temp(1:n_date)=0;

%Weighted average of tracks for surface concentration values and averages
for tr=1:num_track,
    road_meteo_data_temp(:,:)=road_meteo_data_temp(:,:)+road_meteo_data(:,:,tr,ro).*f_track(tr);
    g_road_data_temp(:,:)=g_road_data_temp(:,:)+g_road_data(:,:,tr,ro).*f_track(tr);
    g_road_balance_data_temp(:,:,:)=g_road_balance_data_temp(:,:,:)+g_road_balance_data(:,:,:,tr,ro).*f_track(tr);
    road_salt_data_temp(:,:,:)=road_salt_data_temp(:,:,:)+road_salt_data(:,:,:,tr,ro).*f_track(tr);
    f_q_temp(:,:)=f_q_temp(:,:)+f_q(:,:,tr,ro).*f_track(tr);
    f_q_obs_temp(:)=f_q_obs_temp(:)+f_q_obs(:,tr,ro).*f_track(tr);
end

%Summed values over tracks
C_data_temp(:,:,:,:)=sum(C_data(:,:,:,:,1:num_track,ro),5);
E_road_data_temp(:,:,:,:)=sum(E_road_data(:,:,:,:,1:num_track,ro),5);
M_road_data_temp(:,:,:)=sum(M_road_data(:,:,:,1:num_track,ro),4);
M_road_balance_data_temp(:,:,:,:)=sum(M_road_balance_data(:,:,:,:,1:num_track,ro),5);
WR_time_data_temp(:,:)=sum(WR_time_data(1:num_wear,:,1:num_track,ro),3);


meteo_data_temp(:,:)=meteo_data(:,:,ro);
traffic_data_temp(:,:)=traffic_data(:,:,ro);
activity_data_temp(:,:)=activity_data(:,:,ro);
f_conc_temp=f_conc(:,ro);

date_num=date_data(datenum_index,:);

%Set conversion factor from g/km to g/m^2
factor=1/1000/b_road_lanes;

%This always uses the averaging routine, rather than the original routine
always_use_average=1;
clear a
if always_use_average,
    [x_str xplot val]=Average_data_func(date_num,date_data(year_index,:),min_time,max_time,av);
    if av(1)==1,av_date_str = datestr(xplot,'dd.mm.yyyy HH:MM');end
    if av(1)==2,av_date_str = datestr(xplot,'dd.mm.yyyy');end
    if av(1)==3,av_date_str = x_str;end
    if av(1)==4,av_date_str = datestr(xplot,'dd.mm.yyyy HH:MM');end
    if av(1)==5,av_date_str = x_str;end
    if av(1)==6,av_date_str = datestr(xplot,'dd.mm.yyyy HH:MM');end
    if av(1)==7,av_date_str = datestr(xplot,'dd.mm.yyyy');end
    if av(1)==8,av_date_str = x_str;end
   
    n_save=length(val);
    i_save=2:n_save+1;
    clear a
    j=0;
    %Dates
    %j=j+1;a{1,j}='Date';[x_str xplot val]=Average_data_func(date_num,year,min_time,max_time,av);for i=1:length(x_str),a{i+1,j}=char(x_str(i,:));end
    j=j+1;a{1,j}='Date';for i=1:n_save,a{i+1,j}=char(av_date_str(i,:));end
    j=j+1;a{1,j}='Year';[x_str xplot val]=Average_data_func(date_num,date_data(year_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Month';[x_str xplot val]=Average_data_func(date_num,date_data(month_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Day';[x_str xplot val]=Average_data_func(date_num,date_data(day_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Hour';[x_str xplot val]=Average_data_func(date_num,date_data(hour_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Weekday';[x_str xplot val]=Average_data_func(date_num,weekday(date_num),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %Traffic
    j=j+1;a{1,j}='N(total)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_total_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(he)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_v_index(he),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(li)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_v_index(li),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(st,he)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(st,he),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(st,li)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(st,li),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(wi,he)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(wi,he),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(wi,li)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(wi,li),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(su,he)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(su,he),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='N(su,li)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(su,li),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='V_veh(he) (km/hr)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(V_veh_index(he),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='V_veh(li) (km/hr)';[x_str xplot val]=Average_data_func(date_num,traffic_data_temp(V_veh_index(li),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %Meteorology and energy balance
    j=j+1;a{1,j}='T2m (C)';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(T_a_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Ts_road (C)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(T_s_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Ts_road_obs (C)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(road_temperature_obs_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='RH (%)';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(RH_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='RHs_road (%)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(RH_s_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='FF (m/s)';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(FF_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Rain (mm/hr)';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(Rain_precip_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Snow (mm/hr)';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(Snow_precip_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Cloud cover';[x_str xplot val]=Average_data_func(date_num,meteo_data_temp(cloud_cover_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Net short rad (W/m^2)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(short_rad_net_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Net long rad (W/m^2)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(long_rad_net_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Sensible_road (W/m^2)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(H_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Latent_road (W/m^2)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(L_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Surface_heatflux_road (W/m^2)';[x_str xplot val]=Average_data_func(date_num,road_meteo_data_temp(G_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %Surface moisture
    j=j+1;a{1,j}='Wetness_road (mm)';[x_str xplot val]=Average_data_func(date_num,g_road_data_temp(water_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Ice_road (mm)';[x_str xplot val]=Average_data_func(date_num,sum(g_road_data_temp([snow_index ice_index],:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Evaporation (mm/hr)';[x_str xplot val]=Average_data_func(date_num,g_road_balance_data_temp(water_index,S_evap_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Drainage (mm/hr)';[x_str xplot val]=Average_data_func(date_num,g_road_balance_data_temp(water_index,S_drainage_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='f_q_road';[x_str xplot val]=Average_data_func(date_num,f_q_temp(road_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='f_q_brake';[x_str xplot val]=Average_data_func(date_num,f_q_temp(brake_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='f_q_obs';[x_str xplot val]=Average_data_func(date_num,f_q_obs_temp(:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %Road maintenance
    j=j+1;a{1,j}='M_sanding (g/m^2)';[x_str xplot val]=Average_data_func(date_num,activity_data_temp(M_sanding_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='M_salting(na) (g/m^2)';[x_str xplot val]=Average_data_func(date_num,activity_data_temp(M_salting_index(1),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}=['M_salting(',salt2_str,') (g/m^2)'];[x_str xplot val]=Average_data_func(date_num,activity_data_temp(M_salting_index(2),:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Ploughing_road (0/1)';[x_str xplot val]=Average_data_func(date_num,activity_data_temp(t_ploughing_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Cleaning_road (0/1)';[x_str xplot val]=Average_data_func(date_num,activity_data_temp(t_cleaning_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %Mass balance and emissions
    j=j+1;a{1,j}='Total emissions PM10 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(dust_noexhaust_index,x,E_total_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Direct emissions PM10 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(dust_noexhaust_index,x,E_direct_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Suspended road emissions PM10 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(all_source_index,x,E_suspension_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road dust PM200 mass (g/m^2)';[x_str xplot val]=Average_data_func(date_num,M_road_data_temp(total_dust_index,x_load,:)*factor,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road sand PMall mass (g/m^2)';[x_str xplot val]=Average_data_func(date_num,M_road_data_temp(sand_index,pm_all,:)*factor,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road sand PM200 mass (g/m^2)';[x_str xplot val]=Average_data_func(date_num,M_road_data_temp(sand_index,x_load,:)*factor,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road salt(na) mass (g/m^2)';[x_str xplot val]=Average_data_func(date_num,M_road_data_temp(salt_index(1),x_load,:)*factor,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}=['Road salt(',salt2_str,') mass (g/m^2)'];[x_str xplot val]=Average_data_func(date_num,M_road_data_temp(salt_index(2),x_load,:)*factor,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road wear (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,WR_time_data_temp(road_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Tyre wear (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,WR_time_data_temp(tyre_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Brake wear (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,WR_time_data_temp(brake_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road dust production (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,M_road_balance_data_temp(total_dust_index,x_load,P_dusttotal_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Road dust sink (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,M_road_balance_data_temp(total_dust_index,x_load,S_dusttotal_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Emission factor PM10 (g/km/veh)';[x_str xplot val1]=Average_data_func(date_num,sum(E_road_data_temp(all_source_index,x,E_total_index,:),1),min_time,max_time,av);
                                                   [x_str xplot val2]=Average_data_func(date_num,traffic_data_temp(N_total_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val1(i)/val2(i);end
    
    %Add in PM2.5 emissions (update September 2021)
    j=j+1;a{1,j}='Total emissions PM2.5 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(dust_noexhaust_index,x2,E_total_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Direct emissions PM2.5 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(dust_noexhaust_index,x2,E_direct_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Suspended road emissions PM2.5 (g/km/hr)';[x_str xplot val]=Average_data_func(date_num,sum(E_road_data_temp(all_source_index,x2,E_suspension_index,:),1),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='Emission factor PM2.5 (g/km/veh)';[x_str xplot val1]=Average_data_func(date_num,sum(E_road_data_temp(all_source_index,x2,E_total_index,:),1),min_time,max_time,av);
                                                   [x_str xplot val2]=Average_data_func(date_num,traffic_data_temp(N_total_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val1(i)/val2(i);end
    %Add direct emission factors for light and heavy duty
    %j=j+1;a{1,j}='Emission factor PM10 (g/km/veh)';[x_str xplot val1]=Average_data_func(date_num,sum(E_road_data_temp(all_source_index,x,E_total_index,:),1),min_time,max_time,av);
    %                                               [x_str xplot val2]=Average_data_func(date_num,traffic_data_temp(N_total_index,:),min_time,max_time,av);for i=1:length(val),a{i+1,j}=val1(i)/val2(i);end
    
    %Concentrations
    j=j+1;a{1,j}='PM10_obs net (ug/m^3)';val_in=PM_obs_net(pm_10,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10_obs bg (ug/m^3)';val_in=PM_obs_bg(pm_10,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod total (ug/m^3)';val_in=sum(C_data_temp(all_source_noexhaust_index,x,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod total+ep (ug/m^3)';val_in=sum(C_data_temp(all_source_index,x,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod dust total (ug/m^3)';val_in=sum(C_data_temp(dust_noexhaust_index,x,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod roadwear (ug/m^3)';val_in=C_data_temp(road_index,x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod tyrewear (ug/m^3)';val_in=C_data_temp(tyre_index,x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod brakewear (ug/m^3)';val_in=C_data_temp(brake_index,x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod salt(na) (ug/m^3)';val_in=C_data_temp(salt_index(1),x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}=['PM10 mod salt(',salt2_str,') (ug/m^3)'];val_in=C_data_temp(salt_index(2),x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod sand (ug/m^3)';val_in=C_data_temp(sand_index,x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM10 mod exhaust (ug/m^3)';val_in=C_data_temp(exhaust_index,x,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25_obs net (ug/m^3)';val_in=PM_obs_net(pm_25,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25_obs bg (ug/m^3)';val_in=PM_obs_bg(pm_25,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod total (ug/m^3)';val_in=sum(C_data_temp(all_source_noexhaust_index,pm_25,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod total+ep (ug/m^3)';val_in=sum(C_data_temp(all_source_index,pm_25,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    %New 15.06.2023 PM2.5 sources
    j=j+1;a{1,j}='PM25 mod dust total (ug/m^3)';val_in=sum(C_data_temp(dust_noexhaust_index,x2,C_total_index,:),1);r=find(val_in<0);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod roadwear (ug/m^3)';val_in=C_data_temp(road_index,x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod tyrewear (ug/m^3)';val_in=C_data_temp(tyre_index,x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod brakewear (ug/m^3)';val_in=C_data_temp(brake_index,x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod salt(na) (ug/m^3)';val_in=C_data_temp(salt_index(1),x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}=['PM25 mod salt(',salt2_str,') (ug/m^3)'];val_in=C_data_temp(salt_index(2),x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod sand (ug/m^3)';val_in=C_data_temp(sand_index,x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
    j=j+1;a{1,j}='PM25 mod exhaust (ug/m^3)';val_in=C_data_temp(exhaust_index,x2,C_total_index,:);r=find(val_in==nodata);val_in(r)=NaN;[x_str xplot val]=Average_data_func(date_num,val_in,min_time,max_time,av);for i=1:length(val),a{i+1,j}=val(i);end
end

%Calculate means and sums
ntemp=size(a,2);

%Put the header just in front of the time data
if save_average_flag||always_use_average,
    %Do nothing
else
    a(min_time,:)=a(1,:);%set the min time value to the header, defined inposition 1
end
%Save data as ASCII file instead of excel
if save_data_as_text,
	if save_average_flag||always_use_average,
        %Set the min time to 1 so that the text writing routine can be used
        min_time_temp=min_time;
        max_time_temp=max_time;
        min_time=1;
        max_time=n_save+1;
    end
    new_path_filename_outputdata_data=[path_filename_outputdata_data,'_',char(av_str(av)),'.txt'];
    exist_file=exist(new_path_filename_outputdata_data);
    if exist_file,
        delete(new_path_filename_outputdata_data);
    end
	col_data=size(a,2);
    row_data=size(a,1);
	%Skips over the date string column. Problems with that.
    clear format_str format_header_str a_mat
    %First 5 are different because they are integers
    format_str='%12u\t%12u\t%12u\t%12u\t%12u';
	format_header_str='%12s\t%12s\t%12s\t%12s\t%12s';
	for k=7:col_data,
        format_str=[format_str,'\t%12.4e'];
        format_header_str=[format_header_str,'\t%12s'];
    end
        format_str=[format_str,'\n'];
        format_header_str=[format_header_str,'\n'];
	fid_data=fopen(new_path_filename_outputdata_data,'w');
    
    if fid_data>0,
    fprintf(fid_data,'%12s',char(a(min_time,2)));
	for k=3:col_data,
        fprintf(fid_data,'\t%12s',char(a(min_time,k)));
    end
    fprintf(fid_data,'\n');
	
    a_mat(min_time+1:max_time,:)=cell2mat(a(min_time+1:max_time,2:col_data));
    r=find(isnan(a_mat));
    a_mat(r)=no_val;
    for t=min_time+1:max_time,
        fprintf(fid_data,format_str,a_mat(t,:));
    end
	fclose(fid_data);
    end
    clear a_mat
    
    min_time=min_time_temp;%Set it back again
    max_time=max_time_temp;

end

if save_data_as_text==0

    %Write to file,including header
    %Update 16.056.2023
    path_filename_outputdata_data_new=[path_filename_outputdata_data,'_',char(av_str(av(1))),'.xlsx'];
    exist_file=exist(path_filename_outputdata_data_new);
    if exist_file
        delete(path_filename_outputdata_data_new);
        fprintf('Deleting existing file: %s\n',path_filename_outputdata_data_new);
    end
    fprintf('Writing to: %s\n',path_filename_outputdata_data_new);
    if save_average_flag||always_use_average
        [s] = xlswrite(path_filename_outputdata_data_new,a(:,:),1);
    else
        [s] = xlswrite(path_filename_outputdata_data_new,a(min_time:max_time+1,:),1);
    end

    %Append the input parameter file to the time series data
    %Only include the paramaters, not the calculations
    clear bp bd
    bp=input_param.textdata.Parameters(:,1:5);
    bd=input_param.data.Parameters(:,1:5);
    for i=1:size(bp,1)
    for j=1:size(bp,2)
        if ~isnan(bd(i,j))
            bp{i,j}=num2str(bd(i,j));
        end
    end
    end
    [s] = xlswrite(path_filename_outputdata_data_new,bp,2);

    clear bp bd
    bp=input_param.textdata.Flags;
    bd=input_param.data.Flags;
    for i=1:size(bd,1)
        if ~isnan(bd(i,1))
            bp{i,2}=bd(i,1);
        end
    end
    [s] = xlswrite(path_filename_outputdata_data_new,bp,3);

    clear bp bd
    bp=input_param.textdata.Activities;
    bd=input_param.data.Activities;
    for i=1:size(bd,1)
        if ~isnan(bd(i,1))
            bp{i,2}=bd(i,1);
        end
    end
    [s] = xlswrite(path_filename_outputdata_data_new,bp,4);

end

warning('on');

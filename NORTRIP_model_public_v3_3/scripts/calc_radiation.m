%==========================================================================
%NORTRIP model
%SUBROUTINE: calc_radiation
%VERSION: 1, 27.06.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Pre-calculates raditastion paramters
%==========================================================================

%Set search window in hours for calculating cloud cover
dti=11;

%Set the short wave calculation to be 1/2 hour before, because most
%measurements are the integral form an hour before
%Not set here any more
%Set in the metadata input file, e.g. -1 becomes -0.5
dt_day_sw=0;%-dt_hour/2/24;

%Initialise
%{
if cloud_cover_available==0,
    meteo_data(cloud_cover_index,1:max_time_inputdata,ro)=nodata;
end
road_meteo_data(short_rad_net_index,1:max_time_inputdata,1:num_track,ro)=nodata;
meteo_data(short_rad_in_clearsky_index,1:max_time_inputdata,ro)=nodata;
road_meteo_data(short_rad_net_clearsky_index,1:max_time_inputdata,1:num_track,ro)=nodata;
if ~long_rad_in_available,
    meteo_data(long_rad_in_index,1:max_time_inputdata,ro)=nodata;
end
%}

%Add RH and temperature offset
for ti=min_time:max_time
    meteo_data(RH_index,ti,ro)=max(0,min(100,meteo_data(RH_index,ti,ro)+RH_offset));
    meteo_data(T_a_index,ti,ro)=meteo_data(T_a_index,ti,ro)+T_a_offset;
end

%Set initial cloud cover to default value if no data available
cloud_cover_default=0.5;
if cloud_cover_available==0,
    for ti=min_time:max_time,
        meteo_data(cloud_cover_index,ti,ro)=cloud_cover_default;
    end
end

%Calculate short wave net radiation when global radiation is available
for ti=min_time:max_time
    if short_rad_in_available==1,
        road_meteo_data(short_rad_net_index,ti,1:num_track,ro) = meteo_data(short_rad_in_index,ti,ro)*(1-albedo_road(ro));
    end
    %Calculate short wave net radiation when global radiation is not available
    if short_rad_in_available==0,
        [short_rad_net_temp azimuth_ang(ti) zenith_ang(ti)] = global_radiation_func(LAT,LON,date_data(datenum_index,ti)+dt_day_sw,DIFUTC_H,Z_SURF,meteo_data(cloud_cover_index,ti,ro),albedo_road(ro));
        road_meteo_data(short_rad_net_index,ti,1:num_track,ro) =short_rad_net_temp;
    end
    %Calculate clear sky short radiation
    [meteo_data(short_rad_in_clearsky_index,ti,ro) azimuth_ang(ti) zenith_ang(ti)]  = global_radiation_func(LAT,LON,date_data(datenum_index,ti)+dt_day_sw,DIFUTC_H,Z_SURF,0,0);
    [short_rad_net_temp azimuth_ang(ti) zenith_ang(ti)]  = global_radiation_func(LAT,LON,date_data(datenum_index,ti)+dt_day_sw,DIFUTC_H,Z_SURF,0,albedo_road(ro));
    road_meteo_data(short_rad_net_clearsky_index,ti,1:num_track,ro) = short_rad_net_temp;
end

%Calculate cloud cover when cloud cover is not available and global is available
%Calculate running means to calculate cloud cover per hour
if cloud_cover_available==0&&short_rad_in_available==1,
    for ti=min_time:max_time
        tr=1;
        ti1=max(ti-dti,min_time);
        ti2=min(ti+dti,max_time);
        ti_num=ti2-ti1+1;
        short_rad_net_rmean(ti)=0;
        short_rad_net_clearsky_rmean(ti)=0;
        for tt=ti1:ti2,
            short_rad_net_rmean(ti)=short_rad_net_rmean(ti)+road_meteo_data(short_rad_net_index,tt,tr,ro)/ti_num;
            short_rad_net_clearsky_rmean(ti)=short_rad_net_clearsky_rmean(ti)+road_meteo_data(short_rad_net_clearsky_index,tt,tr,ro)/ti_num;
        end
        f_short_rad(ti)=short_rad_net_rmean(ti)./short_rad_net_clearsky_rmean(ti);
        f_short_rad(ti)=max(0,f_short_rad(ti));
        f_short_rad(ti)=min(1,f_short_rad(ti));
        meteo_data(cloud_cover_index,ti,ro)=min(1,(1-f_short_rad(ti))/.9);    
    end
elseif cloud_cover_available==0,
    for ti=min_time:max_time,
        meteo_data(cloud_cover_index,ti,ro)=cloud_cover_default;
    end
end

%Calculate in coming long wave radiation
if ~long_rad_in_available,
for ti=min_time:max_time
    meteo_data(long_rad_in_index,ti,ro)= longwave_in_radiation_func...
        (meteo_data(T_a_index,ti,ro)...
        ,meteo_data(RH_index,ti,ro)...
        ,meteo_data(cloud_cover_index,ti,ro),Pressure);
    meteo_data(long_rad_in_index,ti,ro) = meteo_data(long_rad_in_index,ti,ro)+ long_rad_in_offset;
end
end

%Calculate the shadow fraction
if canyon_shadow_flag,
tau_cs_diffuse=0.2;
h_canyon_temp=max(0.001,h_canyon);%Avoids division by 0
for ti=min_time:max_time
    shadow_fraction(ti) = road_shading_func(azimuth_ang(ti),zenith_ang(ti),ang_road,b_road,b_canyon,h_canyon_temp);
    tau_diffuse=tau_cs_diffuse+meteo_data(cloud_cover_index,ti,ro)*(1-tau_cs_diffuse);
    short_rad_direct=road_meteo_data(short_rad_net_index,ti,1:num_track,ro)*(1-tau_diffuse)*(1-shadow_fraction(ti));
    short_rad_diffuse=road_meteo_data(short_rad_net_index,ti,1:num_track,ro)*tau_diffuse;    
    road_meteo_data(short_rad_net_index,ti,1:num_track,ro)=short_rad_direct+short_rad_diffuse;
end
end
%[x_str xplot yplot1]=Average_data_func(date_num,shadow_fraction,min_time,max_time,av);

%Canyon building fascade contribution to longwave radiation
if canyon_long_rad_flag,
%This is based on the integral of a cylinder of height h_canyon. Could be done better
%Uses the average of the two possible canyon heights
h_canyon_temp=max(0.001,mean(h_canyon));%Avoids division by 0
canyon_fraction=(1-sin(atan(b_canyon/2/h_canyon_temp)));%original
theta=atan(h_canyon_temp*2/b_canyon);
canyon_fraction=(1-cos(2*theta))/2/3;%factor 1/3 accounts for the non-cylyndrical nature
canyon_fraction=(1-cos(2*theta/2))/2;%factor 2 for theta to get an average
sigma=5.67E-8;
T0C=273.15;
for ti=min_time:max_time
    long_rad_canyon(ti)=sigma*(T0C+meteo_data(T_a_index,ti,ro))^4;
    %long_rad_in_old=long_rad_in(ti);
    meteo_data(long_rad_in_index,ti,ro)=meteo_data(long_rad_in_index,ti,ro)*(1-canyon_fraction)+long_rad_canyon(ti)*canyon_fraction;
    %long_rad_in_diff(ti)=long_rad_in(ti)-long_rad_in_old;
end
end

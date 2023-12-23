%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_emission_model
%VERSION: 2, 27.06.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Subroutine for calculating emissions and mass loading
%NOTES: Bug in crushing routine fixed 10.05.2023
%==========================================================================


%Data inputs: Incomplete description
%   M_road_0(m)        (Inital/previous road mass loading for dust/salt type m)
%   m                  (mass type index: dust(sus), sand(sus), sand(nonsus), salt(1)and salt(2)) 
%   g_road(ti)         (Liquid water on road in mm)
%   s_road(ti)         (Snow/ice on road in mm w.e.)
%   N(t,v,ti)          (Traffic volume per tyre type and vehicle type)
%   T_a(ti)            (Atmospheric temperature)
%   V_veh(v,ti)        (Average vehicle velocity per vehicle type v)
%   num_mass           (Number of mass types: dust(sus), sand(sus), sand(nonsus) and salts)
%   num_tyre           (Number of tyre types, studded, winter, summer)
%   num_veh            (Number of c\vehicle types: light and heavy)
%   num_wear           (Number of wear sources: road, brake and tyre)
%   num_salt           (Number of salts included in the modelling)
%   p_index            (Pavement type index)
%   d_index            (Driving cycle type index)
%   b_road             (total road width from edge to edge in m)
%   b_road_lanes       (total width of road surface in m)
%   All model parameters
%   V_ref(s)           (Reference vehicle velocity per wear source)
%
%Internal variables
%   M_road_total_0     (Inital/previous road mass loading for sum of dust and salt)
%   WR_array(s,t,v)          (Wear rate, not temporally indexed)

%Data outputs:
%   WR_time(s,ti)      (Wear rates, source and temporally indexed)
%   WR_accumulate(s,ti)(Accumulated wear rates, source and temporally indexed)
%   M_road(m,ti)
%   E_direct_all(x,ti)
%   E_susroad_all(x,ti)
%   E_all(x,ti)
%   E_all_m(x,m,ti)

%Loop indexes
%   t                   (tyre type index)
%   v                   (vehicle type index)
%   m                   (surface loading mass type index, e.g. dust and salt)
%   s                   (wear source index, i.e. road, brake, tyre)
%   x                   (PM size fraction index)
%   j                   (dust index)
%   i                   (salt index)
%   ti                  (time loop index)

%--------------------------------------------------------------------------
%Dimmension time dependent variables at the first time step
%--------------------------------------------------------------------------
    
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Set initial mass for this time step
%--------------------------------------------------------------------------
%Set common constants
%road_dust_set_constants_v2


    %Dimmension internal arrays without time dependence
    M_road_bin_0_data(1:num_source,1:num_size)=nodata;
    P_wear(1:num_size)=0;
    E_wear(1:num_size)=0;
    P_abrasion(1:num_size)=0;
    E_abrasion(1:num_size)=0;
    f_abrasion_temp=0;
    abrasion_temp(1:num_size)=0;
    P_crushing(1:num_size)=0;
    E_crushing(1:num_size)=0;
    f_crushing_temp=0;
    crushing_temp(1:num_size)=0;
    %see declarations before each section

%Allows salt that is dissolved to be suspended and sprayed
use_dissolved_ratio=1;

%--------------------------------------------------------------------------
%Set the mass loading prior to the time step
%Bin the size distributions
%--------------------------------------------------------------------------
M_road_bin_0_data(1:num_source,1:num_size)=M_road_bin_data(1:num_source,1:num_size,max(min_time,ti-1),tr,ro);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%It is assumed then throughout the rest of this routine that the binned
%size categories are to be used for calculations
%These will be returned at the end
%--------------------------------------------------------------------------

%==========================================================================
%Calculate road production of dust and salt for each track and each road
%==========================================================================

%--------------------------------------------------------------------------
%Calculate the direct source wear rates for each s, t and v (WR)
%--------------------------------------------------------------------------
clear WR_array
WR_array(1:num_wear,1:num_tyre,1:num_veh)=0;
wear_temp=0;
WR_temp=0;
for s=1:num_wear,
    WR_temp=0;
        for t=1:num_tyre,
        for v=1:num_veh,
            wear_temp=W_func(W_0(s,t,v),h_pave(p_index),h_drivingcycle(d_index)...
                ,traffic_data(V_veh_index(v),ti,ro),a_wear(s,:),sum(g_road_data(snow_ice_index,ti,tr,ro))...
                ,s_roadwear_thresh,s,road_index,tyre_index,brake_index);
            WR_array(s,t,v)=traffic_data(N_t_v_index(t,v),ti,ro)*veh_track(tr)*wear_temp*wear_flag(s);
            WR_temp=WR_temp+WR_array(s,t,v);
        end
        end
     WR_time_data(s,ti,tr,ro)=WR_temp;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate PM fraction speed dependence correction for road wear and PM only
%--------------------------------------------------------------------------
clear f_PM_adjust
f_PM_adjust(1:num_source,1:num_size,1:num_tyre,1:num_veh)=1;
s=road_index;
x=[pm_10 pm_25];
for v=1:num_veh,
    %Only allow the paramterisation between 20 and 60 km/hr
    V_temp=min(60,max(20,traffic_data(V_veh_index(v),ti,ro)));
    f_PM_adjust(s,x,1:num_tyre,v)=(1+c_pm_fraction*V_temp)/(1+c_pm_fraction*V_ref_pm_fraction);
end
%Decrease the 200 um bin accordingly
%for v=1:num_veh,
%    f_PM_adjust(s,[pm_all pm_200],1:num_tyre,v)=1+f_PM_adjust(s,[pm_all pm_200],1:num_tyre,v)-sum(f_PM_adjust(s,x,1:num_tyre,v))/2;
%    f_PM_adjust(s,pm_200,1:num_tyre,v)=1-sum(f_PM_adjust(s,x,1:num_tyre,v).*f_PM_bin(s,x,t))/f_PM_bin(s,pm_200,t);
%end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate surface mass production due to retention of wear (P_wear)
%--------------------------------------------------------------------------
clear P_wear E_wear
P_wear(1:num_size)=0;
E_wear(1:num_size)=0;
for s=1:num_wear,
    P_wear(1:num_size)=0;
    E_wear(1:num_size)=0;
    for t=1:num_tyre,
    for v=1:num_veh,
        P_wear(1:num_size)=P_wear(1:num_size)...
            +WR_array(s,t,v).*(1-f_0_dir(s).*f_q(s,ti,tr,ro)).*f_PM_bin(s,1:num_size,t).*f_PM_adjust(s,1:num_size,t,v);
        E_wear(1:num_size)=E_wear(1:num_size)...
            +WR_array(s,t,v).*f_0_dir(s).*f_PM_bin(s,1:num_size,t).*f_PM_adjust(s,1:num_size,t,v).*f_q(s,ti,tr,ro);
    end
    end
    %Total suspended wear
    E_road_bin_data(s,1:num_size,E_direct_index,ti,tr,ro)=E_wear(1:num_size);
    %Total retained wear distributed over all the tracks according to area
    for tr2=1:num_track,
        M_road_bin_balance_data(s,1:num_size,P_wear_index,ti,tr2,ro)=P_wear(1:num_size)*f_track(tr2);
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate road production and emission rate due to abrasion  (P_abrasion)
%Dependent on the course sand mass (pm_all - pm_200)
%Fix this, this is not right. It does not use larger sizes to abrade
%smaller
%It is also unstable, due tot he dependence on surface mass
%--------------------------------------------------------------------------
if abrasion_flag,
  clear WR_temp P_abrasion E_abrasion f_abrasion_temp
  P_abrasion(1:num_size)=0;
  E_abrasion(1:num_size)=0;
  f_abrasion_temp(1:num_size)=0;
  WR_temp=0;
  for s=1:num_source
    if p_0_abrasion(s)>0,
      %Calculate the abrasion caused by each of the size bins
      for t=1:num_tyre,
      for v=1:num_veh,
        f_abrasion_temp=f_abrasion_func(f_0_abrasion(t,v),h_pave(p_index),traffic_data(V_veh_index(v),ti,ro)...
            ,sum(g_road_data(snow_ice_index,ti,tr,ro)),V_ref_abrasion,s_roadwear_thresh).*h_0_abrasion(1:num_size);
        abrasion_temp(1:num_size)=traffic_data(N_t_v_index(t,v),ti,ro)/n_lanes*veh_track(tr)...
            .*f_abrasion_temp(1:num_size).*M_road_bin_0_data(s,1:num_size); %This could be a sum actually. Tried it unstable.
        P_abrasion(1:num_size)=P_abrasion(1:num_size)+abrasion_temp(1:num_size)...
            .*(1-f_0_dir(abrasion_index)*f_q(road_index,ti,tr,ro));
        E_abrasion(1:num_size)=E_abrasion(1:num_size)+abrasion_temp(1:num_size)...
            .*f_0_dir(abrasion_index)*f_q(road_index,ti,tr,ro);            
        WR_temp=WR_temp+sum(abrasion_temp(1:num_size));
      end
      end   
    end
  end
  %Distribute the abrasion to the size bins and tracks
  s=road_index;
  for x=1:num_size,
    for tr2=1:num_track,
      M_road_bin_balance_data(s,1:num_size,P_abrasion_index,ti,tr2,ro)...
          =P_abrasion(x).*f_PM_bin(abrasion_index,1:num_size,1)*f_track(tr2);
    end
    E_road_bin_data(s,1:num_size,E_direct_index,ti,tr,ro)...
        =E_road_bin_data(s,1:num_size,E_direct_index,ti,tr,ro)...
        +E_abrasion(x).*f_PM_bin(abrasion_index,1:num_size,1);
  end
  WR_time_data(s,ti,tr,ro)=WR_time_data(s,ti,tr,ro)+WR_temp;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate production and emission due to crushing (P_crushing).
%Need to check this!!!!!!!!!!!!!
%No tyre dependence in the distribution f_PM_bin(crushing_index...
%--------------------------------------------------------------------------
clear R_crushing
R_crushing(1:num_source,1:num_size)=0;
f_crushing_temp=0;
%Have changed this
M_road_bin_balance_data(1:num_source,1:num_size,P_crushing_index,ti,:,ro)=0;
if crushing_flag,
  for s=1:num_source
    if p_0_crushing(s)>0,
        for t=1:num_tyre,
        for v=1:num_veh,
            f_crushing_temp=f_crushing_func(f_0_crushing(t,v),traffic_data(V_veh_index(v),ti,ro)...
                ,sum(g_road_data(snow_ice_index,ti,tr,ro)),V_ref_crushing,s_roadwear_thresh)*h_0_crushing(1:num_size);
            R_crushing(s,1:num_size)=R_crushing(s,1:num_size)+traffic_data(N_t_v_index(t,v),ti,ro)/n_lanes*veh_track(tr)*f_crushing_temp;
            M_road_bin_balance_data(s,1:num_size,S_crushing_index,ti,tr,ro)=R_crushing(s,1:num_size).*M_road_bin_0_data(s,1:num_size);
        end
        end
        %Distribute the crushing sink to the product in the smaller sizes
        for x=1:num_size-1,
            for x2=x+1:num_size,
              for tr2=1:num_track,
                %Have changed this
                M_road_bin_balance_data(s,x2,P_crushing_index,ti,tr2,ro)...
                  =M_road_bin_balance_data(s,x2,P_crushing_index,ti,tr2,ro)...
                  +M_road_bin_balance_data(s,x,S_crushing_index,ti,tr,ro)...
                  .*(1-f_0_dir(crushing_index)*f_q(s,ti,tr,ro)).*f_PM_bin(crushing_index,x2,1)./sum(f_PM_bin(crushing_index,x+1:num_size,1));
              end
              E_road_bin_data(s,x2,E_direct_index,ti,tr,ro)...
                =E_road_bin_data(s,x2,E_direct_index,ti,tr,ro)...
                +M_road_bin_balance_data(s,x,S_crushing_index,ti,tr,ro)...
                .*f_0_dir(crushing_index)*f_q(s,ti,tr,ro).*f_PM_bin(crushing_index,x2,1)./sum(f_PM_bin(crushing_index,x+1:num_size,1));
            end
        end
    end  
  end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate road production flux due to deposition (F_deposition g/(km.m)/hr)
%Based on PM10 background concentrations
%--------------------------------------------------------------------------
if (PM_background(pm_10,ti)~=nodata)&&dust_deposition_flag,
    %M_road_bin_balance_data(depo_index,2:num_size,P_depo_index,ti,tr,ro)=w_dep(1:num_size-1)...
    %    .*f_PM_bin(depo_index,2:num_size,1)./f_PM_bin(depo_index,pm_10,1)*max(0,PM_background(pm_10,ti))...
    %    *3.6*b_road_lanes*f_track(tr);
    %w_dep is not classified for over 200 um so there is a shift 
    M_road_bin_balance_data(depo_index,2:num_size,P_depo_index,ti,tr,ro)=w_dep(1:num_size-1)...
        .*f_PM_bin(depo_index,2:num_size,1)./f_PM_bin(depo_index,pm_10,1)*max(0,20)...
        *3.6*b_road_lanes*f_track(tr);
else
    M_road_bin_balance_data(depo_index,1:num_size,P_depo_index,ti,tr,ro)=0;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate road production due to sanding (P_sanding)
%--------------------------------------------------------------------------
M_road_bin_balance_data(sand_index,1:num_size,P_depo_index,ti,tr,ro)=...
    activity_data(M_sanding_index,ti,ro)/dt*f_PM_bin(sand_index,1:num_size,1)...
    *1000*b_road_lanes*f_track(tr)*use_sanding_data_flag;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate road production due to exhaust deposition (P_exhaust)
%Initial exhaust emissions are in E_road_bin_data(exhaust_index,pm_25,E_total_index,ti,tr,ro)
%This is overwritten at the end of the calculation as the sum of direct and
%suspended but the total should be almost the same
%--------------------------------------------------------------------------
if (EP_emis_available||exhaust_EF_available)&&exhaust_flag,
	M_road_bin_balance_data(exhaust_index,1:num_size,P_depo_index,ti,tr,ro)...
        =E_road_bin_data(exhaust_index,1:num_size,E_total_index,ti,tr,ro)...
        .*f_PM_bin(exhaust_index,1:num_size,1)*f_track(tr)*(1-f_0_dir(exhaust_index));        
    E_road_bin_data(exhaust_index,1:num_size,E_direct_index,ti,tr,ro)...
        =E_road_bin_data(exhaust_index,1:num_size,E_total_index,ti,tr,ro)...
        .*f_PM_bin(exhaust_index,1:num_size,1)*f_track(tr)*f_0_dir(exhaust_index);        
else
    M_road_bin_balance_data(exhaust_index,1:num_size,P_depo_index,ti,tr,ro)=0;
    E_road_bin_data(exhaust_index,1:num_size,E_direct_index,ti,tr,ro)=0;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate road production due to fugitive deposition (P_fugitive g/km)
%Currently just a constant. Should be put in as a time series
%--------------------------------------------------------------------------
M_road_bin_balance_data(fugitive_index,1:num_size,P_depo_index,ti,tr,ro)=...
    (P_fugitive+activity_data(M_fugitive_index,ti,ro))/dt*f_PM_bin(fugitive_index,1:num_size,1)*f_track(tr);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Calculate production of salt (P_salt)
%--------------------------------------------------------------------------
for i=1:num_salt,
M_road_bin_balance_data(salt_index(i),1:num_size,P_depo_index,ti,tr,ro)=...
    activity_data(M_salting_index(i),ti,ro)/dt*f_PM_bin(salt_index(i),1:num_size,1)...
    *1000*b_road_lanes*f_track(tr)*use_salting_data_flag(i);
end
%--------------------------------------------------------------------------

%==========================================================================
%Calculate road sinks
%==========================================================================

%--------------------------------------------------------------------------
%Calculate the suspension emission sink rate from the road (R_suspension)
%--------------------------------------------------------------------------
clear R_suspension R_suspension_array
R_suspension(1:num_source,1:num_size)=0;
R_suspension_array(1:num_size)=0;
for s=1:num_source,
    R_suspension(s,1:num_size)=0;
    if s==salt_index(1)&&use_dissolved_ratio,
        not_dissolved_ratio_temp=(1.-road_salt_data(dissolved_ratio_index,1,ti,tr,ro));
    elseif s==salt_index(2)&&use_dissolved_ratio,
        not_dissolved_ratio_temp=(1.-road_salt_data(dissolved_ratio_index,2,ti,tr,ro));
    else
        not_dissolved_ratio_temp=1.;
    end
    for t=1:num_tyre,
    for v=1:num_veh,
        f_0_suspension_temp(1:num_size)=h_sus*f_susroad_func(f_0_suspension(s,1:num_size,t,v),traffic_data(V_veh_index(v),ti,ro),a_sus);
        R_suspension_array(1:num_size)=traffic_data(N_t_v_index(t,v),ti,ro)/n_lanes*veh_track(tr)*f_0_suspension_temp...
            .*(f_q(s,ti,tr,ro).*h_0_q_road(1:num_size)+(1-h_0_q_road(1:num_size)))...
            *not_dissolved_ratio_temp*road_suspension_flag;        
        R_suspension(s,1:num_size)=R_suspension(s,1:num_size)+R_suspension_array(1:num_size);
    end
    end
    %Diagnose the suspension sink 
	M_road_bin_balance_data(s,1:num_size,S_suspension_index,ti,tr,ro)...
        =R_suspension(s,1:num_size).*M_road_bin_0_data(s,1:num_size);
    %Calculate the emissions. The same as the suspension sink
    E_road_bin_data(s,1:num_size,E_suspension_index,ti,tr,ro)...
        =M_road_bin_balance_data(s,1:num_size,S_suspension_index,ti,tr,ro);
end

%--------------------------------------------------------------------------
%Note that retention may not be applicable for large particle sizes
%When ice is present then the wet removal should be 0

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Wind blown dust road sink and emission rate (R_windblown)
%Only suspendable particles included
%--------------------------------------------------------------------------
clear R_windblown
R_windblown(1:num_source,1:num_size)=0;
for s=1:num_source,
    R_windblown(s,pm_sus)=R_0_wind_func(meteo_data(FF_index,ti,ro),tau_wind,FF_thresh)*f_q(s,ti,tr,ro)*wind_suspension_flag;
	M_road_bin_balance_data(s,pm_sus,S_windblown_index,ti,tr,ro)=...
        R_windblown(s,pm_sus).*M_road_bin_0_data(s,pm_sus);
    E_road_bin_data(s,1:num_size,E_windblown_index,ti,tr,ro)=M_road_bin_balance_data(s,1:num_size,S_windblown_index,ti,tr,ro);    
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Spray and splash road sink (R_spray)
%--------------------------------------------------------------------------
clear R_spray
R_spray(1:num_source,1:num_size)=0;
dissolved_ratio_temp=1.;
h_eff_temp(1,1:num_size)=0;
if sum(g_road_data(1:num_moisture,ti,tr,ro),1)>0&&dust_spray_flag,
    for s=1:num_source,
        if s==salt_index(1)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,1,ti,tr,ro);
        elseif s==salt_index(2)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,2,ti,tr,ro);
        else
            dissolved_ratio_temp=1.;
        end
        h_eff_temp(1,1:num_size)=h_eff(spraying_eff_index,s,1:num_size);
        R_spray(s,1:num_size)=sum(g_road_balance_data(1:num_moisture,R_spray_index,ti,tr,ro),1)...
            .*h_eff_temp(1,1:num_size).*dissolved_ratio_temp;
	    M_road_bin_balance_data(s,1:num_size,S_dustspray_index,ti,tr,ro)=...
            R_spray(s,1:num_size).*M_road_bin_0_data(s,1:num_size);
	    %Production due to spray for multitracks. See the surface wetness routine
        M_road_bin_balance_data(s,1:num_size,P_dustspray_index,ti,tr,ro)=...
            sum(g_road_balance_data(1:num_moisture,P_spray_index,ti,tr,ro),1)...
            .*h_eff_temp(1,1:num_size).*dissolved_ratio_temp...
            .*M_road_bin_0_data(s,1:num_size);
    end
else
    M_road_bin_balance_data(1:num_source,1:num_size,S_dustspray_index,ti,tr,ro)=0;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Drainage road sink rate (R_drainage)
%--------------------------------------------------------------------------
clear R_drainage
R_drainage(1:num_source,1:num_size)=0;
dissolved_ratio_temp=1.;
if drainage_type_flag==1||drainage_type_flag==3,
  if g_road_data(snow_index,ti,tr,ro)<snow_dust_drainage_retainment_limit&&dust_drainage_flag>0,
    for s=1:num_source,
        if s==salt_index(1)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,1,ti,tr,ro);
        elseif s==salt_index(2)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,2,ti,tr,ro);
        else
            dissolved_ratio_temp=1.;
        end
        R_drainage(s,1:num_size)=g_road_balance_data(water_index,R_drainage_index,ti,tr,ro)...
            .*h_eff(drainage_eff_index,s,1:num_size).*dissolved_ratio_temp;
	    M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro)=...
            R_drainage(s,1:num_size).*M_road_bin_0_data(s,1:num_size);      
    end
  else
    M_road_bin_balance_data(1:num_source,1:num_size,S_dustdrainage_index,ti,tr,ro)=0;
  end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Cleaning road sink rate (R_cleaning)
%--------------------------------------------------------------------------
clear R_cleaning
R_cleaning(1:num_source,1:num_size)=0;
for s=1:num_source,
    R_cleaning(s,1:num_size)=-log(1-min(0.99999,h_eff(cleaning_eff_index,s,1:num_size)...
        *activity_data(t_cleaning_index,ti,ro)))/dt*use_cleaning_data_flag;
	M_road_bin_balance_data(s,1:num_size,S_cleaning_index,ti,tr,ro)=...
        R_cleaning(s,1:num_size).*M_road_bin_0_data(s,1:num_size);      
end
%--------------------------------------------------------------------------

%Ploughing road sink (R_ploughing)
%--------------------------------------------------------------------------
clear R_ploughing
R_ploughing(1:num_source,1:num_size)=0;
for s=1:num_source,
    R_ploughing(s,1:num_size)=-log(1-min(0.99999,h_eff(ploughing_eff_index,s,1:num_size)...
        *activity_data(t_ploughing_index,ti,ro)))/dt*use_ploughing_data_flag*dust_ploughing_flag;
	M_road_bin_balance_data(s,1:num_size,S_dustploughing_index,ti,tr,ro)=...
        R_ploughing(s,1:num_size).*M_road_bin_0_data(s,1:num_size);      
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Distribute wear, abrasion and crushing production terms between tracks
%--------------------------------------------------------------------------
%{
if num_track>1,
    clear M_road_bin_balance_data_temp
    M_road_bin_balance_data_temp(1:num_source,1:num_size,1:num_dustbalance)=0;
    %Save the current production in all tracks
    M_road_bin_balance_data_temp(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index])...
        =M_road_bin_balance_data(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index],ti,tr,ro);
    %Delete the current balance in the current track
    M_road_bin_balance_data(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index],ti,tr,ro)=0;
    %Redistribute according to area
    for tr2=1:num_track,
        M_road_bin_balance_data(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index],ti,tr2,ro)...
        =M_road_bin_balance_data(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index],ti,tr2,ro)...
        +M_road_bin_balance_data_temp(1:num_source,1:num_size,[P_wear_index P_abrasion_index P_crushing_index])*f_track(tr2);
    end
end
%}
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Add up the contributions for the road mass and salt production (P_road)
%--------------------------------------------------------------------------
M_road_bin_balance_data(1:num_source,1:num_size,P_dusttotal_index,ti,tr,ro)...
    =M_road_bin_balance_data(1:num_source,1:num_size,P_wear_index,ti,tr,ro)...
    +M_road_bin_balance_data(1:num_source,1:num_size,P_abrasion_index,ti,tr,ro)...
    +M_road_bin_balance_data(1:num_source,1:num_size,P_crushing_index,ti,tr,ro)...
    +M_road_bin_balance_data(1:num_source,1:num_size,P_depo_index,ti,tr,ro);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Add up all the road sink rates (R_total)
%--------------------------------------------------------------------------
clear R_total
R_total(1:num_source,1:num_size)=0;
R_total(1:num_source,1:num_size)...
    =R_drainage(1:num_source,1:num_size)...
    +R_cleaning(1:num_source,1:num_size)...
    +R_ploughing(1:num_source,1:num_size)...
    +R_spray(1:num_source,1:num_size)...
    +R_crushing(1:num_source,1:num_size)...
    +R_suspension(1:num_source,1:num_size)...
    +R_windblown(1:num_source,1:num_size);    
%--------------------------------------------------------------------------
    
%--------------------------------------------------------------------------
%Calculate mass balance for the road
%--------------------------------------------------------------------------
%s=salt_index(na);
%x=pm_10;
%fprintf('%f %f %f\n',M_road_bin_0_data(s,x),M_road_bin_balance_data(s,x,P_dusttotal_index,ti,tr,ro),R_total(s,x));
%fprintf('%f %f %f %f %f %f %f\n',R_drainage(s,x),R_cleaning(s,x),R_ploughing(s,x),R_spray(s,x),R_crushing(s,x),R_suspension(s,x),R_windblown(s,x));
for s=1:num_source,
for x=1:num_size,
    M_road_bin_data(s,x,ti,tr,ro)...
    =mass_balance_func(M_road_bin_0_data(s,x)...
    ,M_road_bin_balance_data(s,x,P_dusttotal_index,ti,tr,ro)...
    ,R_total(s,x),dt);
end
end

%Diagnose sinks
M_road_bin_balance_data(1:num_source,1:num_size,S_dusttotal_index,ti,tr,ro)...
    =R_total(1:num_source,1:num_size).*M_road_bin_0_data(1:num_source,1:num_size);
%--------------------------------------------------------------------------

%Remove mass through drainage using drainage type = 2 or 3
%--------------------------------------------------------------------------
clear h_eff_temp
drain_factor=1;
dissolved_ratio_temp=1.;
h_eff_temp(1,1:num_size)=0;
if drainage_type_flag==2||drainage_type_flag==3,
    %drain_factor=g_road_data(water_drainable_index,ti,tr,ro)/(g_road_drainable_min+g_road_data(water_drainable_index,ti,tr,ro));
    drain_factor=g_road_balance_data(water_index,S_drainage_index,ti,tr,ro)*dt...
        /(g_road_drainable_min+g_road_balance_data(water_index,S_drainage_index,ti,tr,ro)*dt);
    for s=1:num_source,
        if s==salt_index(1)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,1,ti,tr,ro);
        elseif s==salt_index(2)&&use_dissolved_ratio,
            dissolved_ratio_temp=road_salt_data(dissolved_ratio_index,2,ti,tr,ro);
        else
            dissolved_ratio_temp=1.;
        end
        M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro)=0;
        h_eff_temp(1,1:num_size)=h_eff(drainage_eff_index,s,1:num_size);
        if dust_drainage_flag==1,
            M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro)...
                =M_road_bin_data(s,1:num_size,ti,tr,ro)...
                *dissolved_ratio_temp.*h_eff_temp*drain_factor/dt;
        elseif dust_drainage_flag==2,
            M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro)...
                =M_road_bin_data(s,1:num_size,ti,tr,ro)...
                .*dissolved_ratio_temp.*(1-exp(-h_eff_temp.*drain_factor))/dt;
        end
        M_road_bin_data(s,1:num_size,ti,tr,ro)...
            =M_road_bin_data(s,1:num_size,ti,tr,ro)...
            -M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro)*dt;
        M_road_bin_balance_data(s,1:num_size,S_dusttotal_index,ti,tr,ro)...
            =M_road_bin_balance_data(s,1:num_size,S_dusttotal_index,ti,tr,ro)...
            +M_road_bin_balance_data(s,1:num_size,S_dustdrainage_index,ti,tr,ro);
    end
end

%--------------------------------------------------------------------------
%Remove any negative values in mass (round off errors)
%--------------------------------------------------------------------------
for s=1:num_source,
    for x=1:num_size,
        M_road_bin_data(s,x,ti,tr,ro)=max(0,M_road_bin_data(s,x,ti,tr,ro));
    end
end
%--------------------------------------------------------------------------
%Calculate the final total road dust loadings. Not including salt
%--------------------------------------------------------------------------
M_road_bin_data(total_dust_index,1:num_size,ti,tr,ro)...
    =sum(M_road_bin_data(dust_index,1:num_size,ti,tr,ro),1);
M_road_bin_balance_data(total_dust_index,1:num_size,1:num_dustbalance,ti,tr,ro)...
    =sum(M_road_bin_balance_data(dust_index,1:num_size,1:num_dustbalance,ti,tr,ro),1);
%--------------------------------------------------------------------------

%==========================================================================
%Calculate binned emissions
%==========================================================================

%--------------------------------------------------------------------------
%Total emissions for each source
%--------------------------------------------------------------------------
E_road_bin_data(1:num_source,1:num_size,E_total_index,ti,tr,ro)...
    =E_road_bin_data(1:num_source,1:num_size,E_direct_index,ti,tr,ro)...
    +E_road_bin_data(1:num_source,1:num_size,E_suspension_index,ti,tr,ro)...
    +E_road_bin_data(1:num_source,1:num_size,E_windblown_index,ti,tr,ro);
%--------------------------------------------------------------------------
%Total dust emissions (i.e. including salt)
%--------------------------------------------------------------------------
E_road_bin_data(total_dust_index,1:num_size,1:num_process,ti,tr,ro)...
    =sum(E_road_bin_data(1:num_source,1:num_size,1:num_process,ti,tr,ro),1);
%--------------------------------------------------------------------------

%==========================================================================


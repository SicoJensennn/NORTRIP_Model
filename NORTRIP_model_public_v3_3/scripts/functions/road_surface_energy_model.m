%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_control_v2
%VERSION: 2.8, 01.11.2014
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no;bruce.denby@met.no) and Ingrid
%Sundvor (is@nilu.no)
%DESCRIPTION: Control script for running the NORTRIP model
%Based on the previous Surface_energy_model_3_func but includes ice
%function [TCs_out evap evap_pot melt freeze H L G long_out long_net rad_net G_sub] = Surface_energy_model_3_func(short_net,long_in,H_traffic,r_aero,TC,TCs,TCsub,RH,RHs,P,dzs_in,dt_h,g_surf,s_surf,g_min,melt_temperature,sub_surf_param,surface_humidity_flag,use_subsurface_flag)
%==========================================================================
%Set a number of local variables to the global variables.
%This is done to preserve the universal application of the model
%Postfixed with ebm (energy balance model) for clarity
short_net_ebm=road_meteo_data(short_rad_net_index,ti,tr,ro);
long_in_ebm=long_rad_in(ti);
H_traffic_ebm=road_meteo_data(H_traffic_index,ti,tr,ro);
r_aero_ebm=road_meteo_data(r_aero_index,ti,tr,ro);
TC_ebm=T_a(ti);
TCs_ebm=road_meteo_data(T_s_index,max(min_time,ti-1),tr,ro);
TCsub_ebm=T_sub(ti);
RH_ebm=RH(ti);
RHs_ebm=road_meteo_data(RHs_index,max(min_time,ti-1),tr,ro);
P_ebm=Pressure;
dzs_ebm=dzs;
dt_h_ebm=dt;
g_surf_ebm=g_road_0_data;
g_min_ebm=g_road_evaporation_thresh;
melt_temperature_ebm=road_meteo_data(T_melt_index,ti,tr,ro);
sub_surf_param_ebm=sub_surf_param;%3 values
%surface_humidity_flag
%use_subsurface_flag

if g_surf_ebm(snow_index)>dz_snow_albedo,
	short_net_ebm=short_net_ebm*(1-albedo_snow)/(1-albedo_road);
end

%Local variables, in addition to the declarations
dzs_temp=nodata;
rho=nodata;
g_surf_fraction=nodata;

%Includes melt of snow as output and includes snow surface and melt temperature as
%additional inputs to the original Surface_energy_model_2_func version
%Also includes a relationship for vapour pressure of ice

%Set the available melting energy (W/m2)
G_melt=0;

%Set constants
Cp=1006;
lambda=2.50E6;
lambda_ice=2.83E6;
lambda_melt=3.33E5; %(J/kg)
RD=287.0;
T0C=273.15;
gam=Cp/lambda;
sigma=5.67E-8;

%Set time step in seconds
dt_sec=dt_h_ebm*3600;
%Set longwave emissivity to 1
eps_s=1;
%Set the absolute temperature (K)
TK_a=T0C+TC_ebm;
%Set the initial surface temperature locally
TCs_0=TCs_ebm;
TCs=TCs_ebm;

%Set the subsurface paramters
rho_s=sub_surf_param_ebm(1);
c_s=sub_surf_param_ebm(2);
k_s_road=sub_surf_param_ebm(3);
C_s=rho_s*c_s;
omega=7.3e-5;

%Set slab septh automatically or not, based on value of dzs_in
if dzs_ebm==0,
    dzs_temp=(k_s_road/C_s/2/omega)^.5;
else
    dzs_temp=dzs_ebm;
end
mu=omega*C_s*dzs_temp;
if ~use_subsurface_flag,
    mu=0;
end

%Set limits of latent heat flux
L_max=500;L_min=-200;

%Set limitflags for evaporation and condensation
%Controls if limits are put in place to avoid overshooting
set_limit_noevap=1;
limit_evap=1;
limit_condens=0;

%Air density
rho=P_ebm*100./(RD*TK_a);

%Fraction of the water, snow and ice
g_surf_fraction=g_surf_ebm./sum(g_surf_ebm,1);
lambda_mixed=g_surf_fraction(water_index)*lambda+(g_surf_fraction(ice_index)+g_surf_fraction(snow_index))*lambda_ice;

%Set values of constants for implicit solution
a_G=1/(C_s*dzs_temp);
a_rad=short_net_ebm+long_in_ebm+H_traffic_ebm;
a_RL=(1-4*TC_ebm/TK_a)*eps_s*sigma*TK_a^4;
b_RL=4*eps_s*sigma*TK_a^3;
a_H=rho*Cp/r_aero_ebm;

%specific humidty of the air
[esat qsat s] = q_sat_func(TC_ebm,P_ebm);
q=qsat*RH_ebm/100;
%Specific humidity of the surface water
%[esat qsats s] = q_sat_func(TCs,P);
%qs=qsats*RHs/100;
%Specific humidity of the surface ice
%[esat_ice qsats_ice s_ice] = q_sat_ice_func(TCs,P);
%qs_ice=qsats_ice*RHs/100;
%Specific humidity of the combined surface

%GOT TO HERE AND FOUND OUT THIS WASN'T SO SMART
%LOOK AT THIS AGAIN LATER

%Loop with updates of the latent heat flux
for i=1:2,
    
    %Specific humidity of the surface
    [esat qsats_water s] = q_sat_func(TCs_ebm,P_ebm);
    [esat_ice qsats_ice s_ice] = q_sat_ice_func(TCs_ebm,P_ebm);
    qsats=g_surf_fraction*qsats_water+s_surf_fraction*qsats_ice;
    qsats=g_surf_fraction(water_index)*qsats_water+(g_surf_fraction(ice_index)+g_surf_fraction(snow_index))*qsats_ice;

    qs_water=qsats_water*RHs/100;
    qs_ice=qsats_ice*RHs/100;

    %{
    if i==1,
        qs_water_0=qs_water;
        qs_ice_0=qs_ice;
    else
        qs_water=(qs_water_0+qs_water)/2;
        qs_ice=(qs_ice_0+qs_ice)/2;
    end
    %}
    qs=g_surf_fraction*qs_water+s_surf_fraction*qs_ice;
    
    %Latent heat flux
    L_water=-rho*lambda*(q-qs_water)/r_aero;
    L_ice=-rho*lambda_ice*(q-qs_ice)/r_aero;
        L_water=max(L_min,min(L_max,L_water));
        L_ice=max(L_min,min(L_max,L_ice));
    evap_water=L_water/lambda*dt_sec/dt_h;
    evap_ice=L_ice/lambda_ice*dt_sec/dt_h;
    L=g_surf_fraction*L_water+s_surf_fraction*L_ice;
    evap=g_surf_fraction*evap_water+s_surf_fraction*evap_ice;
    
    %Limit evaporation (L) to the amount of water available
    if set_limit_noevap==1,
        if surface_humidity_flag==1,
            g_noevap=q/qsats*g_min;
        elseif surface_humidity_flag==2,
            g_noevap=-log(1-q/qsats)*g_min/2;
        end
    else
        g_noevap=0;
    end
    if limit_evap,
      if evap>=(g_s_surf-g_noevap)/dt_h&&evap>=0,
        evap=max(0,(g_s_surf-g_noevap)/dt_h);
        L=evap*lambda_mixed*dt_h/dt_sec;
        L=max(L_min,min(L_max,L));
      end
    end
    if limit_condens,
      if evap<=(g_s_surf-g_noevap)/dt_h&&evap<0,
        evap=min(0,(g_s_surf-g_noevap)/dt_h);
        L=evap*lambda_mixed*dt_h/dt_sec;
        L=max(L_min,min(L_max,L));
      end
    end
    
    %Calculate surface temperature implicitly to avoid instabilities
    %TCs=(TCs_0+dt_sec*a_G*(a_rad-a_RL-L+a_H*TC))/(1+dt_sec*a_G*(a_H+b_RL));
    TCs=(TCs_0+dt_sec*a_G*(a_rad-a_RL-L+a_H*TC+mu*TCsub))/(1+dt_sec*a_G*(a_H+b_RL+mu));
    
    %Limit the surface temperature to the freezing point if there is ice on the surface (> g_min)
    %if s_surf>g_min,
    %    TCs=min(TCs,melt_temperature);
    %end
    %TCs=TC;

    TCs_out=TCs;
    TCs=(TCs_0+TCs)/2;
    %fprintf(' : %6.3f',TCs_out);
end
    %fprintf('\n');

%Sensible heat flux based on average surface temperature
H=-rho*Cp*(TC-TCs_out)/r_aero;

%Potential evaporation
L_pot_water=-rho*lambda*(q-qsats_water)/r_aero;
L_pot_ice=-rho*lambda_ice*(q-qsats_ice)/r_aero;
%L_pot=g_surf_fraction*L_pot_water+s_surf_fraction*L_pot_ice;
evap_pot_water=L_pot_water/lambda*dt_sec/dt_h;
evap_pot_ice=L_pot_ice/lambda_ice*dt_sec/dt_h;
evap_pot=g_surf_fraction*evap_pot_water+s_surf_fraction*evap_pot_ice;

%Radiation based on average temperature
long_out=eps_s*sigma*(T0C+TCs_out)^4;
long_net=long_in-long_out;
rad_net=short_net+long_net;
G_sub=-mu*(TCs-TCsub);

%Surface flux
G=rad_net-H-L+H_traffic;

%Calculate melt
if s_surf>0&&(G+G_melt)>=0&&TCs_out>melt_temperature,
	melt=(G+G_melt)/lambda_melt*dt_sec/dt_h;
	melt=min(melt,s_surf);
else
	melt=0;
end

%Calculate freezing
if g_surf>0&&(G+G_melt)<0&&TCs<=melt_temperature,
	freeze=-(G+G_melt)/lambda_melt*dt_sec/dt_h;
	freeze=min(freeze,g_surf);
else
	freeze=0;
end

end


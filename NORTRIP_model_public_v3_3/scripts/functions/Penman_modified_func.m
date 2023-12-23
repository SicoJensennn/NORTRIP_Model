function [evap_m evap_pot TCs H L G] = Penman_modified_func(rad_net,G,r_aero,TC,RH,RHs,P,dt_h,g_surf,g_min,surface_humidity_flag)
%Output units are mm/hr

set_limit_noevap=1;

%Set constants
Cp=1006;
lambda=2.5E6;
RD=287.0;
T0C=273.15;
gam=Cp/lambda;
dt_sec=dt_h*3600;

%Lower boundary to the surface relative humidity at 1%
RHs=max(RHs,1);

%Setmodified gam
gam_m=gam*100/RHs;

%Determine density
rho=P*100./(RD*(T0C+TC));
%Determine saturated vapour pressure in air
[esat qsat s] = q_sat_func(TC,P);
%Set the water vapour deficit
q_def=qsat*(1-RH/100);
q_def_m=qsat*(RHs/100-RH/100);
q=qsat*(RH/100);
%qsats=qsat;

%Set gamma's
gamma=s/(s+gam);
gamma_m=s/(s+gam_m);

%Set the surface energy flux to be 20% of the net radiation
%G=0.2*rad_net;

%Potential evaporation
evap_pot=3600/lambda*(gamma*(rad_net-G)+(1-gamma)*rho*lambda*q_def/r_aero);
%Modified evaporation
evap_m=3600/lambda*(gamma_m*(rad_net-G)+(1-gamma_m)*rho*lambda*q_def_m/r_aero);

%Limit evaporation (L) to the amount of water available
%if evap_m>=g_surf/dt_h,
%	evap_m=max(0,g_surf/dt_h);
%end

%Limit evaporation (L) to the amount of water available
if set_limit_noevap==1,
    L=lambda*evap_m/3600;
    dT=(rad_net-G-L)*r_aero/Cp/rho;
    TCs=TC+dT;
    [esat qsats s] = q_sat_func(TCs,P);
        if surface_humidity_flag==1,
            g_noevap=q/qsats*g_min;
        elseif surface_humidity_flag==2,
            g_noevap=-log(1-q/qsats)*g_min/2;
        end
else
        g_noevap=0;
end
if evap_m>=(g_surf-g_noevap)/dt_h&&evap_m>=0,
        evap_m=max(0,(g_surf-g_noevap)/dt_h);
        L=evap_m*lambda*dt_h/dt_sec;
end

%Calculate surface temperature and fluxes
L=lambda*evap_m/3600;
dT=(rad_net-G-L)*r_aero/Cp/rho;
TCs=TC+dT;
H=rad_net-G-L;

end


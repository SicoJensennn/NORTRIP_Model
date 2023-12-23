function [TCs_out evap evap_pot melt freeze H L G long_out long_net rad_net G_sub] = Surface_energy_model_3_func(short_net,long_in,H_traffic,r_aero,TC,TCs,TCsub,RH,RHs,P,dzs_in,dt_h,g_surf,s_surf,g_min,melt_temperature,sub_surf_param,surface_humidity_flag,use_subsurface_flag)

%Includes melt of snow as output and includes snow surface and melt temperature as
%additional inputs to the original Surface_energy_model_2_func version
%Also includes a relationship for vapour pressure of ice

%Set the available melting energy (W/m2)
G_melt=0;
G_freeze=0;

%Set constants
Cp=1006;
lambda=2.50E6;
lambda_ice=2.83E6;
lambda_melt=3.33E5; %(J/kg)
RD=287.0;
T0C=273.15;
gam=Cp/lambda;
sigma=5.67E-8;

dt_sec=dt_h*3600;
%C_s_ice=2090*640;
eps_s=1;
TK_a=T0C+TC;

TCs_0=TCs;

%Sub time settings
nsub=1;
dt_sec=dt_sec/nsub;
dt_h=dt_h/nsub;

%C_s=750*2700;
%Set the subsurface paramters
%Need to read from input
rho_s=sub_surf_param(1);
c_s=sub_surf_param(2);
k_s_road=sub_surf_param(3);
%rho_s=2400;
%c_s=800;
%k_s_road=2.0;
C_s=rho_s*c_s;
omega=7.3e-5;

if dzs_in==0,
    dzs=(k_s_road/C_s/2/omega)^.5;
else
    dzs=dzs_in;
end
mu=omega*C_s*dzs;
if ~use_subsurface_flag,
    mu=0;
end
%mu_road=0;
%TCsub=0;
%mu=(1/3600/24)/omega*omega*C_s*dzs;

%Set limits of latent heat flux
L_max=500;L_min=-200;

%Set limitflag
set_limit_noevap=1;
limit_evap=1;
limit_condens=0;

%Air density
rho=P*100./(RD*TK_a);
%Ice density
%rho_ice=800; %(kg/m3)

%Sum of the water and ice
g_s_surf=g_surf+s_surf;
if g_s_surf>0,
    g_surf_fraction=g_surf/g_s_surf;
    s_surf_fraction=s_surf/g_s_surf;
else
    g_surf_fraction=0.5;
    s_surf_fraction=0.5;
end
lambda_mixed=g_surf_fraction*lambda+s_surf_fraction*lambda_ice;

%Mix the heat capacities of the snow and road surface
%C_s=C_s_road*(1-min(1,s_surf/dzs))+C_s_ice*min(1,s_surf/dzs);
%new
%mu=mu_road*(1-min(1,s_surf/dzs))+mu_ice*min(1,s_surf/dzs);

%Set values of constants for implicit solution
a_G=1/(C_s*dzs);
a_rad=short_net+long_in+H_traffic;
a_RL=(1-4*TC/TK_a)*eps_s*sigma*TK_a^4;
b_RL=4*eps_s*sigma*TK_a^3;
a_H=rho*Cp/r_aero;

%specific humidty of the air
[esat qsat s] = q_sat_func(TC,P);
q=qsat*RH/100;
%Specific humidity of the surface water
%[esat qsats s] = q_sat_func(TCs,P);
%qs=qsats*RHs/100;
%Specific humidity of the surface ice
%[esat_ice qsats_ice s_ice] = q_sat_ice_func(TCs,P);
%qs_ice=qsats_ice*RHs/100;
%Specific humidity of the combined surface

melt=0;
freeze=0;
evap_0=0;
evap=0;
for ti_sub=1:nsub,

evap_0=evap;
%Loop with updates of the latent heat flux and melt and freeze flux
for i=1:2,
    
    %Specific humidity of the surface
    [esat qsats_water s] = q_sat_func(TCs,P);
    [esat_ice qsats_ice s_ice] = q_sat_ice_func(TCs,P);
    qsats=g_surf_fraction*qsats_water+s_surf_fraction*qsats_ice;
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
    %qs=g_surf_fraction*qs_water+s_surf_fraction*qs_ice;
    
    %Latent heat flux
    L_water=-rho*lambda*(q-qs_water)/r_aero;
    L_ice=-rho*lambda_ice*(q-qs_ice)/r_aero;
    %Limit latent heat flux to reasonable values
    L_water=max(L_min,min(L_max,L_water));
    L_ice=max(L_min,min(L_max,L_ice));
    %Set evaporation of water
    evap_water=L_water/lambda*dt_sec;%/dt_h;
    evap_ice=L_ice/lambda_ice*dt_sec;%/dt_h;
    %Set total latent heat flux
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
    %TCs=(TCs_0+dt_sec*a_G*(a_rad-a_RL-L+a_H*TC+mu*TCsub))/(1+dt_sec*a_G*(a_H+b_RL+mu));
    TCs=(TCs_0+dt_sec*a_G*(a_rad-a_RL-L+a_H*TC+mu*TCsub-G_melt+G_freeze))/(1+dt_sec*a_G*(a_H+b_RL+mu));
    
    %Limit the surface temperature to the freezing point if there is ice on the surface (> g_min)
    %if s_surf>g_min,
    %    TCs=min(TCs,melt_temperature);
    %end
    %TCs=TC;

    TCs_out=TCs;
    TCs=(TCs_0+TCs)/2;
    %fprintf(' : %6.3f',TCs_out);

    %Sensible heat flux based on average surface temperature
    H=-rho*Cp*(TC-TCs_out)/r_aero;

    %Potential evaporation
    L_pot_water=-rho*lambda*(q-qsats_water)/r_aero;
    L_pot_ice=-rho*lambda_ice*(q-qsats_ice)/r_aero;
    %L_pot=g_surf_fraction*L_pot_water+s_surf_fraction*L_pot_ice;
    evap_pot_water=L_pot_water/lambda*dt_sec;%/dt_h;
    evap_pot_ice=L_pot_ice/lambda_ice*dt_sec;%/dt_h;
    evap_pot=g_surf_fraction*evap_pot_water+s_surf_fraction*evap_pot_ice;

    %Radiation based on average temperature
    long_out=eps_s*sigma*(T0C+TCs_out)^4;
    long_net=long_in-long_out;
    rad_net=short_net+long_net;
    G_sub=-mu*(TCs-TCsub);

    %Surface flux
    G=rad_net-H-L+H_traffic-G_melt+G_freeze;
    
    %Calculate melt
    if i==1,
    if s_surf>0&&G>=0&&(TCs>=melt_temperature),
	melt=melt+G/lambda_melt*dt_sec;%/dt_h;;
	melt=min(melt,s_surf);
    G_melt=melt*lambda_melt/dt_sec;%/dt_h;;
    else
	melt=melt+0;
    G_melt=0;
    end

    %Calculate freezing
    if g_surf>0&&G<0&&(TCs<melt_temperature),
	freeze=freeze-G/lambda_melt*dt_sec;%/dt_h;;
	freeze=min(freeze,g_surf);
    G_freeze=freeze*lambda_melt/dt_sec;%/dt_h;;
    else
	freeze=freeze+0;
    G_freeze=0;
    end
    end
end
    %fprintf('\n');
    TCs_0=TCs_out;

    evap=evap_0+evap;
end%sub


end


function [TCs_out,melt_temperature,RH_salt_final,RHs,M_road_dissolved_ratio_temp,evap,evap_pot,melt,freeze,H,L,G,long_out,long_net,rad_net,G_sub]...
    = Surface_energy_model_4_func(short_net,long_in,H_traffic,r_aero,TC,TCs_in,TCsub,RH,RHs_nosalt,RHs_0,P,dzs_in,dt_h_in...
    ,g_surf_in,s_surf_in,g_min,M2_road_salt_0,salt_type,sub_surf_param,surface_humidity_flag,use_subsurface_flag,use_salt_humidity_flag)

%Includes melt of snow as output and includes snow surface and melt temperature as
%additional inputs to the original Surface_energy_model_2_func version
%Also includes a relationship for vapour pressure of ice

%Set limit flags. These limit evaporation so that it does not exceed the
%expected removal of surface moisture. Reduces oscillations
set_limit_noevap=1;
limit_evap=1;
limit_condens=1;
disolution_flag=1;

%Set time step in seconds
dt_sec=dt_h_in*3600;

%Initialise the available melting/freezing energy (W/m2) and melted/frozen mass
G_melt=0;
G_freeze=0;
melt=0;
freeze=0;

g_surf=g_surf_in;
s_surf=s_surf_in;

%Set constants
Cp=1006;
lambda=2.50E6;
lambda_ice=2.83E6;
lambda_melt=3.33E5; %(J/kg)
RD=287.0;
T0C=273.15;
%gam=Cp/lambda;
sigma=5.67E-8;
eps_s=0.95;

%Set subsurface papameters
rho_s=sub_surf_param(1);
c_s=sub_surf_param(2);
k_s_road=sub_surf_param(3);
C_s=rho_s*c_s;
omega=7.3e-5;

%Automatically set dzs if it is 0.
%This calculated value of dzs is optimal for a sinusoidal varying flux
if dzs_in==0
    dzs=(k_s_road/C_s/2/omega)^.5;
else
    dzs=dzs_in;
end
mu=omega*C_s*dzs;

%If subsurface flux is turned of
if ~use_subsurface_flag,
    mu=0;
end

%Set atmospheric temperature in Kelvin
TK_a=T0C+TC;

%Set air density
rho=P*100./(RD*TK_a);

%Initialise surface temperature
TCs=TCs_in;
TCs_0=TCs_in;
TCs_out=TCs_in;

%Sub time settings. Allows smaller time steps. Not used and not properly
%tested
nsub=1;
dt_sec=dt_sec/nsub;
dt_h=dt_h_in/nsub;

%Set internal limits of latent heat flux. Should not be used but
L_max=500;L_min=-200;

%Prest values of constants for implicit solution
a_G=1/(C_s*dzs);
a_rad=short_net+long_in+H_traffic;
a_RL=(1-4*TC/TK_a)*eps_s*sigma*TK_a^4;
b_RL=4*eps_s*sigma*TK_a^3;
a_H=rho*Cp/r_aero;

%Specific humidty of the air
[esat,qsat,s] = q_sat_func(TC,P);
q=qsat*RH/100;

%Initialise the evaporation
evap=0;

%Start the sub time routine (not used or tested)
for ti_sub=1:nsub

evap_0=evap;

%Loop twice to update the latent heat flux and melt with the new surface temperature
for i=1:2

    %Calculate the salt solution, melt temperature and freezing and melting
    %Assumes an instantaneous balance where the salt solution melt
    %temperature is the same as the surface temperature
    if use_salt_humidity_flag
        no_salt_factor=1.0;
    else
        no_salt_factor=0.0;
    end
        %Calculate the salt solution and change in water and ice/snow

      %  [melt_temperature_salt_temp,RH_salt_temp,M_road_dissolved_ratio_temp,g_road_temp,s_road_temp,g_road_equil_at_T_s,s_road_equil_at_T_s]=...
      %      salt_solution_func(M2_road_salt_0*no_salt_factor,g_surf_in,s_surf_in,TCs_out,salt_type,dt_h,disolution_flag);
        [melt_temperature_salt_temp,RH_salt_temp,M_road_dissolved_ratio_temp,g_road_temp,s_road_temp,g_road_equil_at_T_s,s_road_equil_at_T_s]=...
            salt_solution_func(M2_road_salt_0*no_salt_factor,g_surf_in,s_surf_in,TCs,salt_type,dt_h,disolution_flag);

        %Determine the melt or freezing due to disolution of salt.
        if i==1
            freeze=max(0,s_road_temp-s_surf_in);
            melt=max(0,g_road_temp-g_surf_in);
        end
        
        %Use the salt with the lowest melt temperature
        melt_temperature=min(melt_temperature_salt_temp);

        %Set the energy used for freezing or melting
        if i==2
        G_freeze=freeze*lambda_melt/dt_sec;
        G_melt=melt*lambda_melt/dt_sec;
        end
        
        %Set the surface salt humidity to be the lowest for the two salts
        RH_salt_final=min(RH_salt_temp);
        RH_salt_final=max(RH_salt_final,1.); %RH_salt_temp cannot be = 0

        %RH_salt_final=100.;

        %Set the final surface humidity based on surface and salt humidity
        RHs=RHs_nosalt.*RH_salt_final/100.;

        %Smooth the RH in time to avoid oscillations
        fac=0.333;
        RHs=RHs*(1-fac)+fac*RHs_0;

        %Update g_surf to new values
        g_surf=g_road_temp;
        s_surf=s_road_temp;
    %{
    else
        %If salt not involved then set the following variables
        RHs=RHs_nosalt;
        G_melt=0;G_freeze=0;
        melt=0;freeze=0;
        melt_temperature=0;
        RH_salt_final=100;
        M_road_dissolved_ratio_temp=1;
        if (TCs_0<melt_temperature),
            s_road_equil_at_T_s=g_surf+s_surf;
            g_road_equil_at_T_s=0;
        else
            g_road_equil_at_T_s=g_surf+s_surf;
            s_road_equil_at_T_s=0;
        end
        
        %New no salt calculation. Simply remove salt from this part
        [melt_temperature_salt_temp,RH_salt_temp,M_road_dissolved_ratio_temp,g_road_temp,s_road_temp,g_road_equil_at_T_s,s_road_equil_at_T_s]=...
            salt_solution_func(M2_road_salt_0*0.0,g_surf_in,s_surf_in,TCs_out,salt_type,dt_h,1);
        RHs=RHs_nosalt;
        RH_salt_final=100;
        g_surf=g_road_temp;
        s_surf=s_road_temp;
        melt_temperature=min(melt_temperature_salt_temp);
        fac=0.333;
        RHs=RHs*(1-fac)+fac*RHs_0;
    
    end
    %}
        
    %fprintf('%f %f %f %f  %f %f %f\n',M2_road_salt_0(1),M_road_dissolved_ratio_temp(1),g_surf+s_surf,freeze,melt,melt_temperature,TCs);

    %Do not allow the salt equilibrium to freeze water. Use the energy balance for this
    %%{
    if freeze>0&&melt==0
    	G_melt=0.;
    	G_freeze=0.;
    	melt=0.;
    	freeze=0.;
    	g_surf=g_surf_in;
    	s_surf=s_surf_in;
    end
    %%}
    
    %Set sum of the water and ice and fraction
    g_s_surf=g_surf+s_surf;
    if g_s_surf>0
        g_surf_fraction=g_surf/g_s_surf;
        s_surf_fraction=s_surf/g_s_surf;
    else
        g_surf_fraction=0.5;
        s_surf_fraction=0.5;
    end

    %Weight lambda coefficient according to water and ice distribution
    lambda_mixed=g_surf_fraction*lambda+s_surf_fraction*lambda_ice;

    
    %Specific surface humidity based on current surface temperature (TCs)
    [esat,qsats_water,s] = q_sat_func(TCs,P);
    [esat_ice,qsats_ice,s_ice] = q_sat_ice_func(TCs,P);
    qsats=g_surf_fraction*qsats_water+s_surf_fraction*qsats_ice;
    qs_water=qsats_water*RHs/100;
    qs_ice=qsats_ice*RHs/100;

    %Latent heat flux
    L_water=-rho*lambda*(q-qs_water)/r_aero;
    L_ice=-rho*lambda_ice*(q-qs_ice)/r_aero;
    %Limit latent heat flux to reasonable values
    L_water=max(L_min,min(L_max,L_water));
    L_ice=max(L_min,min(L_max,L_ice));
    L=g_surf_fraction*L_water+s_surf_fraction*L_ice;
    
    %Set evaporation 
    evap_water=L_water/lambda*dt_sec;
    evap_ice=L_ice/lambda_ice*dt_sec;
    evap=g_surf_fraction*evap_water+s_surf_fraction*evap_ice;
        
    %Limit evaporation (L) to the amount of water available
    ratio_equil=RH*qsat/RH_salt_final/qsats;
    if set_limit_noevap==1
        if surface_humidity_flag==1
            %g_equil=q/qsats*g_min;
            g_equil=ratio_equil*g_min;
        elseif surface_humidity_flag==2
            %g_equil=-log(1-q/qsats)*g_min/2;
            if ratio_equil<1
                g_equil=-log(1-ratio_equil)*g_min/4;
            else
                g_equil=g_min*1000.;%Set to a large number which is the limit of g_equil
            end
        else
            g_equil=0.;
        end
    else
        g_equil=0;
    end
    if limit_evap
      if evap>=(g_s_surf-g_equil)/dt_h&&evap>=0
        evap=max(0,(g_s_surf-g_equil)/dt_h);
        L=evap*lambda_mixed*dt_h/dt_sec;
        L=max(L_min,min(L_max,L));
      end
    end
    if limit_condens
      if g_equil<=g_min&&evap<0 
      if evap<=(g_s_surf-g_equil)/dt_h&&evap<0
        evap=min(0,(g_s_surf-g_equil)/dt_h);
        L=evap*lambda_mixed*dt_h/dt_sec;
        L=max(L_min,min(L_max,L));
      end
      end
    end
    
    %G_melt=0;G_freeze=0;
    
    %Calculate surface temperature implicitly to avoid instabilities
    TCs_out=(TCs_0+dt_sec*a_G*(a_rad-a_RL-L+a_H*TC+mu*TCsub-G_melt+G_freeze))/(1+dt_sec*a_G*(a_H+b_RL+mu));
    
    %fprintf('%i %8.3f %8.3f\n',i,TCs_out,TCs_0);
        
    %Reset the current temperature for the iteration
    %This is for diagnostics only
    TCs=(TCs_0+TCs_out)/2;

    %Diagnose sensible heat flux based on average surface temperature
    H=-rho*Cp*(TC-TCs)/r_aero;

    %Diagnose potential evaporation
    L_pot_water=-rho*lambda*(q-qsats_water)/r_aero;
    L_pot_ice=-rho*lambda_ice*(q-qsats_ice)/r_aero;
    %L_pot=g_surf_fraction*L_pot_water+s_surf_fraction*L_pot_ice;
    evap_pot_water=L_pot_water/lambda*dt_sec;%/dt_h;
    evap_pot_ice=L_pot_ice/lambda_ice*dt_sec;%/dt_h;
    evap_pot=g_surf_fraction*evap_pot_water+s_surf_fraction*evap_pot_ice;

    %Diagnose radiation based on current average temperature
    long_out=eps_s*sigma*(T0C+TCs)^4;
    long_net=long_in-long_out;
    rad_net=short_net+long_net;
    G_sub=-mu*(TCs-TCsub);

    %Diagnose surface flux for additional melting or freezing
    G=rad_net-H-L+H_traffic;
    G=rad_net-H-L+H_traffic-G_melt+G_freeze+G_sub;
    G=rad_net-H-L+H_traffic-G_melt+G_freeze;
    %G=rad_net-H-L+H_traffic+G_sub;
    
    %fprintf('G_melt (i,G,Gmelt,Gfreeze,,L,TCs,Tmelt,melt,freeze,s_surf) %u %12.6f %12.6f %12.6f %12.6f %12.4f %12.4f %12.4f %12.4f %12.4f\n',i,G,G_melt,G_freeze,L,TCs_out,melt_temperature,melt,freeze,s_surf);

    if i==1
        %Calculate additional melt in first loop only
        if s_surf>0&&G>=0&&(TCs>=melt_temperature)
        %if s_surf>0&&G>=0&&(TCs_out>=melt_temperature)
        %if s_surf>0&&(TCs_out>=melt_temperature)
            melt_energy=max(0,G)/lambda_melt*dt_sec;
            melt=melt+melt_energy;%/dt_h;;
            melt=min(melt,s_surf);%Can't melt more than is ice and snow
            %melt=min(melt,max(g_road_equil_at_T_s-g_surf,0.));%Can't melt beyond salt equilibrium
            %G_melt=melt_energy*lambda_melt/dt_sec;%/dt_h;;
            G_melt=max(0,melt)*lambda_melt/dt_sec;%/dt_h;;
        else
            melt=melt+0;
            G_melt=melt*lambda_melt/dt_sec;%/dt_h;;
        end

        %Calculate additional freezing in first loop only
        %if g_surf>0&&G<0&&(TCs<melt_temperature)
        %if g_surf>0&&G<0&&(TCs_out<melt_temperature)
        if g_surf>0&&(TCs<melt_temperature)
            freeze_energy=min(0,G)/lambda_melt*dt_sec;
            freeze=freeze-freeze_energy;%/dt_h;;
            freeze=min(freeze,g_surf);%Can't freeze more than is water
            %freeze=min(freeze,max(s_road_equil_at_T_s-s_surf,0.));%Can't freeze beyond salt equilibrium
            G_freeze=freeze*lambda_melt/dt_sec;%/dt_h;;
        else
            freeze=freeze+0;
            G_freeze=freeze*lambda_melt/dt_sec;%/dt_h;;
        end
    end
    
    %Diagnose surface flux with melt and freeze fluxes
    G=rad_net-H-L+H_traffic-G_melt+G_freeze;
    %G=rad_net-H-L+H_traffic-G_melt+G_freeze+G_sub;

end%Finish the double loop

    %Update the starting temperature for the case where sub time steps areused
    TCs_0=TCs_out;

    %Add the evaporations when sub time steps are used
    evap=evap_0+evap;
    
end%sub

%Since freezing and melting can occur due to salt or due to energy then
%make sure only one of these occurs
if freeze>melt
    freeze=freeze-melt;
    melt=0;
else
    melt=melt-freeze;
    freeze=0;
end

    %fprintf('%f %f %f %f  %f %f %f\n',M2_road_salt_0(1),M_road_dissolved_ratio_temp(1),g_surf+s_surf,freeze,melt,melt_temperature,TCs_out);

end %End of function



function [melt_temperature_salt,RH_salt,M_road_dissolved_ratio,g_road_out,s_road_out,g_road_at_T_s_out,s_road_at_T_s_out]...
    =salt_solution_func(M2_road_salt,g_road,s_road,T_s,salt_type,dt_h,disolution_flag)
%==========================================================================
%NORTRIP model
%SUBROUTINE: calc_salt_solution
%VERSION: 1, 27.08.2012
%AUTHOR: Ingrid Sundvor and Bruce Rolstad Denby(bde@nilu.no)
%DESCRIPTION: Calculates salt solution, melt temperature and RH salt
%==========================================================================

%Set the constants used. Includes all other constants as well
set_salt_constants;

%Time scale for melting by salt. Greater than 0 delays the disolvement
%Currently fixed but should be dependent on difference between
%temperatures?
tau=1.0;

%Use the oversaturated parameterisation for melt temperature and water vapour
use_oversaturated=1;

%Declarations and initialisations
N_moles_salt(1:num_salt)=0;
afactor(1:num_salt)=0;
dissolved_salt(1:num_salt)=0;
solution_salt_at_T_s(1:num_salt)=0;
N_moles_water_at_T_s(1:num_salt)=0;
g_road_at_T_s(1:num_salt)=0;
s_road_at_T_s(1:num_salt)=0;
N_moles_water=0;
T_0=273.13;
surface_moisture_min=1e-6;

%Convert surface moisture to moles per m^2
N_moles_water=1000*g_road/M_atomic_water;

if disolution_flag
  %Calculate the salt equilibrium water/ice dependent on temperature
  for i=1:num_salt
    
    %Determine moles of salt /m^2. M2 means salt is in g/m^2
    N_moles_salt(i)=max(0,M2_road_salt(i)/M_atomic(salt_type(i)));

    %Determine the melt based on instantaneous dissolving of the salt
    %in the ice and snow surface to achieve a melt temperature the same as
    %the road surface temperature
    salt_power=salt_power_val(salt_type(i));%salt_power=1.5;

    if T_s<0&&T_s>=melt_temperature_saturated(salt_type(i))
        solution_salt_at_T_s(i)=saturated(salt_type(i))*(T_s/melt_temperature_saturated(salt_type(i)))^(1/salt_power);
        N_moles_water_at_T_s(i)=N_moles_salt(i)/solution_salt_at_T_s(i)-N_moles_salt(i);
        g_road_at_T_s(i)=min(g_road+s_road,N_moles_water_at_T_s(i)*M_atomic_water/1000);
        s_road_at_T_s(i)=max(0,(g_road+s_road)-g_road_at_T_s(i));
        %if (i==1), fprintf('%8.4f %8.4f  %8.4f\n',g_road,s_road,g_road_at_T_s(i));end
    elseif T_s>=0
        %solution_salt_at_T_s(i)=0;
        %N_moles_water_at_T_s(i)=N_moles_water;
        g_road_at_T_s(i)=g_road+s_road;
        s_road_at_T_s(i)=0;
    elseif T_s<melt_temperature_saturated(salt_type(i))
        g_road_at_T_s(i)=0;
        s_road_at_T_s(i)=s_road+g_road;
    else
        g_road_at_T_s(i)=s_road+g_road;
        s_road_at_T_s(i)=s_road+g_road;
    end
  end

    g_road_at_T_s_out=max(g_road_at_T_s);
    s_road_at_T_s_out=g_road+s_road-g_road_at_T_s_out;
    %g_road_out=g_road*exp(-dt_h/tau)+g_road_at_T_s_out*(1-exp(-dt_h/tau));
    
    %Only apply dissolution time scale in the melt direction
    if (g_road_at_T_s_out>g_road)
        g_road_out=g_road*exp(-dt_h/tau)+g_road_at_T_s_out*(1-exp(-dt_h/tau));
    else
        g_road_out=g_road_at_T_s_out;
    end

    s_road_out=max(0,(g_road+s_road)-g_road_out);

    N_moles_water=1000*(g_road_out+surface_moisture_min)/M_atomic_water;
else
    g_road_out=g_road;
    s_road_out=s_road;
    %Set equilibrium limit to total moisture
    g_road_at_T_s_out=g_road+s_road;
    s_road_at_T_s_out=g_road+s_road;
    N_moles_water=1000*(g_road_out+surface_moisture_min)/M_atomic_water;    
    for i=1:num_salt
        N_moles_salt(i)=max(0,M2_road_salt(i)/M_atomic(salt_type(i)));
    end
end

%Calculate vapour pressure and melt temperature of the solution (vp).
for i=1:num_salt
    
    salt_power=salt_power_val(salt_type(i));%salt_power=1.5;
    
    solution_salt(i)=max(0,N_moles_salt(i)/(N_moles_water+N_moles_salt(i)));
    vp_ice=antoine_func(a_antoine_ice,b_antoine_ice,c_antoine_ice,T_s);
    vp_s=max(0,antoine_func(a_antoine(salt_type(i)),b_antoine(salt_type(i)),c_antoine(salt_type(i)),T_s)+vp_correction(salt_type(i)));
    antoine_scaling=vp_ice/vp_s;
    if solution_salt(i)>saturated(salt_type(i))
        afactor(i)=1;
    else
        afactor(i)=((1-antoine_scaling)*(solution_salt(i)/saturated(salt_type(i)))^salt_power)+antoine_scaling;
        %afactor(i)=((1-antoine_scaling)*(solution_salt(i)/saturated(salt_type(i)))^1)+antoine_scaling;
        %afactor(i)=(1-antoine_scaling)*(((1-(1-T_0/(T_0+melt_temperature_saturated(salt_type(i))))*log(1-solution_salt(i))/log(1-saturated(salt_type(i))))^-1)-1)+antoine_scaling;
    end    
    RH_salt(i)=min(100,100*afactor(i)*vp_s/vp_ice);
    RH_salt_saturated=min(100,100*vp_s/vp_ice);
    RH_salt(i)=max(RH_salt_saturated,RH_salt(i));
    melt_temperature_salt(i)=max(melt_temperature_saturated(salt_type(i)),((solution_salt(i)/saturated(salt_type(i)))^salt_power)*melt_temperature_saturated(salt_type(i)));
    %melt_temperature_salt(i)=max(melt_temperature_saturated(salt_type(i)),T_0*((1-(1-T_0/(T_0+melt_temperature_saturated(salt_type(i))))*log(1-solution_salt(i))/log(1-saturated(salt_type(i))))^-1)-T_0);
    
    %Adjust for the oversaturated case. Otherwise sets RH and melt
    %temperature to the saturated value
    if use_oversaturated
      %Oversaturated
      if solution_salt(i)>saturated(salt_type(i))
        solution_salt(i)=min(over_saturated(salt_type(i)),solution_salt(i));
        RH_over_saturated(i)=(100*(1-RH_over_saturated_fraction(salt_type(i)))...
            +RH_salt_saturated*RH_over_saturated_fraction(salt_type(i)));%Large number chosen to make the impact clear. Not known
        RH_salt(i)=min(100,RH_salt_saturated+(RH_over_saturated(i)-RH_salt_saturated)/...
            (f_salt_sat(salt_type(i))*saturated(salt_type(i))-saturated(salt_type(i)))*(solution_salt(i)-saturated(salt_type(i))));
        melt_temperature_salt(i)=min(0,melt_temperature_saturated(salt_type(i))...
            +(melt_temperature_oversaturated(salt_type(i))-melt_temperature_saturated(salt_type(i)))...
            /(f_salt_sat(salt_type(i))*saturated(salt_type(i))-saturated(salt_type(i)))*(solution_salt(i)-saturated(salt_type(i))));
      end
    end
    
    %Calculate dissolved mass of salt
    if solution_salt(i)<saturated(salt_type(i))
        dissolved_salt(i)=N_moles_salt(i)*M_atomic(salt_type(i));
    else
        dissolved_salt(i)=saturated(salt_type(i))*N_moles_water/(1-saturated(salt_type(i)))*M_atomic(salt_type(i));
    end 
    if M2_road_salt(i)>0
        M_road_dissolved_ratio(i)=dissolved_salt(i)/M2_road_salt(i);
    else
        M_road_dissolved_ratio(i)=1.0;
    end
    %Set exact limits
    M_road_dissolved_ratio(i)=max(0,min(1,M_road_dissolved_ratio(i)));

end



%Constants set in regard to salt

road_dust_set_constants_v2

%Set constants for NaCl, MgCl2 and CMA
%All constants for cma are guesses (not quite some data available)
M_atomic_water=18.015;
M_atomic(na)=58.4;M_atomic(mg)=95.2;M_atomic(cma)=124;M_atomic(ca)=111;M_atomic(pfo)=84; %(g/mol)

%Saturated molar solution ratio
saturated(na)=0.086;saturated(mg)=0.050;saturated(cma)=0.066;saturated(ca)=0.065;saturated(pfo)=0.165;
%Expected saturated equilibrium relative humidity. These are calculated and not used directly
RH_saturated(na)=75;RH_saturated(mg)=33;RH_saturated(cma)=40;RH_saturated(ca)=31;RH_saturated(pfo)=12; %fpo is a guess

%https://en.wikipedia.org/wiki/Antoine_equation for conversions 0.4343 is
%from ln to log10 and 2.125 is from kPa to mm Hg
%Antoine constants
%Two alternatives 
a_antoine_ice=10.3;b_antoine_ice=2600;c_antoine_ice=270;
%a_antoine_ice=13.9;b_antoine_ice=4655;c_antoine_ice=352;
a_antoine(mg)=7.20;b_antoine(mg)=1581.00;c_antoine(mg)=225.00;
a_antoine(na)=7.40;b_antoine(na)=1566.00;c_antoine(na)=228.00;
a_antoine(cma)=7.28;b_antoine(cma)=1581.00;c_antoine(cma)=225.00;
a_antoine(ca)=5.8;b_antoine(ca)=1087.00;c_antoine(ca)=198.00;
%a_antoine(pfo)=7.12*0.5;b_antoine(pfo)=1679*0.5;c_antoine(pfo)=230.00;
%a_antoine(pfo)=16.26*0.4343-2.125;b_antoine(pfo)=3800*0.4343;c_antoine(pfo)=226.00;
%a_antoine(pfo)=8.07131;b_antoine(pfo)=1730.63;c_antoine(pfo)=233.426;
%a_antoine(pfo)=(16.379*0.48)*0.4343-2.125;b_antoine(pfo)=3873*0.48*0.4343;c_antoine(pfo)=273-43.7;
%a_antoine(pfo)=(16.379)*0.4343*1.1;b_antoine(pfo)=3873*0.4343;c_antoine(pfo)=273-43.7;
%slight adjustment to the water cureve to get around 60% humidity at saturation
a_antoine(pfo)=10.3*0.975;b_antoine(pfo)=2600;c_antoine(pfo)=270;
		
%Saturated melt/freezing temperatures
melt_temperature_saturated(na)=-21;
melt_temperature_saturated(mg)=-33;
melt_temperature_saturated(cma)=-27.5;
melt_temperature_saturated(ca)=-51;
melt_temperature_saturated(pfo)=-51;
%These three paramters approximate the over saturated curve. Needs updating
%melt_temperature_oversaturated(na)=0;melt_temperature_oversaturated(mg)=-15;melt_temperature_oversaturated(cma)=-7;
%Have set the saturated melt temperature higher than in the paper to emable melt
%in saturated conditions which would not occur other wise. value half way. 
melt_temperature_oversaturated(na)=-1;
melt_temperature_oversaturated(mg)=-15;
melt_temperature_oversaturated(cma)=-12;
melt_temperature_oversaturated(ca)=-1;
melt_temperature_oversaturated(pfo)=-25;
%melt_temperature_oversaturated(na)=melt_temperature_saturated(na);
%melt_temperature_oversaturated(mg)=melt_temperature_saturated(mg);
%melt_temperature_oversaturated(cma)=melt_temperature_saturated(cma);
%melt_temperature_oversaturated(na)=-1;
%melt_temperature_oversaturated(mg)=melt_temperature_saturated(mg);
%melt_temperature_oversaturated(cma)=melt_temperature_saturated(cma);

f_salt_sat(na)=1.17;f_salt_sat(mg)=1.5;f_salt_sat(cma)=1.5;f_salt_sat(ca)=1.4;f_salt_sat(pfo)=1.5;
over_saturated(na)=f_salt_sat(na)*saturated(na);over_saturated(mg)=f_salt_sat(mg)*saturated(mg);
over_saturated(cma)=f_salt_sat(cma)*saturated(cma);over_saturated(ca)=f_salt_sat(ca)*saturated(ca);
over_saturated(pfo)=f_salt_sat(pfo)*saturated(pfo);
%Not used
%RH_over_saturated(na)=100;RH_over_saturated(mg)=70;
%RH_over_saturated(cma)=85;RH_over_saturated(cma)=70;
%Set the interpolation power and corrections
salt_power=1.5;
%Salt dependent curves to better match the measured values
salt_power=1.2;
salt_power_val(na)=1.3;salt_power_val(mg)=1.3;salt_power_val(cma)=1.2;salt_power_val(ca)=1.6;salt_power_val(pfo)=1.2;
vp_correction(na)=0.035;vp_correction(mg)=0.11;vp_correction(cma)=0.17;vp_correction(ca)=0.001;%na updated below
%vp_correction(pfo)=0.022;
vp_correction(pfo)=0.012;

%Saturated mass ratios. These are not used in programme but in testing
saturated_mass(na)=0.233;saturated_mass(mg)=0.216;saturated_mass(cma)=0.325;saturated_mass(ca)=0.298;saturated_mass(pfo)=0.48;
van_hoff(1:5)=[2,3,3,3,3];

%Updates July 2015. None of these are changed in Fortran yet
%--------------------------------------------------------------------------
%{
vp_correction(1:4)=0;
van_hoff(1:4)=[2,3,6,3];
RH_saturated(cma)=50;
a_antoine(cma)=10.3+log10(50/100);b_antoine(cma)=2600.00;c_antoine(cma)=270.00;
M_atomic(cma)=300;saturated(cma)=0.0281;
f_salt_sat(cma)=1.4;over_saturated(cma)=f_salt_sat(cma)*saturated(cma);
%Note. CMA is incorrect. I am guessing it should lie somewhere between salt
%and MgCl2 in terms of vapout pressure depression, but who knows?
%In this version have set vp to be 50% of water, exactly.
%CaCl2 vapout pressure based on Antoine is also not quite the same as the
%saturated should be.
%}
%--------------------------------------------------------------------------


%Set the fractiona distribution of oversaturated solution
%RH_over_saturated_fraction(na)=0.1;RH_over_saturated_fraction(mg)=0.75;RH_over_saturated_fraction(cma)=0.75;RH_over_saturated_fraction(ca)=0.75;
RH_over_saturated_fraction(na)=0.25;RH_over_saturated_fraction(mg)=0.99;RH_over_saturated_fraction(cma)=0.99;RH_over_saturated_fraction(ca)=0.99;
RH_over_saturated_fraction(pfo)=0.99;
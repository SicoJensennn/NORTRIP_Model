function [esat,qsat,d_qsat_dT] = q_sat_func(TC,P)

%TC: Degrees C
%P: mbar or hPa
%esat: hPa
%qsat: kg/kg

%Rv=461.537; %J/kg/K
%T0C=273.15;
%lambda=2.5e6;%J/kg
a=6.1121;
b=17.67;
c=243.5;

esat=a*exp(b*TC./(c+TC));
qsat=0.622*esat./(P-0.378*esat);

d_esat_dT=esat*b*c./(TC+c).^2;
d_qsat_dT=0.622.*P./(P-0.378*esat).^2.*d_esat_dT;

end


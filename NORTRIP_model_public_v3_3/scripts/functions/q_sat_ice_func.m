function [esat,qsat,d_qsat_dT] = q_sat_ice_func(TC,P)

%TC: Degrees C
%P: mbar or hPa
%esat: hPa
%qsat: kg/kg

%NOTE: d_qsat_dT valid only for the ice, not for water vapour
%Comes from CIMO guide (WMO,2008)

%Rv=461.537; %J/kg/K
%T0C=273.15;
%lambda=2.5e6;%J/kg

a=6.1121;
b=22.46;
c=272.62;

esat=a*exp(b*TC./(c+TC));
qsat=0.622*esat./(P-0.378*esat);

d_esat_dT=esat*b*c./(TC+c).^2;
d_qsat_dT=0.622.*P./(P-0.378*esat).^2.*d_esat_dT;

end


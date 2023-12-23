function RL_in = longwave_in_radiation_func(TC,RH,n_c,P)
%Returns the incoming longwave radiation
%based on Konzelman et al. (1994) and other related articles
%See Sedlar and Hock (2008) On the use of incoming radiation
%parameterisations in a glacier environment,

%TC,P,RH,n_c

%Set constants
T0C=273.15;
sigma=5.67E-8;

[esat qsat s] = q_sat_func(TC,P);
e_a=esat*RH/100;
TK_a=T0C+TC;

eps_cs=0.23+0.48*(e_a*100/TK_a)^(1/8);
eps_cl=0.97;
eps_eff=eps_cs*(1-n_c^2)+eps_cl*n_c^2;
RL_in=eps_eff*sigma*TK_a^4;

end


function [TC_dewpoint] = dewpoint_from_RH_func(TC,RH)

%TC: Degrees C
%esat: hPa
%RH: %

a=6.1121;
b=17.67;
c=243.5;

esat=a*exp(b*TC./(c+TC));
eair=RH./100.*esat;
TC_dewpoint=c*log(eair/a)./(b-log(eair/a));

end

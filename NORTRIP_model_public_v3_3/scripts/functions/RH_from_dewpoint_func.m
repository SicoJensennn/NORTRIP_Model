function [RH] = RH_from_dewpoint_func(TC,TC_dewpoint)

%TC: Degrees C
%esat: hPa
%RH: %

a=6.1121;
b=17.67;
c=243.5;

esat=a*exp(b*TC./(c+TC));
eair=a*exp(b*TC_dewpoint./(c+TC_dewpoint));

RH=100*eair./esat;

end

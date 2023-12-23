function [SOLAR_NET,azimuth_ang,zenith_ang] = global_radiation_func(LAT,LON,date_num,DIFUTC_H,Z_SURF,N_CLOUD,ALBEDO)
%INPUT SHOULD BE SINGLE NUMBERS
%RETURNS THE NET SHORT WAVE RADIATION

%LAT,LON,JULIAN_DAY,TIME_S,DIFUTC_H,Z_SURF,N_CLOUD,TSC,QSC)

%C	DETERMINE SHORT WAVE FLUXES ON A HORIZONTAL SURFACE
SECPHOUR=3600.;
SECPDAY=86400.;
PI=3.14159/180.;
S0=1367.;

for i=1:length(date_num),
[Y, M, D, H, MN, S] = datevec(date_num(i));
JULIAN_DAY=floor(date_num(i)-datenum(Y, 0, 0, 0, 0, 0)+1);
TIME_S=(date_num(i)-datenum(Y, M, D, 0, 0, 0))*24*3600;

	DAYANG=360./365.*(JULIAN_DAY-1.);
	DEC=0.396-22.91*cos(PI*DAYANG)+4.025*sin(PI*DAYANG);
	EQTIME=(1.03+25.7*cos(PI*DAYANG)-440.*sin(PI*DAYANG)-201.*cos(2.*PI*DAYANG)-562.*sin(2.*PI*DAYANG))./SECPHOUR;
	SOLARTIME=mod(TIME_S+SECPDAY+SECPHOUR*(LON/15.+DIFUTC_H+EQTIME),SECPDAY);
	HOURANG=15.*(12.-SOLARTIME/SECPHOUR);
    
%	SET AZIMUTH ANGLE FOR ATMOSPHERIC CORRECTIONS
	AZT=sin(PI*DEC).*sin(PI*LAT)+cos(PI*DEC).*cos(PI*LAT).*cos(PI*HOURANG);
	if (abs(AZT)<1),
	  AZ=acos(AZT)/PI;
    else
	  AZ=0;
    end
    
%	CORRECTIONS FOR ATMOSPHERE AND CLOUD FROM OERLEMANS (GREENLAND)
%These need to be updated
%Have included a correction of 1.1 to match the Stockholm data
%THe cloud cover transmission is still not assessed
	TAU_A=1.1*(0.75+6.8E-5*Z_SURF-7.1E-9*Z_SURF^2).*(1-.001*AZ);
    TAU_C=1-0.78.*N_CLOUD^2*exp(-8.5E-4*Z_SURF);
    
%New version Hottel (1976)
%A simple model forestimating the transmittance of direct solar radiation
%through clear atmosphere. Solar Energy 18,129, 1976.
%This version is no better than the previous
    %a0=0.4237-0.00821*(6.0-min(2.5,Z_SURF/1000))^2;
    %a1=0.5055+0.00595*(6.5-min(2.5,Z_SURF/1000))^2;
    %k=0.2711+0.01858*(2.5-min(2.5,Z_SURF/1000))^2;
    %a0=0.4237;%-0.00821*(6.0-min(2.5,Z_SURF/1000))^2;
    %a1=0.5055;%+0.00595*(6.5-min(2.5,Z_SURF/1000))^2;
    %k=0.2711;%+0.01858*(2.5-min(2.5,Z_SURF/1000))^2;
    %TAU_A=a0+a1*exp(-k./cos(AZ*PI));
    %Diffuse radition transmission
    %TAU_D=0.271-0.294*TAU_A;
    %TAU_A=TAU_A+TAU_D;

%	SET DAY BEGINNING AND END
	if abs(tan(PI*DEC)*tan(PI*LAT))<1,
	  DAY_BIG=(12.-acos(-tan(PI*DEC)*tan(PI*LAT))/PI/15.)*SECPHOUR;
	  DAY_END=(12.+acos(-tan(PI*DEC)*tan(PI*LAT))/PI/15.)*SECPHOUR;
    else
	  DAY_BIG=0.;
	  DAY_END=24.*SECPHOUR;
    end
%	DETERMINE SOLAR RADIATION AT SURFACE DURING DAY
	if ((SOLARTIME>DAY_BIG)&&(SOLARTIME<DAY_END)),
	  SOLAR_IN(i)=S0*TAU_A*TAU_C*cos(AZ*PI);
    else
	  SOLAR_IN(i)=0.;
    end
    SOLAR_NET(i)=SOLAR_IN(i)*(1-ALBEDO);
	%if (SOLARNEW<0) then
    %    SOLARNEW=0.
    %end
    
    azimuth_ang=180-HOURANG;
    zenith_ang=AZ;
    
end
end


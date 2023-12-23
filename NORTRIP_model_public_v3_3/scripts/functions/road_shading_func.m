function shadow_fraction = road_shading_func(azimuth,zenith,ang_road,b_road,b_canyon,h_canyon)

%AZ is actually the zenith angle
%HOURANG is actually the azimuth
%for i=1:length(azimuth),

%h_canyon is a double array

if ang_road>180,
    ang_road=ang_road-180;
end

ang_dif=azimuth-ang_road;

if ang_dif==360,
    ang_dif=0;
end

%{
if ang_dif<0,
    ang_dif=ang_dif+180;
    h_canyon_temp=h_canyon(2);
end
if ang_dif>=180,
    ang_dif=ang_dif-180;
    h_canyon_temp=h_canyon(2);
else
    h_canyon_temp=h_canyon(1);
end
%}

if ang_dif<=-180,
    h_canyon_temp=h_canyon(2);
    ang_dif=ang_dif+360;
elseif ang_dif<0,
    h_canyon_temp=h_canyon(1);
    ang_dif=ang_dif+180;
elseif ang_dif>=180,
    h_canyon_temp=h_canyon(1);
    ang_dif=ang_dif-180;
else
    h_canyon_temp=h_canyon(2);
end

if ang_dif==0,
    shadow_fraction=0;
elseif zenith>=90,
    shadow_fraction=1;
else
    d_shadow=h_canyon_temp.*tand(zenith);
    b_kerb=max(0,(b_canyon-b_road)/2);
    b1_kerb=b_kerb./sind(ang_dif);
    b1_road=b_road./sind(ang_dif);
    shadow_fraction=max(0,(d_shadow-b1_kerb)./b1_road);
    shadow_fraction=min(1,shadow_fraction);
end

end


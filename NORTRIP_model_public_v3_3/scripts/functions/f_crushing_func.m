function f = f_crushing_func(f_crushing_0,V_veh,s_road,V_ref,s_roadwear_thresh)
% W_func: Sandpaper function
% Depends on:

%Set common constants
%road_dust_set_constants_v2
if V_ref==0
    f_V=1;
else
    f_V=(V_veh/V_ref);
end

%No wear production due to snow on the surface
f_snow=1;
if s_road>s_roadwear_thresh,
    f_snow=0;
end

f=f_crushing_0*f_V*f_snow;

end


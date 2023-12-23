function f = f_abrasion_func(f_sandpaper_0,h_pave,V_veh,s_road,V_ref,s_roadwear_thresh)
% W_func: Sandpaper function
% Depends on:

%Set common constants
%road_dust_set_constants_v2

f_V=V_veh/V_ref;

%No wear production due to snow on the surface
f_snow=1;
if s_road>s_roadwear_thresh,
    f_snow=0;
end

f=f_sandpaper_0*h_pave*f_V*f_snow;

end


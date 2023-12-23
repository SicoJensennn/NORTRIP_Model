function f = W_func(W_0,h_pave,h_dc,V_veh,a_wear,s_road,s_roadwear_thresh,s,road_index,tyre_index,brake_index)
% W_func: Wear function
% Depends on:

%Define source types
%road_dust_set_constants_v2

%No wear production due to snow on the surface
f_snow=1;
if s_road>s_roadwear_thresh,
    f_snow=0;
end

f_V=max(0,a_wear(1)+a_wear(2)*(max(V_veh,a_wear(5))/a_wear(4))^a_wear(3));

if s==road_index,
    h_dc=1;
end
if s==tyre_index,
    h_dc=1;
    h_pave=1;
end
if s==brake_index,
    h_pave=1;
    f_snow=1;
end

f=W_0*h_pave*h_dc*f_V*f_snow;

end


function f = f_susroad_func(f_0_susroad,V_veh,a_sus)
% f_sus_func: Vehicle speed dependence function for suspention
% Depends on:
% source (s)
% tire type (t)
% vehicle category (v)
% vehicle speed (V_veh and V_ref)
% power law dependence (a_sus)

%Set common constants
%road_dust_set_constants_v2

h_V=max(0,a_sus(1)+a_sus(2)*(max(V_veh,a_sus(5))/a_sus(4))^a_sus(3));
f=f_0_susroad*h_V;

end


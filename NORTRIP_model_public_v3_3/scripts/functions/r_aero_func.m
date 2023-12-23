function [r_aero] = r_aero_func(FF,z_FF,z_T,z0,z0t,V_veh,N_v,num_veh,a_traffic)

%Set common constants
%road_dust_set_constants_v2

kappa=0.4;

inv_r_wind=max(FF,0.2)*kappa^2/(log(z_FF/z0)*log(z_T/z0t));

inv_r_traffic=0;
for v=1:num_veh,
    
    inv_r_traffic=inv_r_traffic+N_v(v).*V_veh(v).*a_traffic(v);
end
inv_r_traffic=max(1e-6,inv_r_traffic/3600/3.6);

inv_r_aero=inv_r_traffic+inv_r_wind;

r_aero=1/inv_r_aero;

%fprintf(':%6.2f %6.2f %6.2f\n',r_aero,1/inv_r_traffic,1/inv_r_wind);

end


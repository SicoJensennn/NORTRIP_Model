function f = R_0_wind_func(FF,tau_wind,FF_thresh)
% R_0_wind_func: Wind blown dust wind speed depedency
% Depends on:
% Wind speed (FF)
% Wind blown dust time scale (tau_wind)
% REference wind speed (FF_ref)
% THreshhold wind speed (FF_thresh)

if FF>FF_thresh,
    h_FF=(FF/FF_thresh-1)^3;
else
    h_FF=0;
end

f=1/tau_wind*h_FF;

end


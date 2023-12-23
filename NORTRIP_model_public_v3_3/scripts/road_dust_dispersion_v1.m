%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_concentrations
%VERSION: 1, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Converts emissions to concentrations using NOX as a tracer
%==========================================================================

for ti=min_time:max_time,
    if f_dis_available,
        f_conc(ti,ro)=f_dis(ti,ro);
    else
        if NOX_obs_net(ti)~=nodata&&NOX_emis(ti)~=nodata&&NOX_obs_net(ti)>conc_min&&NOX_emis(ti)>emis_min,
            f_conc(ti,ro)=NOX_obs_net(ti)./NOX_emis(ti);
        else
            f_conc(ti,ro)=nodata;
        end
    end
end

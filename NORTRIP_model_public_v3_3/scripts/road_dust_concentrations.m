%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_concentrations
%VERSION: 1, 27.01.2015
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Converts emissions to concentrations
%==========================================================================

%Convert emissions to concentrations
for ti=min_time:max_time 
    if f_conc(ti,ro)~=nodata,
        C_bin_data(1:num_source_all,1:num_size,1:num_process,ti,1:num_track,ro)...
            =E_road_bin_data(1:num_source_all,1:num_size,1:num_process,ti,1:num_track,ro)*f_conc(ti,ro);
    else
        C_bin_data(1:num_source_all,1:num_size,1:num_process,ti,1:num_track,ro)=nodata;
    end
end


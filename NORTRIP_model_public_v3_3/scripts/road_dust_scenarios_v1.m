%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_scenarios_v1
%VERSION: 1, 14.03.2013
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Script for making changes to the input data to assess
%scenarios
%==========================================================================

%THIS ROUTINE DOES NOT WORK AFTER UPDATING THE VARIABLE ARRAY STRUCTURES

%Set scenarios to 0.
calc_scenario(1:100)=0;

%calc_scenario(1)=0.80;%Change all speeds by this factor
%calc_scenario(2)=0.0;%Change the number of vehicles by this factor
%calc_scenario(3)=0.0000001;%Change the studded tyred vehicles by this factor max 2
%calc_scenario(4)=1;%Half the precipitation by subtracting median
%calc_scenario(5)=1;%Change the NOX emissions by this factor
%calc_scenario(6)=0.6;%Change the fraction of salts
%calc_scenario(7)=0.5;%Change the HDV by this amount. Also changes total
%calc_scenario(8)=1;%Deposition test, no salt or wear sources

r=find(calc_scenario~=0);
if ~isempty(r)&&print_results,
    fprintf('Calculating scenario %u\n',r(1));
end

if calc_scenario(1),
	V_veh=calc_scenario(1)*V_veh;
end

if calc_scenario(2),
	N=calc_scenario(2)*N;
    N_v=calc_scenario(2)*N_v;
	EP_emis=calc_scenario(2)*EP_emis(:,1);
end

if calc_scenario(3),
	fr_stud=calc_scenario(3);
	N(wi,:,:)=N(wi,:,:)+(1-fr_stud)*N(st,:,:);N(st,:,:)=N(st,:,:)*fr_stud;
    %N(wi,he,:)=N(wi,he,:)+N(st,he,:);N(st,he,:)=N(st,he,:)*0;
end

if calc_scenario(4),
	r_rain=find(Rain>0);r_snow=find(Snow>0);
	rain_median=median(Rain(r_rain));snow_median=median(Snow(r_snow));
	Rain=max(Rain-rain_median,0);Snow=max(Snow-snow_median,0);
end

if calc_scenario(5),
	NOX_emis=NOX_emis*calc_scenario(5);
end

if calc_scenario(6),
	salt_type=calc_scenario(6);
end

if calc_scenario(7),
    N(:,he,:)=N(:,he,:)*calc_scenario(7);
end

if calc_scenario(8),
    dust_deposition_flag=1;
    PM_background(pm_10,:)=100;
    PM_obs(pm_10,:)=101;
    W_0=W_0*0.0;
    use_salting_data_flag=0;
    EP_emis(:)=nodata;
    M_road_init(:)=0;
end



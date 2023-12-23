%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_ospm
%VERSION: 2, 224.09.2013
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Reads writes and runs OSPM to provide dispersion factors
%==========================================================================

%Set this parameter
f_dis_available=1;
filename_param_ospm='input\nortrip_ospm_parameters.txt';
filename_input_ospm='input\nortrip_ospm_input.txt';
filename_output_ospm='output\nortrip_ospm_output.txt';
%filename_runfile_ospm='nortrip_ospm.exe';

%Create ospm input parameter files
%--------------------------------------------------------------------------
%Set some ospm paramters that should be read from the input file
isub_ospm=2;
H_ospm=h_canyon(1); %This is the average or the Northern side. Can improve this
L_ospm=b_canyon;
%SL1_ospm=100;       %defined in metadata
%SL2_ospm=100;       %defined in metadata
P1_ospm=ang_road;
nexc_ospm=1;       %can be used to define north south heights but not yet
dd_l_ospm=359;
dd_u_ospm=360;
gg_ospm=H_ospm;
%RecHeight_ospm=2.5; %defined in metadata
%f_roof_ospm=0.82;  %defined in metadata

%Alternative formulation if sides of canyon are different
%dd_l_ospm=ang_road;
%dd_u_ospm=180+ang_road;
%gg_ospm=h_canyon(2);

filename=[path_ospm,filename_param_ospm];

fid_ospm_param=fopen(filename,'w');
fprintf(fid_ospm_param,'%u\n',isub_ospm);
fprintf(fid_ospm_param,'%6.1f\t%6.1f\t%6.1f\t%6.1f\t%6.1f\n',H_ospm,L_ospm,SL1_ospm,SL2_ospm,P1_ospm);
fprintf(fid_ospm_param,'%u\n',nexc_ospm);
for i=1:nexc_ospm,
    fprintf(fid_ospm_param,'%6.2f\t',dd_l_ospm); 
end
    fprintf(fid_ospm_param,'\n'); 
for i=1:nexc_ospm,
    fprintf(fid_ospm_param,'%6.2f\t',dd_u_ospm); 
end
    fprintf(fid_ospm_param,'\n'); 
for i=1:nexc_ospm,
    fprintf(fid_ospm_param,'%6.2f\t',gg_ospm); 
end
    fprintf(fid_ospm_param,'\n'); 
fprintf(fid_ospm_param,'%6.2f\n',RecHeight_ospm);
fprintf(fid_ospm_param,'%6.2f\n',f_roof_ospm);
fprintf(fid_ospm_param,'%6.2f\n',f_turb_ospm);
fclose(fid_ospm_param);
%--------------------------------------------------------------------------

%Create ospm input data file
%--------------------------------------------------------------------------
%Create the appropriate variables
%year,month,day,hour,U_mast,wind_dir,TK,GlobalRad,cNOx_b,NNp,NNt,Vp,Vt,qNOX
clear year_ospm month_ospm day_ospm hour_ospm
clear U_mast_ospm wind_dir_ospm TK_ospm GlobalRad_ospm
clear cNOx_b_ospm NNp_ospm NNt_ospm Vp_ospm Vt_ospm qNOX_ospm

if use_ospm_flag==1,

year_ospm(:,1)=date_data(year_index,min_time:max_time);
month_ospm(:,1)=date_data(month_index,min_time:max_time);
day_ospm(:,1)=date_data(day_index,min_time:max_time);
hour_ospm(:,1)=date_data(hour_index,min_time:max_time);
U_mast_ospm(:,1)=meteo_data(FF_index,min_time:max_time,ro)/wind_speed_correction;
wind_dir_ospm(:,1)=meteo_data(DD_index,min_time:max_time,ro);
TK_ospm(:,1)=meteo_data(T_a_index,min_time:max_time,ro)+273.15;
GlobalRad_ospm(:,1)=meteo_data(short_rad_in_index,min_time:max_time,ro);
cNOx_b_ospm(:,1)=zeros(max_time-min_time+1,1);
NNp_ospm(:,1)=traffic_data(N_v_index(li),min_time:max_time,ro);
NNt_ospm(:,1)=traffic_data(N_v_index(he),min_time:max_time,ro);
Vp_ospm(:,1)=traffic_data(V_veh_index(li),min_time:max_time,ro);
Vt_ospm(:,1)=traffic_data(V_veh_index(he),min_time:max_time,ro);
qNOX_ospm(:,1)=ones(max_time-min_time+1,1)/3.6;%unit emissions including conversion

elseif use_ospm_flag==2,
    
year_ospm(:,1)=date_data(year_index,min_time:max_time);
month_ospm(:,1)=date_data(month_index,min_time:max_time);
day_ospm(:,1)=date_data(day_index,min_time:max_time);
hour_ospm(:,1)=date_data(hour_index,min_time:max_time);
U_mast_ospm(:,1)=U_mast_ospm_orig(min_time:max_time);
wind_dir_ospm(:,1)=wind_dir_ospm_orig(min_time:max_time);
TK_ospm(:,1)=TK_ospm_orig(min_time:max_time);
GlobalRad_ospm(:,1)=GlobalRad_ospm_orig(min_time:max_time);
cNOx_b_ospm(:,1)=zeros(max_time-min_time+1,1);
NNp_ospm(:,1)=NNp_ospm_orig(min_time:max_time);
NNt_ospm(:,1)=NNt_ospm_orig(min_time:max_time);
Vp_ospm(:,1)=Vp_ospm_orig(min_time:max_time);
Vt_ospm(:,1)=Vt_ospm_orig(min_time:max_time);
qNOX_ospm(:,1)=ones(max_time-min_time+1,1)/3.6;%unit emissions including unit conversion

end
    
filename=[path_ospm,filename_input_ospm];
fid_ospm_input=fopen(filename,'w');

for i=1:length(year_ospm);
%i=1:length(year_ospm);
fprintf(fid_ospm_input,...
    '%6u\t%6u\t%6u\t%6u\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\n',...
    year_ospm(i),month_ospm(i),day_ospm(i),hour_ospm(i),...
    U_mast_ospm(i),wind_dir_ospm(i),TK_ospm(i),GlobalRad_ospm(i),...
    cNOx_b_ospm(i),NNp_ospm(i),NNt_ospm(i),Vp_ospm(i),Vt_ospm(i),qNOX_ospm(i));
end

fclose(fid_ospm_input);
clear year_ospm month_ospm day_ospm hour_ospm
clear U_mast_ospm wind_dir_ospm TK_ospm GlobalRad_ospm
clear cNOx_b_ospm NNp_ospm NNt_ospm Vp_ospm Vt_ospm qNOX_ospm
%--------------------------------------------------------------------------

%Run OSPM from shell
%--------------------------------------------------------------------------
cd(root_path);
current_path=pwd;
cd(path_ospm);

s_ospm=1;
w_ospm='Did not run OSPM at all';
%!nortrip_ospm.exe
%[s_ospm, w_ospm] = system('start nortrip_ospm.exe');
[s_ospm, w_ospm]=dos('nortrip_ospm.exe');
%[s_ospm, w_ospm]=dos('nortrip_ospm.bat');%Doesn't work

%s_ospm=0;
%!nortrip_ospm.exe

cd(current_path);
%--------------------------------------------------------------------------

%Read in OSPM from file
%--------------------------------------------------------------------------
%year mm dd hh u dd csub2_mod_1 	csub2_mod_2 qNOX
%year,month,day,hour,U_mast,wind_dir,cNOX_mod_1b,cNOX_mod_2b,qNOx

clear temp f_dis_ospm
filename=[path_ospm,filename_output_ospm];
ospm_outputfile_exists=exist(filename,'file');
ospm_output_filename=filename;

if s_ospm==0&&ospm_outputfile_exists,
    
    [temp,temp,temp,temp,temp,temp,f_dis_ospm(:,1),f_dis_ospm(:,2),temp]=...
    textread(filename,'%u\t%u\t%u\t%u\t%f\t%f\t%f\t%f\t%f',...
    'headerlines',1);

    r=find(f_dis_ospm<0|isnan(f_dis_ospm));
    f_dis_ospm(r)=nodata;
    if choose_receptor_ospm==3,
        f_dis(min_time:max_time,ro)=mean(f_dis_ospm,2);
    else
        f_dis(min_time:max_time,ro)=f_dis_ospm(:,choose_receptor_ospm);
    end
    
    f_conc=f_dis;
end
%--------------------------------------------------------------------------


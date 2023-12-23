%read_NORTRIP_fortran_output
%This routine reads in the output from NORTRIP_fortran

road_dust_set_constants_v2

%input_path='C:\NORTRIP\Road dust model\fortran\output\';
%input_path=[path_fortran,'output\NORTRIP_'];
input_path=[path_fortran,'output',dir_del];
fprintf('Reading from path: %s\n',input_path);

%Read in dimensions contained in the date data
input_file='NORTRIP_fortran_output_date_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%u',[4 1]);
    min_time=A(1);max_time=A(2);min_time_save=A(3);max_time_save=A(4);
    %n_date=max_time-min_time+1;
    n_date=max_time;
fclose(fid);

%num_track=1;
%n_date=8760;
%nodata=-99;

date_data(1:num_date_index,1:n_date,1:n_roads)=nodata;

traffic_data(1:num_traffic_index,1:n_date,1:n_roads)=nodata;
meteo_data(1:num_meteo_index,1:n_date,1:n_roads)=nodata;
activity_data(1:num_activity_index,1:n_date,1:n_roads)=nodata;

%M_road_bin_data(1:num_source_all,1:num_size,1:n_date,1:num_track,1:n_roads)=nodata;   
%M_road_bin_balance_data(1:num_source_all,1:num_size,1:num_dustbalance,1:n_date,1:num_track,1:n_roads)=nodata;
%C_bin_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=nodata;
%E_road_bin_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=nodata;

M_road_data(1:num_source_all,1:num_size,1:n_date,1:num_track,1:n_roads)=nodata;   
M_road_balance_data(1:num_source_all,1:num_size,1:num_dustbalance,1:n_date,1:num_track,1:n_roads)=nodata;
WR_time_data(1:num_wear,1:n_date,1:num_track,1:n_roads)=nodata;
road_salt_data(1:num_saltdata,1:num_salt,1:n_date,1:num_track,1:n_roads)=nodata;
C_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=nodata;
E_road_data(1:num_source_all,1:num_size,1:num_process,1:n_date,1:num_track,1:n_roads)=nodata;
road_meteo_data(1:num_road_meteo,1:n_date,1:num_track,1:n_roads)=nodata;
g_road_balance_data(1:num_moisture,1:num_moistbalance,1:n_date,1:num_track,1:n_roads)=nodata;
g_road_data(1:num_moisture+2,1:n_date,1:num_track,1:n_roads)=nodata;
f_q(1:num_source_all,1:n_date,1:num_track,1:n_roads)=nodata;
f_q_obs(1:n_date,1:num_track,1:n_roads)=nodata;

airquality_data(1:num_airquality_index,1:n_date,1:n_roads)=nodata;
f_conc(1:n_date,1:n_roads)=nodata;
%f_dis(1:n_date,1:n_roads)=nodata;

ro=1;
tr=1;

%Read in date data
input_file='NORTRIP_fortran_output_date_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%u',[4 1]);
    A=fscanf(fid,'%e',[6 inf]);
fclose(fid);
date_data(1:5,min_time_save:max_time_save)=A(1:5,:);
%Convert date to Matlabs date_num value. Not the same as Fortrans
date_data(datenum_index,min_time_save:max_time_save) = datenum(A(1,:),A(2,:),A(3,:),A(4,:),A(5,:), 0);

%Read in M_road_data
input_file='NORTRIP_fortran_output_M_road_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_source_all*num_size inf]);
fclose(fid);
for x=1:num_size,
for s=1:num_source_all,
	M_road_data(s,x,min_time_save:max_time_save,tr,ro)=A(s+(x-1)*num_source_all,:);
end
end

%Read in M_road_balance_data
input_file='NORTRIP_fortran_output_M_road_balance_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_source_all*num_size*num_dustbalance inf]);
fclose(fid);
for i=1:num_dustbalance,
for x=1:num_size,
for s=1:num_source_all,
	M_road_balance_data(s,x,i,min_time_save:max_time_save,tr,ro)=A(s+(x-1)*num_source_all+(i-1)*num_size*num_source_all,:);
end
end
end

%Read in C_data
input_file='NORTRIP_fortran_output_C_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_source_all*num_size*num_process inf]);
fclose(fid);
for i=1:num_process,
for x=1:num_size,
for s=1:num_source_all,
	C_data(s,x,i,min_time_save:max_time_save,tr,ro)=A(s+(x-1)*num_source_all+(i-1)*num_size*num_source_all,:);
end
end
end

%Read in E_road_data
input_file='NORTRIP_fortran_output_E_road_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_source_all*num_size*num_process inf]);
fclose(fid);
for i=1:num_process,
for x=1:num_size,
for s=1:num_source_all,
	E_road_data(s,x,i,min_time_save:max_time_save,tr,ro)=A(s+(x-1)*num_source_all+(i-1)*num_size*num_source_all,:);
end
end
end

%Read in road wear data
input_file='NORTRIP_fortran_output_WR_time_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    WR_time_data(1:num_wear,min_time_save:max_time_save,tr,ro)=fscanf(fid,'%e',[num_wear inf]);
fclose(fid);

%Read in road_salt_data
input_file='NORTRIP_fortran_output_road_salt_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_saltdata*num_salt inf]);
fclose(fid);
for x=1:num_salt,
for s=1:num_saltdata,
	road_salt_data(s,x,min_time_save:max_time_save,tr,ro)=A(s+(x-1)*num_saltdata,:);
end
end

%Read in road meteo data
input_file='NORTRIP_fortran_output_road_meteo_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    road_meteo_data(1:num_road_meteo,min_time_save:max_time_save,tr,ro)=fscanf(fid,'%e',[num_road_meteo inf]);
fclose(fid);

%Read in g_road_balance_data
input_file='NORTRIP_fortran_output_g_road_balance_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    A=fscanf(fid,'%e',[num_moisture*num_moistbalance inf]);
fclose(fid);
for i=1:num_moistbalance,
for m=1:num_moisture,
	g_road_balance_data(m,i,min_time_save:max_time_save,tr,ro)=A(m+(i-1)*num_moisture,:);
end
end

%Read in g_road_data
input_file='NORTRIP_fortran_output_g_road_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    g_road_data(1:num_moisture,min_time_save:max_time_save,tr,ro)=fscanf(fid,'%e',[num_moisture inf]);
fclose(fid);

%Read in f_q data
input_file='NORTRIP_fortran_output_f_q.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    f_q(1:num_source_all,min_time_save:max_time_save,tr,ro)=fscanf(fid,'%e',[num_source_all inf]);
fclose(fid);

%Read in f_q_obs data
input_file='NORTRIP_fortran_output_f_q_obs.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    f_q_obs(min_time_save:max_time_save,tr,ro)=fscanf(fid,'%e',[1 inf]);
fclose(fid);

%Read in traffic_data
input_file='NORTRIP_fortran_output_traffic_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    traffic_data(1:num_traffic_index,min_time_save:max_time_save,ro)=fscanf(fid,'%e',[num_traffic_index inf]);
fclose(fid);

%Read in activity_data
input_file='NORTRIP_fortran_output_activity_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    activity_data(1:num_activity_index,min_time_save:max_time_save,ro)=fscanf(fid,'%e',[num_activity_index inf]);
fclose(fid);

%Read in meteo_data
input_file='NORTRIP_fortran_output_meteo_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    meteo_data(1:num_meteo_index,min_time_save:max_time_save,ro)=fscanf(fid,'%e',[num_meteo_index inf]);
fclose(fid);

%Read in airquality_data
input_file='NORTRIP_fortran_output_airquality_data.txt';
fprintf('Reading NORTRIP_fortran file: %s\n',input_file);
fid=fopen([input_path,input_file]);
    airquality_data(1:num_airquality_index,min_time_save:max_time_save,ro)=fscanf(fid,'%e',[num_airquality_index inf]);
fclose(fid);
f_conc(min_time_save:max_time_save,ro)=airquality_data(f_conc_index,min_time_save:max_time_save,ro);

%Meteo data saved without corrections. Putting corrections back
meteo_data(FF_index,:,ro)=meteo_data(FF_index,:,ro)*wind_speed_correction(ro);
meteo_data(RH_index,:,ro)=max(0.,min(100.,meteo_data(RH_index,:,ro)+RH_offset));
meteo_data(T_a_index,:,ro)=meteo_data(T_a_index,:,ro)+T_a_offset;

clear A

%Set the plotting times from the saving times. Not necessary when running
%all
    min_time=min_time_save;
    max_time=max_time_save;


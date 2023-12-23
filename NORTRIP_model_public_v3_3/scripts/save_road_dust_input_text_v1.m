%==========================================================================
%NORTRIP model
%SUBROUTINE: save_road_dust_input_text_v1.m
%VERSION: 1, 06.08.2014
%AUTHOR: Bruce Rolstad Denby (bruce.denby@met.no)
%DESCRIPTION: Saves model parameters for the NORTRIP model to ascii files
%==========================================================================

%Set common constants
road_dust_set_constants_v2

k=strfind(path_inputdata,[dir_del,'text',dir_del]);
if isempty(k),
    path_inputdata_text=[path_inputdata,['text',dir_del]];
else
    path_inputdata_text=path_inputdata;
end

%Set so as to save all input data
min_time_text=1;
max_time_text=n_date;

%Specify no data value for output. NaN, does not write values to sheets
no_val=nodata;

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_metadata.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_metadata.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

fprintf(fid_input_txt,'%-44s\n','NORTRIP model text input file (metadata)');
fprintf(fid_input_txt,'%-44s\n','-----------------------------------------');
fprintf(fid_input_txt,'%-44s\t%-12s\t%-12s\n','PARAMETER','VALUE','UNIT');

text='Missing data';val=no_val;unit='';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Driving cycle';val=d_index;unit='';
fprintf(fid_input_txt,'%-44s\t%-12u\t%-12s\n',text,val,unit);

text='Pavement type';val=p_index;unit='';
fprintf(fid_input_txt,'%-44s\t%-12u\t%-12s\n',text,val,unit);

text='Surface texture scaling';val=h_texture;unit='';
fprintf(fid_input_txt,'%-44s\t%-12u\t%-12s\n',text,val,unit);

text='Number of lanes';val=n_lanes;unit='';
fprintf(fid_input_txt,'%-44s\t%-12u\t%-12s\n',text,val,unit);

text='Width of lane';val=b_lane;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Road width';val=b_road;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street canyon width';val=b_canyon;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street canyon height north';val=h_canyon(1);unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street canyon height south';val=h_canyon(2);unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street orientation';val=ang_road;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street slope';val=slope_road;unit='(deg)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Latitude';val=LAT;unit='(deg)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Longitude';val=LON;unit='(deg)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Elevation';val=Z_SURF;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Surface albedo';val=albedo_road;unit='';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Time difference';val=DIFUTC_H;unit='(hr +west)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Height obs wind';val=z_FF;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Height obs temperature';val=z_T;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

%text='Height obs other temperature';val=z2_T;

text='Surface pressure';val=Pressure;unit='(mbar)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Wind speed correction';val=wind_speed_correction;unit='(m/s)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Observed moisture cut off';val=observed_moisture_cutoff_value;unit='(mV)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Suspension rate scaling factor';val=h_sus;unit='';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Exhaust EF (he)';val=exhaust_EF(he);unit='(g/km/veh)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Exhaust EF (li)';val=exhaust_EF(li);unit='(g/km/veh)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='NOX EF (he)';val=NOX_EF(he);unit='(g/km/veh)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='NOX EF (li)';val=NOX_EF(li);unit='(g/km/veh)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Choose receptor position for ospm';val=choose_receptor_ospm;unit='(1=N,2=S,3=av)';
fprintf(fid_input_txt,'%-44s\t%-12u\t%-12s\n',text,val,unit);

text='Street canyon length north for ospm';val=SL1_ospm;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Street canyon length south for ospm';val=SL2_ospm;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='f_roof factor for ospm';val=f_roof_ospm;unit='';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Receptor height for ospm';val=RecHeight_ospm;unit='(m)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='f_turb factor for ospm';val=f_turb_ospm;unit='';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='Start date';val=char(start_date_str);unit='dd.mm.yyyy hh:mm';
fprintf(fid_input_txt,'%-44s\t%-24s\t%-12s\n',text,val,unit);

text='Start save date';val=char(start_date_save_str);unit='dd.mm.yyyy hh:mm';
fprintf(fid_input_txt,'%-44s\t%-24s\t%-12s\n',text,val,unit);

text='End date';val=char(end_date_str);unit='dd.mm.yyyy hh:mm';
fprintf(fid_input_txt,'%-44s\t%-24s\t%-12s\n',text,val,unit);

text='End save date';val=char(end_date_save_str);unit='dd.mm.yyyy hh:mm';
fprintf(fid_input_txt,'%-44s\t%-24s\t%-12s\n',text,val,unit);


%Actual width of road surface
b_road_lanes=n_lanes*b_lane;

%Close the file
fclose(fid_input_txt);
%close('all');
%--------------------------------------------------------------------------

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_initial.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_initial.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

fprintf(fid_input_txt,'%-44s\n','NORTRIP model text input file (initial)');
fprintf(fid_input_txt,'%-44s\n','---------------------------------------');
fprintf(fid_input_txt,'%-44s\t%-12s\t%-12s\n','PARAMETER','VALUE','UNIT');

text='M2_dust_road';val=M_road_init(road_index,1)/b_road_lanes/1000;unit='(g/m2)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='M2_sand_road';val=M_road_init(sand_index,1)/b_road_lanes/1000;unit='(g/m2)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='M2_salt_road(na)';val=M_road_init(salt_index(1),1)/b_road_lanes/1000;unit='(g/m2)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text=['M2_salt_road(',salt2_str,')'];val=M_road_init(salt_index(2),1)/b_road_lanes/1000;unit='(g/m2)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='water_road';val=g_road_init(water_index,1);unit='(mm)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='snow_road';val=g_road_init(snow_index,1);unit='(mm.w.e)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='ice_road';val=g_road_init(ice_index,1);unit='(mm.w.e)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='P2_fugitive';val=P_fugitive;unit='(g/m2/hr)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='long_rad_in_offset';val=long_rad_in_offset;unit='(W/m2)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='RH_offset';val=RH_offset;unit='(%)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

text='T_2m_offset';val=T_a_offset;unit='(C)';
fprintf(fid_input_txt,'%-44s\t%-12.2f\t%-12s\n',text,val,unit);

%Close the file
fclose(fid_input_txt);

%--------------------------------------------------------------------------

%Unless otherwise specified output for PM10
x=pm_10;
ro=1;

%Save traffic
%--------------------------------------------------------------------------
clear a
for ti=min_time_text:max_time_text,
    j=0;
    %Dates
    j=j+1;a{1,j}='Year';val=date_data(year_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Month';val=date_data(month_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Day';val=date_data(day_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Hour';val=date_data(hour_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Minute';val=date_data(minute_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %Traffic
    j=j+1;a{1,j}='N(total)';val=traffic_data(N_total_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(he)';val=traffic_data(N_v_index(he),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(li)';val=traffic_data(N_v_index(li),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(st,he)';val=traffic_data(N_t_v_index(st,he),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(st,li)';val=traffic_data(N_t_v_index(st,li),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(wi,he)';val=traffic_data(N_t_v_index(wi,he),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(wi,li)';val=traffic_data(N_t_v_index(wi,li),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(su,he)';val=traffic_data(N_t_v_index(su,he),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='N(su,li)';val=traffic_data(N_t_v_index(su,li),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='V_veh(he)(km/hr)';val=traffic_data(V_veh_index(he),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='V_veh(li)(km/hr)';val=traffic_data(V_veh_index(li),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
end

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_traffic.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_traffic.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

%Put the header just in front of the time data
a(min_time_text,:)=a(1,:);

%Set format of output
col_data=size(a,2);row_data=size(a,1);
%Initialise date format strings
clear format_str format_header_str
format_str='%-12u\t%-12u\t%-12u\t%-12u\t%-12u';
format_header_str='%-12s\t%-12s\t%-12s\t%-12s\t%-12s';
for k=6:col_data,
    format_str=[format_str,'\t%-16.1f'];
    format_header_str=[format_header_str,'\t%-16s'];
end
    format_str=[format_str,'\n'];
    format_header_str=[format_header_str,'\n'];
%Write the header
fprintf(fid_input_txt,format_header_str,a{min_time_text,:});
%Write the data
clear a_mat
a_mat(min_time_text+1:max_time_text+1,:)=cell2mat(a(min_time_text+1:max_time_text+1,:));
r=find(isnan(a_mat));
a_mat(r)=no_val;
for k=min_time_text+1:max_time_text+1,
    fprintf(fid_input_txt,format_str,a_mat(k,:));
end

%Close the file
fclose(fid_input_txt);
%--------------------------------------------------------------------------
%Save activity
%--------------------------------------------------------------------------
clear a
for ti=min_time_text:max_time_text,
    j=0;
    %Dates
    j=j+1;a{1,j}='Year';val=date_data(year_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Month';val=date_data(month_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Day';val=date_data(day_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Hour';val=date_data(hour_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Minute';val=date_data(minute_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %Activity
    j=j+1;a{1,j}='M_sanding(g/m2)';val=activity_data(M_sanding_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='M_salting(na)(g/m2)';val=activity_data(M_salting_index(1),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}=['M_salting(',salt2_str,')(g/m2)'];val=activity_data(M_salting_index(2),ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Ploughing_road(0/1)';val=activity_data(t_ploughing_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Cleaning_road(0/1)';val=activity_data(t_cleaning_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Wetting(mm)';val=activity_data(g_road_wetting_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='M_fugitive(g/m2)';val=activity_data(M_fugitive_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
end

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_activity.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_activity.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

%Put the header just in front of the time data
a(min_time_text,:)=a(1,:);

%Set format of output
col_data=size(a,2);row_data=size(a,1);
%Initialise date format strings
clear format_str format_header_str
format_str='%-12u\t%-12u\t%-12u\t%-12u\t%-12u';
format_header_str='%-12s\t%-12s\t%-12s\t%-12s\t%-12s';
for k=6:col_data,
    format_str=[format_str,'\t%-24.3f'];
    format_header_str=[format_header_str,'\t%-24s'];
end
    format_str=[format_str,'\n'];
    format_header_str=[format_header_str,'\n'];
%Write the header
fprintf(fid_input_txt,format_header_str,a{min_time_text,:});
%Write the data
clear a_mat
a_mat(min_time_text+1:max_time_text+1,:)=cell2mat(a(min_time_text+1:max_time_text+1,:));
r=find(isnan(a_mat));
a_mat(r)=no_val;
for k=min_time_text+1:max_time_text+1,
    fprintf(fid_input_txt,format_str,a_mat(k,:));
end

%Close the file
fclose(fid_input_txt);
%--------------------------------------------------------------------------
%Save airquality
%--------------------------------------------------------------------------
clear a
for ti=min_time_text:max_time_text,
    j=0;
    %Dates
    j=j+1;a{1,j}='Year';val=date_data(year_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Month';val=date_data(month_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Day';val=date_data(day_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Hour';val=date_data(hour_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Minute';val=date_data(minute_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %Concentrations
    j=j+1;a{1,j}='PM10_obs(ug/m3)';val=PM_obs(pm_10,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='PM10_background(ug/m3)';val=PM_background(pm_10,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='PM25_obs(ug/m3)';val=PM_obs(pm_25,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='PM25_background(ug/m3)';val=PM_background(pm_25,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='NOX_obs(ug/m3)';val=NOX_obs(ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='NOX_background(ug/m3)';val=NOX_background(ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='NOX_emis(g/km/hr)';val=NOX_emis(ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='EP_emis(g/km/hr)';val=EP_emis(ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %if f_dis_available,
    %    j=j+1;a{1,j}='Disp_fac(conc/emis)';val=f_dis(ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %else
    %    j=j+1;a{1,j}='Disp_fac(conc/emis)';val=f_conc(ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %end
end

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_airquality.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_airquality.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

%Put the header just in front of the time data
a(min_time_text,:)=a(1,:);

%Set format of output
col_data=size(a,2);row_data=size(a,1);
%Initialise date format strings
clear format_str format_header_str
format_str='%-12u\t%-12u\t%-12u\t%-12u\t%-12u';
format_header_str='%-12s\t%-12s\t%-12s\t%-12s\t%-12s';
for k=6:col_data,
    format_str=[format_str,'\t%-24.3f'];
    format_header_str=[format_header_str,'\t%-24s'];
end
    format_str=[format_str,'\n'];
    format_header_str=[format_header_str,'\n'];
%Write the header
fprintf(fid_input_txt,format_header_str,a{min_time_text,:});
%Write the data
clear a_mat
a_mat(min_time_text+1:max_time_text+1,:)=cell2mat(a(min_time_text+1:max_time_text+1,:));
r=find(isnan(a_mat));
a_mat(r)=no_val;
for k=min_time_text+1:max_time_text+1,
    fprintf(fid_input_txt,format_str,a_mat(k,:));
end

%Close the file
fclose(fid_input_txt);
%--------------------------------------------------------------------------
%Save meteorology
%--------------------------------------------------------------------------
clear a
for ti=min_time_text:max_time_text,
    j=0;
    %Dates
    j=j+1;a{1,j}='Year';val=date_data(year_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Month';val=date_data(month_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Day';val=date_data(day_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Hour';val=date_data(hour_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Minute';val=date_data(minute_index,ti);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    %Meteorology
    j=j+1;a{1,j}='T2m(C)';val=meteo_data(T_a_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='FF(m/s)';val=meteo_data(FF_index,ti,ro)/wind_speed_correction;if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    if DD_available,
        j=j+1;a{1,j}='DD(deg)';val=meteo_data(DD_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    j=j+1;a{1,j}='RH(%)';val=meteo_data(RH_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    if T_dewpoint_available,
        j=j+1;a{1,j}='T2m dewpoint(C)';val=meteo_data(T_dewpoint_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    j=j+1;a{1,j}='Rain(mm/hr)';val=meteo_data(Rain_precip_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Snow(mm/hr)';val=meteo_data(Snow_precip_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    j=j+1;a{1,j}='Global radiation(W/m2)';val=meteo_data(short_rad_in_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    if long_rad_in_available,
        j=j+1;a{1,j}='Longwave radiation(W/m2)';val=meteo_data(long_rad_in_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    if cloud_cover_available,
        j=j+1;a{1,j}='Cloud cover';val=meteo_data(cloud_cover_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    if pressure_obs_available,
        j=j+1;a{1,j}='Pressure(mbar)';val=meteo_data(pressure_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    if road_temperature_obs_available,
        j=j+1;a{1,j}='Road surface temperature(C)';val=meteo_data(road_temperature_obs_input_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
    if road_wetness_obs_available,
        if road_wetness_obs_in_mm,
            j=j+1;a{1,j}='Road wetness(mm)';val=meteo_data(road_wetness_obs_input_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
        else
            j=j+1;a{1,j}='Road wetness(mV)';val=meteo_data(road_wetness_obs_input_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
        end
    end
    if T_sub_available,
        j=j+1;a{1,j}='T_sub(C)';val=meteo_data(T_sub_input_index,ti,ro);if val==nodata,a{ti+1,j}=no_val;else a{ti+1,j}=val;end
    end
end

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputdata,'.');
if ~isempty(k),
    filename_inputdata_txt=[filename_inputdata(1:k-1),'_meteorology.txt'];
else
    filename_inputdata_txt=[filename_inputdata,'_meteorology.txt'];
end
filename=[path_inputdata_text,filename_inputdata_txt];

%Open the file for writing
fid_input_txt=fopen(filename,'w');

%Put the header just in front of the time data
a(min_time_text,:)=a(1,:);

%Set format of output
col_data=size(a,2);row_data=size(a,1);
%Initialise date format strings
clear format_str format_header_str
format_str='%-12u\t%-12u\t%-12u\t%-12u\t%-12u';
format_header_str='%-12s\t%-12s\t%-12s\t%-12s\t%-12s';
for k=6:col_data,
    format_str=[format_str,'\t%-28.2f'];
    format_header_str=[format_header_str,'\t%-28s'];
end
    format_str=[format_str,'\n'];
    format_header_str=[format_header_str,'\n'];
%Write the header
fprintf(fid_input_txt,format_header_str,a{min_time_text,:});
%Write the data
clear a_mat
a_mat(min_time_text+1:max_time_text+1,:)=cell2mat(a(min_time_text+1:max_time_text+1,:));
r=find(isnan(a_mat));
a_mat(r)=no_val;
for k=min_time_text+1:max_time_text+1,
    fprintf(fid_input_txt,format_str,a_mat(k,:));
end

%Close the file
fclose(fid_input_txt);
%--------------------------------------------------------------------------


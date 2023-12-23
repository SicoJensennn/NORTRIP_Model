%==========================================================================
%NORTRIP model
%SUBROUTINE: read_road_dust_input
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Reads model input data from excel sheets
%==========================================================================

bad_input_data=0;

if read_inputdata_as_text==0
    filename=[path_inputdata,filename_inputdata];
    fprintf('Reading input data from excel\n');

    input_exists_flag=1;
    if ~exist(filename),
        hf=errordlg(['File ',filename, ' does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
else
    %Set file name by removing the data type and replacing with '.txt'
    filename=[path_inputdata,filename_inputdata];
    k=strfind(filename,[dir_del,'text',dir_del]);
    if isempty(k),
        filename=[path_inputdata,['text',dir_del],filename_inputdata];
    end
    fprintf('Reading input data as text\n');
end

%Set common constants
%road_dust_set_constants_v2

%Read Metadata
clear A
if read_inputdata_as_text==0,
    A = importdata(filename,'\t');
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_metadata.txt'];
    else
        filename_txt=[filename,'_metadata.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, ' does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    clear A_temp
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp.textdata(i,1)=A_line{1}(1);
        if size(A_line{1},1)>1,
            A_temp.textdata(i,2)=A_line{1}(2);
            num_temp=str2num(char(A_line{1}(2)));
            if ~isempty(num_temp),
                A_temp.data(i,1)=num_temp;
            else
                A_temp.data(i,1)=nan;
            end
        else
        end
    end
    fclose(fid);
    A.data.Metadata=A_temp.data;
    A.textdata.Metadata=A_temp.textdata;
end

header_text=A.textdata.Metadata(:,1);

text='Driving cycle';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), d_index=A.data.Metadata(k2,1);else d_index=1;end
text='Pavement type';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), p_index=A.data.Metadata(k2,1);else p_index=1;end
text='Road width';
k2 = strmatch(text,header_text);
b_road=A.data.Metadata(k2,1);
text='Latitude';
k2 = strmatch(text,header_text);
LAT=A.data.Metadata(k2,1);
text='Longitude';
k2 = strmatch(text,header_text);
LON=A.data.Metadata(k2,1);
text='Elevation';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), Z_SURF=A.data.Metadata(k2,1);else Z_SURF=0;end
text='Height obs wind';
k2 = strmatch(text,header_text);
z_FF=A.data.Metadata(k2,1);
text='Height obs temperature';
k2 = strmatch(text,header_text);
z_T=A.data.Metadata(k2,1);
text='Height obs other temperature';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), z2_T=A.data.Metadata(k2,1);else z2_T=25;end 
text='Surface albedo';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), albedo_road=A.data.Metadata(k2,1);else albedo_road=0.3;end
text='Time difference';
k2 = strmatch(text,header_text);
DIFUTC_H=A.data.Metadata(k2,1);
text='Surface pressure';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), Pressure=A.data.Metadata(k2,1);else Pressure=1000;end
text='Missing data';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), nodata=A.data.Metadata(k2,1);else nodata=-99;end
text='Number of lanes';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), n_lanes=A.data.Metadata(k2,1);else n_lanes=2;end
text='Width of lane';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), b_lane=A.data.Metadata(k2,1);else b_lane=3.5;end
text='Street canyon width';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), b_canyon=A.data.Metadata(k2,1);else b_canyon=b_road;end
if b_canyon<b_road,b_canyon=b_road;end%Does not like a 0 value
text='Street canyon height';
k2 = strmatch(text,header_text);
if ~isempty(k2), h_canyon=A.data.Metadata(k2,1);else h_canyon=0;end
%Look for North and south only if there are more than one street canyon value
if length(h_canyon)>1,
  %Allows for two street canyon heights. The first is Northern side and the second Southern side
  %Overrides the street canyon input and puts it into the north and south values
  text='Street canyon height north';
  k2 = strmatch(text,header_text);
  if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), h_canyon(1)=A.data.Metadata(k2,1);else h_canyon(1)=0;end
  text='Street canyon height south';
  k2 = strmatch(text,header_text);
  if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), h_canyon(2)=A.data.Metadata(k2,1);else h_canyon(2)=0;end
else
  h_canyon(2)=h_canyon(1);
end

text='Street orientation';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), ang_road=A.data.Metadata(k2,1);else ang_road=0;end
text='Street slope';%In degrees, positive slope when increasing in Northwards direction
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), slope_road=A.data.Metadata(k2,1);else slope_road=0;end
text='Wind speed correction';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), wind_speed_correction=A.data.Metadata(k2,1);else wind_speed_correction=1;end
text='Observed moisture cut off';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), observed_moisture_cutoff_value=A.data.Metadata(k2,1);else observed_moisture_cutoff_value=1.5;end
text='Suspension rate scaling factor';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), h_sus=A.data.Metadata(k2,1);else h_sus=1.0;end
text='Surface texture scaling';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), h_texture=A.data.Metadata(k2,1);else h_texture=1.0;end
text='Choose receptor position for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), choose_receptor_ospm=A.data.Metadata(k2,1);else choose_receptor_ospm=3;end
text='Street canyon length north for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), SL1_ospm=A.data.Metadata(k2,1);else SL1_ospm=100;end
text='Street canyon length south for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), SL2_ospm=A.data.Metadata(k2,1);else SL2_ospm=100;end
text='f_roof factor for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), f_roof_ospm=A.data.Metadata(k2,1);else f_roof_ospm=0.82;end
text='Receptor height for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), RecHeight_ospm=A.data.Metadata(k2,1);else RecHeight_ospm=2.5;end
text='f_turb factor for ospm';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), f_turb_ospm=A.data.Metadata(k2,1);else f_turb_ospm=1.0;end
text='Exhaust EF (he)';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), exhaust_EF(he)=A.data.Metadata(k2,1);else exhaust_EF(he)=0.0;end
text='Exhaust EF (li)';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), exhaust_EF(li)=A.data.Metadata(k2,1);else exhaust_EF(li)=0.0;end
if sum(exhaust_EF(:))==0,
    exhaust_EF_available=0;
else
    exhaust_EF_available=1;
end
text='NOX EF (he)';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), NOX_EF(he)=A.data.Metadata(k2,1);else NOX_EF(he)=0.0;end
text='NOX EF (li)';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isnan(A.data.Metadata(k2,1)), NOX_EF(li)=A.data.Metadata(k2,1);else NOX_EF(li)=0.0;end
if sum(NOX_EF(:))==0,
    NOX_EF_available=0;
else
    NOX_EF_available=1;
end
text='Start date';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,2)))
    start_date_str=A.textdata.Metadata(k2,2);
    if length(char(start_date_str))<11
        start_date_str=[char(start_date_str),' 00:00:00'];
    end
end
text='End date';
k2 = strmatch(text,header_text);
if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,2)))
    end_date_str=A.textdata.Metadata(k2,2);
    if length(char(end_date_str))<11
        end_date_str=[char(end_date_str),' 00:00:00'];
    end
end

%New routine for reading multiple saving dates 16.06.2023
%Set to 1 as there will always be a possible plotting date
n_save_subdate=1;
text='Start save date';
k2 = strmatch(text,header_text);
%if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,2))), start_date_save_str=A.textdata.Metadata(k2,2);end
i=1;ii=0;
finished_subdate_reading=0;
while ~finished_subdate_reading
if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,i+1)))
        ii=ii+1;
        start_subdate_save_str{ii}=A.textdata.Metadata(k2,i+1);
        i=i+1;
        %Need to add 00:00 the dates because excel removes the 00:00 if length(char(start_subdate_save_str{ii}))<11
        if length(char(start_subdate_save_str{ii}))<11
            start_subdate_save_str{ii}=[char(start_subdate_save_str{ii}),' 00:00:00'];
        end
        n_save_subdate=ii;
    else
        finished_subdate_reading=1;
    end
    
end

text='End save date';
k2 = strmatch(text,header_text);
%if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,2))), end_date_save_str=A.textdata.Metadata(k2,2);end
i=1;ii=0;
finished_subdate_reading=0;
while ~finished_subdate_reading
    if ~isempty(k2)&&~isempty(char(A.textdata.Metadata(k2,i+1)))
        ii=ii+1;
        end_subdate_save_str{ii}=A.textdata.Metadata(k2,i+1);
        i=i+1;
        %Need to add 00:00 the dates because excel removes the 00:00
        if length(char(end_subdate_save_str{ii}))<11
            end_subdate_save_str{ii}=[char(end_subdate_save_str{ii}),' 00:00:00'];
        end
        n_save_subdate=ii;
    else
        finished_subdate_reading=1;
    end
    
end

if n_save_subdate==1&&exist('start_subdate_save_str')
    start_date_save_str=char(start_subdate_save_str{n_save_subdate});
    end_date_save_str=char(end_subdate_save_str{n_save_subdate});
end

%Actual width of road surface
b_road_lanes=n_lanes*b_lane;

if read_inputdata_as_text==0,
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_initial.txt'];
    else
        filename_txt=[filename,'_initial.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    clear A_temp A_line
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp.textdata(i,1)=A_line{1}(1);
        if size(A_line{1},1)>1,
            A_temp.textdata(i,2)=A_line{1}(2);
            num_temp=str2num(char(A_line{1}(2)));
            if ~isempty(num_temp),
                A_temp.data(i,1)=num_temp;
            else
                A_temp.data(i,1)=nan;
            end
        else
        end
    end
    fclose(fid);
    A.textdata.Initialconditions=A_temp.textdata;
    A.data.Initialconditions=A_temp.data;
end
%Read intitial conditions
header_text=A.textdata.Initialconditions(:,1);

%Initialise mass loading. All wear mass goes into road wear at start
clear M_road_init
M_road_init(1:num_source,1:num_track)=0;

text='M_dust_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(road_index,1)=A.data.Initialconditions(k2(1),1); end
text='M2_dust_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(road_index,1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end

text='M_sand_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(sand_index,1)=A.data.Initialconditions(k2(1),1);end
text='M2_sand_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(sand_index,1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end

text='M_salt_road(na)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(1),1)=A.data.Initialconditions(k2(1),1);end
text='M2_salt_road(na)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(1),1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end

text='M_salt_road(mg)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1);end
text='M2_salt_road(mg)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end
text='M_salt_road(cma)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1);end
text='M2_salt_road(cma)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end
text='M_salt_road(ca)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1);end
text='M2_salt_road(ca)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),M_road_init(salt_index(2),1)=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;end

%Distribute initial mass over all the tracks
for tr=1:num_track,
    M_road_init(:,tr)=M_road_init(:,1)*f_track(tr);
end

clear g_road_init
g_road_init(1:num_moisture,1:num_track)=0;
text='g_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(water_index,1)=A.data.Initialconditions(k2(1),1);end
text='water_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(water_index,1)=A.data.Initialconditions(k2(1),1);end

text='s_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(snow_index,1)=A.data.Initialconditions(k2(1),1);end
text='snow_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(snow_index,1)=A.data.Initialconditions(k2(1),1);end

text='i_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(ice_index,1)=A.data.Initialconditions(k2(1),1);end
text='ice_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),g_road_init(ice_index,1)=A.data.Initialconditions(k2(1),1);end

%Distribute initial moisture over all the tracks
for tr=1:num_track,
    g_road_init(:,tr)=g_road_init(:,1);
end

text='long_rad_in_offset';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),long_rad_in_offset=A.data.Initialconditions(k2(1),1);else long_rad_in_offset=0;end

text='RH_offset';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),RH_offset=A.data.Initialconditions(k2(1),1);else RH_offset=0;end

text='T_2m_offset';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];return;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),T_a_offset=A.data.Initialconditions(k2(1),1);else T_a_offset=0;end

P_fugitive=0;
text='P_fugitive';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),P_fugitive=A.data.Initialconditions(k2(1),1);end
text='P2_fugitive';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2)&&~isnan(A.data.Initialconditions(k2,1)),P_fugitive=A.data.Initialconditions(k2(1),1)*b_road_lanes*1000;else P_fugitive=0;end

%Read Traffic data dates
if read_inputdata_as_text==0,
else
    clear A_temp
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_traffic.txt'];
    else
        filename_txt=[filename,'_traffic.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    A_temp = importdata(filename_txt,'\t');
    A.textdata.Traffic=A_temp.textdata;
    A.data.Traffic=A_temp.data;
end

clear year month day hour minute
header_text=A.textdata.Traffic(1,:);
text='Year';
k2 = strmatch(text,header_text);
year=A.data.Traffic(:,k2);
text='Month';
k2 = strmatch(text,header_text);
month=A.data.Traffic(:,k2);
text='Day';
k2 = strmatch(text,header_text);
day=A.data.Traffic(:,k2);
text='Hour';
k2 = strmatch(text,header_text);
hour=A.data.Traffic(:,k2);
text='Minute';
k2 = strmatch(text,header_text);
if ~isempty(k2),minute=A.data.Traffic(:,k2);else minute=year*0;end

n_date=length(year);

%Convert date and time data
date_num = datenum(year, month, day, hour, minute, 0);
date_str(1,:,:) = datestr(date_num ,'yyyy.mm.dd HH');
date_str(2,:,:) = datestr(date_num ,'HH:MM dd mmm ');

%Read traffic volumes
clear N N_v N_total N_nodata V_veh V_veh_nodata;
text='N(total)';
k2 = strmatch(text,header_text);
if ~isempty(k2), 
    N_total(:,1)=A.data.Traffic(:,k2);
else
    fprintf('No traffic data\n');return
end
text='N(he)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N_v(he,:)=A.data.Traffic(:,k2(1));end
text='N(li)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N_v(li,:)=A.data.Traffic(:,k2(1));end
text='N(st,he)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N(st,he,:)=A.data.Traffic(:,k2(1));end
text='N(st,li)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N(st,li,:)=A.data.Traffic(:,k2(1));end
text='N(wi,he)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N(wi,he,:)=A.data.Traffic(:,k2(1));end
text='N(wi,li)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2), N(wi,li,:)=A.data.Traffic(:,k2(1));end
text='N(su,he)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),N(su,he,:)=A.data.Traffic(:,k2(1));end
text='N(su,li)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),N(su,li,:)=A.data.Traffic(:,k2(1));end
%Read traffic speeds
text='V_veh(he)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),V_veh(he,:)=A.data.Traffic(:,k2(1));end
text='V_veh(li)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),V_veh(li,:)=A.data.Traffic(:,k2(1));end

%Check data and fill missing with previous
%Do this if any of the traffic data is missing
N_total_nodata=[];
r=find(N_total==nodata|isnan(N_total));
%Find all the good data for all traffic columns
clear temp
temp(1,:)=N(st,he,:);temp(2,:)=N(wi,he,:);temp(3,:)=N(su,he,:);
temp(4,:)=N(st,li,:);temp(5,:)=N(wi,li,:);temp(6,:)=N(su,li,:);
N_good_data=find(N_total'~=nodata&~isnan(N_total')&...
                  N_v(li,:)~=nodata&~isnan(N_v(li,:))&...
                  N_v(he,:)~=nodata&~isnan(N_v(he,:))&...
                  temp(1,:)~=nodata&~isnan(temp(1,:))&...
                  temp(2,:)~=nodata&~isnan(temp(2,:))&...
                  temp(3,:)~=nodata&~isnan(temp(3,:))&...
                  temp(4,:)~=nodata&~isnan(temp(4,:))&...
                  temp(5,:)~=nodata&~isnan(temp(5,:))&...
                  temp(6,:)~=nodata&~isnan(temp(6,:))...
                  )';
if ~isempty(r),
if length(r)~=length(N_total),
	for i=1:length(r),
        N_total(r(i))=N_total(r(i)-1);
        N_total_nodata(i)=r(i);
	end
end
end
N_v_nodata=[];
for v=1:num_veh,
    r=find(N_v(v,:)==nodata|isnan(N_v(v,:)));
    if ~isempty(r),
    if length(r)~=length(N_v),
        for i=1:length(r),
        N_v(v,r(i))=N_v(v,r(i)-1);
        N_v_nodata(v,i)=r(i);
        end
    end
    end
end
N_nodata=[];
for t=1:num_tyre,
for v=1:num_veh,
    r=find(N(t,v,:)==nodata|isnan(N(t,v,:)));
    if ~isempty(r),
    if length(r)~=length(N),
        for i=1:length(r),
        N(t,v,r(i))=N(t,v,r(i)-1);
        N_nodata(t,v,i)=r(i);
        end
    end
    end
end
end
V_veh_nodata=[];
for v=1:num_veh,
    r=find(V_veh(v,:)==nodata|V_veh(v,:)==0|isnan(V_veh(v,:)));
    if ~isempty(r),
    if length(r)~=length(N),
    for i=1:length(r),
        V_veh(v,r(i))=V_veh(v,r(i)-1);
        V_veh_nodata(t,v,i)=r(i);
    end
    end
    end
end

%Create missing traffic data using average daily cycles and existing ratio
%of tyre types
n_traffic=length(N_total);
%Set the current ratios
clear N_ratio
for v=1:num_veh,    
clear temp
r=find(N_v(v,:)~=0);
for t=1:num_tyre,
    N_ratio(t,v,1:n_traffic)=0;
    temp(1,:)=N(t,v,r);
    N_ratio(t,v,r)=temp./N_v(v,r);
end
end

if ~isempty(N_total_nodata),
    [x_str xplot yplot]=Average_data_func(date_num(N_good_data),N_total(N_good_data),1,length(N_good_data),3);
	for i=1:length(N_total_nodata),
        for j=1:24,
            if hour(N_total_nodata(i))==xplot(j),
                N_total(N_total_nodata(i))=yplot(j);
            end
        end
	end
end
if ~isempty(N_v_nodata),
for v=1:num_veh,
    [x_str xplot yplot]=Average_data_func(date_num(N_good_data),N_v(v,N_good_data),1,length(N_good_data),3);
	for i=1:size(N_v_nodata,2),
        for j=1:24,
            if N_v_nodata(v,i)~=0
                if hour(N_v_nodata(v,i))==xplot(j),
                    N_v(v,N_v_nodata(v,i))=yplot(j);
                end
            end
        end
	end
end
end

if ~isempty(N_v_nodata),
for t=1:num_tyre,
for v=1:num_veh,
    for i=1:size(N_v_nodata,2),
        if N_v_nodata(v,i)~=0,
        N(t,v,N_v_nodata(v,i))=N_ratio(t,v,N_v_nodata(v,i)).*N_v(v,N_v_nodata(v,i));
        %N(t,v,N_v_nodata(v,i))=N_ratio(t,v,N_v_nodata(v,i)).*N_total(N_total_nodata(i));
        end
	end
end
end
end

%{
%No longer used

%Needs static traffic volume ratios and recalculates if values are positive
%Reads data directly without checking
    r_v(he)=A.data.Statictraffic(1,1);
    r(st,he)=A.data.Statictraffic(1,2);
    r(wi,he)=A.data.Statictraffic(1,3);
    r(su,he)=A.data.Statictraffic(1,4);
    r_v(li)=A.data.Statictraffic(2,1);
    r(st,li)=A.data.Statictraffic(2,2);
    r(wi,li)=A.data.Statictraffic(2,3);
    r(su,li)=A.data.Statictraffic(2,4);

%Convert from total traffic
for v=1:num_veh,
    if r_v(v)>=0,
       N_v(v,:)=N_total(:).*r_v(v); 
    end
end
for t=1:num_tyre,
for v=1:num_veh,
    if r(t,v)>=0,
       N(t,v,:)=N_v(v,:).*r(t,v); 
    end
end
end
%}

%Read Traffic data dates
if read_inputdata_as_text==0,
else
    clear A_temp
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_meteorology.txt'];
    else
        filename_txt=[filename,'_meteorology.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    A_temp = importdata(filename_txt,'\t');
    A.textdata.Meteorology=A_temp.textdata;
    A.data.Meteorology=A_temp.data;
end

%Read in meteorological data
clear T_a T2_a FF DD RH Rain Snow short_rad_in long_rad_in cloud_cover road_wetness_obs road_temperature_obs T_sub T_dewpoint Pressure_a;
header_text=A.textdata.Meteorology(1,:);
text='T2m';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
T_a(:,1)=A.data.Meteorology(:,k2(1));
text='T25m';%This is optional and not listed in the documentation
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),T2_a(:,1)=A.data.Meteorology(:,k2(1));T2_a_available=1;else T2_a_available=0;T2_a=T_a*0;end
text='FF';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
FF(:,1)=A.data.Meteorology(:,k2(1));
text='DD';%This is optional and not listed in the documentation
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),DD(:,1)=A.data.Meteorology(:,k2(1));DD_available=1;else DD_available=0;DD=FF*0;end
text='RH';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),RH(:,1)=A.data.Meteorology(:,k2(1));RH_available=1;else RH_available=0;end
text='T2m dewpoint';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),T_dewpoint(:,1)=A.data.Meteorology(:,k2(1));T_dewpoint_available=1;else T_dewpoint_available=0;end
text='Rain';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
Rain(:,1)=A.data.Meteorology(:,k2(1));
text='Snow';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
Snow(:,1)=A.data.Meteorology(:,k2(1));
text='Global radiation';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),short_rad_in(:,1)=A.data.Meteorology(:,k2(1));short_rad_in_available=1;else short_rad_in_available=0;short_rad_in=T_a*0;end
text='Longwave radiation';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),long_rad_in(:,1)=A.data.Meteorology(:,k2(1));long_rad_in_available=1;else long_rad_in_available=0;long_rad_in=T_a*0;end
text='Cloud cover';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),cloud_cover(:,1)=A.data.Meteorology(:,k2(1));cloud_cover_available=1;else cloud_cover_available=0;cloud_cover_in=T_a*0;end
text='Road wetness';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),road_wetness_obs(1,:)=A.data.Meteorology(:,k2(1));road_wetness_obs_available=1;else road_wetness_obs_available=0;road_wetness_obs=T_a*NaN;end
text='Road surface temperature';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),road_temperature_obs(:,1)=A.data.Meteorology(:,k2(1));road_temperature_obs_available=1;else road_temperature_obs_available=0;road_temperature_obs=T_a*NaN;end
text='Pressure';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),Pressure_a(:,1)=A.data.Meteorology(:,k2(1));pressure_obs_available=1;else Pressure_a(1:n_date,1)=Pressure;pressure_obs_available=1;end
text='T subsurface';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),T_sub(:,1)=A.data.Meteorology(:,k2(1));T_sub_available=1;else T_sub=T_a*0+nodata;T_sub_available=0;end

%Check data and fill missing with previous
r=find(T_a==nodata|isnan(T_a));
T_a_nodata=[];
for i=1:length(r),
	T_a(r(i))=T_a(r(i)-1);
    T_a_nodata(i)=r(i);
end
r=find(FF==nodata|isnan(FF));
FF_nodata=[];
for i=1:length(r),
	FF(r(i))=FF(r(i)-1);
    FF_nodata(i)=r(i);
end
%Correct wind speed
FF=FF*wind_speed_correction;

r=find(RH==nodata|isnan(RH));
RH_nodata=[];
for i=1:length(r),
	RH(r(i))=RH(r(i)-1);
    RH_nodata(i)=r(i);
end
%Remove negative values in RH
r=find(RH~=nodata);
RH=max(RH(r),0);

r=find(Rain==nodata|isnan(Rain));
Rain_nodata=[];
for i=1:length(r),
	Rain(r(i))=Rain(r(i)-1);
    Rain_nodata(i)=r(i);
end
%Remove negative values in RH
r=find(Rain~=nodata);
Rain=max(Rain(r),0);
r=find(Snow==nodata|isnan(Snow));
Snow_nodata=[];
for i=1:length(r),
	Snow(r(i))=Snow(r(i)-1);
    Snow_nodata(i)=r(i);
end
r=find(Snow~=nodata);
Snow=max(Snow(r),0);
if DD_available,
r=find(DD==nodata|isnan(DD));
DD_nodata=[];
if length(r)==length(DD),
    DD_availabe=0;
else
for i=1:length(r),
	DD(r(i))=DD(r(i)-1);
    DD_nodata(i)=r(i);
end
end
end
if T2_a_available,
r=find(T2_a==nodata|isnan(T2_a));
T2_a_nodata=[];
if length(r)==length(T2_a),
    T2_a_availabe=0;
else
for i=1:length(r),
	T2_a(r(i))=T2_a(r(i)-1);
    T2_a_nodata(i)=r(i);
end
end
end
if T_sub_available,
r=find(T_sub==nodata|isnan(T_sub));
T_sub_nodata=[];
if length(r)==length(T_sub),
    T_sub_availabe=0;
else
for i=1:length(r),
	T_sub(r(i))=T_sub(r(i)-1);
    T_sub_nodata(i)=r(i);
end
end
end

%Special test to remove constant surface temperature values

if road_temperature_obs_available,
for i=length(road_temperature_obs)-1:-1:1,
	if road_temperature_obs(i)==road_temperature_obs(i+1),
        road_temperature_obs(i+1)=nodata;
    end
end
end

%Check for all no data
if short_rad_in_available,
    [short_rad_in,short_rad_in_available,short_rad_in_missing] = check_data_func(short_rad_in,short_rad_in_available,nodata);
end
if long_rad_in_available,
    [long_rad_in,long_rad_in_available,long_rad_in_missing] = check_data_func(long_rad_in,long_rad_in_available,nodata);
end
if cloud_cover_available,
    [cloud_cover,cloud_cover_available,cloud_cover_missing] = check_data_func(cloud_cover,cloud_cover_available,nodata);
end
if road_wetness_obs_available,
    [road_wetness_obs,road_wetness_obs_available,road_wetness_obs_missing] = check_data_func(road_wetness_obs,road_wetness_obs_available,nodata);
end
if road_temperature_obs_available,
    [road_temperature_obs,road_temperature_obs_available,road_temperature_obs_missing] = check_data_func(road_temperature_obs,road_temperature_obs_available,nodata);
end
if pressure_obs_available,
    [Pressure_a,pressure_obs_available,pressure_obs_missing] = check_data_func(Pressure_a,pressure_obs_available,nodata);
end
%If pressure is full of nodata then use the default from the metadata
if pressure_obs_available==0,
    Pressure_a(:)=Pressure;
end

%Fill in
if road_wetness_obs_available,
r=find(road_wetness_obs==nodata|isnan(road_wetness_obs));
%for i=1:length(r),
%	road_wetness_obs(r(i))=road_wetness_obs(r(i)-1);
%    road_wetness_obs_nodata(i)=r(i);
%end
end
%Convert road wetness signal to a retention signal
road_wetness_obs_in_mm=0;
if road_wetness_obs_available,
    k2 = strmatch('Road wetness',header_text);
    temp_str=header_text(k2(1));
    k3 = strfind(char(temp_str),'(mm)');
    if ~isempty(k3),road_wetness_obs_in_mm=1;end
    max_road_wetness_obs=max(road_wetness_obs);
    min_road_wetness_obs=min(road_wetness_obs);
end
if road_wetness_obs_available,
    max_road_wetness_obs=max(road_wetness_obs);
    min_road_wetness_obs=min(road_wetness_obs);
    mean_road_wetness_obs=mean(road_wetness_obs);
else
    max_road_wetness_obs=nodata;
    min_road_wetness_obs=nodata;
    mean_road_wetness_obs=nodata;
end

if RH_available&&~T_dewpoint_available,
    T_dewpoint=dewpoint_from_RH_func(T_a,RH);
end
if T_dewpoint_available&&~RH_available,
    RH=RH_from_dewpoint_func(T_a,T_dewpoint);
end

%Read in activity dates
if read_inputdata_as_text==0,
else
    clear A_temp
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_activity.txt'];
    else
        filename_txt=[filename,'_activity.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    A_temp = importdata(filename_txt,'\t');
    A.textdata.Activity=A_temp.textdata;
    A.data.Activity=A_temp.data;
end

%Read in activity dates
clear year_act month_act day_act hour_act minute_act
if isfield(A.data,'Activity')
header_text=A.textdata.Activity(1,:);
text='Year';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
year_act=A.data.Activity(:,k2(1));
text='Month';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
month_act=A.data.Activity(:,k2(1));
text='Day';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
day_act=A.data.Activity(:,k2(1));
text='Hour';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
hour_act=A.data.Activity(:,k2(1));
text='Minute';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),minute_act=A.data.Activity(:,k2(1));else minute_act=year_act*0;end

n_act=length(year_act);

%Read in activity data
clear M_sanding M_salting t_ploughing t_cleaning g_road_wetting M_fugitive
clear M_sanding_input M_salting_input t_ploughing_input t_cleaning_input g_road_wetting_input M_fugitive_input
header_text=A.textdata.Activity(1,:);
text='M_sanding';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_sanding(:,1)=A.data.Activity(:,k2(1));else M_sanding(1:n_act,1)=0;end
text='M_salting(na)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_salting(1,:)=A.data.Activity(:,k2(1));else M_salting(1,1:n_act)=0;end
text='M_salting(mg)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_salting(2,:)=A.data.Activity(:,k2(1));second_salt_type=mg;second_salt_available=1;else M_salting(2,1:n_act)=0;second_salt_available=0;end
if second_salt_available==0,%Only look for cma if mg is not available
text='M_salting(cma)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_salting(2,:)=A.data.Activity(:,k2(1));second_salt_type=cma;second_salt_available=1;else M_salting(2,1:n_act)=0;second_salt_available=0;end
end
if second_salt_available==0,%Only look for ca if mg is not available
text='M_salting(ca)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_salting(2,:)=A.data.Activity(:,k2(1));second_salt_type=ca;second_salt_available=1;else M_salting(2,1:n_act)=0;second_salt_available=0;end
end
text='Wetting';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
g_road_wetting_available=0;
if ~isempty(k2),g_road_wetting(:,1)=A.data.Activity(:,k2(1));g_road_wetting_available=1;else g_road_wetting(1:n_act)=0;end
text='Ploughing_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
t_ploughing(:,1)=A.data.Activity(:,k2(1));
text='Cleaning_road';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
t_cleaning(:,1)=A.data.Activity(:,k2(1));
text='Fugitive';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),M_fugitive(:,1)=A.data.Activity(:,k2(1));else M_fugitive(1:n_act,1)=0;end

%Set the second salt type for use in solution calculation. First type is always NaCl
salt2_str='';
if second_salt_type==cma,salt2_str='cma';end
if second_salt_type==mg,salt2_str='mg';end
if second_salt_type==ca,salt2_str='ca';end
salt_type(1)=na;
salt_type(2)=second_salt_type;

%If the activity dates do not correspond to the traffic dates then fill in
%This allows just the dates for activity to be put in, simpler for input
if length(year_act)~=length(year),
    if print_results,
        fprintf('Redistributing activity input data\n');
    end
    n_traf=length(year);
    n_act=length(year_act);
    %Set everything to 0
    clear M_sanding_act M_fugitive_act M_salting_act t_ploughing_act t_cleaning_act g_road_wetting_act
    M_sanding_act=M_sanding;
    M_fugitive_act=M_fugitive;
    M_salting_act=M_salting;
    g_road_wetting_act=g_road_wetting;
    t_ploughing_act=t_ploughing;
    t_cleaning_act=t_cleaning;
    clear M_sanding M_salting t_ploughing t_cleaning g_road_wetting M_fugitive
    M_sanding(:,1)=zeros(n_traf,1);
    M_fugitive(:,1)=zeros(n_traf,1);
    M_salting(1,:)=zeros(1,n_traf);
    M_salting(2,:)=zeros(1,n_traf);
    g_road_wetting(:,1)=zeros(n_traf,1);
    t_ploughing(:,1)=zeros(n_traf,1);
    t_cleaning(:,1)=zeros(n_traf,1);
    
    for i=1:n_act;
        r=find(year_act(i)==year&month_act(i)==month&day_act(i)==day&hour_act(i)==hour&minute_act(i)==minute);
        if length(r)==1;
            M_sanding(r,1)=M_sanding_act(i,1)+M_sanding(r,1);
            M_fugitive(r,1)=M_fugitive_act(i,1)+M_fugitive(r,1);
            M_salting(1,r)=M_salting_act(1,i)+M_salting(1,r);
            M_salting(2,r)=M_salting_act(2,i)+M_salting(2,r);
            g_road_wetting(r,1)=g_road_wetting_act(i,1)+g_road_wetting(r,1);
            t_ploughing(r,1)=t_ploughing_act(i,1)+t_ploughing(r,1);
            t_cleaning(r,1)=t_cleaning_act(i,1)+t_cleaning(r,1);     
        elseif length(r)>1,
            if print_results,
                fprintf('Problem with activity input data\n');
            end
        end
        
    end
end

else
    clear M_sanding M_salting t_ploughing t_cleaning g_road_wetting M_fugitive salt_type
    M_salting(1:2,1:n_date)=0;
    g_road_wetting(1:n_date)=0;
    M_sanding(1:n_date)=0;
    t_ploughing(1:n_date)=0;
    t_cleaning(1:n_date)=0;   
    M_fugitive(1:n_date)=0;
    
    salt_type(1)=na;
    salt_type(2)=mg;
    salt2_str='mg';


end %if Activity field for data exists

M_salting_input=M_salting;
g_road_wetting_input=g_road_wetting;
M_sanding_input=M_sanding;
t_ploughing_input=t_ploughing;
t_cleaning_input=t_cleaning;   
M_fugitive_input=M_fugitive;


%Read in air quality data
if read_inputdata_as_text==0,
else
    clear A_temp
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_airquality.txt'];
    else
        filename_txt=[filename,'_airquality.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    A_temp = importdata(filename_txt,'\t');
    A.textdata.Airquality=A_temp.textdata;
    A.data.Airquality=A_temp.data;
end

%Read in air quality data
clear PM_obs PM_background NOX_obs NOX_background NOX_emis EP_emis Salt_obs f_dis_input
PM_obs([pm_10 pm_25],1:n_date)=nodata;
PM_background([pm_10 pm_25],1:n_date)=nodata;
NOX_obs(1:n_date,1)=nodata;
NOX_background(1:n_date,1)=nodata;
header_text=A.textdata.Airquality(1,:);
NOX_emis(1:n_date,1)=nodata;
EP_emis(1:n_date,1)=nodata;
text='PM10_obs';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),PM_obs(pm_10,:)=A.data.Airquality(:,k2(1));end
text='PM10_background';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),PM_background(pm_10,:)=A.data.Airquality(:,k2(1));end
%text='PM10_bg';
%k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
%if ~isempty(k2),PM_background(pm_10,:)=A.data.Airquality(:,k2);end
text='PM25_obs';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),PM_obs(pm_25,:)=A.data.Airquality(:,k2(1));end
text='PM25_background';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),PM_background(pm_25,:)=A.data.Airquality(:,k2(1));end
%text='PM25_bg';
%k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
%if ~isempty(k2),PM_background(pm_25,:)=A.data.Airquality(:,k2);end
text='NOX_obs';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),NOX_obs(:,1)=A.data.Airquality(:,k2(1));end
text='NOX_background';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),NOX_background(:,1)=A.data.Airquality(:,k2(1));end
%text='NOX_bg';
%k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
%if ~isempty(k2),NOX_background(:,1)=A.data.Airquality(:,k2);end
text='NOX_emis';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
NOX_emis_available=0;
if ~isempty(k2),NOX_emis(:,1)=A.data.Airquality(:,k2(1)); NOX_emis_available=1;end
text='EP_emis';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
EP_emis_available=0;
if ~isempty(k2),EP_emis(:,1)=A.data.Airquality(:,k2(1));EP_emis_available=1;end
text='Salt_obs(na)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
Salt_obs_available(na)=0;
if ~isempty(k2),Salt_obs(na,:)=A.data.Airquality(:,k2(1));Salt_obs_available(na)=1;end
text='Disp_fac';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),f_dis_input(:,1)=A.data.Airquality(:,k2(1));f_dis_available=1;else f_dis_available=0;f_dis_input(1:n_date)=nodata;end

%if f_dis_available,
%r=find(f_dis==nodata|isnan(f_dis));
%f_dis_nodata=[];
%for i=1:length(r),
%	f_dis(r(i))=f_dis(r(i)-1);
%    f_dis_nodata(i)=r(i);
%end
%end

r=find(isnan(PM_obs));rr=find(PM_obs==nodata);
PM_obs(r)=nodata;
%if length(r)==length(PM_obs)||length(rr)==length(PM_obs),PM_obs_available=0;end
r=find(isnan(PM_background));rr=find(PM_background==nodata);
PM_background(r)=nodata;
%if length(r)==length(PM_background)||length(rr)==length(PM_background),PM_background_available=0;end
r=find(isnan(NOX_obs));rr=find(NOX_obs==nodata);
NOX_obs(r)=nodata;
%if length(r)==length(NOX_obs)||length(rr)==length(NOX_obs),NOX_obs_available=0;end
r=find(isnan(NOX_background));rr=find(NOX_background==nodata);
NOX_background(r)=nodata;
%if length(r)==length(NOX_background)||length(rr)==length(NOX_background),NOX_background_available=0;end
r=find(isnan(NOX_emis));rr=find(NOX_emis==nodata);
NOX_emis(r)=nodata;
if length(r)==length(NOX_emis)||length(rr)==length(NOX_emis),NOX_emis_available=0;end
r=find(isnan(EP_emis));rr=find(EP_emis==nodata);
EP_emis(r)=nodata;
if length(r)==length(EP_emis)||length(rr)==length(EP_emis),EP_emis_available=0;end
if Salt_obs_available(na),
    r=find(isnan(Salt_obs(na,:)));
    Salt_obs(na,r)=nodata;
end

%Replaces emission data when there is no traffic data (as this is usually
%coupled)
if ~isempty(N_total_nodata),
    [x_str xplot yplot]=Average_data_func(date_num(N_good_data),NOX_emis(N_good_data),1,length(N_good_data),3);
	for i=1:length(N_total_nodata),
        for j=1:24,
            if hour(N_total_nodata(i))==xplot(j),
                NOX_emis(N_total_nodata(i))=yplot(j);
            end
        end
	end
    [x_str xplot yplot]=Average_data_func(date_num(N_good_data),EP_emis(N_good_data),1,length(N_good_data),3);
	for i=1:length(N_total_nodata),
        for j=1:24,
            if hour(N_total_nodata(i))==xplot(j),
                EP_emis(N_total_nodata(i))=yplot(j);
            end
        end
	end
end

%Calculate the net concentrations for PM and NOX here
clear PM_obs_net PM_obs_bg NOX_obs_net
PM_obs_net(1:num_size,1:n_date)=NaN;   
PM_obs_bg(1:num_size,1:n_date)=NaN;   
NOX_obs_net(1:num_size,1:n_date)=NaN;   
for ti=1:1:n_date,
    for x=pm_10:pm_25,
    if PM_obs(x,ti)~=nodata&&PM_background(x,ti)~=nodata,
        PM_obs_net(x,ti)=PM_obs(x,ti)-PM_background(x,ti);
    else
        PM_obs_net(x,ti)=nodata;
    end
    if PM_obs_net(x,ti)<=0,
        PM_obs_net(x,ti)=nodata;
    end
    end

    %Rewrite background concentrations for consistency
    for x=pm_10:pm_25,
        PM_obs_bg(x,ti)=PM_background(x,ti);
    end
    
    %Set net NOX concentrations
    if NOX_obs(ti)~=nodata&&NOX_background(ti)~=nodata,
        NOX_obs_net(ti)=NOX_obs(ti)-NOX_background(ti);
    else
        NOX_obs_net(ti)=nodata;
    end
    if NOX_obs_net(ti)<=0,
        NOX_obs_net(ti)=nodata;
    end
    
end

%Read OSPM data if it exists
OSPM_data_exists=0;
if isfield(A.textdata,'OSPM'),
header_text=A.textdata.OSPM(1,:);
OSPM_data_exists=1;

text='FF ospm (m/s)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),U_mast_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='DD ospm (deg)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),wind_dir_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='TK ospm (deg K)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),TK_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='Global radiation ospm (W/m^2)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),GlobalRad_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='C background ospm (ug/m^3)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),cNOx_b_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='N(li) ospm';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),NNp_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='N(he) ospm';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),NNt_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='V_veh(li) ospm (km/hr)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),Vp_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='V_veh(he) ospm (km/hr)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),Vt_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end

text='C emis ospm (ug/m/s)';
k2 = strmatch(text,header_text);if length(k2)>1,message_str=['Double occurence of input data header ',text,': USING THE FIRST'];if print_results,fprintf('%s\n',message_str);end;end
if ~isempty(k2),qNOX_ospm_orig(:,1)=A.data.OSPM(:,k2(1));end


r=find(U_mast_ospm_orig<0|isnan(U_mast_ospm_orig));
U_mast_ospm_orig(r)=nodata;

r=find(wind_dir_ospm_orig<0|isnan(wind_dir_ospm_orig));
wind_dir_ospm_orig(r)=nodata;

r=find(TK_ospm_orig<0|isnan(TK_ospm_orig));
TK_ospm_orig(r)=nodata;

r=find(GlobalRad_ospm_orig<0|isnan(GlobalRad_ospm_orig));
GlobalRad_ospm_orig(r)=nodata;

r=find(cNOx_b_ospm_orig<0|isnan(cNOx_b_ospm_orig));
cNOx_b_ospm_orig(r)=nodata;

r=find(NNp_ospm_orig<0|isnan(NNp_ospm_orig));
NNp_ospm_orig(r)=nodata;

r=find(NNt_ospm_orig<0|isnan(NNt_ospm_orig));
NNt_ospm_orig(r)=nodata;

r=find(Vp_ospm_orig<0|isnan(Vp_ospm_orig));
Vp_ospm_orig(r)=nodata;

r=find(Vt_ospm_orig<0|isnan(Vt_ospm_orig));
Vt_ospm_orig(r)=nodata;

r=find(qNOX_ospm_orig<0|isnan(qNOX_ospm_orig));
qNOX_ospm_orig(r)=nodata;

end

%Clear this since it is also a function used later
clear text


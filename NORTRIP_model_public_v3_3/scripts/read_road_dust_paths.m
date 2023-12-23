%==========================================================================
%NORTRIP model
%SUBROUTINE: read_road_dust_paths
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Reads in paths and filenames from the modelrun file
%==========================================================================

%Initialise
path_inputparam='';    
path_inputdata='';    
path_outputdata='';    
path_outputfig='';    
path_ospm='';
path_fortran='';
path_fortran_output='';
filename_inputparam='';    
filename_inputdata='';    
filename_outputdata='';    
filename_outputfigures='';    

%Need to check for key words here. Not done yet
if read_infofile_as_text==0
    filename=[root_path,path_modelrun_data,filename_modelrun_data];
    fprintf('Reading info file and setting paths from excel\n');
    road_dust_info_file=1;
    if ~exist(filename),
        hf=errordlg(['File ',filename, ' does not exist.'],'File error');
        road_dust_info_file=0;
        return
    end
else
    %Set file name by removing the data type and replacing with '.txt'
    filename=[root_path,path_modelrun_data,filename_modelrun_data];
    k=strfind(filename,[dir_del,'text',dir_del]);
    if isempty(k),
        filename=[root_path,path_modelrun_data,['text',dir_del],filename_modelrun_data];
    end
    fprintf('Reading info file and setting paths from text\n');
end

if read_infofile_as_text==0,
    A = importdata(filename,'\t');
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'.txt'];
    else
        filename_txt=[filename,'.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        road_dust_info_file=0;
        return
    else
        road_dust_info_file=1;
    end
    clear A_temp
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp(i,1)=A_line{1}(1);
        if size(A_line{1},1)>1,
            A_temp(i,2)=A_line{1}(2);
        else
            A_temp(i,2)={''};
        end
    end
    fclose(fid);
    A=A_temp;
end

header_text=A(:,1);
file_text=A(:,2);


text='Model input parameter path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_inputparam=char(file_text(k2));
end
text='Model input data path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_inputdata=char(file_text(k2));
end
text='Model output data path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_outputdata=char(file_text(k2));
end
text='Model output figures path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_outputfig=char(file_text(k2));
end
text='Model parameter filename';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    filename_inputparam=char(file_text(k2));
end
text='Model input data filename';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    filename_inputdata=char(file_text(k2));
end
text='Model output data filename';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    filename_outputdata=char(file_text(k2));
    if isempty(filename_outputdata),
        filename_outputdata='';
    end
else
    filename_outputdata='';
end

text='Model ospm path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_ospm=char(file_text(k2));
end
text='Model fortran path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_fortran=char(file_text(k2));
else
    %automatically set using output data path name
    k=strfind(path_outputdata,'output');
    path_fortran=[path_outputdata(1:k-1),'fortran\'];
end
text='Model fortran output path';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    path_fortran_output=char(file_text(k2));
else
    %automatically set using output data path name
    k=strfind(path_outputdata,'output');
    path_fortran_output=[path_outputdata(1:k-1),'fortran\output\'];
end
text='Log file name';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    filename_log=char(file_text(k2));
else
    %automatically sets to fortran path
    filename_log=[path_fortran,'NORTRIP_log.txt'];
end
text='Model fortran executable filename';
k2 = strmatch(text,header_text);
if ~isempty(k2),
    file_fortran_exe=char(file_text(k2));
else
    file_fortran_exe='nortrip';
end

%text='Model output data filename';
%k2 = strmatch(text,header_text);
%if ~isempty(k2),
%    filename_outputdata=char(file_text(k2));
%end
%text='Model output figures filename';
%k2 = strmatch(text,header_text);
%if ~isempty(k2),
%    filename_outputfigures=char(file_text(k2));
%end

%Set title string by removing everything after the . of the input data file
k = findstr(filename_inputdata,'.');
title_str=filename_inputdata(1:k-1);
%If the words "input data" occur then remove everything after those as well
k2 = findstr(title_str,'input data');
if k2>0, title_str=filename_inputdata(1:k2-2);end

%Initial filenames of the input data
path_filename_inputparam=[path_inputparam,filename_inputparam];
path_filename_inputdata=[path_inputdata,filename_inputdata];
path_filename_modelrun_data=[path_modelrun_data,filename_modelrun_data];



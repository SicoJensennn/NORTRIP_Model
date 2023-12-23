%==========================================================================
%NORTRIP model
%SUBROUTINE: save_road_dust_paths_text_v1.m
%VERSION: 1, 06.08.2014
%AUTHOR: Bruce Rolstad Denby (bruce.denby@met.no)
%DESCRIPTION: Saves model parameters for the NORTRIP model to ascii files
%==========================================================================

%Set common constants
road_dust_set_constants_v2

filename=[root_path,path_modelrun_data,filename_modelrun_data];
k=strfind(filename,[dir_del,'text',dir_del]);
if isempty(k),
    filename=[root_path,path_modelrun_data,['text',dir_del],filename_modelrun_data];
end

%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename,'.');
if ~isempty(k),
    filename_txt=[filename(1:k-1),'.txt'];
else
    filename_txt=[filename,'.txt'];
end

fortran_info_file=filename_txt;

%Open the file for writing
fid_input_txt=fopen(filename_txt,'w');

fprintf(fid_input_txt,'%-44s\n','NORTRIP model text path and file names (model run info)');
fprintf(fid_input_txt,'%-44s\n','-------------------------------------------------------');
fprintf(fid_input_txt,'%-44s\t%-s\n','Path or filename','String');

text='Model input parameter path';val=path_inputparam;
k=strfind(val,[dir_del,'text',dir_del]);if isempty(k),val=[val,['text',dir_del]];end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model input data path';val=path_inputdata;
k=strfind(val,[dir_del,'text',dir_del]);if isempty(k),val=[val,['text',dir_del]];end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model output data path';val=path_outputdata;
k=strfind(val,[dir_del,'text',dir_del]);if isempty(k),val=[val,['text',dir_del]];end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model output figures path';val=path_outputfig;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model parameter filename';val=filename_inputparam;
k=strfind(val,'.');if ~isempty(k),val=filename_inputparam(1:k-1);end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model input data filename';val=filename_inputdata;
k=strfind(val,'.');if ~isempty(k),val=filename_inputdata(1:k-1);end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model output data filename';val=filename_outputdata;
k=strfind(val,'.');if ~isempty(k),val=filename_outputdata(1:k-1);end
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model ospm path';val=path_ospm;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model fortran path';val=path_fortran;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model fortran output path';val=path_fortran_output;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Log file name';val=filename_log;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

text='Model fortran executable filename';val=file_fortran_exe;
fprintf(fid_input_txt,'%-44s\t%-s\n',text,val);

%Close the file
fclose(fid_input_txt);

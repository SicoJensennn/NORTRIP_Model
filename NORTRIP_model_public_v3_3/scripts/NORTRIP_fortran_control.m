%This routine uses Matlab as a script and runs the executable

save_inputfiles_text=1;

%Do not save input files as text if it is reading them
if read_inputdata_as_text,
    save_inputfiles_text=0;
end

%Do not save info file as text if it reads it
if read_infofile_as_text==0,
    fprintf('%s\n','Saving text info file');
    save_road_dust_paths_text_v1
else
    fprintf('%s\n','Using saved info file');
end

%Do not save parameter file as text if it reads it
if read_parameters_as_text==0,
    fprintf('%s\n','Saving text parameter files');
    save_road_dust_parameters_text_v2
else
    fprintf('%s\n','Using saved text parameter files');
end

if save_inputfiles_text,
    fprintf('%s\n','Saving text input data files');
    save_road_dust_input_text_v1
else
    fprintf('%s\n','Using saved text input data files');
end

%Run NORTRIP_fortran from shell
%--------------------------------------------------------------------------
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

%Copy the info file to the executable directory to make it available for the command call
fortran_info_file=filename_txt;
copyfile(fortran_info_file,[path_fortran,'fortran_command_info_file.txt']);

cd(root_path);
current_path=pwd;
cd(path_fortran);

s_fortran=1;
w_fortran='Did not run NORTRIP_fortran at all';
if only_show_fortran_results==0,
    fprintf('%s\n','Running NORTRIP_fortran');
    [s_fortran, w_fortran]=system([file_fortran_exe,' fortran_command_info_file.txt'],'-echo');
    %[s_fortran, w_fortran]=dos(['NORTRIP_v3.2.exe',fortran_info_file],'-echo'); %This only works if there are no spacesin the file name
else
    fprintf('%s\n','Not running NORTRIP_fortran, only reading');
end

cd(current_path);
%--------------------------------------------------------------------------

fprintf('%s\n','Reading NORTRIP_fortran output');
read_NORTRIP_fortran_output;

%Carry out some conversions that were not complete between the two
%programmes


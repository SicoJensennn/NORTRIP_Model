%==========================================================================
%NORTRIP model
%SUBROUTINE: save_road_dust_parameters_text_v2
%VERSION: 2, 20.02.2015
%AUTHOR: Bruce Rolstad Denby (bruce.denby@met.no)
%DESCRIPTION: Saves model parameters for the NORTRIP model to ascii files
%==========================================================================

%Set common constants
road_dust_set_constants_v2

k=strfind(path_inputparam,[dir_del,'text',dir_del]);
if isempty(k),
    path_inputparam_text=[path_inputparam,['text',dir_del]];
else
    path_inputparam_text=path_inputdata;
end

%--------------------------------------------------------------------------
%Save parameter file
%--------------------------------------------------------------------------
%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputparam,'.');
if ~isempty(k),
    filename_inputparam_txt=[filename_inputparam(1:k-1),'_params.txt'];
else
    filename_inputparam_txt=[filename_inputparam,'_params.txt'];
end
filename=[path_inputparam_text,filename_inputparam_txt];

%Convert input file to array
clear bp bd
bp=input_param.textdata.Parameters(:,1:6);
bd=input_param.data.Parameters(:,1:6);
for i=1:size(bp,1),
for j=1:size(bp,2),
    if ~isnan(bd(i,j)),
        bp{i,j}=num2str(bd(i,j));
    end
end
end
    
%Open file for writing
fid_param_txt=fopen(filename,'w');
    
    %Write  new header
    fprintf(fid_param_txt,'%-64s\n','NORTRIP model text parameter file (params)');
    fprintf(fid_param_txt,'%-64s\n','-----------------------------------------');
    fprintf(fid_param_txt,'%-64s\n','Tab seperated. 48 and 24 characters');
    fprintf(fid_param_txt,'%-64s\n','Check log file to assess proper reading');
    fprintf(fid_param_txt,'%-64s\n','-----------------------------------------');
    
    %Miss out old header header line
    for i=2:size(bp,1),
        for j=1:size(bp,2),
            if j==1,
                format_str='%-48s\t';
            elseif j==6, %This is the maximum width. Do this to avoid a tab at the end
                format_str='%-24s';
            else
                format_str='%-24s\t';
            end
            fprintf(fid_param_txt,format_str,char(bp{i,j}));
        end
            fprintf(fid_param_txt,'\n');
    end
    
fclose(fid_param_txt);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Save flags file
%--------------------------------------------------------------------------
%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputparam,'.');
if ~isempty(k),
    filename_inputparam_txt=[filename_inputparam(1:k-1),'_flags.txt'];
else
    filename_inputparam_txt=[filename_inputparam,'_flags.txt'];
end
filename=[path_inputparam_text,filename_inputparam_txt];

clear bp bd
bp=input_param.textdata.Flags(:,1:3);
bd=input_param.data.Flags(:,1:2);
for i=1:size(bp,1),
for j=1:size(bp,2)-1,
    if ~isnan(bd(i,j)),
        bp{i,j+1}=num2str(bd(i,j));
    end
end
end

%Open file for writing
fid_param_txt=fopen(filename,'w');
    
    %Write  new header
    fprintf(fid_param_txt,'%-64s\n','NORTRIP model text parameter file (flags)');
    fprintf(fid_param_txt,'%-64s\n','-----------------------------------------');

    %Miss out old header header line
    for i=1:size(bp,1),
        for j=1:size(bp,2),
            if j==1,
                format_str='%-32s\t';
            elseif j==2,
                format_str='%-12s\t';
            else
                format_str='%-128s';
            end
            fprintf(fid_param_txt,format_str,char(bp{i,j}));
        end
            fprintf(fid_param_txt,'\n');
    end
    
fclose(fid_param_txt);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Save activity file
%--------------------------------------------------------------------------
%Set file name by removing the data type and replacing with '.txt'
k=strfind(filename_inputparam,'.');
if ~isempty(k),
    filename_inputparam_txt=[filename_inputparam(1:k-1),'_activities.txt'];
else
    filename_inputparam_txt=[filename_inputparam,'_activities.txt'];
end
filename=[path_inputparam_text,filename_inputparam_txt];

clear bp bd
bp=input_param.textdata.Activities(:,1:3);
bd=input_param.data.Activities(:,1);
j=1;
for i=1:size(bp,1),
%for j=1:size(bp,2)-1,
    if ~isnan(bd(i,j)),
        bp{i,j+1}=num2str(bd(i,j));
    end
%end
end

%Open file for writing
fid_param_txt=fopen(filename,'w');
    
    %Write  new header
    fprintf(fid_param_txt,'%-64s\n','NORTRIP model text parameter file (activities)');
    fprintf(fid_param_txt,'%-64s\n','----------------------------------------------');

    %Miss out old header header line
    for i=1:size(bp,1),
        for j=1:size(bp,2),
            if j==1,
                format_str='%-32s\t';
            elseif j==2,
                format_str='%-12s\t';
            else
                format_str='%-128s';
            end
            fprintf(fid_param_txt,format_str,char(bp{i,j}));
        end
            fprintf(fid_param_txt,'\n');
    end
    
fclose(fid_param_txt);
%--------------------------------------------------------------------------

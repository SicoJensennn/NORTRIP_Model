%==========================================================================
%NORTRIP model
%SUBROUTINE: read_road_dust_parameters_v3
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Reads in model parameters for the NORTRIP model
%==========================================================================

%Set common constants
road_dust_set_constants_v2

%Define parameters

%Clear arrays
clear W_0 a_wear h_pave_str h_pave h_drivingcycle_str h_drivingcycle
clear h_0_sus h_0_q_road f_0_suspension a_sus
clear h_0_abrasion f_0_abrasion V_ref_abrasion p_0_abrasion
clear h_0_crushing f_0_crushing V_ref_crushing p_0_crushing 
clear f_0_dir f_PM f_PM_bin h_eff w_dep
clear R_0_spray V_ref_spray g_road_sprayable_min a_spray V_thresh_spray
clear h_ploughing_moisture ploughing_thresh
clear sub_surf_param a_traffic H_veh
clear g_retention_thresh g_retention_min texture_scaling
clear f_track veh_track num_track track_type

%Allocate parameters
W_0(1:num_wear,1:num_tyre,1:num_veh)=0;
a_wear(1:num_wear,1:5)=0;%a1,a2,a3,V_ref,V_min
s_roadwear_thresh=0;
num_pave=1;%reallocated
h_pave_str{1:num_pave}=0;
h_pave(1:num_pave)=0;
num_dc=1;%reallocated
h_drivingcycle_str{1:num_dc}=0;
h_drivingcycle(1:num_dc)=0;
h_0_sus(1:num_source,1:num_size)=0;
h_0_q_road(1:num_size)=0;
f_0_suspension(1:num_source,1:num_size,1:num_tyre,1:num_veh)=0;
a_sus(1:5)=0;
h_0_abrasion(1:num_size)=1;
f_0_abrasion(1:num_tyre,1:num_veh)=0;
V_ref_abrasion=0;
h_0_crushing(1:num_size)=1;
f_0_crushing(1:num_tyre,1:num_veh)=0;
p_0_crushing(1:num_source)=0;
p_0_abrasion(1:num_source)=0;
f_0_dir(1:num_source_all_extra)=1;
f_PM(1:num_source_all_extra,1:num_size,1:num_tyre)=0;
f_PM_bin(1:num_source_all_extra,1:num_size,1:num_tyre)=0;
V_ref_pm_fraction=0;
c_pm_fraction=0;
tau_wind=0;
FF_thresh=0;
h_eff(1:4,1:num_source,1:num_size)=0;
w_dep(1:num_size)=0;
conc_min=0;
emis_min=0;
R_0_spray(1:num_veh,num_moisture)=0;
V_ref_spray(1:num_moisture)=0;
g_road_sprayable_min(1:num_moisture)=0;
a_spray(1:num_moisture)=0;
V_thresh_spray(1:num_moisture)=0;
V_ref_spray=0;
g_road_drainable_min=0;
snow_dust_drainage_retainment_limit=0;
tau_road_drainage=0;
h_ploughing_moisture(1:num_moisture)=0;
ploughing_thresh(1:num_moisture)=0;
g_road_evaporation_thresh=0;
z0=0;
albedo_snow=0;
dzs=0;
sub_surf_param(1:3)=0;
a_traffic(1:num_veh)=0;
H_veh(1:num_veh)=0;
g_retention_thresh(1:num_source)=0;
g_retention_min(1:num_source)=0;
texture_scaling(1:5)=1;
num_track=1;%reallocated on the fly
f_track(1:num_track)=1;
veh_track(1:num_track)=1;
mig_track(1:num_track)=1;
track_type(1:num_track)=1;

if read_parameters_as_text==0
    filename=[path_inputparam,filename_inputparam];
    fprintf('Reading parameters from excel\n');

    input_exists_flag=1;
    if ~exist(filename),
        hf=errordlg(['File ',filename, ' does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
else
    %Set file name by removing the data type and replacing with '.txt'
    filename=[path_inputparam,filename_inputparam];
    k=strfind(filename,[dir_del,'text',dir_del]);
    if isempty(k),
        filename=[path_inputparam,['text',dir_del],filename_inputparam];
    end
    fprintf('Reading parameters from text\n');
end

%Read in file
if read_parameters_as_text==0,
    A = importdata(filename,'\t',0);
    input_param=A;
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_params.txt'];
    else
        filename_txt=[filename,'_params.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    clear A_temp A
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp.textdata(i,1)=A_line{1}(1);
        line_size=size(A_line{1},1);
        if line_size>1,
            for j=2:line_size,
                A_temp.textdata(i,j)=A_line{1}(j);
                num_temp=str2num(char(A_line{1}(j)));
                if ~isempty(num_temp),
                    A_temp.data(i,j)=num_temp;
                else
                    A_temp.data(i,j)=nan;
                end
            end
        else
        end
    end
    fclose(fid);
    A.data.Parameters=A_temp.data;
    A.textdata.Parameters=A_temp.textdata;
    input_param.data.Parameters=A_temp.data;
    input_param.textdata.Parameters=A_temp.textdata;
end


%find key text in the data to extract the values
%This means that each table can be placed anywhere in the file but that the
%table format must be consistent if information is to be extracted

header_text=A.textdata.Parameters(:,1);

%--------------------------------------------------------------------------
%Read road wear parameters
%--------------------------------------------------------------------------
for s=1:num_wear,
    if s==road_index, text='Road wear';end
    if s==tyre_index, text='Tyre wear';end
    if s==brake_index, text='Brake wear';end
    
    k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end
    if ~isempty(k2),
        W_0(s,st,he)=A.data.Parameters(k2+2,2);
        W_0(s,wi,he)=A.data.Parameters(k2+2,3);
        W_0(s,su,he)=A.data.Parameters(k2+2,4);
        W_0(s,st,li)=A.data.Parameters(k2+3,2);
        W_0(s,wi,li)=A.data.Parameters(k2+3,3);
        W_0(s,su,li)=A.data.Parameters(k2+3,4);
        for i=1:5,
            a_wear(s,i)=A.data.Parameters(k2+5,1+i);
        end
    else
        fprintf('Error in reading wear parameters. \n');
        return
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read Snow depth wear threshold
%--------------------------------------------------------------------------
text='Snow depth wear threshold';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        s_roadwear_thresh=A.data.Parameters(k2+2,2);
else
    fprintf('Error in reading snow depth wear threshold. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Pavement type scaling factors
%--------------------------------------------------------------------------
text='Pavement type scaling factor';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    num_pave=A.data.Parameters(k2+1,2);
    for p=1:num_pave,
        h_pave_str{p}=A.textdata.Parameters(k2+2+p,2);
        h_pave(p)=A.data.Parameters(k2+2+p,3);
    end
else
    fprintf('Error in reading pavement types. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Driving cycle scaling factors
%--------------------------------------------------------------------------
text='Driving cycle scaling factor';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    num_dc=A.data.Parameters(k2+1,2);
    for d=1:num_dc,
        h_drivingcycle_str{d}=A.textdata.Parameters(k2+2+d,2);
        h_drivingcycle(d)=A.data.Parameters(k2+2+d,3);
    end
else
    fprintf('Error in reading driving cycle types. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read Suspension scaling factors
%--------------------------------------------------------------------------
text='Suspension scaling factors';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        for x=1:num_size,
        for s=1:num_source,
            h_0_sus(s,x)=A.data.Parameters(k2+1+s,1+x);
        end
            h_0_q_road(x)=A.data.Parameters(k2+2+num_source,1+x);
        end
else
    fprintf('Error in reading suspendable fraction of sanding. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Road suspension factors
%--------------------------------------------------------------------------
text='Road suspension';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        f_0_suspension(1,1,st,he)=A.data.Parameters(k2+2,2);
        f_0_suspension(1,1,wi,he)=A.data.Parameters(k2+2,3);
        f_0_suspension(1,1,su,he)=A.data.Parameters(k2+2,4);
        f_0_suspension(1,1,st,li)=A.data.Parameters(k2+3,2);
        f_0_suspension(1,1,wi,li)=A.data.Parameters(k2+3,3);
        f_0_suspension(1,1,su,li)=A.data.Parameters(k2+3,4);
        for i=1:5,
            a_sus(i)=A.data.Parameters(k2+5,1+i);
        end
        %Fill in the suspension matrix for tyres and vehicles
        for s=1:num_source,
        for x=1:num_size,
        for t=1:num_tyre,
        for v=1:num_veh,
            f_0_suspension(s,x,t,v)=f_0_suspension(1,1,t,v).*h_0_sus(s,x);
        end
        end
        end
        end
    else
        fprintf('Error in reading road suspension parameters. \n');
        return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read road abrasion factor
%--------------------------------------------------------------------------
text='Abrasion factor';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        f_0_abrasion(st,he)=A.data.Parameters(k2+2,2);
        f_0_abrasion(wi,he)=A.data.Parameters(k2+2,3);
        f_0_abrasion(su,he)=A.data.Parameters(k2+2,4);
        f_0_abrasion(st,li)=A.data.Parameters(k2+3,2);
        f_0_abrasion(wi,li)=A.data.Parameters(k2+3,3);
        f_0_abrasion(su,li)=A.data.Parameters(k2+3,4);
        V_ref_abrasion=A.data.Parameters(k2+4,2);
        for x=1:num_size,
            h_0_abrasion(x)=A.data.Parameters(k2+6,1+x);
        end
    else
        fprintf('Error in reading abrasion parameters. \n');
        return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Non-suspendable crushing factors
%--------------------------------------------------------------------------
text='Crushing factor';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        f_0_crushing(st,he)=A.data.Parameters(k2+2,2);
        f_0_crushing(wi,he)=A.data.Parameters(k2+2,3);
        f_0_crushing(su,he)=A.data.Parameters(k2+2,4);
        f_0_crushing(st,li)=A.data.Parameters(k2+3,2);
        f_0_crushing(wi,li)=A.data.Parameters(k2+3,3);
        f_0_crushing(su,li)=A.data.Parameters(k2+3,4);
        V_ref_crushing=A.data.Parameters(k2+4,2);
        for x=1:num_size,
            h_0_crushing(x)=A.data.Parameters(k2+6,1+x);
        end
else
        fprintf('Error in reading crushing parameters. \n');
        return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read source identifiers for abrasion and crushing
%--------------------------------------------------------------------------
text='Sources participating in abrasion and crushing';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        for s=1:num_source,
            p_0_abrasion(s)=A.data.Parameters(k2+1+s,2);
            p_0_crushing(s)=A.data.Parameters(k2+1+s,3);            
        end
else
    fprintf('Error in reading suspendable fraction of sanding. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read direct emission factors
%--------------------------------------------------------------------------
text='Direct emission factor';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    for s=1:num_wear,
        f_0_dir(s)=A.data.Parameters(k2+1+s,2);
    end
        f_0_dir(crushing_index)=A.data.Parameters(k2+2+num_wear,2);
        f_0_dir(abrasion_index)=A.data.Parameters(k2+3+num_wear,2);
        f_0_dir(exhaust_index)=A.data.Parameters(k2+4+num_wear,2);
else
    fprintf('Error in reading direct emission factors. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read Fractional size distribution
%--------------------------------------------------------------------------
text='Fractional size distribution';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    for x=1:num_size,
        for s=1:num_source,
            f_PM(s,x,1)=A.data.Parameters(k2+1+s,1+x);
            %Distribute the same to all tyre types
            for t=1:num_tyre,
                f_PM(s,x,t)=f_PM(s,x,1);
            end
        end
        f_PM(crushing_index,x,1)=A.data.Parameters(k2+2+num_source,1+x);
        f_PM(abrasion_index,x,1)=A.data.Parameters(k2+3+num_source,1+x);
            for t=1:num_tyre,
                f_PM(crushing_index,x,t)=f_PM(crushing_index,x,1);
                f_PM(abrasion_index,x,t)=f_PM(abrasion_index,x,1);
            end       
    end
    %Create the differential size array
    %pm_all-pm_200,pm_200-pm10,pm_10-pm_25,pm_25
    f_PM_bin(1:num_source+2,1:num_size,1:num_tyre)=f_PM(1:num_source+2,1:num_size,1:num_tyre);
    for x=1:num_size-1,
        f_PM_bin(1:num_source,x,1:num_tyre)=f_PM(1:num_source,x,1:num_tyre)-f_PM(1:num_source,x+1,1:num_tyre);
        f_PM_bin(crushing_index,x,1:num_tyre)=f_PM(crushing_index,x,1:num_tyre)-f_PM(crushing_index,x+1,1:num_tyre);
        f_PM_bin(abrasion_index,x,1:num_tyre)=f_PM(abrasion_index,x,1:num_tyre)-f_PM(abrasion_index,x+1,1:num_tyre);
    end
    V_ref_pm_fraction=A.data.Parameters(k2+4+num_source,2);
    c_pm_fraction=A.data.Parameters(k2+5+num_source,2);
else
    fprintf('Error in reading fractional size distribution. \n');
    return
end

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read wind blown dust parameters
%--------------------------------------------------------------------------
text='Wind blown dust emission factors';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        tau_wind=A.data.Parameters(k2+2,2);
        FF_thresh=A.data.Parameters(k2+3,2);
else
    fprintf('Error in reading wind blown parameters. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read activity efficiency factors 
%--------------------------------------------------------------------------
text='Activity efficiency factors';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),    
    for x=1:num_size,
        h_eff(ploughing_eff_index,dust_index,x)=A.data.Parameters(k2+2,1+x);
        h_eff(cleaning_eff_index,dust_index,x)=A.data.Parameters(k2+3,1+x);
        h_eff(drainage_eff_index,dust_index,x)=A.data.Parameters(k2+4,1+x);
        h_eff(spraying_eff_index,dust_index,x)=A.data.Parameters(k2+5,1+x);
    end
    for i=1:num_salt,
        h_eff(ploughing_eff_index,salt_index(i),1:num_size)=A.data.Parameters(k2+7,1+i);
        h_eff(cleaning_eff_index,salt_index(i),1:num_size)=A.data.Parameters(k2+8,1+i);
        h_eff(drainage_eff_index,salt_index(i),1:num_size)=A.data.Parameters(k2+9,1+i);
        h_eff(spraying_eff_index,salt_index(i),1:num_size)=A.data.Parameters(k2+10,1+i);
    end
else
    fprintf('Error in reading Activity efficiency factors. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read deposition velocities
%--------------------------------------------------------------------------
text='Deposition velocity';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    for x=1:num_size,
            w_dep(x)=A.data.Parameters(k2+2,1+x);
    end
else
    fprintf('Error in reading deposition velocity. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read concentration conversion limit values
%--------------------------------------------------------------------------
text='Concentration conversion limit values';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        conc_min=A.data.Parameters(k2+2,2);
        emis_min=A.data.Parameters(k2+3,2);
else
    fprintf('Error in reading concentration conversion limit values \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read splash and spray parameters
%--------------------------------------------------------------------------
text='Spray and splash factors';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    for m=1:num_moisture,
        R_0_spray(he,m)=A.data.Parameters(k2+2,1+m);
        R_0_spray(li,m)=A.data.Parameters(k2+3,1+m);
        V_ref_spray(m)=A.data.Parameters(k2+4,1+m);
        g_road_sprayable_min(m)=A.data.Parameters(k2+5,1+m);
        a_spray(m)=A.data.Parameters(k2+6,1+m);
        V_thresh_spray(m)=A.data.Parameters(k2+7,1+m);
        if V_ref_spray(m)<=V_thresh_spray(m),
            fprintf('Reference spray speed must be significantly larger than threshold speed \n');
            return
        end
    end
else
    fprintf('Error in reading Spray and splash factors. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read drainage parameters
%--------------------------------------------------------------------------
text='Drainage parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        g_road_drainable_min=A.data.Parameters(k2+2,2);
        g_road_drainable_thresh=A.data.Parameters(k2+2,3);
        snow_dust_drainage_retainment_limit=A.data.Parameters(k2+3,2);
        tau_road_drainage=A.data.Parameters(k2+4,2);
else
    fprintf('Error in reading Drainage time scales. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read ploughing parameters
%--------------------------------------------------------------------------
text='Ploughing parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
    for m=1:num_moisture,
        h_ploughing_moisture(m)=A.data.Parameters(k2+2,1+m);
        ploughing_thresh(m)=A.data.Parameters(k2+3,1+m);
    end
else
    fprintf('Error in reading ploughing paramters. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read energy balance parameters
%--------------------------------------------------------------------------
text='Energy balance parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        g_road_evaporation_thresh=A.data.Parameters(k2+2,2);
        z0=A.data.Parameters(k2+3,2);%Read in as mm
        z0=z0/1000;%Convert to metres
        albedo_snow=A.data.Parameters(k2+4,2);
        dzs=A.data.Parameters(k2+5,2);
        sub_surf_average_time=A.data.Parameters(k2+6,2);
        sub_surf_param(1)=A.data.Parameters(k2+8,2);
        sub_surf_param(2)=A.data.Parameters(k2+8,3);
        sub_surf_param(3)=A.data.Parameters(k2+8,4);
        a_traffic(he)=A.data.Parameters(k2+10,2);
        a_traffic(li)=A.data.Parameters(k2+10,3);
        H_veh(he)=A.data.Parameters(k2+11,2);
        H_veh(li)=A.data.Parameters(k2+11,3);
else
    fprintf('Error in reading Energy balance parameters. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read retention parameters
%--------------------------------------------------------------------------
text='Retention parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        g_retention_thresh(road_index)=A.data.Parameters(k2+2,2);
        g_retention_thresh(brake_index)=A.data.Parameters(k2+2,3);
        g_retention_thresh(salt_index(2))=A.data.Parameters(k2+2,4);
        g_retention_min(road_index)=A.data.Parameters(k2+3,2);
        g_retention_min(brake_index)=A.data.Parameters(k2+3,3);
        g_retention_min(salt_index(2))=A.data.Parameters(k2+3,4);
else
    fprintf('Error in reading retention parameters. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Read surface texturing scaling
%--------------------------------------------------------------------------
text='Surface texture parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
        texture_scaling(1)=A.data.Parameters(k2+2,2);%g_road_drainable_min
        texture_scaling(2)=A.data.Parameters(k2+3,2);%f_0_suspension
        texture_scaling(3)=A.data.Parameters(k2+4,2);%R_0_spray
        texture_scaling(4)=A.data.Parameters(k2+5,2);%h_eff(drainage_eff_index,dust_index,:)
        texture_scaling(5)=A.data.Parameters(k2+6,2);%h_eff(spraying_eff_index,dust_index,:)
        %Scale the paramters
        g_road_drainable_min=g_road_drainable_min*texture_scaling(1);
        f_0_suspension=f_0_suspension*texture_scaling(2);
        R_0_spray=R_0_spray*texture_scaling(3);
        h_eff(drainage_eff_index,dust_index,:)=h_eff(drainage_eff_index,dust_index,:)*texture_scaling(4);
        h_eff(spraying_eff_index,dust_index,:)=h_eff(spraying_eff_index,dust_index,:)*texture_scaling(5);
else
    fprintf('Error in reading Surface texture parameters. \n');
    return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Track parameters
%--------------------------------------------------------------------------
text='Road track parameters';
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),
   num_track=0;
   for i=[alltrack_type,outtrack_type,intrack_type,shoulder_type,kerb_type],
        include_track_temp=A.data.Parameters(k2+1+i,2);
        if include_track_temp,
            num_track=num_track+1;
            f_track(num_track)=A.data.Parameters(k2+1+i,3);
            veh_track(num_track)=A.data.Parameters(k2+1+i,4);
            mig_track(num_track)=A.data.Parameters(k2+1+i,5);
            track_type(num_track)=i;
        end
   end
   %Double check that the sums are 1
   if sum(f_track)~=1,
       f_track=f_track/sum(f_track);
       fprintf('Adjusting f_track to add up to 1. New f_track: 5%f \n',f_track);
   end
   if sum(veh_track)~=1,
       veh_track=veh_track/sum(veh_track);
       fprintf('Adjusting veh_track to add up to 1. New veh_track: %f \n',veh_track);
   end
else
    fprintf('Error in reading track parameters. \n');
    return
end

%--------------------------------------------------------------------------
%Read in file
if read_parameters_as_text==0,
    %filename=[path_inputparam,filename_inputparam];
    %A = importdata(filename,'\t',0);
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_flag.txt'];
    else
        filename_txt=[filename,'_flags.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        return
    end
    clear A_temp A
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp.textdata(i,1)=A_line{1}(1);
        line_size=size(A_line{1},1);
        if line_size>1,
            for j=2:line_size,
                A_temp.textdata(i,j)=A_line{1}(j);
                num_temp=str2num(char(A_line{1}(j)));
                if ~isempty(num_temp)&&~isempty(A_line{1}(j))
                    A_temp.data(i,j-1)=num_temp;
                else
                    A_temp.data(i,j-1)=nan;
                end
            end
        else
        end
    end
    fclose(fid);
    A.data.Flags=A_temp.data;
    A.textdata.Flags=A_temp.textdata;
    input_param.data.Flags=A_temp.data;
    input_param.textdata.Flags=A_temp.textdata;
end

%Read flags.
%If no value found then the flag is set to a default
%Looks for exact matches to the string
header_text=A.textdata.Flags(:,1);
data_val=A.data.Flags(:,1);

text='road_wear_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
wear_flag(road_index)=val;

text='tyre_wear_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
wear_flag(tyre_index)=val;

text='brake_wear_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
wear_flag(brake_index)=val;

text='road_suspension_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
road_suspension_flag=val;

text='evaporation_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
evaporation_flag=val;

text='plot_type_flag';default=1;
k1 = strcmp(text,strtrim(strtrim(header_text)));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
plot_type_flag=val;

text='save_type_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
save_type_flag=val;

text='abrasion_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
abrasion_flag=val;

text='crushing_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
crushing_flag=val;

text='exhaust_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
exhaust_flag=val;

text='retention_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
retention_flag=val;

text='wind_suspension_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
wind_suspension_flag=val;

text='dust_drainage_flag';default=2;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
dust_drainage_flag=val;
%Allows for two different types of dust drainage
%1 is instantaneous and 2 is continuous over the hour (2 is in the article
%but 2 is default now)
        
text='dust_ploughing_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
dust_ploughing_flag=val;

text='use_obs_retention_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_obs_retention_flag=val;

text='canyon_shadow_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
canyon_shadow_flag=val;

text='canyon_long_rad_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
canyon_long_rad_flag=val;

text='auto_salting_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
auto_salting_flag=val;

text='auto_binding_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
auto_binding_flag=val;

text='auto_sanding_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
auto_sanding_flag=val;

text='auto_ploughing_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
auto_ploughing_flag=val;

text='auto_cleaning_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
auto_cleaning_flag=val;

text='use_salting_data_1_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_salting_data_flag(1)=val;

text='use_salting_data_2_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_salting_data_flag(2)=val;

text='use_sanding_data_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_sanding_data_flag=val;

text='use_ploughing_data_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_ploughing_data_flag=val;

text='use_cleaning_data_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_cleaning_data_flag=val;

text='water_spray_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
water_spray_flag=val;

text='drainage_type_flag';default=2;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
drainage_type_flag=val;

text='dust_spray_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
dust_spray_flag=val;

text='surface_humidity_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
surface_humidity_flag=val;

text='use_salt_humidity_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_salt_humidity_flag=val;

text='use_wetting_data_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_wetting_data_flag=val;

text='use_subsurface_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_subsurface_flag=val;

text='dust_deposition_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
dust_deposition_flag=val;

text='use_traffic_turb_flag';default=1;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_traffic_turb_flag=val;

text='use_ospm_flag';default=0;
k1 = strcmp(text,strtrim(header_text));k2=find(k1~=0); 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
use_ospm_flag=val;

%--------------------------------------------------------------------------

%Read salt and sand activity data
%If no value found then the flag is set to a default
%Does not need exact matches

%Read in the activity data if available

if read_parameters_as_text==0,
    %filename=[path_inputparam,filename_inputparam];
    %A = importdata(filename,'\t',0);
    if isfield(A.textdata,'Activities'),
        auto_activity_data_available=1;
    else
        auto_activity_data_available=0;
    end
else
    k=strfind(filename,'.');
    if ~isempty(k),
        filename_txt=[filename(1:k-1),'_activities.txt'];
    else
        filename_txt=[filename,'_activities.txt'];
    end
    if ~exist(filename_txt),
        hf=errordlg(['File ',filename_txt, 'does not exist.'],'File error');
        input_exists_flag=0;
        auto_activity_data_available=0;
        return
    else
        auto_activity_data_available=1;
    end
    clear A_temp A
    fid=fopen(filename_txt);
    i=0;
    while (~feof(fid)),
        i=i+1;
        the_line=fgetl(fid);
        A_line=textscan(the_line,'%s','delimiter','\t');
        A_temp.textdata(i,1)=A_line{1}(1);
        line_size=size(A_line{1},1);
        if line_size>1,
            for j=2:line_size,
                if ~isempty(A_line{1}(j))
                    A_temp.textdata(i,j)=A_line{1}(j);
                else
                    A_temp.textdata(i,j)={''};
                end
                num_temp=str2num(char(A_line{1}(j)));
                if ~isempty(num_temp)&&~isempty(A_line{1}(j))
                    A_temp.data(i,j-1)=num_temp;
                else
                    A_temp.data(i,j-1)=nan;
                end
            end
        else
        end
    end
    fclose(fid);
    A.data.Activities=A_temp.data;
    A.textdata.Activities=A_temp.textdata;
    input_param.data.Activities=A_temp.data;
    input_param.textdata.Activities=A_temp.textdata;
end

if auto_activity_data_available,

header_text=A.textdata.Activities(:,1);
data_val=A.data.Activities(:,1);

text='salting_hour(1)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
salting_hour(1)=val;

text='salting_hour(2)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
salting_hour(2)=val;

text='delay_salting_day';default=.9;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
delay_salting_day=val;

text='check_salting_day';default=.5;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
check_salting_day=val;

text='min_temp_salt';default=-6;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
min_temp_salt=val;

text='max_temp_salt';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
max_temp_salt=val;

text='precip_rule_salt';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
precip_rule_salt=val;

text='RH_rule_salt';default=90;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
RH_rule_salt=val;

text='g_salting_rule';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
g_salting_rule=val;

text='salt_mass';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
salt_mass=val;

text='salt_dilution';default=.2;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
salt_dilution=val;

text='salt_type_distribution';default=1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
salt_type_distribution=val;

end

%if auto_sanding_flag,
if isfield(A.textdata,'Activities'),
    
header_text=A.textdata.Activities(:,1);
data_val=A.data.Activities(:,1);

text='sanding_hour(1)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
sanding_hour(1)=val;

text='sanding_hour(2)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
sanding_hour(2)=val;

text='delay_sanding_day';default=.9;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
delay_sanding_day=val;

text='check_sanding_day';default=.5;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
check_sanding_day=val;

text='min_temp_sand';default=-6;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
min_temp_sand=val;

text='max_temp_sand';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
max_temp_sand=val;

text='precip_rule_sand';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
precip_rule_sand=val;

text='RH_rule_sand';default=90;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
RH_rule_sand=val;

text='g_sanding_rule';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
g_sanding_rule=val;

text='sand_mass';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
sand_mass=val;

text='sand_dilution';default=.2;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
sand_dilution=val;

end

%if auto_ploughing_flag,
if isfield(A.textdata,'Activities'),
    
header_text=A.textdata.Activities(:,1);
data_val=A.data.Activities(:,1);

text='delay_ploughing_hour';default=3;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
delay_ploughing_hour=val;

text='ploughing_thresh';default=ploughing_thresh;%Already exists
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2)&&~isnan(data_val(k2,1)),val=data_val(k2,1);else val=default;end
ploughing_thresh=val;

end

%if auto_cleaning_flag,
if isfield(A.textdata,'Activities'),
    
header_text=A.textdata.Activities(:,1);
data_val=A.data.Activities(:,1);

text='delay_cleaning_hour';default=7*24;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
delay_cleaning_hour=val;

text='min_temp_cleaning';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
min_temp_cleaning=val;

text='clean_with_salting';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
clean_with_salting=val;

text='start_month_cleaning';default=1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
start_month_cleaning=val;

text='end_month_cleaning';default=12;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
end_month_cleaning=val;

text='wetting_with_cleaning';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
wetting_with_cleaning=val;

text='efficiency_of_cleaning';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
efficiency_of_cleaning=val;

end

%if auto_binding_flag,
if isfield(A.textdata,'Activities'),
    
header_text=A.textdata.Activities(:,1);
data_val=A.data.Activities(:,1);

text='binding_hour(1)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
binding_hour(1)=val;

text='binding_hour(2)';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
binding_hour(2)=val;

text='delay_binding_day';default=.9;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
delay_binding_day=val;

text='check_binding_day';default=.5;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
check_binding_day=val;

text='min_temp_binding';default=-6;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
min_temp_binding=val;

text='max_temp_binding';default=0;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
max_temp_binding=val;

text='precip_rule_binding';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
precip_rule_binding=val;

text='RH_rule_binding';default=90;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
RH_rule_binding=val;

text='g_binding_rule';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
g_binding_rule=val;

text='binding_mass';default=.1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
binding_mass=val;

text='binding_dilution';default=.2;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
binding_dilution=val;

text='start_month_binding';default=1;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
start_month_binding=val;

text='end_month_binding';default=12;
k1 = strfind(header_text,text);k2=[];for i=1:length(k1),if ~isempty(k1{i}),k2=i;end;end 
if ~isempty(k2),val=data_val(k2,1);else val=default;end
end_month_binding=val;


end


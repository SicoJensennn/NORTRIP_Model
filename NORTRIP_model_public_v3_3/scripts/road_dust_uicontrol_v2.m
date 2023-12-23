%==========================================================================
%NORTRIP model
%SUBROUTINE: road_dust_uicontrol_v2
%VERSION: 2.8, 01.11.2014
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no;brucerd@met.no) and Ingrid Sundvor
%DESCRIPTION: Control script for running the NORTRIP model user interface
%==========================================================================

%--------------------------------------------------------------------------
%The following command will install MCR (Matlab Compiler Runtime) libraries
%$MATLABROOT\toolbox\compiler\deploy\win32\mcrInstaller.exe

%The following command creates the executable version
%This can only be implemented if the executable toolbox is installed
%mcc -e Scripts\road_dust_uicontrol_v2.m -d Compilation -o NORTRIP_model_v2_6
%Produces an error log file
%mcc -e -R '-logfile,nortrip_errorlog.txt' Scripts\road_dust_uicontrol_v2.m -d Compilation -o NORTRIP_model_v2_8a
%--------------------------------------------------------------------------

clear

%Never print results to screen in this UI version
print_results=0;

gui_title='NORTRIP EMISSION MODEL: USER INTERFACE (v2.8a)';

%--------------------------------------------------------------------------
%Initialise control flags
plot_type_flag=1;%1 hourly means, 2 daily means, 3 daily cycle
plot_type_flag_temp=plot_type_flag;
save_type_flag=1;%1 save data, 2 save plots, 3 save both

%root_path='C:\NORTRIP\Road dust model\';

%Set the default root path to the use path
%root_path='C:\NORTRIP\Road dust model\';
%userpath(root_path);
%cd(root_path);
%temp_path=char(userpath);
%root_path=temp_path(1:end-1);
root_path=pwd;%local path
root_path=[root_path,'\'];

%Set model run file name that contains filenames and paths, should be local
path_modelrun_data='model run info\';
filename_modelrun_data='modelrun_file.xlsx';

%Initial filenames of the input data
path_filename_inputparam='';
path_filename_inputdata='';
path_filename_modelrun_data='';

%Read paths and filenames from the modelrun file
read_road_dust_paths

%Set constants for indexing. Need to be common to the subroutine
road_dust_set_constants_v2

%Set the main plot size fraction
plot_size_fraction=pm_10;%Assume PM10 unless otherwise chosen
plot_size_fraction_temp=plot_size_fraction;

%Set some uicontrol display parameters
date_format_str='dd.mm.yyyy HH:MM';
fontsize=10;
fontsize_filename=8;
message_str='Select and load input data file';
%--------------------------------------------------------------------------

%Initialise figure containing user interface controls
scale=2.5; %(pixels/mm on screen)
fig_ui=figure(20);
set(fig_ui,'Name','NORTRIP emission model user interface','MenuBar','figure','color','w','position',[10 80 fix(400*scale) fix(250*scale)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig_ui);
clf;

%Initialise flags used to control the user interface
select_modelinfo_flag=0;
change_modelinfo_flag=0;
open_modelinfo_flag=0;
select_inputparam_flag=0;
change_inputparam_flag=0;
open_inputparam_flag=0;
select_inputdata_flag=0;
change_inputdata_flag=0;
open_inputdata_flag=0;
select_outputdata_flag=0;
change_outputdata_flag=0;
select_figure_flag=0;
change_figure_flag=0;
change_slider_flag=0;
change_time_flag=0;
read_input_flag=0;
input_exists_flag=0;
save_flag=0;
plot_flag=0;
run_flag=0;
exit_flag=0;
restart_flag=0;
bad_input_data=0;
plot_size_fraction_flag=0;

has_been_run_once_flag=0;
has_been_plotted_once_flag=0;
data_has_been_read_once_flag=0;
uiplot_exists=0;

min_time=1;
max_time=2;
%min_time_init=min_time;
%max_time_init=max_time;
date_num(min_time)=0;
date_num(max_time)=0;


%While in this loop the userinterface can be accessed
%while exit_flag==0&&restart_flag==0,
figure(fig_ui);

%Define the user interface controls
h0 = uicontrol('Style', 'text', 'String',gui_title,'HorizontalAlignment','center','units','normal','fontsize',18,'fontweight','bold','Position', [.12 .85 .8 .1],'BackgroundColor','w','foregroundcolor',[0.4 0.4 0.8]);
h01 = uicontrol('Style', 'text', 'String','PATH AND FILE SELECTION','HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .85 .25 .04],'BackgroundColor','w');

h13 = uicontrol('Style', 'pushbutton', 'String', 'Select model info file','units','normal','fontsize',fontsize,'Position', [.02 .8 .2 .05], 'Callback', 'uiresume(fig_ui);select_modelinfo_flag=1;');
h13a = uicontrol('Style', 'pushbutton', 'String', 'Open file','units','normal','fontsize',fontsize,'Position', [.90 .8 .07 .05], 'Callback', 'uiresume(fig_ui);open_modelinfo_flag=1;');
h14 = uicontrol('Style', 'edit', 'String', path_filename_modelrun_data,'HorizontalAlignment','left','units','normal','fontsize',fontsize_filename,'Position', [.25 .8 .63 .05],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_modelinfo_flag=1;');

h11 = uicontrol('Style', 'pushbutton', 'String', 'Select model parameter input','units','normal','fontsize',fontsize,'Position', [.02 .75 .2 .05], 'Callback', 'uiresume(fig_ui);select_inputparam_flag=1;');
h11a = uicontrol('Style', 'pushbutton', 'String', 'Open file','units','normal','fontsize',fontsize,'Position', [.90 .75 .07 .05], 'Callback', 'uiresume(fig_ui);open_inputparam_flag=1;');
h12 = uicontrol('Style', 'edit', 'String', path_filename_inputparam,'HorizontalAlignment','left','units','normal','fontsize',fontsize_filename,'Position', [.25 .75 .63 .05],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_inputparam_flag=1;');

h1 = uicontrol('Style', 'pushbutton', 'String', 'Select model input data','units','normal','fontsize',fontsize,'Position', [.02 .7 .2 .05], 'Callback', 'uiresume(fig_ui);select_inputdata_flag=1;');
h1a = uicontrol('Style', 'pushbutton', 'String', 'Open file','units','normal','fontsize',fontsize,'Position', [.90 .7 .07 .05], 'Callback', 'uiresume(fig_ui);open_inputdata_flag=1;');
h2 = uicontrol('Style', 'edit', 'String', path_filename_inputdata,'HorizontalAlignment','left','units','normal','fontsize',fontsize_filename,'Position', [.25 .7 .63 .05],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_inputdata_flag=1;');

h3 = uicontrol('Style', 'pushbutton', 'String', 'Select output data directory','units','normal','fontsize',fontsize,'Position', [.02 .65 .2 .05], 'Callback', 'uiresume(fig_ui);select_outputdata_flag=1;');
h4 = uicontrol('Style', 'edit', 'String', path_outputdata,'HorizontalAlignment','left','units','normal','fontsize',fontsize_filename,'Position', [.25 .65 .63 .05],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_outputdata_flag=1;');

h5 = uicontrol('Style', 'pushbutton', 'String', 'Select output plots directory','units','normal','fontsize',fontsize,'Position', [.02 .6 .2 .05], 'Callback', 'uiresume(fig_ui);select_figure_flag=1;');
h6 = uicontrol('Style', 'edit', 'String', path_outputfig,'HorizontalAlignment','left','units','normal','fontsize',fontsize_filename,'Position', [.25 .6 .63 .05],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_figure_flag=1;');

h02 = uicontrol('Style', 'text', 'String','DATE SELECTION','HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .46 .2 .04],'BackgroundColor','w');

%h04 = uicontrol('Style', 'text', 'String','STATUS','HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .51 .07 .04],'BackgroundColor','w');
hm = uicontrol('Style', 'edit', 'String', message_str,'HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.25 .51 .63 .05],'BackgroundColor',[.7 1 .7]);

h03 = uicontrol('Style', 'text', 'String','MODEL CONTROL','HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .3 .2 .04],'BackgroundColor','w');
h19 = uicontrol('Style', 'pushbutton', 'String', 'Load input data','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .25 .2 .04],'BackgroundColor',[1 .7 .7], 'Callback', 'uiresume(fig_ui);read_input_flag=1;');
h9 = uicontrol('Style', 'pushbutton', 'String', 'Run model','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .2 .2 .04],'BackgroundColor',[.7 1 .7], 'Callback', 'uiresume(fig_ui);run_flag=1;');
%h22 = uicontrol('Style', 'popup', 'String', 'Plot hourly mean|Plot daily mean|Plot daily cycle|Plot weekday cycle|Plot weekly mean|Plot monthly mean','Value',plot_type_flag_temp,'HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .14 .2 .05],'BackgroundColor',[1 1 .5], 'Callback', 'uiresume(fig_ui);plot_flag=1;');
h22 = uicontrol('Style', 'popup', 'String', 'Plot hourly mean|Plot daily mean|Plot daily cycle|Plot weekday cycle|Plot weekly mean|Plot monthly mean','Value',plot_type_flag_temp,'HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .14 .14 .05],'BackgroundColor',[1 1 .5], 'Callback', 'uiresume(fig_ui);plot_flag=1;');
h23 = uicontrol('Style', 'popup', 'String', 'PM10|PM2.5','Value',plot_size_fraction_temp,'HorizontalAlignment','left','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.16 .14 .06 .05],'BackgroundColor',[1 1 .5], 'Callback', 'uiresume(fig_ui);plot_size_fraction_flag=1;');
h21 = uicontrol('Style', 'popup', 'String', 'Save plots|Save data hourly (excel)|Save data averaged (excel)|Save data hourly (text)|Save data averaged (text)','Value',save_type_flag,'units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .09 .2 .05],'BackgroundColor',[1 1 .5], 'Callback', 'uiresume(fig_ui);save_flag=1;');
h20 = uicontrol('Style', 'pushbutton', 'String', 'Restart','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.02 .05 .1 .04],'BackgroundColor',[.5 .7 1], 'Callback', 'uiresume(fig_ui);restart_flag=1;');
h10 = uicontrol('Style', 'pushbutton', 'String', 'Exit','units','normal','fontsize',fontsize,'fontweight','bold','Position', [.12 .05 .1 .04],'BackgroundColor',[.5 .7 1], 'Callback', 'uiresume(fig_ui);exit_flag=1;');

while exit_flag==0&&restart_flag==0,

figure(fig_ui);
%pause(.5);
if input_exists_flag,
    %clear h17 h18 h7 h8
    if exist('h7'),delete(h7);end
    if exist('h8'),delete(h8);end
    if exist('h17'),delete(h17);end
    if exist('h18'),delete(h18);end
    h7 = uicontrol('Style', 'slider', 'Min', min_time_init,'Max', max_time_init,'Value',min_time,'units','normal','Position', [.25 .43 .72 .02],'BackgroundColor',[.6 .6 1], 'Callback', 'uiresume(fig_ui);change_slider_flag=1;');
    h8 = uicontrol('Style', 'slider', 'Min', min_time_init,'Max', max_time_init,'Value',max_time,'units','normal','Position', [.25 .39 .72 .02],'BackgroundColor',[.6 .6 1], 'Callback', 'uiresume(fig_ui);change_slider_flag=1;');
    h17 = uicontrol('Style', 'edit', 'String', datestr(date_num(min_time),date_format_str),'HorizontalAlignment','left','units','normal','fontsize',fontsize,'Position', [.02 .42 .2 .04],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_time_flag=1;');
    h18 = uicontrol('Style', 'edit', 'String', datestr(date_num(max_time),date_format_str),'HorizontalAlignment','left','units','normal','fontsize',fontsize,'Position', [.02 .38 .2 .04],'BackgroundColor',[.9 .9 .9], 'Callback', 'uiresume(fig_ui);change_time_flag=1;');
end

%pause(1);
if ~bad_input_data,message_str='Ready';end
set(hm,'String',message_str);drawnow;
if ~road_dust_info_file,
    message_str=['Model info file does not exist: ',path_modelrun_data,filename_modelrun_data];set(hm,'String',message_str);drawnow;
end

%Wait for something to happen
uiwait(fig_ui);

%fprintf('%u\n',select_modelinfo_flag,change_modelinfo_flag,open_modelinfo_flag,select_inputparam_flag,change_inputparam_flag,open_inputparam_flag,select_inputdata_flag,change_inputdata_flag,open_inputdata_flag,select_outputdata_flag,change_outputdata_flag,select_figure_flag,change_figure_flag,change_slider_flag,change_time_flag,read_input_flag,input_exists_flag,save_flag,plot_flag,run_flag,exit_flag,restart_flag);
%What to do once something happens
    if select_modelinfo_flag,
        [filename_modelrun_data,path_modelrun_data,FilterIndex] = uigetfile('*.*','Select model path file',root_path);
        path_filename_modelrun_data=[path_modelrun_data,filename_modelrun_data];
        message_str=['Updating path and file info from: ',filename_modelrun_data];set(hm,'String',message_str);drawnow
        read_road_dust_paths
        set(h14,'String',path_filename_modelrun_data);
        set(h12,'String',path_filename_inputparam);
        set(h2,'String',path_filename_inputdata);
        set(h4,'String',path_outputdata);
        set(h6,'String',path_outputfig);
    end
    
    if open_modelinfo_flag,
        path_filename_modelrun_data = get(h14,'String');
        winopen(path_filename_modelrun_data);
        message_str=['Opening file in EXCEL: ',filename_modelrun_data];set(hm,'String',message_str);drawnow
    end
    
    if change_modelinfo_flag,
        path_filename_modelrun_data = get(h14,'String');
        k = findstr(path_filename_modelrun_data,'\');
        path_modelrun_data=path_filename_modelrun_data(1:k(end));
        filename_modelrun_data=path_filename_modelrun_data(k(end)+1:end);
        message_str=['Updating path and file info from: ',filename_modelrun_data];set(hm,'String',message_str);drawnow
        read_road_dust_paths
    end
    
    if select_inputparam_flag,
        [filename_inputparam,path_inputparam,FilterIndex] = uigetfile('*.*','Select input parameter file',root_path);
        path_filename_inputparam=[path_inputparam,filename_inputparam];
        set(h12,'String',path_filename_inputparam);
    end
    
    if open_inputparam_flag,
        path_filename_inputparam = get(h12,'String');
        winopen(path_filename_inputparam);
        message_str=['Opening file in EXCEL: ',path_filename_inputparam];set(hm,'String',message_str);drawnow
    end
    
    if change_inputparam_flag,
        path_filename_inputparam = get(h12,'String');
        k = findstr(path_filename_inputparam,'\');
        path_inputparam=path_filename_inputparam(1:k(end));
        filename_inputparam=path_filename_inputparam(k(end)+1:end);
    end
    
    if select_inputdata_flag,
        [filename_inputdata,path_inputdata,FilterIndex] = uigetfile('*.*','Select input data file',root_path);
        path_filename_inputdata=[path_inputdata,filename_inputdata];
        set(h2,'String',path_filename_inputdata);
    end
    
    if open_inputdata_flag,
        path_filename_inputdata = get(h2,'String');
        winopen(path_filename_inputdata);
        message_str=['Opening file in EXCEL: ',path_filename_inputdata];set(hm,'String',message_str);drawnow
    end
    
    if change_inputdata_flag,
        path_filename_inputdata = get(h2,'String');
        k = findstr(path_filename_inputdata,'\');
        path_inputdata=path_filename_inputdata(1:k(end));
        filename_inputdata=path_filename_inputdata(k(end)+1:end);
    end
    
    if select_outputdata_flag,
        path_outputdata = [uigetdir(root_path,'Select output data directory'),'\'];
        set(h4,'String',path_outputdata);
    end
    
    if change_outputdata_flag,
        path_outputdata = get(h4,'String');
    end
    
    if select_figure_flag,
        path_outputfig = [uigetdir(root_path,'Select figure output directory'),'\'];
        set(h6,'String',path_outputfig);
    end
    
    if change_figure_flag,
        path_outputfig= get(h6,'String');
    end
    
    if change_slider_flag,
        min_time= round(get(h7,'Value'));
        max_time= round(get(h8,'Value'));
        if min_time==1&&max_time==1,max_time=2;end
        if min_time>=max_time, min_time=max_time-1;end
    end
    
    if change_time_flag,
        [YY, MM, DD1, HH, MN, SS] = datevec(get(h17,'String'),date_format_str);
        r=find(YY==year&MM==month&DD1==day&HH==hour);
        if length(r)==1,min_time=r;end
        [YY, MM, DD1, HH, MN, SS] = datevec(get(h18,'String'),date_format_str);
        r=find(YY==year&MM==month&DD1==day&HH==hour);
        if length(r)==1,max_time=r;end
        if min_time>=max_time, min_time=max_time-1;end
    end
    
    if read_input_flag,
        %fprintf('Reading input data\n');
        message_str=['Reading input data from: ',filename_inputdata];set(hm,'String',message_str);drawnow
        bad_input_data=0;
        read_road_dust_input_v2;      
        %fprintf('Input data read\n');
        if ~bad_input_data,
        if input_exists_flag,
            message_str='Input data has been read';set(hm,'String',message_str);drawnow
            input_exists_flag=1; 
            %Set time loop index
            min_time=1;
            max_time=length(year);
            min_time_init=min_time;
            max_time_init=max_time;
        else
            message_str='File does not exist. Try again';set(hm,'String',message_str);drawnow
        end
        data_has_been_read_once_flag=1;
        uiplot_exists=0;
        else
        input_exists_flag=0;
        end
    end
    
    if plot_size_fraction_flag,
        plot_size_fraction_temp=round(get(h23,'Value'));
        if plot_size_fraction_temp==1,
            plot_size_fraction=pm_10;
            message_str='Setting main plot size fraction to PM10';set(hm,'String',message_str);drawnow;pause(1);
        end
        if plot_size_fraction_temp==2,
            plot_size_fraction=pm_25;
            message_str='Setting main plot size fraction to PM2.5';set(hm,'String',message_str);drawnow;pause(1);
        end        
    end

    if input_exists_flag,
        %On the fly plotting
        exist_hplot=exist('hplot');
        if exist_hplot,
            delete(hplot);
        end
        hplot=axes('position',[.25 .05 .72 .25],'units','normal','box','on');
        cla;
        hold on;

        fly_plot1=PM_obs(plot_size_fraction,:);
        r=find(fly_plot1==nodata);
        fly_plot1(r)=NaN;
        fly_plot2=PM_background(plot_size_fraction,:);
        r=find(fly_plot2==nodata);
        fly_plot2(r)=NaN;
        axes(hplot);
        plot(min_time:max_time,fly_plot1(min_time:max_time),'b-');
        plot(min_time:max_time,fly_plot2(min_time:max_time),'b:');
        if uiplot_exists&&~run_flag,
        	min_time_plot=max(min_time,min_time_run);
            max_time_plot=min(max_time,max_time_run);
            plot(min_time_plot:max_time_plot,C_all(plot_size_fraction,min_time_plot:max_time_plot),'ms','markersize',3);
        end
        if plot_size_fraction==pm_10,
            title('PM_1_0 concentrations','fontweight','normal');
        elseif plot_size_fraction==pm_25,
            title('PM_2_._5 concentrations','fontweight','normal');
        end            
        %axis tight
        max_yplot=max(max(fly_plot1(min_time:max_time)),max(fly_plot2(min_time:max_time)));
        if ~isnan(max_yplot)&&max_yplot~=nodata,
            ylim([0 max_yplot]);
        end
        xlim([min_time max_time]);

        drawnow
    end
    
    if restart_flag,
        message_str='Restarting user interface';set(hm,'String',message_str);drawnow   
    end
    
    if plot_flag,
        message_str='Plotting data';set(hm,'String',message_str);drawnow
        %Update the title
        k = findstr(filename_inputdata,'.');title_str=filename_inputdata(1:k-1);
        k2 = findstr(title_str,'input data');if k2>0, title_str=filename_inputdata(1:k2-2);end
        plot_type_flag_temp= round(get(h22,'Value'));
        plot_type_flag=plot_type_flag_temp;
        if plot_type_flag_temp==4, plot_type_flag=5;end
        if plot_type_flag_temp==5, plot_type_flag=7;end
        if plot_type_flag_temp==6, plot_type_flag=8;end
        
        %Make sure the plot times are within the run times incase the
        %sliders have been changed
        min_time=max(min_time,min_time_run);
        max_time=min(max_time,max_time_run);

        %Plot results
        if has_been_run_once_flag,
            plot_road_dust_results_v2
        else
        	message_str='Model has not been run yet. No plotting.';set(hm,'String',message_str);drawnow
        end
        has_been_plotted_once_flag=1;
    end
    
    if save_flag,
        %Update the title as this is used to define the inital file names
        title_str=filename_inputdata;
        k = findstr(filename_inputdata,'.');title_str=filename_inputdata(1:k-1);
        k2 = findstr(title_str,'input data');if k2>0, title_str=filename_inputdata(1:k2-2);end
        save_type_flag= round(get(h21,'Value'));
        % 'Save plots|Save data hourly (excel)|Save data averaged (excel)|Save data hourly (text)|Save data averaged (text)'
        save_average_flag=1;
        save_data_as_text=0;
        if save_type_flag==2||save_type_flag==4,save_average_flag=0;end

        %Make sure the plot times are within the run times incase the
        %sliders have been changed
        min_time=max(min_time,min_time_run);
        max_time=min(max_time,max_time_run);

        if save_type_flag==2||save_type_flag==3,
            message_str='Saving data to excel file';set(hm,'String',message_str);drawnow;
            %Set filenames according to the title_str
            filename_outputdata=[title_str,'_data'];
            path_outputdata_temp=path_outputdata;
            filename_outputdata_temp=filename_outputdata;
            path_filename_outputdata_data=[path_outputdata,filename_outputdata];
            [filename_outputdata,path_outputdata,FilterIndex] = uiputfile('*.*','Save data to excel file',path_filename_outputdata_data);
            path_filename_outputdata_data=[path_outputdata,'\',filename_outputdata];
            ok_to_save_files=1;
            if path_outputdata==0,
                path_outputdata=path_outputdata_temp;
                filename_outputdata=filename_outputdata_temp;
                message_str='Saving files cancelled. No files saved.';set(hm,'String',message_str);drawnow
                ok_to_save_files=0;
            end
        
            if has_been_run_once_flag&&ok_to_save_files,
                save_road_dust_results_average_v2
            else
                message_str='Model has not been run yet. No data saved.';set(hm,'String',message_str);drawnow
            end
        end
        if save_type_flag==4||save_type_flag==5,
            save_data_as_text=1;
            message_str='Saving data to text file';set(hm,'String',message_str);drawnow;
            %Set filenames according to the title_str
            filename_outputdata=[title_str,'_data'];
            path_outputdata_temp=path_outputdata;
            filename_outputdata_temp=filename_outputdata;
            path_filename_outputdata_data=[path_outputdata,filename_outputdata];
            [filename_outputdata,path_outputdata,FilterIndex] = uiputfile('*.*','Save data to text file',path_filename_outputdata_data);
            path_filename_outputdata_data=[path_outputdata,'\',filename_outputdata];
            ok_to_save_files=1;
            if path_outputdata==0,
                path_outputdata=path_outputdata_temp;
                filename_outputdata=filename_outputdata_temp;
                message_str='Saving files cancelled. No files saved.';set(hm,'String',message_str);drawnow
                ok_to_save_files=0;
            end
           
            if has_been_run_once_flag&&ok_to_save_files,
                save_road_dust_results_average_v2
            else
                message_str='Model has not been run yet. No data saved.';set(hm,'String',message_str);drawnow
            end
        end
        if save_type_flag==1,
            message_str='Saving plots';set(hm,'String',message_str);drawnow;
            %This is the name of the path for later when choosing the path: path_outputfig
            filename_outputfig=title_str;
            path_outputfig_temp=path_outputfig;
            title_str_temp=title_str;
            path_filename_outputfig=[path_outputfig,filename_outputfig];
            [title_str,path_outputfig,FilterIndex] = uiputfile('*.*','Save plots to this folder using this base file name',path_filename_outputfig);
            %path_filename_outputdata_data=[path_outputdata_temp,'\',filename_outputdata_temp];
            %path_outputfig_temp = uigetdir(path_outputfig,'Select folder to save plots');
            ok_to_save_plots=1;
            if path_outputfig==0,
                path_outputfig=path_outputfig_temp;
                title_str=title_str_temp;                
                message_str='Saving plots cancelled. No plots saved.';set(hm,'String',message_str);drawnow
                ok_to_save_plots=0;
            end
            if has_been_run_once_flag&&has_been_plotted_once_flag&&ok_to_save_plots,
                %path_outputfig=path_outputfig_temp;
                save_plot_road_dust_results_2
            else
                message_str='Model has not been run or plotted yet. No plots saved.';set(hm,'String',message_str);drawnow
            end
            
            %path_outputfig=path_outputfig_temp2;
        end
    end
    

%Reset all the flags to 0 again
select_modelinfo_flag=0;
change_modelinfo_flag=0;
open_modelinfo_flag=0;
select_inputparam_flag=0;
change_inputparam_flag=0;
open_inputparam_flag=0;
select_inputdata_flag=0;
change_inputdata_flag=0;
open_inputdata_flag=0;
select_outputdata_flag=0;
change_outputdata_flag=0;
select_figure_flag=0;
change_figure_flag=0;
change_slider_flag=0;
change_time_flag=0;
read_input_flag=0;
plot_flag=0;
save_flag=0;
plot_size_fraction_flag=0;

f_dis_available=0;


%Update the figure
drawnow;

if run_flag&&~data_has_been_read_once_flag,
    message_str='No data available yet';set(hm,'String',message_str);drawnow
end

%Start the model run
if run_flag&&data_has_been_read_once_flag,
%Set tabled parameters
    max_time_inputdata=length(year); %Needed for radiation
    min_time_run=min_time;
    max_time_run=max_time;
    has_been_run_once_flag=1;
    uiplot_exists=0;
    message_str='Reading model parameters';set(hm,'String',message_str);drawnow
    read_road_dust_parameters_v3
    
    %Set control flags for plotting and saving to default every time
    plot_type_flag=1;%1 hourly means, 2 daily means, 3 daily cycle
    plot_type_flag_temp=plot_type_flag;
    save_type_flag=1;%1 save data, 2 save plots, 3 save both

%Precalculate radiation input data
    message_str='Calculating radiation and mean temperature';set(hm,'String',message_str);drawnow
    calc_radiation;
    T_sub = running_mean_temperature_func(T_a,3*24,min_time,max_time);

    if use_ospm_flag==1&&DD_available==0,
        %Do not run if OSPM is chosen without DD data
        message_str='No wind direction (DD) data available for OSPM. Stopping';set(hm,'String',message_str);drawnow
        return;
    end
    if use_ospm_flag==2&&OSPM_data_exists==0,
        %Do not run if OSPM is chosen and no OSPM sheet exists
        message_str='No extra sheet with OSPM data exists. Stopping';set(hm,'String',message_str);drawnow
        return;
    end
    if use_ospm_flag,
        %Do not run if folder is wrong
        h_exist=exist(path_ospm);
        if h_exist==0,
        message_str=['Error in OSPM folder, check modelrun_file. Current folder: ',path_ospm];set(hm,'String',message_str);drawnow
        return;
        end
    end

%Precalculate dispersion factors using ospm
    if use_ospm_flag,
        message_str='Calculating dispersion using OSPM';set(hm,'String',message_str);drawnow
        road_dust_ospm_v1;
        if s_ospm~=0,
            %Remove end of lines
            r=find(isspace(w_ospm));
            w_ospm(r)=' ';
            message_str=['OSPM Error: ',w_ospm];set(hm,'String',message_str);drawnow
            return;
        end
        if ospm_outputfile_exists==0,
            message_str=['Stopping because OSPM output file does not exist: ', ospm_output_filename];set(hm,'String',message_str);drawnow
            return
        end        
    end

%Set time step for iteration
    dt=(date_num(min_time+1)-date_num(min_time))*24;

%Loop through time
    message_str='Starting calculation';set(hm,'String',message_str);drawnow
    
    clear C_all_uiplot
    ti_last_uiplot=min_time;

for ti=min_time:max_time
    
    %Print date
    %if hour(ti)==1,
    %    message_str=char(date_str2(ti,7:12));set(hm,'String',message_str);%drawnow
    %end
    
    %Use salting and ploughing rules to determine activities
    set_activity_data_v2;
    
    %Calculate road and shoulder surface conditions
    road_dust_surface_wetness_v2;

    %Calculate road and shoulder emissions and dust loading
    road_dust_emission_model_v2;
    
    %Calculate concentrations
    road_dust_concentrations;
    
    %On the fly plotting
    %if (f_conc(ti)~=nodata),
    %    C_all_uiplot(1,ti)=C_all(pm_10,ti);
        %plot(ti,C_all_uiplot(1,ti),'rs','markersize',3);
    %    uiplot_exists=1;
    %else
    %    C_all_uiplot(1,ti)=NaN;
    %end

    %Only update plot once every 7 days
    if mod(ti,24*1)==0,
        plot(ti_last_uiplot:ti,C_all(plot_size_fraction,ti_last_uiplot:ti),'rs','markersize',3);        
        message_str=char(date_str2(ti,7:12));set(hm,'String',message_str);%drawnow
        drawnow;
        ti_last_uiplot=ti+1;
        uiplot_exists=1;
    end
          
end
%End time loop

message_str='Model run complete';set(hm,'String',message_str);drawnow

    %Reset availability of dispersion parameter to 0 if ospm has been used
    %This is so it can be changed again when rereading the parameter file
    if use_ospm_flag,
        f_dis_available=0;
    end

end

run_flag=0;
    
if restart_flag,
   message_str='Restarting';set(hm,'String',message_str);drawnow
   close all;
   clear
   road_dust_uicontrol_v2;
   return
end
    
end

message_str='NORTRIP emission model user interface has stopped. Closing figures.';set(hm,'String',message_str);drawnow
pause(1);
close all;




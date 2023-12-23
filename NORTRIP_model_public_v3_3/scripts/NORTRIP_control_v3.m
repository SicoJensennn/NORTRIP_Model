%==========================================================================
%NORTRIP model
%SUBROUTINE: NORTRIP_control_v3
%VERSION: 3.3, 21.12.2020
%AUTHOR: Bruce Rolstad Denby (bruce.denby@met.no) and Ingrid Sundvor (is@nilu.no)
%DESCRIPTION: Control script for running the NORTRIP model
%             Includes the ability to cal the fortran version
%             v3.1 update includes reading of text files for all inputs
%             v3.2 includes bug fixes and compatability for Linux Matlab
%             v3.3 implementation of improved road surface modelling
%==========================================================================
fprintf('Starting NORTRIP_model_public_v3_3\n');

clear

%--------------------------------------------------------------------------
%Set these to specify root path, model run info path and directory delimiter
%--------------------------------------------------------------------------
    %Directory delimiter which is different for windows or linux
    dir_del='\'; %Windows
    %dir_del='/'; %Linux

    %Set the default user path
    %root_path='C:\NORTRIP\NORTRIP_model_public_v3_2\';
    root_path=['D:',dir_del,'NORTRIP',dir_del,'NORTRIP_model_public_v3_3',dir_del];
    userpath(root_path);
    cd(root_path);

    %Set model run file name that contains filenames and paths
    path_modelrun_data=['model_paths',dir_del];
    filename_modelrun_data='model_paths_and_files.xlsx';
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%Possible to run in forecast mode for road surface temperature.
%Initialises with observed road surface temperature for the given number
%of forecasts hours previous to the calculation hour. For every hourly
%calculation then 'forecast_hour' number of calculations are made to give
%a forecasted surface temperature. Only surface temperature is initialised.
%forecast_hour=0 is no forecast mode.
%Can not be used with fortran variant as this is not yet implemented
%--------------------------------------------------------------------------
    forecast_hour=0;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%Set whether to use fortran executable or not for model calculations
%--------------------------------------------------------------------------
    %If on then will automatically save excel sheets as text files if 
    %'read_inputs_from_text=0'
    use_fortran_flag=0;
    %Set whether to actually run fortran or show existing fortran text
    %results assuming it has already been run
    only_show_fortran_results=0;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%Set whether to read parameters and input from text files instead of excel
%Reading from text files is quicker. If selected then will automatically
%replace '.xlsx' with '.txt' on the file names
%--------------------------------------------------------------------------
    read_inputs_from_text=0;
    %Set the individual reading flags based on read_inputs_from_text
    %Provides flexibility in what is read from text or from excel
    if read_inputs_from_text,
        read_inputdata_as_text=1;
        read_infofile_as_text=1;
        read_parameters_as_text=1;
    else
        read_inputdata_as_text=0;
        read_infofile_as_text=0;
        read_parameters_as_text=0;
    end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%Print some statistical results to page for copying to excel
%--------------------------------------------------------------------------
    print_results=1;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%These parameters need to be initialised before the model run
%--------------------------------------------------------------------------
%Set control flags for plotting and saving
    %plot_type_flag=3;%1 hourly means, 2 daily means, 3 daily cycle
    %save_type_flag=0;%1 save data, 2 save plots, 3 save both, 0 no save

%Initialise date strings prior to setting in set_road_dust_inputdata_files_v1
    date_format_str='dd.mm.yyyy HH:MM';
    start_date_str='';
    end_date_str='';
    start_date_save_str='';
    end_date_save_str='';
%--------------------------------------------------------------------------
    
%filename_modelrun_data='modelrun_file_salt_paper.xlsx';

%--------------------------------------------------------------------------
%Start reading input data
%--------------------------------------------------------------------------
%Read paths and filenames from the modelrun file
    read_road_dust_paths

%Define input file names
    title_str=[];
    message_str=[];

%Define input filename other than in 'modelrun_info' file
    set_road_dust_inputdata_files_v1;

%Set constants for indexing. Are set in all functions as well
    fprintf('Setting constants\n');
    road_dust_set_constants_v2
    
%Set tabled parameters
    read_road_dust_parameters_v3

%Set/read input data
    read_road_dust_input_v2;
    convert_road_dust_input;

%Change inputs for scenarios. Not used
    road_dust_scenarios_v1;

%Set the main plot size fraction
    plot_size_fraction=pm_10;
    
%Initialise times and run dates
    road_dust_initialise_time;
    if time_bad, return; end
    
%Initialise time dependent variables
    road_dust_initialise_variables;

%Run fortran code
    if use_fortran_flag,
        NORTRIP_fortran_control
    end 
    
%Start main programme control loops if not using fortran    
%--------------------------------------------------------------------------
    if use_fortran_flag==0,
    
      %Start road loop. Number of roads in Matlab version is always 1
      for ro=1:n_roads,
      %--------------------------------------------------------------------------

        %Precalculate radiation and temperature input data. 3 day running mean
        fprintf('Calculating radiation and running mean temperature\n');
        calc_radiation;
        for tr=1:num_track,
            if T_sub_available,
                road_meteo_data(T_sub_index,:,tr,ro)=meteo_data(T_sub_input_index,:,ro);
            else
                road_meteo_data(T_sub_index,:,tr,ro)...
                = running_mean_temperature_func(meteo_data(T_a_index,:,ro),sub_surf_average_time,1,max_time_inputdata,dt);
            end
        end

        %Print an error message if there is one
        if ~isempty(message_str),
            fprintf('MESSAGE: %s\n',message_str);
        end

        %Main time loop
        %----------------------------------------------------------------------
        fprintf('Starting time loop\n');

        for tf=min_time:max_time 

            %Set the previous (initial) model surface temperature to
            %the observed surface temperature in forecast mode
            forecast_index=max(0,forecast_hour-1);
            road_temperature_forecast_missing(tf+forecast_index)=1;
            if forecast_hour>0&&tf>min_time,
               r=find(road_temperature_obs_missing==tf-1);               
               if isempty(r),
                   road_meteo_data(T_s_index,tf-1,tr,ro)=road_meteo_data(road_temperature_obs_index,tf-1,tr,ro);
                   %fprintf('Forecast %u\n',ti-tf+1);
                   road_temperature_forecast_missing(tf+forecast_index)=0;
               end
            end

            %Print the date
            if (date_data(hour_index,tf)==1),
                if (forecast_hour>0),
                    fprintf('%s %2s %u\n',char(date_str(2,tf,7:12)),'F:',forecast_hour);
                else
                    fprintf('%s \n',char(date_str(2,tf,7:12)));
                end
            end
                
            %Forecast loop. This is not a loop if forecast_hour=0 or 1
            for ti=tf:tf+forecast_index,

              if ti<=max_time,

                %Use road maintenance activity rules to determine activities
                set_activity_data_v2;

                %Loop through the tracks. Future development since num_track=1
                for tr=1:num_track,

                    %Calculate road surface conditions
                    road_dust_surface_wetness_v2;

                    %Calculate road emissions and dust loading
                    road_dust_emission_model_v2;

                end

              end

            end

            %Save the forecast surface temperature into the +forecast index
            forecast_type=1;
            if forecast_hour>0&&tf>min_time&&tf+forecast_index<=max_time,
                %modelled
                if forecast_type==1,
                    forecast_T_s(tf+forecast_index)=road_meteo_data(T_s_index,tf+forecast_index,tr,ro);
                end
                %persistence
                if forecast_type==2,
                    forecast_T_s(tf+forecast_index)=road_meteo_data(T_s_index,tf-1,tr,ro);
                end
                %linear extrapolation
                if forecast_type==3&&tf-1>min_time,
                    forecast_T_s(tf+forecast_index)=interp1(date_data(datenum_index,tf-2:tf-1),...
                    road_meteo_data(T_s_index,tf-2:tf-1,tr,ro),date_data(datenum_index,tf+forecast_index),'linear','extrap');                
                end
            end
            
            %Redistribute mass and moisture between tracks.
            %Not implemented yet

        end
        %End main time loop
        %----------------------------------------------------------------------

        %Put forecast surface temperature into the normal road temperature
        if forecast_hour>0,
            road_meteo_data(T_s_index,min_time:max_time,tr,ro)=forecast_T_s(min_time:max_time);
        end

        %Calculate dispersion factors using ospm or NOx
        if use_ospm_flag,
            fprintf('Calculating dispersion using OSPM\n');
            road_dust_ospm_v1;
        else
            fprintf('Calculating dispersion using NOX\n');
            road_dust_dispersion_v1;
        end

        %Calculate concentrations
        fprintf('Calculating concentrations and converting variables\n');
        road_dust_concentrations;

        %Put binned balance data into normal arrays.
        road_dust_convert_variables;

      end
      %--------------------------------------------------------------------------
      %End road loop
    
    end
    %--------------------------------------------------------------------------
    %if use_fortran_flag=0
     
    fprintf('Finished calculations\n');

%Set the title string for plots and files
    if isempty(filename_outputdata),
        filename_outputdata=filename_inputdata;
    end
    if isempty(title_str),
        k = findstr(filename_outputdata,'.');if k>0, title_str=filename_outputdata(1:k-1);else title_str=filename_outputdata; end
        %Remove input data if it exists in the title_str
        k2 = findstr(title_str,'input data');if k2>0, title_str=filename_outputdata(1:k2-2);end
    end
    %Remove underscores form title because this gives subscipts
    k = findstr(title_str,'_');if k>0, title_str(k)=' ';end

%Plot results
%Set the plotting and saving times
    %Set the start and end index to be the the saving times
    min_time=min_time_save;
    max_time=max_time_save;

    %Restore these after looping through the subdates, if any
    min_time_original=min_time;
    max_time_original=max_time;
    
    %Plot individual subdate periods
    for i_subdate=1:n_save_subdate
        %Change the date if there is more than one
        if n_save_subdate>1
            start_date_str=char(start_subdate_save_str{i_subdate});
            end_date_str=char(end_subdate_save_str{i_subdate});
            min_time=min_subtime_save(i_subdate);
            max_time=max_subtime_save(i_subdate);
        end

        plot_road_dust_results_v2

        %Save plots
        if save_type_flag==2||save_type_flag==3
            fprintf('Saving plots\n');
            save_plot_road_dust_results_2
        end
    end
    
    %Restore original for any date saving
    min_time=min_time_original;
    max_time=max_time_original;

 %If there are more than 1 subdate then save the data over the whole period, not the first date only
    if n_save_subdate>1
        min_time=min(min_subtime_save);
        max_time=max(max_subtime_save);
    end

%Save data
    if save_type_flag==1||save_type_flag==3
        save_data_as_text=0;
        save_average_flag=1;%This means it saves using the current plot averaging value
        fprintf('Saving data\n');
        %Set filenames according to the title_str
        filename_outputdata=[title_str,'_data'];
        path_filename_outputdata_data=[path_outputdata,filename_outputdata];
        save_road_dust_results_average_v2
    end

    if save_type_flag==4
        save_data_as_text=1;
        save_average_flag=1;%This means it saves using the current plot averaging value
        fprintf('Saving data in text file\n');
        %Set filenames according to the title_str
        filename_outputdata=[title_str,'_data'];
        path_filename_outputdata_data=[path_outputdata,filename_outputdata];
        save_road_dust_results_average_v2
    end

%End control script for running the NORTRIP model
%==========================================================================


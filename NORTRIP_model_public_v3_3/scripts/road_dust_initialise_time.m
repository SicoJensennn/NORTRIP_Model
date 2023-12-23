%Set time loop index
    min_time=1;
    max_time=n_date;
    max_time_inputdata=n_date;

%Set time step for iteration based on the first time step of the input data
    dt=(date_data(datenum_index,min_time+1)-date_data(datenum_index,min_time))*24;

%Flag for incorrect start and stop times. Stops model run
    time_bad=0;
    
%Set start and end dates based on date string (if specified in 'set_road_dust_inputdata_files_v1')
    if ~isempty(start_date_str)
        [Y, M, D, H, MN, S] = datevec(start_date_str,date_format_str);
        rstart=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rstart)==1,min_time=rstart;else fprintf('Start date not found. Stopping \n');time_bad=1;return;end
    end
    if ~isempty(end_date_str)
        [Y, M, D, H, MN, S] = datevec(end_date_str,date_format_str);
        rend=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rend)==1,max_time=rend;else fprintf('End date not found. Stopping \n');time_bad=1;return;end
    end
%Set start and end dates for plotting and saving based on date string (if specified)
    if ~isempty(start_date_save_str)
        [Y, M, D, H, MN, S] = datevec(start_date_save_str,date_format_str);
        rstart=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rstart)==1,min_time_save=rstart;else fprintf('Start save date not found. Stopping \n');time_bad=1;return;end
    else
        min_time_save=min_time;
    end
    if ~isempty(end_date_save_str)
        [Y, M, D, H, MN, S] = datevec(end_date_save_str,date_format_str);
        rend=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rend)==1,max_time_save=rend;else fprintf('End save date not found. Stopping \n');time_bad=1;return;end
    else
        max_time_save=max_time;
    end

%Set the subdate start and end dates for plotting and saving based on date string (if specified)
    if n_save_subdate>1
    for i_subdate=1:n_save_subdate
        [Y, M, D, H, MN, S] = datevec(char(start_subdate_save_str{i_subdate}),date_format_str);
        rstart=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rstart)==1,min_subtime_save(i_subdate)=rstart;else fprintf('Start save subdate not found. Stopping \n');time_bad=1;return;end
        [Y, M, D, H, MN, S] = datevec(char(end_subdate_save_str{i_subdate}),date_format_str);
        rend=find(Y==date_data(year_index,:)&M==date_data(month_index,:)&D==date_data(day_index,:)&H==date_data(hour_index,:));
        if length(rend)==1,max_subtime_save(i_subdate)=rend;else fprintf('End save subdate not found. Stopping \n');time_bad=1;return;end
    end
    end

    %Always run all the data when using fortran
    if use_fortran_flag
        min_time=1;
        max_time=n_date;
    end

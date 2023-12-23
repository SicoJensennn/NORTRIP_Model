%==========================================================================
%NORTRIP model
%SUBROUTINE: save_plot_road_dust_results_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Saves figures made by the NORTRIP model
%==========================================================================

if exist('plot_figure')
    for i=1:length(plot_figure)
    if plot_figure(i)==1
        plot_name=get(handle_plot(i),'Name');
        filename_outputfigures=[title_str,'_',char(av_str{plot_type_flag}),'_fig'];
        filename=[path_outputfig,filename_outputfigures,'_',num2str(i),'_',plot_name];
        %If there are more than one subdates than add the start and stop date to the figure name
        %if n_save_subdate>1
            file_start_date=datestr(date_num(min_time),'yyyymmdd');file_end_date=datestr(date_num(max_time),'yyyymmdd');
            filename=[path_outputfig,filename_outputfigures,'_',num2str(i),'_',plot_name,'_',file_start_date,'-',file_end_date];
        %end
        %saveas(i,filename,'tiff');
        saveas(i,filename,'png');
    end
    end
end
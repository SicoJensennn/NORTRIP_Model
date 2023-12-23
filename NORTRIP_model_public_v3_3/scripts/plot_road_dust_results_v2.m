%==========================================================================
%NORTRIP model
%SUBROUTINE: plot_road_dust_results_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Plots results for the NORTTRIP model
%==========================================================================

%Sets which plots to show
 plot_figure=[1 1 1 1 1 1 1 0 0 0 1 0 1 0];%All normal plots
%plot_figure=[0 0 0 0 0 0 0 0 0 0 0 0 1 0];%Just the summary
%plot_figure=[0 0 0 1 0 0 0 1 0 0 0 0 1 0];%AE article plots
%plot_figure=[1 1 1 1 1 1 1 1 0 0 1 0 1 0];
%plot_figure=[0 1 0 1 0 1 0 0 0 0 0 0 1 1];%Temperature and other plots
%plot_figure=[0 1 0 0 0 0 0 0 0 0 0 0 1 1];%Meteo, temperature plot and summary
%plot_figure=[0 0 0 1 0 0 0 0 0 0 0 0 0 0];%Moisture plot only
%plot_figure=[0 0 0 1 0 1 0 1 0 0 0 0 1 0];%AE article plots + summary + budget
%plot_figure=[0 0 0 0 0 0 0 0 0 0 1 0 1 0];%Scatter and summary plots

%Open text file for printing
fid_print=1;%print to screen
summary_filename='summary_plot_statistics.txt';
print_results_temp=print_results;
if print_results==0,
   fid_print=fopen(summary_filename,'w');
   print_results=1;
end

handle_plot(1:length(plot_figure))=0;
%Special temperature plot
which_moisture_plot=1;%Plots temperature scatter and mositure hits
which_moisture_plot=3; %This one plots the temperature error instead of moisture
%Moisture plot
show_ploughing=1;
%Special AE plotting routine
plot_emission_factor=1;%or
plot_salt_application=0;
print_sensitivity_output=0;
Salt_obs_available(1:num_salt)=0;
show_salt_budget=0;
    
%Set the averaging time (1=hourly, 2=daily, 3=daily cycle, 4=12 hour starting 10:00)
%plot_type_flag=1;
av=plot_type_flag;
%av=[4 10 22];
%av=3;

%Set the output size fraction
x=plot_size_fraction;
x_load=pm_200;
%x=pm_10;
%x=pm_25;
%x=pm_course;

%Set text string for size fraction
if x==pm_10,
    pm_text='PM_1_0';
elseif x==pm_25,
    pm_text='PM_2_._5';
elseif x==pm_course,
    pm_text='PM_c_o_u_r_s_e';
end

if av(1)==1||av(1)==2||av(1)==4||av(1)==7||av(1)==8,
    xlabel_text='Date';
elseif av(1)==3,
    xlabel_text='Hour';
elseif av(1)==5,
    xlabel_text='Day';
end

%Start the plots
scale_all=3.5;
scale_all=2.9;
scale_x=3.5;scale_y=2.9;
shift_x=20;shift_y=0;
bottom_corner=50;left_corner=10;
fontsize_title=10;
fontsize_legend=7;
fontsize_fig=7;
fontsize_text=7;
day_tick_limit=150;
clear text

if av(1)==1,
   day_tick_limit=day_tick_limit*24;
end

%Initialise temporary files for concentrations. Sum of tracks
ro=1;
tr=1;
clear road_meteo_data_temp C_data_temp E_road_data_temp M_road_data_temp M_road_balance_data_temp
clear g_road_data_temp g_road_balance_data_temp road_meteo_data_temp road_salt_data_temp WR_time_data_temp
clear f_q_temp f_q_obs_temp f_conc_temp
clear meteo_data_temp traffic_data_temp activity_data_temp date_num
road_meteo_data_temp(1:num_road_meteo,1:n_date)=0;
g_road_data_temp(1:num_moisture+2,1:n_date)=0;
g_road_balance_data_temp(1:num_moisture,1:num_moistbalance,1:n_date)=0;
road_salt_data_temp(1:num_saltdata,1:num_salt,1:n_date)=0;
f_q_temp(1:num_source_all,1:n_date)=0;
f_q_obs_temp(1:n_date)=0;

meteo_data_temp(1:num_meteo_index,1:n_date)=0;
traffic_data_temp(1:num_traffic_index,1:n_date)=0;
activity_data_temp(1:num_activity_index,1:n_date)=0;
f_conc_temp(1:n_date)=0;

C_data_temp(:,:,:,:)=sum(C_data(:,:,:,:,1:num_track,ro),5);
E_road_data_temp(:,:,:,:)=sum(E_road_data(:,:,:,:,1:num_track,ro),5);
M_road_data_temp(:,:,:)=sum(M_road_data(:,:,:,1:num_track,ro),4);
M_road_balance_data_temp(:,:,:,:)=sum(M_road_balance_data(:,:,:,:,1:num_track,ro),5);
WR_time_data_temp(:,:)=sum(WR_time_data(1:num_wear,:,1:num_track,ro),3);

meteo_data_temp(:,:)=meteo_data(:,:,ro);
traffic_data_temp(:,:)=traffic_data(:,:,ro);
activity_data_temp(:,:)=activity_data(:,:,ro);
f_conc_temp(:)=f_conc(:,ro);

%If airquality data exists (read from text file)then put it in the correct arrays
%if exist(airquality_data),
%    PM_obs_net(pm_10,:)=airquality_data();
%end


%If show course fraction then create new data
PM_obs_net(pm_course,:)=PM_obs_net(pm_10,:);
PM_obs_net(pm_course,:)=nodata;
PM_obs(pm_course,:)=PM_obs(pm_10,:);
PM_obs(pm_course,:)=nodata;
PM_obs_bg(pm_course,:)=PM_obs_bg(pm_10,:);
PM_obs_bg(pm_course,:)=nodata;
if x==pm_course
    C_data_temp(:,pm_course,:,:)=C_data_temp(:,pm_10,:,:)-C_data_temp(:,pm_25,:,:);
    r1=find(PM_obs(pm_10,:)~=nodata&PM_obs(pm_25,:)~=nodata);
    r2=find(PM_obs_bg(pm_10,:)~=nodata&PM_obs_bg(pm_25,:)~=nodata);
    r3=find(PM_obs_net(pm_10,:)~=nodata&PM_obs_net(pm_25,:)~=nodata);    
    PM_obs(pm_course,r1)=PM_obs(pm_10,r1)-PM_obs(pm_25,r1);
    PM_obs_bg(pm_course,r2)=PM_obs_bg(pm_10,r2)-PM_obs_bg(pm_25,r2);
    PM_obs_net(pm_course,r3)=PM_obs_net(pm_10,r3)-PM_obs_net(pm_25,r3);
    E_road_data_temp(:,pm_course,:,:)=E_road_data_temp(:,pm_10,:,:)-E_road_data_temp(:,pm_25,:,:);
    M_road_data_temp(:,pm_course,:)=M_road_data_temp(:,pm_10,:)-M_road_data_temp(:,pm_25,:);
    M_road_balance_data_temp(:,pm_course,:,:)=M_road_balance_data_temp(:,pm_10,:,:)-M_road_balance_data_temp(:,pm_25,:,:);
end

%Weighted average of tracks for surface concentration values and averages
for tr=1:num_track,
    road_meteo_data_temp(:,:)=road_meteo_data_temp(:,:)+road_meteo_data(:,:,tr,ro).*f_track(tr);
    g_road_data_temp(:,:)=g_road_data_temp(:,:)+g_road_data(1:num_moisture+2,:,tr,ro).*f_track(tr);
    g_road_balance_data_temp(:,:,:)=g_road_balance_data_temp(:,:,:)+g_road_balance_data(:,:,:,tr,ro).*f_track(tr);
    road_salt_data_temp(:,:,:)=road_salt_data_temp(:,:,:)+road_salt_data(:,:,:,tr,ro).*f_track(tr);
    f_q_temp(:,:)=f_q_temp(:,:)+f_q(:,:,tr,ro).*f_track(tr);
    f_q_obs_temp(:)=f_q_obs_temp(:)+f_q_obs(:,tr,ro).*f_track(tr);
end

date_num=date_data(datenum_index,:);


b_factor=1/1000/b_road_lanes;

%Set the plot page parameters for figure 1
%--------------------------------------------------------------------------
if plot_figure(1),
scale=scale_all; %(pixels/mm on screen)
fig1=figure(1);
handle_plot(1)=fig1;
set(fig1,'Name','Traffic','MenuBar','figure','position',[left_corner bottom_corner fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig1);
clf;
n_plot=1;
m_plot=3;

%plot traffic volume
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Traffic'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Traffic volume (veh/hr)';
legend_text={'Total','Light','Heavy','Light studded','Light winter'};
[x_str xplot yplot1]=Average_data_func(date_num,traffic_data_temp(N_total_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,traffic_data_temp(N_v_index(li),:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,traffic_data_temp(N_v_index(he),:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(st,li),:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,traffic_data_temp(N_t_v_index(wi,li),:),min_time,max_time,av);
plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot2,'b--','linewidth',0.5);
plot(xplot,yplot3,'r--','linewidth',0.5);
plot(xplot,yplot4,'m:','linewidth',0.5);
plot(xplot,yplot5,'g--','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
clear N_temp
N_temp(1,:)=traffic_data_temp(N_t_v_index(st,li),:);
r=find((traffic_data_temp(N_v_index(li),:)~=0&traffic_data_temp(N_v_index(li),:)~=nodata));
max_studded_light=max(N_temp(1,r)./traffic_data_temp(N_v_index(li),r))*100;
text(0.8,0.92,['Max LDV studded = ',num2str(max_studded_light,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);

%plot traffic speed
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Traffic speed (km/hr)';
legend_text={'Light','Heavy'};
[x_str xplot yplot1]=Average_data_func(date_num,traffic_data_temp(V_veh_index(li),:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,traffic_data_temp(V_veh_index(he),:),min_time,max_time,av);
plot(xplot,yplot1,'b--','linewidth',1);
plot(xplot,yplot2,'r--','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%plot salting sanding
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Salting/sanding (g/m^2)';
legend_text={'Sanding/10','Salting(na)',['Salting(',salt2_str,')']};
[x_str xplot yplot1]=Average_data_func(date_num,activity_data_temp(M_sanding_index,:)/10,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,activity_data_temp(M_salting_index(1),:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,activity_data_temp(M_salting_index(2),:),min_time,max_time,av);
%bar(xplot, [yplot1 yplot2 yplot3],'EdgeColor','none');
stairs(xplot, yplot1,'b-');
stairs(xplot, yplot2,'g-');
stairs(xplot, yplot3,'g--');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------


%Set the plot page parameters for figure 2
%--------------------------------------------------------------------------
if plot_figure(2),
scale=scale_all; %(pixels/mm on screen)
fig2=figure(2);
handle_plot(2)=fig2;
set(fig2,'Name','Meteorology','MenuBar','figure','position',[left_corner+1*shift_x bottom_corner+1*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig2);
clf;
n_plot=1;
m_plot=5;
use_salt_humidity_flag_plot=1;
if use_salt_humidity_flag==0,use_salt_humidity_flag_plot=0;end

%Plot temperature
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Meteorology'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Temperature (C)';
if road_temperature_obs_available,
    legend_text={'Temperature (C) < 0','Temperature (C) > 0','Road temperature (C)','Observed road'};
    if use_salt_humidity_flag_plot,
        legend_text={'Temperature (C) < 0','Temperature (C) > 0','Road temperature (C)','Observed road','Freezing temperature'};    
    end
else
    legend_text={'Temperature (C) < 0','Temperature (C) > 0','Road temperature (C)'};
    if use_salt_humidity_flag_plot,
        legend_text={'Temperature (C) < 0','Temperature (C) > 0','Road temperature (C)','Freezing temperature'};    
    end
end
[x_str xplot yplot1]=Average_data_func(date_num,meteo_data_temp(T_a_index,:),min_time,max_time,av);
r2=find(yplot1<0);
r3=find(yplot1>=0);
yplot2=yplot1*NaN;
yplot3=yplot1*NaN;
[x_str xplot yplot4]=Average_data_func(date_num,road_meteo_data_temp(T_s_index,:),min_time,max_time,av);
if road_temperature_obs_available,
    [x_str xplot yplot6]=Average_data_func(date_num,road_meteo_data_temp(road_temperature_obs_index,:),min_time,max_time,av);
end
if use_salt_humidity_flag,
    [x_str xplot yplot7]=Average_data_func(date_num,road_meteo_data_temp(T_melt_index,:),min_time,max_time,av);
end
[x_str xplot yplot8]=Average_data_func(date_num,road_meteo_data_temp(T_sub_index,:),min_time,max_time,av);
if ~isempty(r2),yplot2(r2)=yplot1(r2);end
if ~isempty(r3),yplot3(r3)=yplot1(r3);end
plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot3,'r-','linewidth',1);
plot(xplot,yplot4,'m--','linewidth',1);
if road_temperature_obs_available,
plot(xplot,yplot6,'k--','linewidth',1);
end
if use_salt_humidity_flag_plot,
plot(xplot,yplot7,'g--','linewidth',1);
end
plot(xplot,yplot8,'r:','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Plot RH
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Relative humidity (%)';
legend_text={'RH air','RH road','RH salt'};
[x_str xplot yplot1]=Average_data_func(date_num,meteo_data_temp(RH_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,road_meteo_data_temp(RH_s_index,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,road_meteo_data_temp(RH_salt_final_index,:),min_time,max_time,av);
%[x_str xplot yplot3]=Average_data_func(date_num,road_salt_data_temp(RH_salt_index,1,:),min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot2,'m-','linewidth',0.5);
plot(xplot,yplot3,'r:','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Plot cloud cover
sp2=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Cloud cover (%)';
legend_text={'Cloud cover'};
[x_str xplot yplot4]=Average_data_func(date_num,meteo_data_temp(cloud_cover_index,:)*100,min_time,max_time,av);
plot(xplot,yplot4,'k:','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%Plot wind speed
sp3=subplot(m_plot,n_plot,4);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Wind speed (m/s)';
legend_text={'Wind speed'};
[x_str xplot yplot1]=Average_data_func(date_num,meteo_data_temp(FF_index,:),min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
text(0.75,0.92,['Wind speed correction factor = ',num2str(wind_speed_correction,'%4.2f')],'units','normalized','fontsize',fontsize_text);

%plot precipitation
sp4=subplot(m_plot,n_plot,5);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Precipitation (mm/hr)';
legend_text={'Rain','Snow'};
[x_str xplot yplot1]=Average_data_func(date_num,meteo_data_temp(Rain_precip_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,meteo_data_temp(Snow_precip_index,:),min_time,max_time,av);
%bar(xplot, [yplot1 yplot2],'EdgeColor','none','BarWidth',1);
stairs(xplot, yplot1,'b');
stairs(xplot, yplot2,'m');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------

%Set the plot page parameters for figure 3
%--------------------------------------------------------------------------
if plot_figure(3),
scale=scale_all; %(pixels/mm on screen)
fig3=figure(3);
handle_plot(3)=fig3;
set(fig3,'Name','Emissions and mass','MenuBar','figure','position',[left_corner+2*shift_x bottom_corner+2*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig3);
clf;
n_plot=1;
m_plot=3;

%plot emissions
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Emissions (',pm_text,') and mass balance'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Emission (g/km/hr)';
legend_text={'Total','Direct dust','Suspended dust','Exhaust'};
[x_str xplot yplot1]=Average_data_func(date_num,E_road_data_temp(total_dust_index,x,E_total_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,sum(E_road_data_temp(dust_noexhaust_index,x,E_direct_index,:),1),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,E_road_data_temp(exhaust_index,x,E_total_index,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,E_road_data_temp(total_dust_index,x,E_suspension_index,:),min_time,max_time,av);
plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot2,'b-','linewidth',1);
plot(xplot,yplot3,'r-','linewidth',1);
plot(xplot,yplot4,'m--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot road mass
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Mass loading (g/m^2)';
legend_text={'Suspendable dust','Salt(na)',['Salt(',salt2_str,')'],'Suspendable sand','Non-suspendable sand (/10)'};
[x_str xplot yplot1]=Average_data_func(date_num,M_road_data_temp(total_dust_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M_road_data_temp(salt_index(1),x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road_data_temp(sand_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,M_road_data_temp(salt_index(2),x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,(M_road_data_temp(sand_index,pm_all,:)-M_road_data_temp(sand_index,pm_200,:))*b_factor,min_time,max_time,av);

max_plot=max(max([yplot1 yplot2 yplot3]));
[x_str xplot yplot4]=Average_data_func(date_num,activity_data_temp(t_cleaning_index,:),min_time,max_time,av);
r=find(road_meteo_data_temp(T_s_index,:)~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',1);
    legend_text={'Cleaning','Suspendable dust','Salt(na)',['Salt(',salt2_str,')'],'Suspendable sand','Non-suspendable sand (/10)'};
end
plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot2,'g-','linewidth',1);
plot(xplot,yplot5,'g--','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',1);
plot(xplot,yplot6/10,'k:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot Road dust production and sink
sp4=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Rates (g/m^2/hr)';

[x_str xplot yplot1]=Average_data_func(date_num,sum(M_road_balance_data_temp(wear_index,x_load,P_wear_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,sum(M_road_balance_data_temp([fugitive_index sand_index depo_index],x_load,P_depo_index,:),1)...
    +M_road_balance_data_temp(road_index,x_load,P_abrasion_index,:)...
    +sum(M_road_balance_data_temp(all_source_index,x_load,P_crushing_index,:),1),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,-M_road_balance_data_temp(total_dust_index,x_load,S_suspension_index,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,-M_road_balance_data_temp(total_dust_index,x_load,S_dustdrainage_index,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,-M_road_balance_data_temp(total_dust_index,x_load,S_dustspray_index,:),min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,-M_road_balance_data_temp(total_dust_index,x_load,S_cleaning_index,:),min_time,max_time,av);
[x_str xplot yplot7]=Average_data_func(date_num,-M_road_balance_data_temp(total_dust_index,x_load,S_windblown_index,:),min_time,max_time,av);
plot(xplot,yplot1*b_factor,'k-','linewidth',0.5);
plot(xplot,yplot2*b_factor,'k:','linewidth',0.5);
plot(xplot,yplot3*b_factor,'r-','linewidth',0.5);
plot(xplot,yplot4*b_factor,'b-','linewidth',0.5);
plot(xplot,yplot5*b_factor,'m-','linewidth',0.5);
plot(xplot,yplot6*b_factor,'g-','linewidth',0.5);
plot(xplot,yplot7*b_factor,'y-','linewidth',0.5);

ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
sum_P_road_wearsource=sum(sum(M_road_balance_data_temp(wear_index,x_load,P_wear_index,min_time:max_time),1))*b_factor;
sum_P_road_allother=sum(sum(M_road_balance_data_temp([fugitive_index sand_index depo_index],x_load,P_depo_index,min_time:max_time),1)...
    +M_road_balance_data_temp(road_index,x_load,P_abrasion_index,min_time:max_time)...
    +sum(M_road_balance_data_temp(all_source_index,x_load,P_crushing_index,min_time:max_time),1))*b_factor;
sum_S_suspension=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_suspension_index,min_time:max_time))*b_factor;
sum_S_drainage=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_dustdrainage_index,min_time:max_time))*b_factor;
sum_S_spray=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_dustspray_index,min_time:max_time))*b_factor;
sum_S_cleaning=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_cleaning_index,min_time:max_time))*b_factor;
sum_S_ploughing=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_dustploughing_index,min_time:max_time))*b_factor;
sum_S_windblown=sum(-M_road_balance_data_temp(total_dust_index,x_load,S_windblown_index,min_time:max_time))*b_factor;
legend_text={'Wear retention','Other production','Suspension','Drainage','Spray','Cleaning','Windblown'};
legend_text={['Wear retention = ',num2str(sum_P_road_wearsource,'%4.1f'),' (g/m^2)']...
    ,['Other production = ',num2str(sum_P_road_allother,'%4.1f'),' (g/m^2)']...
    ,['Suspension = ',num2str(sum_S_suspension,'%4.1f'),' (g/m^2)']...
    ,['Drainage = ',num2str(sum_S_drainage,'%4.1f'),' (g/m^2)']...
    ,['Spray = ',num2str(sum_S_spray,'%4.1f'),' (g/m^2)']...
    ,['Cleaning = ',num2str(sum_S_cleaning,'%4.1f'),' (g/m^2)']...
    ,['Windblown = ',num2str(sum_S_windblown,'%4.1f'),' (g/m^2)']};

l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
%Write the balance

%{
text(0.7,.95,'Total road dust balance (g/m^2)','fontweight','bold','units','normalized','fontsize',fontsize_text);
text(0.7,0.875,['Wear retention = ',num2str(sum_P_road_wearsource,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.80,['Other production = ',num2str(sum_P_road_allother,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.725,['Suspension= ',num2str(sum_S_suspension,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.65,['Drainage = ',num2str(sum_S_drainage,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.575,['Spray = ',num2str(sum_S_spray,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.5,['Cleaning = ',num2str(sum_S_cleaning,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.425,['Windblown = ',num2str(sum_S_windblown,'%4.1f')],'units','normalized','fontsize',fontsize_text);
%}

if print_results,
fprintf(fid_print,'%-18s\n',[title_str,' (',pm_text,') ',char(av_str(av(1)))]);
fprintf(fid_print,'-----------------------------------------------------\n');
fprintf(fid_print,'Total surface mass budget (g/m^2)\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Wear retention','Other production','Suspension','Drainage','Spray','Cleaning','Ploughing','Windblown');
fprintf(fid_print,'%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\n',sum_P_road_wearsource,sum_P_road_allother,sum_S_suspension,sum_S_drainage,sum_S_spray,sum_S_cleaning,sum_S_ploughing,sum_S_windblown);
end

if print_results&&show_salt_budget,
sum_salt_application=sum(M_road_balance_data_temp(salt_index(1),pm_all,P_depo_index,min_time:max_time))*dt*b_factor;
sum_S_suspension=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_suspension_index,min_time:max_time))*dt*b_factor;
sum_S_emission=sum(-E_road_data_temp(salt_index(1),pm_all,E_suspension_index,min_time:max_time))*dt*b_factor;
sum_S_drainage=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_dustdrainage_index,min_time:max_time))*dt*b_factor;
sum_S_spray=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_dustspray_index,min_time:max_time))*dt*b_factor;
sum_S_cleaning=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_cleaning_index,min_time:max_time))*dt*b_factor;
sum_S_windblown=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_windblown_index,min_time:max_time))*dt*b_factor;
sum_S_ploughing=sum(-M_road_balance_data_temp(salt_index(1),pm_all,S_dustploughing_index,min_time:max_time))*dt*b_factor;
    

fprintf(fid_print,'Total surface salt (NaCl) budget (g/m^2)\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Salt application','Suspension','Total emission','Drainage','Spray','Cleaning','Ploughing','Windblown');
fprintf(fid_print,'%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\n',sum_salt_application,sum_S_suspension,sum_S_emission,sum_S_drainage,sum_S_spray,sum_S_cleaning,sum_S_ploughing,sum_S_windblown);
end

end
%--------------------------------------------------------------------------

%Set the plot page parameters for figure 4
%--------------------------------------------------------------------------
if plot_figure(4),
scale=scale_all; %(pixels/mm on screen)
fig4=figure(4);
handle_plot(4)=fig4;
set(fig4,'Name','Road wetness','MenuBar','figure','position',[left_corner+3*shift_x bottom_corner+3*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig4);
clf;
n_plot=1;
m_plot=3;

%plot road wetness
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Road surface condition'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Surface wetness (mm)';
legend_text={'Modelled water depth'};
[x_str xplot yplot1]=Average_data_func(date_num,g_road_data_temp(water_index,:),min_time,max_time,av);
%[x_str xplot yplot3]=Average_data_func(date_num,g_road_data_temp(water_drainable_index,:),min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',1);
%plot(xplot,yplot3,'r-','linewidth',1);
y_max=max(yplot1)*1.1;
if road_wetness_obs_available&&road_wetness_obs_in_mm,
    [x_str xplot yplot2]=Average_data_func(date_num,meteo_data(road_wetness_obs_input_index,:,ro),min_time,max_time,av);    
    legend_text={'Modelled water depth','Observed water depth'};
    plot(xplot,yplot2,'k--','linewidth',1);
    y_max=max(max(yplot2)*1.1,y_max);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
%y_max=max(yplot1)*1.1;
if ~isnan(y_max),
ylim([0 y_max]);
end

sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Surface snow and ice (mm w.e.)';
[x_str xplot yplot1]=Average_data_func(date_num,g_road_data_temp(snow_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,g_road_data_temp(ice_index,:),min_time,max_time,av);
max_plot=max(max([yplot1;yplot2]));
[x_str xplot yplot3]=Average_data_func(date_num,activity_data_temp(t_ploughing_index,:),min_time,max_time,av);
r=find(yplot3~=0);
legend_text={'Road snow depth','Road ice depth'};
if ~isempty(r),
    if show_ploughing,
        stairs(xplot,yplot3/max(yplot3)*max_plot,'g-','linewidth',0.5);
        legend_text={'Ploughing','Road snow depth','Road ice depth'};
    else
        legend_text={'Road snow depth','Road ice depth'};
    end
    
end
plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot2,'b--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight

%Plot retention
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Retention factor f_q';
if road_wetness_obs_available==1,
    legend_text={'Road','Brake','Observed'};
    %legend_text={'Modelled retention','Observed retention'};
else
    legend_text={'Road','Brake'};
    %legend_text={'Road'};
end

[x_str xplot yplot1]=Average_data_func(date_num,f_q(road_index,:,tr,ro),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,f_q(brake_index,:,tr,ro),min_time,max_time,av);
if road_wetness_obs_available==1,
    [x_str xplot yplot5]=Average_data_func(date_num,f_q_obs(:,tr,ro),min_time,max_time,av);    
end
plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot4,'m--','linewidth',0.5);
if road_wetness_obs_available==1,
    plot(xplot,yplot5,'k--','linewidth',1);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
ylim([-.05 1.05]);
end
%--------------------------------------------------------------------------

%Set the plot page parameters for figure 5
%--------------------------------------------------------------------------
if plot_figure(5),
scale=scale_all; %(pixels/mm on screen)
fig5=figure(5);
handle_plot(5)=fig5;
set(fig5,'Name','Other factors','MenuBar','figure','position',[left_corner+4*shift_x bottom_corner+4*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig5);
clf;
n_plot=1;
m_plot=4;

%plot effective emission factor
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Other factors'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Emission factor (g/km/veh)';
legend_text={'Modelled emission factor','Observed emission factor'};

clear N_total_temp f_conc_temp2 E_all_temp PM_obs_net_temp ef_temp
clear yplot1 yplot2 yplot3 yplot4 yplot4a yplot4b yplot5 yplot6
N_total_temp(1,:)=traffic_data_temp(N_total_index,:);
f_conc_temp2=f_conc_temp;
%if EP_emis_available,
%    E_all_temp(1,:)=E_all(x,1:max_time)+EP_emis(1:max_time)';
%else
%    E_all_temp(1,:)=E_all(x,1:max_time);
%end
E_all_temp(1,:)=E_road_data_temp(total_dust_index,x,E_total_index,:);
PM_obs_net_temp(1,:)=PM_obs_net(x,:);
r=find(f_conc_temp==nodata|PM_obs_net(x,:)==nodata);
f_conc_temp2(r)=NaN;
%r=find(PM_obs_net(pm_10,:)==nodata);
PM_obs_net_temp(r)=NaN;
%N_total_temp(r)=NaN;
%E_all_temp(r)=NaN;
E_obs_temp=PM_obs_net_temp./f_conc_temp2;

%E_obs_temp=ef_temp.*N_total_temp;
%ef_mod_temp=E_all_temp./N_total_temp;
[x_str xplot yplot4a]=Average_data_func(date_num,PM_obs_net_temp,min_time,max_time,av);
[x_str xplot yplot4b]=Average_data_func(date_num,f_conc_temp2,min_time,max_time,av);
%[x_str xplot yplot4]=Average_data_func(date_num,ef_temp,min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,E_all_temp,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,E_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_total_temp,min_time,max_time,av);
yplot3=yplot1./yplot2;
yplot4=yplot5./yplot2;
%yplot4=yplot4a./yplot4b;
plot(xplot,yplot3,'b-','linewidth',1);
%plot(xplot,yplot4./yplot2,'k--','linewidth',1);
plot(xplot,yplot4,'k--','linewidth',1);

ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%plot concentration conversion factor
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Dispersion factor ((\mug/m^3)).(g/km/hr))';
legend_text={'Concentration emission dispersion factor'};
r=find(f_conc_temp==nodata);
f_conc_temp2=f_conc_temp;
f_conc_temp2(r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,f_conc_temp2,min_time,max_time,av);
%[x_str xplot yplot2]=Average_data_func(date_num,N_total,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%plot ratio of PM/PM200 and dissolved salt ratio as %
sp2=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Ratio (%)';
legend_text={'Salt(na) solution ratio',['Salt(',salt2_str,') solution ratio']...
    ,'PM10/PM200 ratio surface','PM2.5/PM10 ratio surface','PM2.5/PM10 mod ratio air'...
    ,'PM2.5/PM10 obs ratio air'};
r=find(f_conc_temp==nodata);
C_data_temp2=C_data_temp;
C_data_temp2(:,:,:,r)=NaN;
%C_obs_temp=PM_obs_net(:,:);
clear C_obs_ratio
C_obs_ratio(1,:)=PM_obs_net(pm_25,:)./(PM_obs_net(pm_10,:)+.001);
r_obs=find(PM_obs_net(pm_10,:)==nodata|PM_obs_net(pm_25,:)==nodata|C_obs_ratio(1,:)>1.5|C_obs_ratio(1,:)<-0.1|PM_obs_net(pm_10,:)<2);
%r_obs=find(C_obs_temp==nodata);
C_obs_ratio(1,r_obs)=NaN;
clear M2_salt_temp
M2_salt_temp(:,:)=M_road_data_temp(salt_index,pm_all,:)*b_factor;
%[x_str xplot yplot1]=Average_data_func(date_num,road_salt_data_temp(dissolved_ratio_index,1,:),min_time,max_time,av);
%[x_str xplot yplot2]=Average_data_func(date_num,road_salt_data_temp(dissolved_ratio_index,2,:),min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,M2_salt_temp(1,:)./(M2_salt_temp(1,:)+g_road_data_temp(water_index,:)*1000),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M2_salt_temp(2,:)./(M2_salt_temp(2,:)+g_road_data_temp(water_index,:)*1000),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road_data_temp(total_dust_index,pm_10,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,M_road_data_temp(total_dust_index,pm_200,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,M_road_data_temp(total_dust_index,pm_25,:),min_time,max_time,av);
%[x_str xplot yplot5]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_25,C_total_index,:),1),min_time,max_time,av);
%[x_str xplot yplot6]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_10,C_total_index,:),1),min_time,max_time,av);
%[x_str xplot yplot9]=Average_data_func(date_num,C_obs_temp(pm_10,:),min_time,max_time,av);
%[x_str xplot yplot10]=Average_data_func(date_num,C_obs_temp(pm_25,:),min_time,max_time,av);
[x_str xplot yplot8]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_25,C_total_index,:),1)./sum(C_data_temp2(1:num_source,pm_10,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot11]=Average_data_func(date_num,C_obs_ratio,min_time,max_time,av);

yplot7=yplot3./yplot4;
yplot6=yplot5./yplot3;
%yplot11=yplot10./yplot9;

plot(xplot,yplot1*100,'g-','linewidth',1);
plot(xplot,yplot2*100,'g--','linewidth',1);
plot(xplot,yplot7*100,'r-','linewidth',1);
plot(xplot,yplot6*100,'r--','linewidth',1);
plot(xplot,yplot8*100,'b-','linewidth',1);
plot(xplot,yplot11*100,'k--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%Bulk transfer coefficient (1/r_aero)
sp3=subplot(m_plot,n_plot,4);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Bulk transfer coefficient (m/s)';
legend_text={'With traffic','Without traffic'};
[x_str xplot yplot1]=Average_data_func(date_num,1./road_meteo_data_temp(r_aero_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,1./road_meteo_data_temp(r_aero_notraffic_index,:),min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',0.5);
plot(xplot,yplot2,'r-','linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------


%Set the plot page parameters for figure 7
%--------------------------------------------------------------------------
if plot_figure(6),
scale=scale_all; %(pixels/mm on screen)
fig6=figure(6);
handle_plot(6)=fig6;
set(fig6,'Name','Energy and moisture balance','MenuBar','figure','position',[left_corner+5*shift_x bottom_corner+5*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig6);
clf;
n_plot=1;
m_plot=2;

%plot energy balance
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Energy balance'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Energy (W/m^2)';
%legend_text={'Net short','Net long','Sensible heat','Latent heat','Surface heat flux','Traffic heat flux'};
[x_str xplot yplot1]=Average_data_func(date_num,road_meteo_data_temp(rad_net_index,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,road_meteo_data_temp(short_rad_net_index,:),min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,road_meteo_data_temp(long_rad_net_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,-road_meteo_data_temp(H_index,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,-road_meteo_data_temp(L_index,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,road_meteo_data_temp(G_index,:),min_time,max_time,av);
[x_str xplot yplot7]=Average_data_func(date_num,road_meteo_data_temp(short_rad_net_clearsky_index,:),min_time,max_time,av);
[x_str xplot yplot8]=Average_data_func(date_num,road_meteo_data_temp(H_traffic_index,:),min_time,max_time,av);
[x_str xplot yplot9]=Average_data_func(date_num,road_meteo_data_temp(G_sub_index,:),min_time,max_time,av);

r=find(~isnan(yplot5));
mean_short_rad_net=mean(yplot5(r));
mean_long_rad_net=mean(yplot6(r));
mean_H=mean(yplot2(r));
mean_L=mean(yplot3(r));
mean_H_traffic=mean(yplot8(r));
mean_G=mean(yplot4(r));
mean_G_sub=mean(yplot9(r));
mean_short_rad_net_calc=mean(yplot7(r));

legend_text={['Net shortwave flux = ',num2str(mean_short_rad_net,'%4.2f'),' W/m^2']...
    ,['Net longwave flux = ',num2str(mean_long_rad_net,'%4.2f'),' W/m^2']...
    ,['Sensible heat flux = ',num2str(mean_H,'%4.2f'),' W/m^2']...
    ,['Latent heat flux = ',num2str(mean_L,'%4.2f'),' W/m^2']...
    ,['Surface heat flux = ',num2str(mean_G,'%4.2f'),' W/m^2']...
    ,['Traffic heat flux = ',num2str(mean_H_traffic,'%4.2f'),' W/m^2']...
    ,['Clear sky short = ',num2str(mean_short_rad_net_calc,'%4.2f'),' W/m^2']...
    ,['Sub-surface heat flux = ',num2str(mean_G_sub,'%4.2f'),' W/m^2']};

%plot(xplot,yplot1,'k-','linewidth',0.5);
plot(xplot,yplot5,'k--','linewidth',1);
plot(xplot,yplot6,'k:','linewidth',1);
plot(xplot,yplot2,'r-','linewidth',1);
plot(xplot,yplot3,'b-','linewidth',1);
plot(xplot,yplot4,'g-','linewidth',1);
plot(xplot,yplot8,'m--','linewidth',1);
plot(xplot,yplot7,'m:','linewidth',1);
plot(xplot,yplot9,'c-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Write the balance
%text(0.7,.95,'Mean energy balance (W/m^2)','fontweight','bold','units','normalized','fontsize',fontsize_text);
%text(0.7,0.90,['Net shortwave flux = ',num2str(mean_short_rad_net,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.85,['Net longwave flux = ',num2str(mean_long_rad_net,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.80,['Sensible heat flux= ',num2str(mean_H,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.75,['Latent heat flux = ',num2str(mean_L,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.70,['Traffic heat flux = ',num2str(mean_H_traffic,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.65,['Surface heat flux = ',num2str(mean_G,'%4.2f')],'units','normalized','fontsize',fontsize_text);

if print_results,
fprintf(fid_print,'Energy budget (W/m^2)\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Net shortwave','Net longwave','Net radiation','Sensible heat','Latent heat','Traffic heat','Surface heat','Sub-surface heat');
fprintf(fid_print,'%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\n',mean_short_rad_net,mean_long_rad_net,mean_short_rad_net+mean_long_rad_net,mean_H,mean_L,mean_H_traffic,mean_G,mean_G_sub);
end

%plot evaporation and drainage
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
title([title_str,': Surface water balance'],'fontsize',fontsize_title,'fontweight','bold');
ylabel_text='Rates (mm/hr)';
%legend_text={'Evaporation/condensation','Melt+Rain-Drainage','Freezing','Spray','Wetting'};

[x_str xplot yplot1]=Average_data_func(date_num,-g_road_balance_data_temp(water_index,S_evap_index,:)...
    +g_road_balance_data_temp(water_index,P_evap_index,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,g_road_balance_data_temp(water_index,P_precip_index,:)-g_road_balance_data_temp(water_index,S_drainage_index,:)-g_road_balance_data_temp(water_index,S_drainage_tau_index,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,g_road_balance_data_temp(water_index,P_melt_index,:),min_time,max_time,av);
[x_str xplot yplot7]=Average_data_func(date_num,-g_road_balance_data_temp(water_index,S_freeze_index,:),min_time,max_time,av);
[x_str xplot yplot9]=Average_data_func(date_num,-g_road_balance_data_temp(water_index,S_spray_index,:),min_time,max_time,av);
[x_str xplot yplot10]=Average_data_func(date_num,activity_data(g_road_wetting_index,:)/dt*use_wetting_data_flag,min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,-g_road_balance_data_temp(water_index,S_drainage_index,:)-g_road_balance_data_temp(water_index,S_drainage_tau_index,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,g_road_balance_data_temp(water_index,P_precip_index,:),min_time,max_time,av);


r=find(~isnan(yplot1));
mean_evap=mean(yplot1(r));
mean_rain_drain=mean(yplot3(r));
mean_freeze=mean(yplot7(r));
mean_spray=mean(yplot9(r));
mean_wetting=mean(yplot10(r));
mean_melt=mean(yplot5(r));
mean_rain=mean(yplot2(r));
mean_drain=mean(yplot4(r));

plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot3,'r-','linewidth',1);
plot(xplot,yplot5,'g-','linewidth',1);
plot(xplot,yplot7,'c-','linewidth',1);
plot(xplot,yplot9,'m-','linewidth',1);
plot(xplot,yplot10,'y-','linewidth',1);
%plot(xplot,yplot5,'k-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
legend_text={['Evap/condens = ',num2str(mean_evap*1000,'%4.2f'),' (\mum/hr)']...
    ,['Rain-drainage = ',num2str(mean_rain_drain*1000,'%4.2f'),' (\mum/hr)']...
    ,['Melt = ',num2str(mean_melt*1000,'%4.2f'),' (\mum/hr)']...
    ,['Freezing = ',num2str(mean_freeze*1000,'%4.2f'),' (\mum/hr)']...
    ,['Spray = ',num2str(mean_spray*1000,'%4.2f'),' (\mum/hr)']...
    ,['Wetting = ',num2str(mean_wetting*1000,'%4.2f'),' (\mum/hr)']};

l1=legend(legend_text,'Location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Write the budget
%text(0.7,.95,'Mean moisture budget (x 10^-^3 mm/hr)','fontweight','bold','units','normalized','fontsize',fontsize_text);
%text(0.7,0.90,['Evaporation/condensation = ',num2str(mean_evap*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.85,['Rain-drainage = ',num2str(mean_rain_drain*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.80,['Melt = ',num2str(mean_melt*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.75,['Freezing = ',num2str(mean_freeze*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.70,['Spray = ',num2str(mean_spray*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%text(0.7,0.65,['Wetting = ',num2str(mean_wetting*1000,'%4.2f')],'units','normalized','fontsize',fontsize_text);

if print_results,
fprintf(fid_print,'Moisture budget (mm/day)\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Rain','Drainage','Rain-drainage','Evaporation','Melt','Freezing','Spray','Wetting');
fprintf(fid_print,'%-18.4f\t%-18.4f\t%-18.4f\t%-18.4f\t%-18.4f\t%-18.4f\t%-18.4f\t%-18.4f\n',mean_rain*24,mean_drain*24,mean_rain_drain*24,mean_evap*24,mean_melt*24,mean_freeze*24,mean_spray*24,mean_wetting*24);
end

end
%--------------------------------------------------------------------------
%Set the plot page parameters for figure 7
%--------------------------------------------------------------------------
if plot_figure(7),
scale=scale_all; %(pixels/mm on screen)
fig7=figure(7);
handle_plot(7)=fig7;
set(fig7,'Name','Concentrations','MenuBar','figure','position',[left_corner+6*shift_x bottom_corner+6*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig7);
clf;
n_plot=1;
m_plot=3;

%plot concentrations
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Net concentrations'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='PM_1_0 concentration (\mug/m^3)';
legend_text={'Observed','Modelled salt(na)',['Modelled salt(',salt2_str,')'],'Modelled wear','Modelled sand','Modelled total'};
if Salt_obs_available(na),
legend_text={'Observed','Modelled salt(na)',['Modelled salt(',salt2_str,')'],'Modelled wear','Modelled sand','Modelled total','Observed salt'};    
end
r=find(f_conc_temp==nodata|PM_obs_net(pm_10,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;
if Salt_obs_available(na),
    r_salt=find(Salt_obs(na,:)==nodata);
    Salt_obs(na,r_salt)=NaN;
end
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(all_source_index,pm_10,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_data_temp2(salt_index(1),pm_10,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,sum(C_data_temp2(wear_index,pm_10,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_data_temp2(sand_index,pm_10,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,C_data_temp2(salt_index(2),pm_10,C_total_index,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',1);
plot(xplot,yplot3,'g-','linewidth',1);
plot(xplot,yplot6,'g--','linewidth',1);
plot(xplot,yplot4,'r:','linewidth',1);
plot(xplot,yplot5,'m--','linewidth',1);
plot(xplot,yplot1,'b-','linewidth',1);
%plot(xplot,yplot5,'b-','linewidth',0.5);
%plot(xplot,yplot6,'b:','linewidth',0.5);
if Salt_obs_available(na),
[x_str xplot yplot7]=Average_data_func(date_num,Salt_obs(na,:),min_time,max_time,av);
plot(xplot,yplot7,'g-','linewidth',1);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
y_max=max([yplot1;yplot2;yplot3;yplot4;yplot5])*1.1;
if ~isnan(y_max),
ylim([0 y_max]);
end

sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='PM_2_._5 concentration (\mug/m^3)';
legend_text={'Observed','Exhaust','Modelled total'};
PM_obs_net_temp=PM_obs_net;
r=find(f_conc_temp==nodata|PM_obs_net(pm_25,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(pm_25,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_25,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_25,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_data_temp2(exhaust_index,pm_25,C_total_index,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',1);
plot(xplot,yplot3,'m:','linewidth',1);
plot(xplot,yplot1,'b-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='NO_X concentration (\mug/m^3)';
legend_text={'Observed','Background','Net'};
r_obs=find(NOX_obs==nodata);
r_background=find(NOX_background==nodata);
r_obs_net=find(NOX_obs_net==nodata);
NOX_obs_temp=NOX_obs;
NOX_background_temp=NOX_background;
NOX_obs_net_temp=NOX_obs_net;
NOX_obs_temp(r_obs)=NaN;
NOX_background_temp(r_background)=NaN;
NOX_obs_net_temp(r_obs_net)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,NOX_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,NOX_background_temp,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,NOX_obs_net_temp,min_time,max_time,av);
plot(xplot,yplot1,'r--','linewidth',0.5);
plot(xplot,yplot2,'b--','linewidth',0.5);
plot(xplot,yplot3,'k-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------
%Set the plot page parameters for figure 11
%--------------------------------------------------------------------------
if plot_figure(11),
scale=scale_all; %(pixels/mm on screen)
fig11=figure(11);
handle_plot(11)=fig11;
set(fig11,'Name','Scatter plots','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig11);
clf;
n_plot=2;
m_plot=2;

%plot concentrations
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
if EP_emis_available,
    title([title_str,': Scatter plot total net PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': Scatter plot net non-exhaust PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
end
hold on
ylabel_text='PM_1_0 observed concentration (\mug/m^3)';
xlabel_text='PM_1_0 modelled concentration (\mug/m^3)';
%legend_text={'Modelled','Observed','Modelled salt','Modelled dust'};
r=find(f_conc_temp==nodata|PM_obs_net(pm_10,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;

[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_10,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'bo','markersize',4);
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
if ~isempty(max_plot),
    xlim([0 max_plot]);
    ylim([0 max_plot]);
end
grid on
%Calculate some basic statistics and display them
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_pm10=Rcor(1,2).^2;
rmse_pm10=rmse(yplot1(r),yplot2(r));
fr_bias_pm10=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_pm10=length(rfac)/length(r);
mean_obs_pm10=mean(yplot2(r));
mean_mod_pm10=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);

text(0.05,0.95,['r^2  = ',num2str(r_sq_pm10,'%4.2f')],'units','normalized');
text(0.05,0.88,['RMSE = ',num2str(rmse_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.05,0.81,['OBS  = ',num2str(mean_obs_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.05,0.74,['MOD  = ',num2str(mean_mod_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized');

text(0.55,0.2-.1,['a_0  = ',num2str(a_reg(2),'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.55,0.13-.1,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized');

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);

drawnow

sp2=subplot(m_plot,n_plot,2);
%Order for quantile plots
set(gca,'fontsize',fontsize_fig);
hold on
if EP_emis_available,
    title([title_str,': QQ plot total net PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': QQ plot net non-exhaust PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
end
r=find(~isnan(yplot1)&~isnan(yplot2));
yplot1_sort=sort(yplot1(r));
yplot2_sort=sort(yplot2(r));
plot(yplot1_sort,yplot2_sort,'ro','markersize',4);
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1_sort),max(yplot2_sort));
if ~isempty(max_plot),
    xlim([0 max_plot]);
    ylim([0 max_plot]);
end
grid on
if av(1)==2,
    if length(yplot1_sort)>36,high36_mod=yplot1_sort(end-35);else high36_mod=0;end
    if length(yplot2_sort)>36,high36_obs=yplot2_sort(end-35);else high36_obs=0;end
    r=find(yplot1>50);ex50_mod=length(r);
    r=find(yplot2>50);ex50_obs=length(r);
    text(0.05,0.95,['36th highest MOD  = ',num2str(high36_mod,'%4.1f'),' (\mug/m^3)'],'units','normalized');
    text(0.05,0.88,['36th highest OBS  = ',num2str(high36_obs,'%4.1f'),' (\mug/m^3)'],'units','normalized');
    text(0.05,0.81,['Days > 50 \mug/m^3 MOD= ',num2str(ex50_mod,'%4.0f')],'units','normalized');
    text(0.05,0.74,['Days > 50 \mug/m^3 OBS  = ',num2str(ex50_obs,'%4.0f')],'units','normalized');    
end

drawnow

sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
if EP_emis_available,
    title([title_str,': Scatter plot total net PM_2_._5'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': Scatter plot net non-exhaust PM_2_._5'],'fontsize',fontsize_title,'fontweight','bold');
    
end
hold on
ylabel_text='PM_2_._5 observed concentration (\mug/m^3)';
xlabel_text='PM_2_._5 modelled concentration (\mug/m^3)';
r=find(f_conc_temp==nodata|PM_obs_net(pm_25,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(pm_25,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,pm_25,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_25,:),min_time,max_time,av);
r=find(~isnan(yplot1)&~isnan(yplot2));
if length(r)>1,
plot(yplot1(r),yplot2(r),'bo','markersize',4);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
if ~isempty(max_plot),
    xlim([0 max_plot]);
    ylim([0 max_plot]);
end
grid on
%Calculate some basic statistics and display them
if length(r)>1,
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_pm25=Rcor(1,2).^2;
rmse_pm25=rmse(yplot1(r),yplot2(r));
fr_bias_pm25=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_pm25=length(rfac)/length(r);
mean_obs_pm25=mean(yplot2(r));
mean_mod_pm25=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);

text(0.05,0.95,['r^2  = ',num2str(r_sq_pm25,'%4.2f')],'units','normalized');
text(0.05,0.88,['RMSE = ',num2str(rmse_pm25,'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.05,0.81,['OBS  = ',num2str(mean_obs_pm25,'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.05,0.74,['MOD  = ',num2str(mean_mod_pm25,'%4.1f'),' (\mug/m^3)'],'units','normalized');

text(0.55,0.2-.1,['a_0  = ',num2str(a_reg(2),'%4.1f'),' (\mug/m^3)'],'units','normalized');
text(0.55,0.13-.1,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized');

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);
drawnow
end

sp4=subplot(m_plot,n_plot,4);
set(gca,'fontsize',fontsize_fig);
%Order for quantile plots
hold on
if EP_emis_available,
    title([title_str,': QQ plot PM_2_._5 + EP'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': QQ plot PM_2_._5'],'fontsize',fontsize_title,'fontweight','bold');
end
r=find(~isnan(yplot1)&~isnan(yplot2));
yplot1_sort=sort(yplot1(r));
yplot2_sort=sort(yplot2(r));
plot(yplot1_sort,yplot2_sort,'ro','markersize',4);
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1_sort),max(yplot2_sort));
if ~isempty(max_plot),
    xlim([0 max_plot]);
    ylim([0 max_plot]);
end
grid on
drawnow

end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Set the plot page parameters for figure 13
%--------------------------------------------------------------------------
if plot_figure(13),
scale=scale_all; %(pixels/mm on screen)
fig13=figure(13);
handle_plot(13)=fig13;
set(fig13,'Name','Summary','MenuBar','figure','position',[left_corner+9*shift_x bottom_corner+9*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig13);
clf;
n_plot=1;
m_plot=3;

%plot concentrations
sp1=subplot(4,1,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': ',pm_text],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text=[pm_text,' concentration (\mug/m^3)'];
xlabel_text='Date';
legend_text={'Observed','Modelled salt(na)',['Modelled salt(',salt2_str,')'],'Modelled wear','Modelled sand','Modelled total'};
r=find(f_conc_temp==nodata|PM_obs_net(x,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(x,r)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(all_source_index,x,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(x,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_data_temp2(salt_index(1),x,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,sum(C_data_temp2(wear_index,x,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_data_temp2(sand_index,x,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,C_data_temp2(salt_index(2),x,C_total_index,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',1);
plot(xplot,yplot3,'g-','linewidth',1);
plot(xplot,yplot6,'g--','linewidth',1);
plot(xplot,yplot4,'r:','linewidth',1);
plot(xplot,yplot5,'m--','linewidth',1);
plot(xplot,yplot1,'b-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
y_max=max([yplot1;yplot2;yplot3;yplot4;yplot5])*1.1;
if ~isnan(y_max),
ylim([0 y_max]);
end

%axis tight
drawnow

sp2=subplot(4,1,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Mass loading (g/m^2)';
%legend_text={'Suspendable dust','Road salt','Dissolved salt','Suspendable sand'};
legend_text={'Suspendable dust','Salt(na)',['Salt(',salt2_str,')'],'Suspendable sand'};
[x_str xplot yplot1]=Average_data_func(date_num,M_road_data_temp(total_dust_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M_road_data_temp(salt_index(1),x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road_data_temp(sand_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,M_road_data_temp(salt_index(2),x_load,:)*b_factor,min_time,max_time,av);

max_plot=max(max([yplot1 yplot2 yplot3]));
[x_str xplot, yplot4]=Average_data_func(date_num,activity_data(t_cleaning_index,:),min_time,max_time,av);
r=find(activity_data(t_cleaning_index,:)~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',0.5);
    legend_text={'Cleaning','Suspendable dust','Salt(na)',['Salt(',salt2_str,')'],'Suspendable sand'};
end
plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot2,'g-','linewidth',1);
plot(xplot,yplot5,'g--','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot concentrations scatter
sp1=subplot(4,3,7);
set(gca,'fontsize',fontsize_fig);
if EP_emis_available,
    title('Scatter daily mean','fontsize',fontsize_title,'fontweight','bold');
else
    title('Scatter daily mean no exhaust','fontsize',fontsize_title,'fontweight','bold');
end
hold on
ylabel_text=[pm_text,' observed concentration (\mug/m^3)'];
xlabel_text=[pm_text,' modelled concentration (\mug/m^3)'];
r=find(f_conc_temp==nodata|PM_obs_net(x,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(x,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(1:num_source,x,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(x,:),min_time,max_time,av);


r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'bo','markersize',4);
ylabel(ylabel_text,'fontsize',fontsize_fig);
xlabel(xlabel_text,'fontsize',fontsize_fig);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
if ~isempty(max_plot),
    xlim([0 max_plot]);
    ylim([0 max_plot]);
end
%grid on
%Calculate some basic statistics and display them
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_pm10=Rcor(1,2).^2;
rmse_pm10=rmse(yplot1(r),yplot2(r));
fr_bias_pm10=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_pm10=length(rfac)/length(r);
mean_obs_pm10=mean(yplot2(r));
mean_mod_pm10=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);

text(0.05,0.95,['r^2  = ',num2str(r_sq_pm10,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.05,0.85,['RMSE = ',num2str(rmse_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.05,0.75,['OBS  = ',num2str(mean_obs_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.05,0.65,['MOD  = ',num2str(mean_mod_pm10,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);

text(0.55,0.2-.0,['a_0  = ',num2str(a_reg(2),'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.55,0.1-.0,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized','fontsize',fontsize_text);

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);

drawnow

%Calculate summary statistics
%emissions
%x=pm_10;

clear E_all_m_temp E_suspension_all_temp E_direct_all_temp E_all_temp E_exhaust_temp
E_all_temp(:,1)=E_road_data_temp(total_dust_index,x,E_total_index,min_time:max_time);
total_emissions=mean(E_all_temp);
total_ef=mean(E_all_temp)./mean(traffic_data_temp(N_total_index,min_time:max_time));

%Not used
%E_all_m_temp(:,1)=E_road_data_temp(total_dust_index,x,E_total_index,min_time:max_time)-E_road_data_temp(exhaust_index,x,E_total_index,min_time:max_time);
%dust_emissions=mean(E_all_m_temp);
%dust_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

E_suspension_all_temp(:,1)=sum(E_road_data_temp(dust_noexhaust_index,x,E_suspension_index,min_time:max_time),1);
suspension_emissions=mean(E_suspension_all_temp);
suspension_ef=mean(E_suspension_all_temp)./mean(traffic_data_temp(N_total_index,min_time:max_time));

E_direct_all_temp(:,1)=sum(E_road_data_temp(dust_noexhaust_index,x,E_direct_index,min_time:max_time),1);
direct_emissions=mean(E_direct_all_temp);
direct_ef=mean(E_direct_all_temp)./mean(traffic_data_temp(N_total_index,min_time:max_time));

E_exhaust_temp(:,1)=E_road_data_temp(exhaust_index,x,E_total_index,min_time:max_time);
exhaust_emissions=mean(E_exhaust_temp);
exhaust_ef=mean(E_exhaust_temp)./mean(traffic_data_temp(N_total_index,min_time:max_time));

%{
sand_emissions=mean(E_all_m(dust(sussand),x,min_time:max_time));
E_all_m_temp(:,1)=E_all_m(dust(sussand),x,min_time:max_time);
sand_ef=mean(E_all_m_temp./N_total(min_time:max_time));
sand_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

salt_emissions=mean(E_all_m(salt(1),x,min_time:max_time)+E_all_m(salt(2),x,min_time:max_time));
E_all_m_temp(:,1)=E_all_m(salt(1),x,min_time:max_time)+E_all_m(salt(2),x,min_time:max_time);
salt_ef=mean(E_all_m_temp./N_total(min_time:max_time));
salt_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

if EP_emis_available,
    exhaust_emissions=mean(EP_emis(min_time:max_time));
else
    exhaust_emissions=0;
end
exhaust_ef=mean(EP_emis(min_time:max_time)./N_total(min_time:max_time));
exhaust_ef=mean(EP_emis(min_time:max_time))./mean(N_total(min_time:max_time));
%}

%concentrations
clear PM_obs_net_temp PM_obs_bg_temp f_conc_temp2 C_all_m_temp2 C_all_temp2 C_all_m_wearsource_temp C_ep_temp
PM_obs_net_temp(1,:)=PM_obs_net(x,min_time:max_time);
PM_obs_bg_temp(1,:)=PM_obs_bg(x,min_time:max_time);
f_conc_temp2=f_conc_temp(min_time:max_time);
C_all_m_temp2(:,:,:)=C_data_temp(:,:,C_total_index,min_time:max_time);
r=find(PM_obs_net_temp~=nodata&f_conc_temp2~=nodata);
r_bg=find(PM_obs_net_temp~=nodata&f_conc_temp2~=nodata&PM_obs_bg_temp~=nodata);
rf_conc=find(f_conc_temp2~=nodata);

dust_concentrations=mean(C_all_m_temp2(total_dust_index,x,r)-C_all_m_temp2(sand_index,x,r)-C_all_m_temp2(exhaust_index,x,r));
sand_concentrations=mean(C_all_m_temp2(sand_index,x,r));
salt_concentrations(1)=mean(C_all_m_temp2(salt_index(1),x,r));
salt_concentrations(2)=mean(C_all_m_temp2(salt_index(2),x,r));
salt_concentrations_all=salt_concentrations(1)+salt_concentrations(2);
exhaust_concentrations=mean(C_all_m_temp2(exhaust_index,x,r));
roadwear_concentrations=mean(C_all_m_temp2(road_index,x,r));
tyrewear_concentrations=mean(C_all_m_temp2(tyre_index,x,r));
brakewear_concentrations=mean(C_all_m_temp2(brake_index,x,r));
total_concentrations=mean(sum(C_all_m_temp2(1:num_source,x,r),1));
observed_concentrations=mean(PM_obs_net_temp(r));
observed_concentrations_bg=mean(PM_obs_bg_temp(r_bg));
comparable_hours=length(r)./length(f_conc_temp2);
mean_f_conc=mean(f_conc_temp2(rf_conc));
%Percentiles and exceedances
clear PM10_obs_net_temp PM10_obs_bg_temp PM10_mod_net_temp
PM10_obs_net_temp(1,:)=PM_obs_net(x,:);
PM10_obs_bg_temp(1,:)=PM_obs_bg(x,:);
PM10_mod_net_temp(1,:)=sum(C_data_temp(1:num_source,x,C_total_index,:),1);
r_bg=find(PM10_obs_net_temp==nodata|f_conc_temp==nodata|PM10_obs_bg_temp==nodata);
PM10_obs_net_temp(r_bg)=NaN;
PM10_obs_bg_temp(r_bg)=NaN;
PM10_mod_net_temp(r_bg)=NaN;

[x_str xplot PM10_mod_net_av_temp]=Average_data_func(date_num,PM10_mod_net_temp,min_time,max_time,av);
[x_str xplot PM10_obs_net_av_temp]=Average_data_func(date_num,PM10_obs_net_temp,min_time,max_time,av);
[x_str xplot PM10_obs_bg_av_temp]=Average_data_func(date_num,PM10_obs_bg_temp,min_time,max_time,av);

r_av=find(~isnan(PM10_mod_net_av_temp)&~isnan(PM10_obs_net_av_temp)&~isnan(PM10_obs_bg_av_temp));

Rcor = corrcoef(PM10_obs_net_av_temp(r_av),PM10_mod_net_av_temp(r_av));
r_sq_net_pm10=Rcor(1,2).^2;
Rcor = corrcoef(PM10_obs_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av),PM10_mod_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av));
r_sq_bg_pm10=Rcor(1,2).^2;

rmse_net = rmse(PM10_obs_net_av_temp(r_av),PM10_mod_net_av_temp(r_av));
rmse_bg = rmse(PM10_obs_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av),PM10_mod_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av));
nrmse_net=rmse_net/mean(PM10_obs_net_av_temp(r_av))*100;
nrmse_bg=rmse_bg/mean(PM10_obs_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av))*100;
fb_net=(mean(PM10_mod_net_av_temp(r_av))-mean(PM10_obs_net_av_temp(r_av)))/(mean(PM10_mod_net_av_temp(r_av))+mean(PM10_obs_net_av_temp(r_av)))*2*100;
fb_bg=(mean(PM10_mod_net_av_temp(r_av))-mean(PM10_obs_net_av_temp(r_av)))/((mean(PM10_mod_net_av_temp(r_av))+mean(PM10_obs_net_av_temp(r_av))+mean(PM10_obs_bg_av_temp(r_av))*2))*2*100;

per=90;
if ~isempty(r_av),
obs_c_sort=sort(PM10_obs_net_av_temp(r_av),'ascend');
mod_c_sort=sort(PM10_mod_net_av_temp(r_av),'ascend');
obs_c_bg_sort=sort(PM10_obs_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av),'ascend');
mod_c_bg_sort=sort(PM10_mod_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av),'ascend');
index_per=round(length(obs_c_sort)*per/100);obs_c_per=obs_c_sort(index_per);
index_per=round(length(mod_c_sort)*per/100);mod_c_per=mod_c_sort(index_per);
index_per=round(length(obs_c_bg_sort)*per/100);obs_c_bg_per=obs_c_bg_sort(index_per);
index_per=round(length(mod_c_bg_sort)*per/100);mod_c_bg_per=mod_c_bg_sort(index_per);
else
obs_c_sort=1;
obs_c_bg_sort=1;
obs_c_per=0;
mod_c_per=0;
obs_c_bg_per=0;
mod_c_bg_per=0;    
end

days_lim=36;
if length(obs_c_sort)>days_lim,
    high36_obs=obs_c_sort(end-days_lim+1);
    high36_mod=mod_c_sort(end-days_lim+1);
    high36_obs_bg=obs_c_bg_sort(end-days_lim+1);
    high36_mod_bg=mod_c_bg_sort(end-days_lim+1);
else
    high36_obs=0;
    high36_mod=0;
    high36_obs_bg=0;
    high36_mod_bg=0;
end

limit=50;
obs_c_ex=length(find(PM10_obs_net_av_temp(r_av)>limit));
mod_c_ex=length(find(PM10_mod_net_av_temp(r_av)>limit));
obs_c_bg_ex=length(find(PM10_obs_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av)>limit));
mod_c_bg_ex=length(find(PM10_mod_net_av_temp(r_av)+PM10_obs_bg_av_temp(r_av)>limit));
obs_c_dif_ex=obs_c_bg_ex-sum(PM10_obs_bg_av_temp(r_av)>limit);
mod_c_dif_ex=mod_c_bg_ex-sum(PM10_obs_bg_av_temp(r_av)>limit);

%emissions
observed_emission=observed_concentrations/mean_f_conc;
%observed_emission=mean(PM_obs_net_temp(r)./f_conc_temp2(r));
observed_ef=mean(PM_obs_net_temp(r)./f_conc_temp2(r)./traffic_data_temp(N_total_index,r));


%production
%roadwear_mean=mean(WR_time(road_index,min_time:max_time));
%tyrewear_mean=mean(WR_time(tyre_index,min_time:max_time));
%brakewear_mean=mean(WR_time(brake_index,min_time:max_time));
%salting_mean=mean(P_road(salt(1),min_time:max_time)+P_road(salt(2),min_time:max_time));
%salting_total=sum(P_road(salt(1),min_time:max_time)+P_road(salt(2),min_time:max_time))*dt;
%sussand_mean=mean(P_road(dust(sussand),min_time:max_time));
salting_total=sum(sum(activity_data_temp(M_salting_index,min_time:max_time)))*b_road_lanes*1000;

%sinks
%suspension
%drainage

%Number of salting days
%Number of sanding days
rsalting=find(activity_data_temp(M_salting_index(1),min_time:max_time)>0);
num_salting(1)=length(rsalting);
rsalting=find(activity_data_temp(M_salting_index(2),min_time:max_time)>0);
num_salting(2)=length(rsalting);
rsanding=find(activity_data_temp(M_sanding_index,min_time:max_time)>0);
num_sanding=length(rsanding);
rcleaning=find(activity_data_temp(t_cleaning_index,min_time:max_time)>0);
num_cleaning=length(rcleaning);
rploughing=find(activity_data_temp(t_ploughing_index,min_time:max_time)>0);
num_ploughing=length(rploughing);

%Days and meteo data
num_days=length(date_data(year_index,min_time:max_time))*dt/24;
mean_RH=mean(meteo_data_temp(RH_index,min_time:max_time));
mean_Ta=mean(meteo_data_temp(T_a_index,min_time:max_time));
mean_cloud=mean(meteo_data_temp(cloud_cover_index,min_time:max_time));
mean_short_rad=mean(meteo_data_temp(short_rad_in_index,min_time:max_time));
mean_short_rad_net=mean(road_meteo_data(short_rad_net_index,min_time:max_time));

%Average ADT
clear mean_ADT_all mean_ADT
for t=1:num_tyre,
for v=1:num_veh,
    mean_ADT_all(t,v)=mean(traffic_data_temp(N_t_v_index(t,v),min_time:max_time),2)*24*dt;%(t,v)
end
end
for v=1:num_veh,
    mean_ADT(v)=sum(mean_ADT_all(:,v),1);%(v)
end
clear N_temp
N_temp(1,:)=traffic_data_temp(N_t_v_index(st,li),min_time:max_time);
max_prop_studded(li)=max(N_temp(1,:)./traffic_data_temp(N_v_index(li),min_time:max_time));%v
N_temp(1,:)=traffic_data_temp(N_t_v_index(st,he),min_time:max_time);
max_prop_studded(he)=max(N_temp(1,:)./traffic_data_temp(N_v_index(li),min_time:max_time));%v
prop_studded=mean_ADT_all(st,:)./mean_ADT;
mean_AHT=sum(mean_ADT)/24;
%Average speed
mean_speed(he)=sum(traffic_data_temp(V_veh_index(he),min_time:max_time).*traffic_data_temp(N_v_index(he),min_time:max_time))./sum(traffic_data_temp(N_v_index(he),min_time:max_time));
mean_speed(li)=sum(traffic_data_temp(V_veh_index(li),min_time:max_time).*traffic_data_temp(N_v_index(li),min_time:max_time))./sum(traffic_data_temp(N_v_index(li),min_time:max_time));

%Meteo
%total precipitation
total_precip=sum(meteo_data_temp(Snow_precip_index,min_time:max_time)+meteo_data_temp(Rain_precip_index,min_time:max_time));
%frequency
rsnow=find(meteo_data_temp(Snow_precip_index,min_time:max_time)>0);rrain=find(meteo_data_temp(Rain_precip_index,min_time:max_time)>0);
freq_snow=length(rsnow)/length(meteo_data_temp(Snow_precip_index,min_time:max_time));freq_rain=length(rrain)/length(meteo_data_temp(Rain_precip_index,min_time:max_time));freq_precip=freq_rain+freq_snow;
%proportion wet/dry roads
rwet=find(f_q_temp(road_index,min_time:max_time)<0.5);
rwet_obs=find(f_q_obs_temp(min_time:max_time)<0.5);
rdry=find(f_q_temp(road_index,min_time:max_time)>=0.5);
rdry_obs=find(f_q_obs_temp(min_time:max_time)>=0.5);
prop_wet=length(rwet)/length(f_q_temp(road_index,min_time:max_time));
prop_wet_mod=length(rwet)/length(f_q_temp(road_index,min_time:max_time));
prop_wet_obs=length(rwet_obs)/length(f_q_obs_temp(min_time:max_time));
%Wet dry score
clear r_wetscore f_q_obs_temp2 f_q_road_temp
f_q_obs_temp2(:,1)=f_q_obs_temp(min_time:max_time);
f_q_road_temp(:,1)=f_q_temp(road_index,min_time:max_time);
f_q_obs_temp2(rwet_obs)=-1;
f_q_road_temp(rwet)=-1;
f_q_obs_temp2(rdry_obs)=1;
f_q_road_temp(rdry)=1;
f_q_score=mean(f_q_obs_temp2.*f_q_road_temp);
r_hits=find(f_q_obs_temp2.*f_q_road_temp>0);
f_q_hits=length(r_hits)/length(f_q_road_temp);
rel_prop_wet=length(rwet)/length(rwet_obs);
rel_prop_dry=length(rdry)/length(rdry_obs);
r_wetscore(1)=sum(f_q_obs_temp2<0&f_q_road_temp<0);
r_wetscore(2)=sum(f_q_obs_temp2>0&f_q_road_temp<0);
r_wetscore(3)=sum(f_q_obs_temp2>0&f_q_road_temp>0);
r_wetscore(4)=sum(f_q_obs_temp2<0&f_q_road_temp>0);
rel_prop_wet_wet=length(find(f_q_obs_temp2<0&f_q_road_temp<0))/length(find(f_q_obs_temp2<0));
r_wetscore=r_wetscore/sum(r_wetscore);
r_wetscore(5)=r_wetscore(1)+r_wetscore(3);
r_wetscore(6)=r_wetscore(2)+r_wetscore(4);

%plot emissions
sp1=subplot(4,3,8);
set(gca,'fontsize',fontsize_fig);
%ploty1=[total_emissions dust_emissions sand_emissions salt_emissions exhaust_emissions];
%ploty1=[total_emissions direct_dust_emissions suspension_dust_emissions salt_emissions exhaust_emissions];
ploty1=[observed_emission/mean_AHT*1000 total_emissions/mean_AHT*1000 direct_emissions/mean_AHT*1000 suspension_emissions/mean_AHT*1000 exhaust_emissions/mean_AHT*1000];
ploty2=[observed_emission/mean_AHT*1000 0 0 0 0];
%ploty1=[observed_ef*1000 total_ef*1000 direct_dust_ef*1000 suspension_dust_ef*1000 exhaust_ef*1000];
%ploty2=[observed_ef*1000 0 0 0 0];

hbar1=bar(ploty1,'g');
set(gca,'XTickLabel',{'Obs.','Mod.','Dir.','Sus.','Exh.'},'fontsize',fontsize_fig)
title('Mean emission factor','fontsize',fontsize_title,'fontweight','bold');
ylabel(['Emission factor ',pm_text,' (mg/km/veh)'],'fontsize',fontsize_fig);
for i=1:5,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.0f'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize_text);
    end
end
colormap summer
hold on
hbar2=bar(ploty2,'k');
hold off
xlim([0 6]);

%plot concentrations
sp2=subplot(4,3,9);
set(gca,'fontsize',fontsize_fig);
clear ploty1 ploty2
%ploty1=[observed_concentrations total_concentrations dust_concentrations sand_concentrations salt_concentrations_all exhaust_concentrations];
%ploty2=[observed_concentrations 0 0 0 0 0];
%ploty1=[observed_concentrations total_concentrations roadwear_concentrations tyrewear_concentrations brakewear_concentrations sand_concentrations salt_concentrations_all exhaust_concentrations];
%ploty2=[observed_concentrations 0 0 0 0 0 0 0];
ploty1=[observed_concentrations total_concentrations roadwear_concentrations tyrewear_concentrations brakewear_concentrations sand_concentrations salt_concentrations(1) salt_concentrations(2) exhaust_concentrations];
ploty2=[observed_concentrations 0 0 0 0 0 0 0 0];
hbar1=bar(ploty1,'r');
%set(gca,'XTickLabel',{'Observed','Total','Dust','Sand','Salt','Exhaust'})
%set(gca,'XTickLabel',{'Obs.','Mod.','Road','Tyre','Brake','Sand','Salt','Exh.'})
set(gca,'XTickLabel',{'obs','mod','road','tyre','brake','sand','na',salt2_str,'exh'},'fontsize',fontsize_text-1)
title('Mean concentrations','fontsize',fontsize_title,'fontweight','bold');
ylabel(['Concentration ',pm_text,' (\mug/m^3)'],'fontsize',fontsize_fig);
%for i=1:6,
%for i=1:8,
for i=1:9,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.1f'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize_text);
    end
end
hold on
hbar2=bar(ploty2,'k');
hold off
%xlim([0 9])
xlim([0 10])

%tabulated values
sp5=subplot(4,3,10);
set(gca,'fontsize',fontsize_fig);
axis off
text(0.0,1,'Traffic and activity','fontweight','bold');
%text(0.5,0.90,['Mean ADT (li/he) = ',num2str(mean_ADT(he),'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.90,['Mean ADT  = ',num2str(mean_ADT(li)+mean_ADT(he),'%4.0f'),' (veh)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.80,['Mean ADT (li / he) = ',num2str(mean_ADT(li)/(mean_ADT(li)+mean_ADT(he))*100,'%4.1f'),' / ',num2str(mean_ADT(he)/(mean_ADT(li)+mean_ADT(he))*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
%text(0.5,0.80,['Mean speed (he) = ',num2str(mean_speed(he),'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.00,0.70,['Mean speed (li / he) = ',num2str(mean_speed(li),'%4.1f'),' / ',num2str(mean_speed(he),'%4.1f'),' (km/hr)'],'units','normalized','fontsize',fontsize_text);
%text(0.5,0.70,['Studded (he) = ',num2str(prop_studded(he)*100,'%4.1f'),'%'],'units','normalized','fontsize',fontsize_text);
text(0.00,0.60,['Studded (li / he) = ',num2str(prop_studded(li)*100,'%4.1f'),' / ',num2str(prop_studded(he)*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.50,['Number of days = ',num2str(num_days,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.40,['Number salting events (na/',salt2_str,') = ',num2str(num_salting(1),'%3.0f'),'/',num2str(num_salting(2),'%3.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.30,['Number sanding events = ',num2str(num_sanding,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Number cleaning events = ',num2str(num_cleaning,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['Number ploughing events = ',num2str(num_ploughing,'%4.0f')],'units','normalized','fontsize',fontsize_text);
%title(['Traffic and activity'],'fontsize',fontsize_title,'fontweight','bold');

if print_results,
fprintf(fid_print,'Traffic and activity data\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n',...
    'Number of days','Mean ADT','HDV (%)','Mean speed (km/hr)','Mean studded (%LDV)','Max studded (%LDV)','Total salt (ton/km)','Salting(1) events','Salting(2) events','Sanding events','Cleaning events','Ploughing events');
fprintf(fid_print,'%-18.2f\t%-18.0f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\n',...
    num_days,mean_ADT(li)+mean_ADT(he),mean_ADT(he)/(mean_ADT(li)+mean_ADT(he))*100,mean(mean_speed),prop_studded(li)*100,max_prop_studded(li)*100,salting_total*1e-6,num_salting(1),num_salting(2),num_sanding,num_cleaning,num_ploughing);
end

if print_results,
fprintf(fid_print,'Meteorological data\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Mean Temp(C)','Mean RH(%)','Mean global(W/m^2)','Mean cloud cover(%)','Total precip(mm)','Frequency precip(%)','Frequency wet(%)','Mean dispersion');
fprintf(fid_print,'%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.3f\n',mean_Ta,mean_RH,mean_short_rad,mean_cloud*100,total_precip,freq_precip*100,prop_wet*100,mean_f_conc);
end

if print_results,
fprintf(fid_print,'Source contribution (ug/m^3)\n');
fprintf(fid_print,'%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\t%-18s\n','Observed total','Model total','Model road','Model tyre','Model brake','Model sand','Model salt(na)',['Model salt(',salt2_str,')'],'Model exhaust');
fprintf(fid_print,'%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\t%-18.2f\n',observed_concentrations,total_concentrations,roadwear_concentrations,tyrewear_concentrations,brakewear_concentrations,sand_concentrations,salt_concentrations(1),salt_concentrations(2),exhaust_concentrations);
end

%tabulated values
sp6=subplot(4,3,11);
set(gca,'fontsize',fontsize_fig);
axis off
text(0.0,1,'Meteorology','fontweight','bold');
text(0.0,0.90,['Mean Temperature = ',num2str(mean_Ta,'%4.2f'),' (^oC)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.80,['Mean RH = ',num2str(mean_RH,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.70,['Mean short radiation global/net = ',num2str(mean_short_rad,'%4.1f'),'/',num2str(mean_short_rad_net,'%4.1f'),' (W/m^2)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.60,['Mean cloud cover = ',num2str(mean_cloud*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.50,['Total precipitation = ',num2str(total_precip,'%4.1f'),' (mm)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.40,['Frequency precipitation = ',num2str(freq_precip*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.30,['Frequency wet road = ',num2str(prop_wet*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Relative freq wet road = ',num2str(rel_prop_wet,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['Surface moisture hits = ',num2str(f_q_hits*100,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.00,['Mean dispersion = ',num2str(mean_f_conc,'%4.3f'),' (\mug/m^3.(g/km/hr)^-^1)'],'units','normalized','fontsize',fontsize_text);

%tabulated values
sp6=subplot(4,3,12);
set(gca,'fontsize',fontsize_fig);
axis off
text(0.0,1,['Concentrations ',pm_text],'fontweight','bold');
text(0.0,0.90,['Mean obs (net,total) = ',num2str(observed_concentrations,'%4.1f'),', ',num2str(observed_concentrations+observed_concentrations_bg,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.80,['Mean model (net,total) = ',num2str(total_concentrations,'%4.1f'),', ',num2str(total_concentrations+observed_concentrations_bg,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.70,['Mean background obs = ',num2str(observed_concentrations_bg,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.60,['90th per obs (net,total)  = ',num2str(obs_c_per,'%4.1f'),', ',num2str(obs_c_bg_per,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.50,['90th per model (net,total) = ',num2str(mod_c_per,'%4.1f'),', ',num2str(mod_c_bg_per,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.40,['36th highest obs (net,total)  = ',num2str(high36_obs,'%4.1f'),', ',num2str(high36_obs_bg,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.30,['36th highest model (net,total) = ',num2str(high36_mod,'%4.1f'),', ',num2str(high36_mod_bg,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Days>50 \mug/m^3 obs (net,total) = ',num2str(obs_c_ex,'%4.0f'),', ',num2str(obs_c_bg_ex,'%4.0f'),' (days)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['Days>50 \mug/m^3 model (net,total) = ',num2str(mod_c_ex,'%4.0f'),', ',num2str(mod_c_bg_ex,'%4.0f'),' (days)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.00,['Comparable hours = ',num2str(comparable_hours*100,'%4.1f'),' %'],'units','normalized','fontsize',fontsize_text);

if print_results,
fprintf(fid_print,'Net concentration results (ug/m^3)\n');
fprintf(fid_print,'%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\n','Obs_mean','Mod_mean','Obs_90_per','Mod_90_per','Obs_36_high','Mod_36_high','Obs_ex_50','Mod_ex_50','R_sq','RMSE','NRMSE(%)','FB(%)');
fprintf(fid_print,'%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\n',observed_concentrations,total_concentrations,obs_c_per,mod_c_per,high36_obs,high36_mod,obs_c_dif_ex,mod_c_dif_ex,r_sq_net_pm10,rmse_net,nrmse_net,fb_net);
fprintf(fid_print,'With background concentration results (ug/m^3)\n');
fprintf(fid_print,'%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\n','Obs_mean','Mod_mean','Obs_90_per','Mod_90_per','Obs_36_high','Mod_36_high','Obs_ex_50','Mod_ex_50','R_sq','RMSE','NRMSE(%)','FB(%)');
fprintf(fid_print,'%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\n',observed_concentrations+observed_concentrations_bg,total_concentrations+observed_concentrations_bg,obs_c_bg_per,mod_c_bg_per,high36_obs_bg,high36_mod_bg,obs_c_bg_ex,mod_c_bg_ex,r_sq_bg_pm10,rmse_bg,nrmse_bg,fb_bg);
end
if print_results&&print_sensitivity_output,
fprintf(fid_print,'Sensitivity outputs (ug/m^3)\n');
fprintf(fid_print,'%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\t%-12s\n','Obs_mean','Mod_mean','Obs_per','Mod_per','R_sq','FB(%)','rel_WET_freq','f_q_HITS');
fprintf(fid_print,'%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\t%-12.2f\n',observed_concentrations,total_concentrations,obs_c_per,mod_c_per,r_sq_net_pm10,fb_net,rel_prop_wet,f_q_hits*100);
end

drawnow
end%plot 13

%Special AE plotting routines
if plot_figure(8),
scale=scale_all; %(pixels/mm on screen)
fig8=figure(8);
handle_plot(8)=fig8;
set(fig8,'Name','AE plot','MenuBar','figure','position',[left_corner+9*shift_x bottom_corner+9*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig8);
clf;
n_plot=1;
m_plot=3;
fontsize_fig=8;
fontsize_legend=8;

%plot concentrations
sp1=subplot(2,1,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': PM_1_0 concentrations'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='PM_1_0 concentration (\mug.m^-^3)';
xlabel_text='Date';
legend_text={'Observed','Modelled+exhaust'};
if use_salting_data_flag(1),legend_text={'Observed','Modelled salt','Modelled+exhaust',};end
if use_sanding_data_flag,legend_text={'Observed','Modelled sand','Modelled+exhaust',};end
if use_sanding_data_flag&&use_salting_data_flag(1),legend_text={'Observed','Modelled sand','Modelled salt','Modelled+exhaust',};end

r=find(f_conc_temp==nodata|PM_obs_net(x,:)==nodata);
C_data_temp2=C_data_temp;
PM_obs_net_temp=PM_obs_net;
C_data_temp2(:,:,:,r)=NaN;
PM_obs_net_temp(x,r)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,sum(C_data_temp2(all_source_index,x,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(x,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_data_temp2(salt_index(1),x,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,sum(C_data_temp2(wear_index,x,C_total_index,:),1),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_data_temp2(sand_index,x,C_total_index,:),min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,C_data_temp2(salt_index(2),x,C_total_index,:),min_time,max_time,av);


%{
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
temp=C_all_m(salt_type(1):salt_type(num_salt),:,:);
clear C_salt_sum;
C_salt_sum(:,:)=sum(temp,1);
r=find(PM_obs_net_temp(pm_10,:)==nodata|f_conc_temp==nodata);
C_all_temp(pm_10,r)=NaN;
C_ep_temp=C_ep;
C_ep_temp(r)=NaN;
C_salt_sum(pm_10,r)=NaN;
C_all_m_temp(dust(sus),pm_10,r)=NaN;
C_all_m_temp(dust(sussand),pm_10,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;
r2=find(f_conc_temp==nodata|C_ep_temp==nodata);
C_ep_temp(r2)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:)+C_ep_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_salt_sum(pm_10,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,C_all_m_temp(dust(sus),pm_10,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_all_m_temp(dust(sussand),pm_10,:),min_time,max_time,av);
%[x_str xplot yplot5]=Average_data_func(date_num,PM_obs_temp(pm_10,:),min_time,max_time,av);
%}
plot(xplot,yplot2,'k--','linewidth',1);
%plot(xplot,yplot4,'r:','linewidth',1);
if use_sanding_data_flag,plot(xplot,yplot5,'r:','linewidth',1);end
if use_salting_data_flag,plot(xplot,yplot3,'g:','linewidth',1);end
plot(xplot,yplot1,'b-','linewidth',1);
%plot(xplot,yplot5,'b-','linewidth',0.5);
%plot(xplot,yplot6,'b:','linewidth',0.5);
ylabel(ylabel_text);
%xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
%l1=legend(legend_text,'location','NorthWest');
l1=legend(legend_text,'location','Best');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
y_max=max([yplot1;yplot2;yplot3;yplot4;yplot5])*1.1;
if ~isnan(y_max),
ylim([0 y_max]);
end

%axis tight
drawnow

%plot road mass
sp2=subplot(4,1,3);
set(gca,'fontsize',fontsize_fig);
title(['Mass loading'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Mass loading (g.m^-^2)';
legend_text={'Suspendable dust'};
if use_salting_data_flag,legend_text={'Suspendable dust','Salt'};end
if use_sanding_data_flag,legend_text={'Suspendable dust','Suspendable sand'};end
if use_sanding_data_flag&&use_salting_data_flag(1),legend_text={'Suspendable dust','Road salt','Suspendable sand'};end


[x_str xplot yplot1]=Average_data_func(date_num,M_road_data_temp(total_dust_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M_road_data_temp(salt_index(1),x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road_data_temp(sand_index,x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,M_road_data_temp(salt_index(2),x_load,:)*b_factor,min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,(M_road_data_temp(sand_index,pm_all,:)-M_road_data_temp(sand_index,pm_200,:))*b_factor,min_time,max_time,av);

%{
[x_str xplot yplot1]=Average_data_func(date_num,M_road(dust(sus),:)*b_factor,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,(M_road(salt(1),:)+M_road(salt(2),:))*b_factor,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road(dust(sussand),:)*b_factor,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,(M_road(salt(1),:).*M_road_dissolved_ratio(salt(1),:)+M_road(salt(2),:).*M_road_dissolved_ratio(salt(2),:))*b_factor,min_time,max_time,av);
%}

show_cleaning_AE_plot=0;
max_plot=max(max([yplot1 yplot2 yplot3]));
plot(xplot,yplot1,'b-','linewidth',1);
if use_salting_data_flag(1),plot(xplot,yplot2,'g:','linewidth',1);end
%plot(xplot,yplot5,'g--','linewidth',0.5);
if use_sanding_data_flag,plot(xplot,yplot3,'r:','linewidth',1);end
ylabel(ylabel_text);
%xlabel(xlabel_text);
[x_str xplot yplot4]=Average_data_func(date_num,activity_data_temp(t_cleaning_index,:),min_time,max_time,av);
r=find(activity_data_temp(t_cleaning_index,:)~=0);
if ~isempty(r)&&use_cleaning_data_flag&&show_cleaning_AE_plot,
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',0.5);
    %legend_text={'Cleaning','Suspendable dust','Salt','Dissolved salt','Suspendable sand'};
    legend_text(length(legend_text)+1)={'Cleaning'};
end
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
%l1=legend(legend_text,'location','NorthWest');
l1=legend(legend_text,'location','Best');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
%axis tight;

%plot effective emission factor
if plot_emission_factor,
sp1=subplot(4,1,4);
set(gca,'fontsize',fontsize_fig);
title(['Emission factor'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Emission factor (g.km^-^1.veh^-^1)';
legend_text={'Modelled emission factor','Observed emission factor'};
clear N_total_temp f_conc_temp2 E_all_temp PM_obs_net_temp ef_temp
clear yplot1 yplot2 yplot3 yplot4 yplot4a yplot4b yplot5

N_total_temp(1,:)=traffic_data_temp(N_total_index,:);
f_conc_temp2=f_conc_temp;
E_all_temp(1,:)=E_road_data_temp(total_dust_index,x,E_total_index,:);
PM_obs_net_temp(1,:)=PM_obs_net(x,:);
r=find(f_conc_temp==nodata|PM_obs_net(x,:)==nodata);
f_conc_temp2(r)=NaN;
%r=find(PM_obs_net(pm_10,:)==nodata);
PM_obs_net_temp(r)=NaN;
%N_total_temp(r)=NaN;
%E_all_temp(r)=NaN;
E_obs_temp=PM_obs_net_temp./f_conc_temp2;

%E_obs_temp=ef_temp.*N_total_temp;
%ef_mod_temp=E_all_temp./N_total_temp;
[x_str xplot yplot4a]=Average_data_func(date_num,PM_obs_net_temp,min_time,max_time,av);
[x_str xplot yplot4b]=Average_data_func(date_num,f_conc_temp2,min_time,max_time,av);
%[x_str xplot yplot4]=Average_data_func(date_num,ef_temp,min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,E_all_temp,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,E_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_total_temp,min_time,max_time,av);
yplot3=yplot1./yplot2;
yplot4=yplot5./yplot2;

%{
N_total_temp(1,:)=traffic_data_temp(N_total_index,r);
f_conc_temp2(1,:)=f_conc_temp;
E_all_temp(1,:)=E_all(pm_10,1:max_time)+EP_emis(1:max_time)';
PM_obs_net_temp(1,:)=PM_obs_net(pm_10,:);
r=find(f_conc_temp==nodata|PM_obs_net(pm_10,:)==nodata);
f_conc_temp2(r)=NaN;
%r=find(PM_obs_net(pm_10,:)==nodata);
PM_obs_net_temp(r)=NaN;
N_total_temp(r)=NaN;
E_all_temp(r)=NaN;
E_obs_temp=PM_obs_net_temp./f_conc_temp2;
%E_obs_temp=ef_temp.*N_total_temp;
%ef_mod_temp=E_all_temp./N_total_temp;
[x_str xplot yplot4a]=Average_data_func(date_num,PM_obs_net_temp,min_time,max_time,av);
[x_str xplot yplot4b]=Average_data_func(date_num,f_conc_temp2,min_time,max_time,av);
%[x_str xplot yplot4]=Average_data_func(date_num,ef_temp,min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,E_all_temp,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,E_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_total_temp,min_time,max_time,av);
yplot3=yplot1./yplot2;
yplot4=yplot5./yplot2;
%yplot4=yplot4a./yplot4b;
%}

plot(xplot,yplot3,'b-','linewidth',1);
%plot(xplot,yplot4./yplot2,'k--','linewidth',1);
plot(xplot,yplot4,'k--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
%l1=legend(legend_text,'location','NorthWest');
l1=legend(legend_text,'location','Best');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

drawnow
end

if plot_salt_application,
sp1=subplot(4,1,4);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Suspendable salting/sanding (g/m^2)';
legend_text={'Sanding','Salting'};
if use_sanding_data_flag&&use_salting_data_flag,legend_text={'Sanding','Salting'};end
if use_sanding_data_flag,legend_text={'Sanding'};end
if use_salting_data_flag,legend_text={'Salting'};end

[x_str xplot yplot1]=Average_data_func(date_num,M_sanding*f_sus_sanding,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M_salting(1,:)+M_salting(2,:),min_time,max_time,av);
%[x_str xplot yplot3]=Average_data_func(date_num,M_salting(2,:),min_time,max_time,av);
%bar(xplot, [yplot1 yplot2 yplot3],'EdgeColor','none');
if av(1)==2,m_scale=24;else m_scale=1;end
if use_salting_data_flag,stairs(xplot, yplot2*m_scale,'b-','linewidth',1);end
if use_sanding_data_flag,stairs(xplot, yplot1*m_scale,'r-','linewidth',1);end
%stairs(xplot, yplot3,'g--');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av(1)==3||av(1)==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

end

end%Special EA plotting routines

%--------------------------------------------------------------------------
%Set the plot page parameters for figure 14
%--------------------------------------------------------------------------
if plot_figure(14),
scale=scale_all; %(pixels/mm on screen)
fig14=figure(14);
handle_plot(14)=fig14;
if which_moisture_plot==0,
    set(fig14,'Name','Scatter temperature and moisture','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x/1.5) fix(260*scale_y/1.5)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
    n_plot=1;
    m_plot=1;
elseif which_moisture_plot==3,
    set(fig14,'Name','Scatter temperature','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x*1.5) fix(260*scale_y/1.5)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
    n_plot=2;
    m_plot=1;
else
    set(fig14,'Name','Scatter temperature and moisture','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x*1.5) fix(260*scale_y/1.5)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
    n_plot=2;
    m_plot=1;
end
figure(fig14);
clf;

%plot temperature
plot_diff_temperature=1;
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig*1.5);
if ~road_temperature_obs_available,
    fprintf('No road temperature observations available\n');
else
if plot_diff_temperature,
    title([title_str,': temperature difference'],'fontsize',fontsize_title*1.2,'fontweight','bold');
else
    title([title_str,': surface temperature'],'fontsize',fontsize_title*1.2,'fontweight','bold');    
end
hold on
%ylabel_text='T_s - T_a observed (C^o)';
%xlabel_text='T_s - T_a modelled (C^o)';
if plot_diff_temperature,
    ylabel_text='\DeltaT_s observed (C^o)';
    xlabel_text='\DeltaT_s modelled (C^o)';
else
    ylabel_text='T_s observed (C^o)';
    xlabel_text='T_s modelled (C^o)';
end

T_a_temp2=meteo_data_temp(T_a_index,:);
if ~isempty(T_a_nodata),T_a_temp2(T_a_nodata)=nodata;end
road_temperature_obs_temp2=road_meteo_data_temp(road_temperature_obs_index,:);
if ~isempty(road_temperature_obs_missing),road_temperature_obs_temp2(road_temperature_obs_missing)=nodata;end
if forecast_hour>0,
    r=find(road_temperature_forecast_missing);
    if ~isempty(r),road_temperature_obs_temp2(r)=nodata;end
end
T_a_temp=T_a_temp2(min_time:max_time);
T_s_temp=road_meteo_data_temp(T_s_index,min_time:max_time);
road_temperature_obs_temp=road_temperature_obs_temp2(min_time:max_time);
date_num_temp=date_num(min_time:max_time);
r=find(T_a_temp==nodata|T_s_temp==nodata|road_temperature_obs_temp==nodata);
T_a_temp(r)=NaN;
T_s_temp(r)=NaN;
road_temperature_obs_temp(r)=NaN;
if plot_diff_temperature,
    T_diff_mod=T_s_temp-T_a_temp;
    T_diff_obs=road_temperature_obs_temp-T_a_temp;
else
    T_diff_mod=T_s_temp;
    T_diff_obs=road_temperature_obs_temp;
end

[x_str xplot yplot1]=Average_data_func(date_num_temp,T_diff_mod,1,length(T_diff_mod),av);
[x_str xplot yplot2]=Average_data_func(date_num_temp,T_diff_obs,1,length(T_diff_mod),av);
r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'ko','markersize',3,'linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
min_plot=min(min(yplot1(r)),min(yplot2(r)));
if ~isempty(max_plot),
    xlim([min_plot max_plot]);
    ylim([min_plot max_plot]);
end
%grid on
%Calculate some basic statistics and display them
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_T=Rcor(1,2).^2;
rmse_T=rmse(yplot1(r),yplot2(r));
mae_T=mean(abs(yplot1(r)-yplot2(r)));
fr_bias_T=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_T=length(rfac)/length(r);
mean_obs_T=mean(yplot2(r));
mean_mod_T=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);
if ~isempty(yplot2(r)),
    %a_reg=linortfit2(yplot2(r),yplot1(r));a_reg=fliplr(a_reg);
    a_reg = polyfit(yplot1(r),yplot2(r),1);
end

text(0.05,0.95,['r^2  = ',num2str(r_sq_T,'%4.2f')],'units','normalized');
text(0.05,0.88,['RMSE = ',num2str(rmse_T,'%4.2f'),' (^oC)'],'units','normalized');
text(0.05,0.81,['OBS MEAN = ',num2str(mean_obs_T,'%4.2f'),' (^oC)'],'units','normalized');
text(0.05,0.74,['MOD MEAN = ',num2str(mean_mod_T,'%4.2f'),' (^oC)'],'units','normalized');

text(0.80,0.2-.1,['a_0  = ',num2str(a_reg(2),'%4.2f'),' (^oC)'],'units','normalized');
text(0.80,0.13-.1,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized');

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);

drawnow
    if print_results,
    fprintf(fid_print,'%20s\t%20s\t%20s\t%20s\t%20s\t%20s\t%20s\t%20s\n','Mean observed','Mean modelled','RMSE','MAE','Corr (r^2)','Intercept','Slope','Bias');
    fprintf(fid_print,'%20.3f\t%20.3f\t%20.3f\t%20.3f\t%20.3f\t%20.3f\t%20.3f\t%20.3f\n',mean_obs_T,mean_mod_T,rmse_T,mae_T,r_sq_T,a_reg(2),a_reg(1),mean_mod_T-mean_obs_T);
    end

if which_moisture_plot==3,
sp1=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig*1.5);
title([title_str,': surface temperature error'],'fontsize',fontsize_title*1.2,'fontweight','bold');    
hold on
%ylabel_text='T_s - T_a observed (C^o)';
%xlabel_text='T_s - T_a modelled (C^o)';
ylabel_text='T_s modelled  - T_s observed (C^o)';
xlabel_text='T_s observed (C^o)';

T_a_temp2=meteo_data_temp(T_a_index,:);
if ~isempty(T_a_nodata),T_a_temp2(T_a_nodata)=nodata;end
road_temperature_obs_temp2=road_meteo_data_temp(road_temperature_obs_index,:);
if ~isempty(road_temperature_obs_missing),road_temperature_obs_temp2(road_temperature_obs_missing)=nodata;end
if forecast_hour>0,
    r=find(road_temperature_forecast_missing);
    if ~isempty(r),road_temperature_obs_temp2(r)=nodata;end
end
T_a_temp=T_a_temp2(min_time:max_time);
T_s_temp=road_meteo_data_temp(T_s_index,min_time:max_time);
road_temperature_obs_temp=road_temperature_obs_temp2(min_time:max_time);
date_num_temp=date_num(min_time:max_time);
r=find(T_a_temp==nodata|T_s_temp==nodata|road_temperature_obs_temp==nodata);
T_a_temp(r)=NaN;
T_s_temp(r)=NaN;
road_temperature_obs_temp(r)=NaN;
T_error_mod=T_s_temp-road_temperature_obs_temp;

[x_str xplot yplot1]=Average_data_func(date_num_temp,road_temperature_obs_temp,1,length(T_error_mod),av);
[x_str xplot yplot2]=Average_data_func(date_num_temp,T_error_mod,1,length(T_error_mod),av);
r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'bo','markersize',3,'linewidth',0.5);
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
min_plot=min(min(yplot1(r)),min(yplot2(r)));
if ~isempty(max_plot),
    xlim([min(min(yplot1(r))) max(max(yplot1(r)))]);
    ylim([min(min(yplot2(r))) max(max(yplot2(r)))]);
end
%grid on
%Calculate some basic statistics and display them
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_T=Rcor(1,2).^2;
rmse_T=rmse(yplot1(r),yplot2(r));
mae_T=mean(abs(yplot2(r)));
fr_bias_T=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_T=length(rfac)/length(r);
mean_error_T=mean(yplot2(r));
mean_mod_T=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);
if ~isempty(yplot2(r)),
    %a_reg=linortfit2(yplot2(r),yplot1(r));a_reg=fliplr(a_reg);
    a_reg = polyfit(yplot1(r),yplot2(r),1);
end

text(0.05,0.95,['r^2  = ',num2str(r_sq_T,'%4.2f')],'units','normalized');
%text(0.05,0.88,['RMSE = ',num2str(rmse_T,'%4.2f'),' (^oC)'],'units','normalized');
text(0.05,0.81,['MEAN ERROR = ',num2str(mean_error_T,'%4.2f'),' (^oC)'],'units','normalized');
text(0.05,0.88,['MAE = ',num2str(mae_T,'%4.2f'),' (^oC)'],'units','normalized');
%text(0.05,0.74,['MOD MEAN = ',num2str(mean_mod_T,'%4.2f'),' (^oC)'],'units','normalized');

text(0.80,0.2-.1,['a_0  = ',num2str(a_reg(2),'%4.2f'),' (^oC)'],'units','normalized');
text(0.80,0.13-.1,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized');

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);

drawnow
    
end


if which_moisture_plot==1,
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig*1.5);
hold on
title([title_str,': road moisture frequency'],'fontsize',fontsize_title*1.2,'fontweight','bold');

r_wetscore_temp=r_wetscore([1 2 5 6]);
r_wetscore_temp(1)=prop_wet_obs;
r_wetscore_temp(2)=prop_wet_mod;
r_wetscore_temp(4)=rel_prop_wet_wet;
r_wetscore_temp2=r_wetscore_temp;
bar(r_wetscore_temp([1,2,3,4])*100,'FaceColor',[0.8 0.8 1.0],'EdgeColor','k');
%r_wetscore_temp(1:4)=NaN;
r_wetscore_temp(1:2)=NaN;

%bar(r_wetscore_temp,'FaceColor',[0.4 0.4 1.0],'EdgeColor','k');
bar(r_wetscore_temp(1:4)*100,'FaceColor',[0.4 0.4 1.0],'EdgeColor','k');
score_str={'Wet&Wet','Dry&Wet','Dry&Dry','Wet&Dry','Hit','Miss'};
score_str={'Observed wet','Modelled wet','Model hit all','Model hit wet'};
set(gca,'XTick',1:4,'XTickLabel',score_str,'Fontsize',fontsize_fig*1.5);

ylabel_text='Frequency (%)';
xlabel_text='';
ylabel(ylabel_text,'fontsize',fontsize_fig*1.5);
xlabel(xlabel_text,'fontsize',fontsize_fig*1.5);
    %xlim([0 1]);
    ylim([0 100]);

    for i=[1 2 3 4],
        text(i,r_wetscore_temp2(i)*100,[num2str(r_wetscore_temp2(i)*100,'%3.0f'),' %'],'HorizontalAlignment','center','VerticalAlignment','bottom','Fontsize',fontsize_fig*1.5);
    end
    if print_results,
    fprintf(fid_print,'%20s\t%20s\t%20s\t%20s\t%20s\t%20s\t%20s\n','Mean observed','Mean modelled','RMSE','MAE','Corr (r^2)','Intercept','Slope');
    fprintf(fid_print,'%20.2f\t%20.2f\t%20.2f\t%20.2f\t%20.2f\t%20.2f\t%20.2f\n',mean_obs_T,mean_mod_T,rmse_T,mae_T,r_sq_T,a_reg(2),a_reg(1));
    fprintf(fid_print,'%20s\t%20s\t%20s\t%20s\t%20s\t%20s\n','Wet road observed','Wet road modelled','Hits all conditions','Hits wet conditions','Nothing','FB_wet road');
    fprintf(fid_print,'%20.1f\t%20.1f\t%20.1f\t%20.1f\t%20.1f\t%20.3f\n',r_wetscore_temp2(1)*100,r_wetscore_temp2(2)*100,r_wetscore_temp2(3)*100,r_wetscore_temp2(4)*100,0,(r_wetscore_temp2(2)-r_wetscore_temp2(1))/(r_wetscore_temp2(1)+r_wetscore_temp2(2))*2);
    end
end
%return

if which_moisture_plot==2,
sp2=subplot(m_plot,n_plot,2);
r=find(f_q_obs_temp==nodata|f_q_temp(road_index,:)==nodata);
road_wetness_obs_temp=road_meteo_data_temp(road_wetness_obs_index,min_time:max_time);
g_road_temp=sum(g_road_data_temp(1:num_moisture,min_time:max_time),1);
date_num_temp=date_data_temp(date_num_index,min_time:max_time);

road_wetness_obs_temp(r)=NaN;
g_road_temp(r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num_temp,g_road_temp,1,length(g_road_temp),av);
[x_str xplot yplot2]=Average_data_func(date_num,road_wetness_obs_temp,1,length(g_road_temp),av);

r=find(~isnan(yplot1)&~isnan(yplot2));
if length(r)>1,
plot(yplot1(r),yplot2(r),'rs','markersize',6);
end
ylabel_text='Observed road moisture (mm)';
xlabel_text='Modelled road moisture (mm)';
ylabel(ylabel_text);
xlabel(xlabel_text);
max_plot=max(max(yplot1(r)),max(yplot2(r)));
%min_plot=min(min(yplot1(r)),min(yplot2(r)));
min_plot=0;
if ~isempty(max_plot),
    xlim([min_plot max_plot]);
    ylim([min_plot max_plot]);
end
%grid on
%Calculate some basic statistics and display them
if length(r)>1,
Rcor = corrcoef(yplot1(r),yplot2(r));
r_sq_fq=Rcor(1,2).^2;
rmse_fq=rmse(yplot1(r),yplot2(r));
fr_bias_fq=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_fq=length(rfac)/length(r);
mean_obs_fq=mean(yplot2(r));
mean_mod_fq=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);
if ~isempty(yplot2(r)),
    %a_reg=linortfit2(yplot2(r),yplot1(r));a_reg=fliplr(a_reg);
    a_reg = polyfit(yplot1(r),yplot2(r),1);
end

set(gca,'fontsize',fontsize_fig*1.5);
title([title_str,': road moisture scatter plot'],'fontsize',fontsize_title*1.2,'fontweight','bold');
hold on
text(0.05,0.95,['r^2  = ',num2str(r_sq_fq,'%4.2f')],'units','normalized');
text(0.05,0.88,['RMSE = ',num2str(rmse_fq,'%4.2f')],'units','normalized');
text(0.05,0.81,['OBS  = ',num2str(mean_obs_fq,'%4.2f')],'units','normalized');
text(0.05,0.74,['MOD  = ',num2str(mean_mod_fq,'%4.2f')],'units','normalized');

text(0.55,0.2-.1,['a_0  = ',num2str(a_reg(2),'%4.2f')],'units','normalized');
text(0.55,0.13-.1,['a_1  = ',num2str(a_reg(1),'%4.2f')],'units','normalized');

xmin=min(yplot1(r));
xmax=max(yplot1(r));
plot([xmin xmax],[a_reg(2)+a_reg(1)*xmin a_reg(2)+a_reg(1)*xmax],'-','Color',[0.5 0.5 0.5]);
drawnow
end

end

drawnow
end
end
%--------------------------------------------------------------------------

%Open text file for printing
print_results=print_results_temp;
if exist(summary_filename,'file')&&fid_print>=3,
    fclose(fid_print);
end

return

%==========================================================================
%NORTRIP model
%SUBROUTINE: plot_speacial_road_dust_results_v2
%VERSION: 2, 27.08.2012
%AUTHOR: Bruce Rolstad Denby (bde@nilu.no)
%DESCRIPTION: Plots special results for the NORTRIP model
%==========================================================================

%Sets which plots to show
plot_figure=[1 1 1 1 1 1 1 0 0 0 1 0 1 0];
%plot_figure=[0 0 0 0 0 0 0 0 0 0 0 0 1 0];
plot_figure=[1 0 0 1 0 1 1 1 0 0 0 0 1 0];%AE article plots
%plot_figure=[1 1 1 1 1 1 1 1 0 0 1 0 1 0];
%plot_figure=[0 1 0 1 0 1 0 0 0 0 0 0 1 1];%Temperature and other plots
%plot_figure=[0 0 0 0 0 0 0 0 0 0 0 0 0 1];%Temperature plot only
plot_figure=[0 0 0 1 0 0 0 0 0 0 0 0 0 0];%Moisture plot only

%Special temperature plot
which_moisture_plot=0;
%Moisture plot
show_ploughing=0;
%Special AE plotting routines
plot_emission_factor=1;%or
plot_salt_application=0;
%Single vehicle emissions plot
plot_single_vehicle=0;
    fraction_HDV=sum(N_v(he,:))/sum(N_total);
    f_sus_scale_single=1.4;%/((1-fraction_HDV)*1+fraction_HDV*10);THis term should be in the direct one
    V_veh_single=30;%If 0 then use the traffic speed
    v_single=li;
    t_single=wi;
    show_dry_means=0;%If 2 then dry medians
    
%Set the output size fraction
x=pm_10;

%Set the averaging time (1=hourly, 2=daily, 3=daily cycle, 4=12 hour starting 10:00)
%plot_type_flag=1;
av=plot_type_flag;
%av=1;

if av==1||av==2||av==4||av==7||av==8,
    xlabel_text='Date';
elseif av==3,
    xlabel_text='Hour';
elseif av==5,
    xlabel_text='Day';
end

%Start the plots
scale_all=3.5;
scale_all=2.9;
scale_x=3.5;scale_y=2.9;
%scale_x=5;scale_y=2.9;
shift_x=20;shift_y=0;
bottom_corner=50;left_corner=10;
fontsize_title=12;
fontsize_legend=9;
fontsize_fig=9;
fontsize_text=9;
day_tick_limit=150;
clear text

%Initialise some temporary files
C_all_temp=C_all;
C_all_m_temp=C_all_m;

%Set the plot page parameters for figure 1
%--------------------------------------------------------------------------
if plot_figure(1),
scale=scale_all; %(pixels/mm on screen)
fig1=figure(1);
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
[x_str xplot yplot1]=Average_data_func(date_num,N_total,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_v(li,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,N_v(he,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,N(st,li,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,N(wi,li,:),min_time,max_time,av);
plot(xplot,yplot1,'k-','linewidth',2);
plot(xplot,yplot2,'b--','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',1);
plot(xplot,yplot4,'m:','linewidth',1);
plot(xplot,yplot5,'g:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
clear N_temp
N_temp(1,:)=N(st,li,:);r=find((N_v(li,:)~=0));max_studded_light=max(N_temp(1,r)./N_v(li,r))*100;
text(0.8,0.92,['Max LDV studded = ',num2str(max_studded_light,'%4.1f'),' (%)'],'units','normalized','fontsize',fontsize_text);

%plot traffic speed
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Traffic speed (km/hr)';
legend_text={'Light','Heavy'};
[x_str xplot yplot1]=Average_data_func(date_num,V_veh(li,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,V_veh(he,:),min_time,max_time,av);
plot(xplot,yplot1,'b--','linewidth',2);
plot(xplot,yplot2,'r--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%plot salting sanding
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Salting/sanding (g/m^2)';
legend_text={'Sanding/10','Salting(Na)','Salting(Mg)'};
[x_str xplot yplot1]=Average_data_func(date_num,M_sanding/10,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,M_salting(na,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_salting(mg,:),min_time,max_time,av);
%bar(xplot, [yplot1 yplot2 yplot3],'EdgeColor','none');
stairs(xplot, yplot1,'b-');
stairs(xplot, yplot2,'g-');
stairs(xplot, yplot3,'g:');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
set(fig2,'Name','Meteorology','MenuBar','figure','position',[left_corner+1*shift_x bottom_corner+1*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig2);
clf;
n_plot=1;
m_plot=5;
use_salt_humidity_flag_plot=0;

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
[x_str xplot yplot1]=Average_data_func(date_num,T_a,min_time,max_time,av);
r2=find(yplot1<0);
r3=find(yplot1>=0);
yplot2=yplot1*NaN;
yplot3=yplot1*NaN;
[x_str xplot yplot4]=Average_data_func(date_num,T_s,min_time,max_time,av);
if road_temperature_obs_available,
    [x_str xplot yplot6]=Average_data_func(date_num,road_temperature_obs,min_time,max_time,av);
end
if use_salt_humidity_flag,
    [x_str xplot yplot7]=Average_data_func(date_num,T_melt,min_time,max_time,av);
end
[x_str xplot yplot8]=Average_data_func(date_num,T_sub,min_time,max_time,av);
if ~isempty(r2),yplot2(r2)=yplot1(r2);end
if ~isempty(r3),yplot3(r3)=yplot1(r3);end
plot(xplot,yplot1,'b-','linewidth',2);
plot(xplot,yplot3,'r-','linewidth',2);
plot(xplot,yplot4,'m-','linewidth',1);
if road_temperature_obs_available,
plot(xplot,yplot6,'k-','linewidth',1);
end
if use_salt_humidity_flag_plot,
plot(xplot,yplot7,'g--','linewidth',1);
end
%plot(xplot,yplot8,'r:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
[x_str xplot yplot1]=Average_data_func(date_num,RH,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,RHs,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,RH_salt_final,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',2);
plot(xplot,yplot2,'m-','linewidth',1);
plot(xplot,yplot3,'r:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
[x_str xplot yplot4]=Average_data_func(date_num,cloud_cover*100,min_time,max_time,av);
plot(xplot,yplot4,'k:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
[x_str xplot yplot1]=Average_data_func(date_num,FF,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
[x_str xplot yplot1]=Average_data_func(date_num,Rain,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,Snow,min_time,max_time,av);
%bar(xplot, [yplot1 yplot2],'EdgeColor','none','BarWidth',1);
stairs(xplot, yplot1,'b');
stairs(xplot, yplot2,'m');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
set(fig3,'Name','Emissions and mass','MenuBar','figure','position',[left_corner+2*shift_x bottom_corner+2*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig3);
clf;
n_plot=1;
m_plot=4;

%plot emissions
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Emissions and mass balance'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Emission (g/km/hr)';
legend_text={'Total','Direct dust','Direct sand','Suspended'};
[x_str xplot yplot1]=Average_data_func(date_num,E_all(x,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,E_direct_dust(x,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,E_direct_sand(x,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,E_suspension_all(x,:),min_time,max_time,av);
plot(xplot,yplot1,'k-','linewidth',2);
plot(xplot,yplot2,'b--','linewidth',1);
plot(xplot,yplot4,'m--','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot road mass
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
fact=1/1000/b_road_lanes;
hold on
ylabel_text='Mass loading (g/m^2)';
legend_text={'Suspendable dust','Road salt','Dissolved salt','Suspendable sand'};
[x_str xplot yplot1]=Average_data_func(date_num,M_road(dust(sus),:)*fact,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,(M_road(salt(na),:)+M_road(salt(mg),:))*fact,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road(dust(sussand),:)*fact,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,(M_road_0_dissolved_salt(na,:)+M_road_0_dissolved_salt(mg,:))*fact,min_time,max_time,av);

max_plot=max(max([yplot1 yplot2 yplot3]));
[x_str xplot yplot4]=Average_data_func(date_num,t_cleaning,min_time,max_time,av);
r=find(t_cleaning~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',1);
    legend_text={'Cleaning','Suspendable dust','Road salt','Dissolved salt','Suspendable sand'};
end
plot(xplot,yplot1,'k-','linewidth',2);
plot(xplot,yplot2,'g--','linewidth',2);
plot(xplot,yplot5,'g:','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot nonsuspendable mass
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Mass loading (g/m^2)';
legend_text={'Non-suspendable sand'};
[x_str xplot yplot1]=Average_data_func(date_num,M_road(dust(sand),:)*fact,min_time,max_time,av);
max_plot=max(max([yplot1]));
[x_str xplot yplot4]=Average_data_func(date_num,t_cleaning*max_plot,min_time,max_time,av);
r=find(yplot4~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'g-','linewidth',2);
    legend_text={'Cleaning','Non-suspendable dust'};
end
plot(xplot,yplot1,'k-','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%plot Road dust production and sink
sp4=subplot(m_plot,n_plot,4);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Rates (g/km/hr)';
legend_text={'Road dust production','Road dust sink'};
[x_str xplot yplot1]=Average_data_func(date_num,P_road(dust(sus),:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,-S_road(dust(sus),:),min_time,max_time,av);
plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------

%Set the plot page parameters for figure 4
%--------------------------------------------------------------------------
if plot_figure(4),
scale=scale_all; %(pixels/mm on screen)
fig4=figure(4);
set(fig4,'Name','Road wetness','MenuBar','figure','position',[left_corner+3*shift_x bottom_corner+3*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig4);
clf;
n_plot=1;
m_plot=3;

%plot road wetness
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Road surface wetness'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Surface wetness (mm)';
legend_text={'Modelled water depth'};
[x_str xplot yplot1]=Average_data_func(date_num,g_road,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',2);
if road_wetness_obs_available&&road_wetness_obs_in_mm,
    [x_str xplot yplot2]=Average_data_func(date_num,road_wetness_obs,min_time,max_time,av);    
    legend_text={'Modelled water depth','Observed water depth'};
    plot(xplot,yplot2,'k--','linewidth',2);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Surface snow (mm w.e.)';
legend_text={'Road snow depth'};
[x_str xplot yplot1]=Average_data_func(date_num,s_road,min_time,max_time,av);
max_plot=max(max([yplot1]));
[x_str xplot yplot3]=Average_data_func(date_num,t_ploughing,min_time,max_time,av);
r=find(yplot3~=0);
if ~isempty(r),
    if show_ploughing,
        stairs(xplot,yplot3/max(yplot3)*max_plot,'g-','linewidth',1);
        legend_text={'Ploughing','Road snow depth'};
    else
        legend_text={'Modelled snow depth'};
    end
    
end
plot(xplot,yplot1,'b-','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
    legend_text={'Modelled retention','Observed retention'};
else
    legend_text={'Road','Brake'};
end
[x_str xplot yplot1]=Average_data_func(date_num,f_q_road,min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,f_q_brake,min_time,max_time,av);
if road_wetness_obs_available==1,
    [x_str xplot yplot5]=Average_data_func(date_num,f_q_obs,min_time,max_time,av);    
end
plot(xplot,yplot1,'b-','linewidth',2);
%plot(xplot,yplot4,'m--','linewidth',1);
if road_wetness_obs_available==1,
    plot(xplot,yplot5,'k--','linewidth',2);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
end
%--------------------------------------------------------------------------

%Set the plot page parameters for figure 5
%--------------------------------------------------------------------------
if plot_figure(5),
scale=scale_all; %(pixels/mm on screen)
fig5=figure(5);
set(fig5,'Name','Other factors','MenuBar','figure','position',[left_corner+4*shift_x bottom_corner+4*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig5);
clf;
n_plot=1;
m_plot=3;

%plot effective emission factor
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Other factors'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='Emission factor (g/km/veh)';
legend_text={'Modelled emission factor','Observed emission factor'};
if plot_single_vehicle,
    legend_text={'Modelled emission factor','Observed emission factor','Single vehcile emission'};
    v=v_single;
    t=t_single;
    s=roadwear;
    if V_veh_single==0,V_veh_single=V_veh(v,:);end
    %f_PM_dir_new_temp=f_PM_dir(x,s,t,v).*(1+c_pm_fraction.*V_veh(v,:))/(1+c_pm_fraction*V_ref_pm_fraction);
    f_PM_susroad_new_temp=f_PM_susroad(x,t,v).*(1+c_pm_fraction.*V_veh(v,:))/(1+c_pm_fraction*V_ref_pm_fraction);
    E_veh=zeros(1,length(M_road_total));
    for m=1:num_mass,
        f_0_suspension_temp=f_sus_scale_single*h_sus*f_susroad_func(f_0_suspension(m,t,v),V_veh_single,V_ref_suspension,a_sus,t,v);
        if m~=dust(sand),
            E_veh=E_veh+f_0_suspension_temp.*M_road(m,:)/n_lanes.*f_q_road.*f_PM_susroad_new_temp;
        end
    end
    %E_veh=E_veh+f_sus_scale_single/((1-fraction_HDV)+fraction_HDV*W_0(s,t,he)/W_0(s,t,li))*E_direct_dust(x,:)./N_total';
    E_veh=E_veh+f_sus_scale_single/((1-fraction_HDV)+fraction_HDV*f_0_suspension(dust(sus),t,he)/f_0_suspension(dust(sus),t,li))*E_direct_dust(x,:)./N_total'*V_veh_single./V_veh(v,:);
    %Above is not right yet as it must take into account the proportion of
    %heavy and light using studded or non studded tyres
    %Simplified version
    E_veh=f_sus_scale_single/((1-fraction_HDV)+fraction_HDV*f_0_suspension(dust(sus),t,he)/f_0_suspension(dust(sus),t,li))*E_all(x,:)./N_total'*V_veh_single./V_veh(v,:);    
    if show_dry_means,
        r=find(f_q_road<0.5);
        E_veh(r)=NaN;
    end
    r=find(~isnan(E_veh)&E_veh~=nodata);
    E_veh_mean=mean(E_veh(r));
    E_veh_median=median(E_veh(r));
    if print_results,
        fprintf('Mean single vehicle EF:   %6.2f (mg/km/veh)\n',E_veh_mean*1000);
        fprintf('Median single vehicle EF: %6.2f (mg/km/veh)\n',E_veh_median*1000);
    end
end
clear N_total_temp f_conc_temp E_all_temp PM_obs_net_temp ef_temp
clear yplot1 yplot2 yplot3 yplot4 yplot4a yplot4b yplot5 yplot6
N_total_temp(1,:)=N_total(1:max_time)';
f_conc_temp(1,:)=f_conc;
if EP_emis_available,
    E_all_temp(1,:)=E_all(x,1:max_time)+EP_emis(1:max_time)';
else
    E_all_temp(1,:)=E_all(x,1:max_time);
end    
PM_obs_net_temp(1,:)=PM_obs_net(pm_10,:);
r=find(f_conc==nodata|PM_obs_net(pm_10,:)==nodata);
f_conc_temp(r)=NaN;
%r=find(PM_obs_net(pm_10,:)==nodata);
PM_obs_net_temp(r)=NaN;
%N_total_temp(r)=NaN;
%E_all_temp(r)=NaN;
E_obs_temp=PM_obs_net_temp./f_conc_temp;
%E_obs_temp=ef_temp.*N_total_temp;
%ef_mod_temp=E_all_temp./N_total_temp;
[x_str xplot yplot4a]=Average_data_func(date_num,PM_obs_net_temp,min_time,max_time,av);
[x_str xplot yplot4b]=Average_data_func(date_num,f_conc_temp,min_time,max_time,av);
%[x_str xplot yplot4]=Average_data_func(date_num,ef_temp,min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,E_all_temp,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,E_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_total_temp,min_time,max_time,av);
yplot3=yplot1./yplot2;
yplot4=yplot5./yplot2;
%yplot4=yplot4a./yplot4b;
plot(xplot,yplot3,'b-','linewidth',2);
%plot(xplot,yplot4./yplot2,'k--','linewidth',2);
plot(xplot,yplot4,'k--','linewidth',2);
if plot_single_vehicle,
    if show_dry_means==1||show_dry_means==0,
        [x_str xplot yplot5]=Average_data_func(date_num,E_veh,min_time,max_time,av);
    else
        av_temp(1)=av;
        av_temp(2)=2;%Set to 2 to get median
        [x_str xplot yplot5]=Average_data_func(date_num,E_veh,min_time,max_time,av_temp);
    end      
    plot(xplot,yplot5,'r-','linewidth',2);
end

ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
r=find(f_conc==nodata);
f_conc_temp=f_conc;
f_conc_temp(r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,f_conc_temp,min_time,max_time,av);
%[x_str xplot yplot2]=Average_data_func(date_num,N_total,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

%plot effective emission factor
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='Bulk transfer coefficient (m/s)';
legend_text={'With traffic','Without traffic'};
[x_str xplot yplot1]=Average_data_func(date_num,1./r_aero,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,1./r_aero_notraffic,min_time,max_time,av);
plot(xplot,yplot1,'b-','linewidth',1);
plot(xplot,yplot2,'r-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
ylabel_text='Energy flux (W/m^2)';
%legend_text={'Net short','Net long','Sensible heat','Latent heat','Surface heat flux','Traffic heat flux','Clear sky short','Sub-surface'};
legend_text={'Net short','Net long','Sensible heat','Latent heat','Surface heat flux','Traffic heat flux'};
%legend_text={'Net short','Net long','Sensible heat','Latent heat','Surface heat flux','Traffic heat flux'};
[x_str xplot yplot1]=Average_data_func(date_num,rad_net,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,short_rad_net,min_time,max_time,av);
[x_str xplot yplot6]=Average_data_func(date_num,long_rad_net,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,H,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,L,min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,G,min_time,max_time,av);
[x_str xplot yplot7]=Average_data_func(date_num,short_rad_net_calc,min_time,max_time,av);
[x_str xplot yplot8]=Average_data_func(date_num,H_traffic,min_time,max_time,av);
[x_str xplot yplot9]=Average_data_func(date_num,G_sub,min_time,max_time,av);

r=find(~isnan(yplot5));
mean_short_rad_net=mean(yplot5(r));
mean_long_rad_net=mean(yplot6(r));
mean_H=mean(yplot2(r));
mean_L=mean(yplot3(r));
mean_H_traffic=mean(yplot8(r));
mean_G=mean(yplot4(r));

%plot(xplot,yplot1,'k-','linewidth',1);
plot(xplot,yplot5,'kv--','linewidth',2);
plot(xplot,yplot6,'k^:','linewidth',2);
plot(xplot,yplot2,'ro-','linewidth',2);
plot(xplot,yplot3,'bs-','linewidth',2);
plot(xplot,yplot4,'gx-','linewidth',2);
plot(xplot,yplot8,'m:','linewidth',2);
%plot(xplot,yplot7,'m:','linewidth',1);
%plot(xplot,yplot9,'c:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Write the balance
%{
text(0.7,.95,'Mean energy balance (W/m^2)','fontweight','bold','units','normalized','fontsize',fontsize_text);
text(0.7,0.90,['Net shortwave flux = ',num2str(mean_short_rad_net,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.85,['Net shortwave flux = ',num2str(mean_long_rad_net,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.80,['Sensible heat flux= ',num2str(mean_H,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.75,['Latent heat flux = ',num2str(mean_L,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.70,['Traffic heat flux = ',num2str(mean_H_traffic,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.65,['Surface heat flux = ',num2str(mean_G,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%}
if print_results,
    fprintf('Mean energy balance (W/m^2)\n');
    fprintf('%16s\t%16s\t%16s\t%16s\t%16s\t%16s\t\n','Net shortwave','Net shortwave','Sensible','Latent','Traffic','Surface');
    fprintf('%16.4f\t%16.4f\t%16.4f\t%16.4f\t%16.4f\t%16.4f\t\n',mean_short_rad_net,mean_long_rad_net,mean_H,mean_L,mean_H_traffic,mean_G);
end

%plot evaporation and drainage
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
title([title_str,': Moisture balance'],'fontsize',fontsize_title,'fontweight','bold');
ylabel_text='Surface moisture rates (mm/day)';
legend_text={'Evaporation/condensation','Rain-Drainage','Melt','Freezing','Spray','Wetting'};
%legend_text={'Evaporation/condensation','Melt+Rain-Drainage','Freezing','Spray','Wetting'};
[x_str xplot yplot1]=Average_data_func(date_num,(-S_g_evaporation+P_g_evaporation)*24,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,(P_rain-S_g_drainage)*24,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,(P_g_snowmelt)*24,min_time,max_time,av);
[x_str xplot yplot7]=Average_data_func(date_num,-P_s_freeze*24,min_time,max_time,av);
[x_str xplot yplot9]=Average_data_func(date_num,-S_g_spray*24,min_time,max_time,av);
[x_str xplot yplot10]=Average_data_func(date_num,g_road_wetting/dt*use_wetting_data_flag*24,min_time,max_time,av);


r=find(~isnan(yplot1));
mean_evap=mean(yplot1(r));
mean_rain_drain=mean(yplot3(r));
mean_freeze=mean(yplot7(r));
mean_spray=mean(yplot9(r));
mean_wetting=mean(yplot10(r));
mean_melt=mean(yplot5(r));

plot(xplot,yplot1,'ks-','linewidth',2);
plot(xplot,yplot3,'ro--','linewidth',2);
plot(xplot,yplot5,'g^:','linewidth',2);
plot(xplot,yplot7,'cv:','linewidth',2);
plot(xplot,yplot9,'mx-.','linewidth',2);
plot(xplot,yplot10,'b-','linewidth',2);
%plot(xplot,yplot5,'k-','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'Location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
axis tight;

%Write the budget
%{
text(0.7,.95,'Mean moisture budget (mm/day)','fontweight','bold','units','normalized','fontsize',fontsize_text);
text(0.7,0.90,['Evaporation/condensation = ',num2str(mean_evap,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.85,['Rain-drainage = ',num2str(mean_rain_drain,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.80,['Melt = ',num2str(mean_melt,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.75,['Freezing = ',num2str(mean_freeze,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.70,['Spray = ',num2str(mean_spray,'%4.2f')],'units','normalized','fontsize',fontsize_text);
text(0.7,0.65,['Wetting = ',num2str(mean_wetting,'%4.2f')],'units','normalized','fontsize',fontsize_text);
%}
if print_results,
    fprintf('Mean moisture budget (mm/day)\n');
    fprintf('%16s\t%16s\t%16s\t%16s\t%16s\t%16s\t\n','Evaporation','Rain-drainage','Melt','Freezing','Spray','Wetting');
    fprintf('%16.4f\t%16.4f\t%16.4f\t%16.4f\t%16.4f\t%16.4f\t\n',mean_evap,mean_rain_drain,mean_melt,mean_freeze,mean_spray,mean_wetting);
end

end
%--------------------------------------------------------------------------
%Set the plot page parameters for figure 7
%--------------------------------------------------------------------------
if plot_figure(7),
scale=scale_all; %(pixels/mm on screen)
fig7=figure(7);
set(fig7,'Name','Concentrations','MenuBar','figure','position',[left_corner+6*shift_x bottom_corner+6*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig7);
clf;
n_plot=1;
m_plot=3;

%plot concentrations
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': Concentrations'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='PM_1_0 concentration (\mug/m^3)';
legend_text={'Observed','Modelled salt','Modelled dust','Modelled sand','Modelled+EP'};
if Salt_obs_available(na),
legend_text={'Observed','Modelled salt','Modelled dust','Modelled sand','Modelled+EP','Observed salt'};    
end
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
temp=C_all_m(min(salt):max(salt),:,:);
clear C_salt_sum;
C_salt_sum(:,:)=sum(temp,1);
r=find(PM_obs_net_temp(pm_10,:)==nodata|f_conc==nodata);
%r=find(f_conc==nodata);
C_all_temp(pm_10,r)=NaN;
C_ep_temp=C_ep;
C_ep_temp(r)=NaN;
C_salt_sum(pm_10,r)=NaN;
C_all_m_temp(dust(sus),pm_10,r)=NaN;
C_all_m_temp(dust(sussand),pm_10,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;
r2=find(f_conc==nodata|C_ep_temp==nodata);
C_ep_temp(r2)=NaN;
if Salt_obs_available(na),
    r_salt=find(Salt_obs(na,:)==nodata);
    Salt_obs(na,r_salt)=NaN;
end
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:)+C_ep_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_salt_sum(pm_10,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,C_all_m_temp(dust(sus),pm_10,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_all_m_temp(dust(sussand),pm_10,:),min_time,max_time,av);
%[x_str xplot yplot6]=Average_data_func(date_num,PM_obs_temp(pm_10,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',2);
plot(xplot,yplot3,'g:','linewidth',2);
plot(xplot,yplot4,'r:','linewidth',2);
plot(xplot,yplot5,'m--','linewidth',2);
plot(xplot,yplot1,'b-','linewidth',2);
%plot(xplot,yplot5,'b-','linewidth',1);
%plot(xplot,yplot6,'b:','linewidth',1);
if Salt_obs_available(na),
[x_str xplot yplot6]=Average_data_func(date_num,Salt_obs(na,:),min_time,max_time,av);
plot(xplot,yplot6,'g-','linewidth',2);
end
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
hold on
ylabel_text='PM_2_._5 concentration (\mug/m^3)';
legend_text={'Observed','Exhaust','Modelled+EP'};
r=find(f_conc==nodata);
C_all_temp(pm_25,r)=NaN;
C_ep_temp=C_ep;
r2=find(f_conc==nodata|C_ep_temp==nodata);
C_ep_temp(r2)=NaN;
PM_obs_net_temp=PM_obs_net;
r=find(PM_obs_net_temp(pm_25,:)==nodata);
PM_obs_net_temp(pm_25,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_25,:)+C_ep_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_25,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_ep_temp,min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',2);
plot(xplot,yplot3,'m:','linewidth',2);
plot(xplot,yplot1,'b-','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
plot(xplot,yplot1,'r--','linewidth',1);
plot(xplot,yplot2,'b--','linewidth',1);
plot(xplot,yplot3,'k-','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
set(fig11,'Name','Scatter plots','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig11);
clf;
n_plot=2;
m_plot=2;

%plot concentrations
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
if EP_emis_available,
    title([title_str,': Scatter plot PM_1_0 + EP'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': Scatter plot PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
end
hold on
ylabel_text='PM_1_0 observed concentration (\mug/m^3)';
xlabel_text='PM_1_0 modelled concentration (\mug/m^3)';
%legend_text={'Modelled','Observed','Modelled salt','Modelled dust'};
r=find(f_conc==nodata);
C_all_temp(pm_10,r)=NaN;
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
r=find(PM_obs_net_temp(pm_10,:)==nodata);
PM_obs_net_temp(pm_10,r)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
if EP_emis_available,
    C_ep_temp=C_ep;
    r2=find(f_conc==nodata|C_ep_temp==nodata);
    C_ep_temp(r2)=NaN;
end
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
if EP_emis_available,
    [x_str xplot yplot3]=Average_data_func(date_num,C_ep_temp,min_time,max_time,av);
    yplot1=yplot1+yplot3;
end
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
    title([title_str,': QQ plot PM_1_0 + EP'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': QQ plot PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
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
if av==2,
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
    title([title_str,': Scatter plot PM_2_._5 + EP'],'fontsize',fontsize_title,'fontweight','bold');
else
    title([title_str,': Scatter plot PM_2_._5'],'fontsize',fontsize_title,'fontweight','bold');
    
end
hold on
ylabel_text='PM_2_._5 observed concentration (\mug/m^3)';
xlabel_text='PM_2_._5 modelled concentration (\mug/m^3)';
r=find(f_conc==nodata);
C_all_temp(pm_25,r)=NaN;
PM_obs_net_temp=PM_obs_net;
r=find(PM_obs_net_temp(pm_25,:)==nodata);
PM_obs_net_temp(pm_25,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_25,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_25,:),min_time,max_time,av);
if EP_emis_available,
    [x_str xplot yplot3]=Average_data_func(date_num,C_ep_temp,min_time,max_time,av);
    yplot1=yplot1+yplot3;
end
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
%Set the plot page parameters for figure 12
%--------------------------------------------------------------------------
if plot_figure(12),
scale=scale_all; %(pixels/mm on screen)
fig12=figure(12);
set(fig12,'Name','Summary information','MenuBar','figure','position',[left_corner+8*shift_x bottom_corner+8*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig12);
clf;
n_plot=2;
m_plot=3;

%Calculate summary statistics
%emissions
x=pm_10;
dust_emissions=mean(E_all_m(dust(sus),x,min_time:max_time));
suspension_dust_emissions=mean(E_suspension_all(x,min_time:max_time));
direct_dust_emissions=mean(E_direct_all(x,min_time:max_time));
sand_emissions=mean(E_all_m(dust(sussand),x,min_time:max_time));
salt_emissions=mean(E_all_m(salt(na),x,min_time:max_time)+E_all_m(salt(mg),x,min_time:max_time));
exhaust_emissions=mean(EP_emis(min_time:max_time));
total_emissions=dust_emissions+sand_emissions+salt_emissions+exhaust_emissions;

%concentrations
clear PM_obs_net_temp f_conc_temp C_all_m_temp2 C_all_temp2 C_ep_temp
PM_obs_net_temp(1,:)=PM_obs_net(pm_10,min_time:max_time);
f_conc_temp=f_conc(min_time:max_time);
C_all_m_temp2=C_all_m(:,:,min_time:max_time);
C_all_m_wearsource_temp=C_all_m_wearsource(:,:,min_time:max_time);
C_ep_temp=C_ep(min_time:max_time);
%r=find(PM_obs_net_temp(min_time:max_time)~=nodata&f_conc(min_time:max_time)~=nodata);
r=find(PM_obs_net_temp~=nodata&f_conc_temp~=nodata);
%f_conc_temp=f_conc;
rf_conc=find(f_conc_temp~=nodata);
clear temp;
temp(1,:)=C_all_m_temp2(dust(sus),x,r)+C_all_m_temp2(dust(sussand),x,r)+C_all_m_temp2(salt(na),x,r)+C_all_m_temp2(salt(mg),x,r);
C_all_temp2=temp+C_ep_temp(1,r);
dust_concentrations=mean(C_all_m_temp2(dust(sus),x,r));
sand_concentrations=mean(C_all_m_temp2(dust(sussand),x,r));
salt_concentrations=mean(C_all_m_temp2(salt(na),x,r)+C_all_m_temp2(salt(mg),x,r));
exhaust_concentrations=mean(C_ep_temp(r));
roadwear_concentrations=mean(C_all_m_wearsource_temp(x,roadwear,r));
tyrewear_concentrations=mean(C_all_m_wearsource_temp(x,tyrewear,r));
brakewear_concentrations=mean(C_all_m_wearsource_temp(x,brakewear,r));
total_concentrations=dust_concentrations+sand_concentrations+salt_concentrations+exhaust_concentrations;
observed_concentrations=mean(PM_obs_net_temp(r));
comparable_hours=length(rf_conc)./length(f_conc_temp);
mean_f_conc=mean(f_conc_temp(rf_conc));
%Percentiles
per=90;
obs_c_sort=sort(PM_obs_net_temp(r),'ascend');
mod_c_sort=sort(C_all_temp2,'ascend');
index_per=round(length(obs_c_sort)*per/100);
obs_c_per=obs_c_sort(index_per);
mod_c_per=mod_c_sort(index_per);

%production
%road wear
roadwear_mean=mean(WR_time(roadwear,min_time:max_time));
tyrewear_mean=mean(WR_time(tyrewear,min_time:max_time));
brakewear_mean=mean(WR_time(brakewear,min_time:max_time));
salting_mean=mean(P_road(salt(na),min_time:max_time)+P_road(salt(mg),min_time:max_time));
sussand_mean=mean(P_road(dust(sussand),min_time:max_time));


%sinks
%suspension
%drainage

%Number of salting days
%Number of sanding days
rsalting=find(M_salting(na,min_time:max_time)+M_salting(mg,min_time:max_time)>0);
num_salting=length(rsalting);
freq_salting=length(rsalting)/length(M_salting(na,min_time:max_time));
rsanding=find(M_sanding(min_time:max_time)>0);
num_sanding=length(rsanding);
freq_sanding=length(rsanding)/length(M_sanding(min_time:max_time));
rcleaning=find(t_cleaning(min_time:max_time)>0);
num_cleaning=length(rcleaning);
freq_cleaning=length(rcleaning)/length(t_cleaning(min_time:max_time));
rploughing=find(t_ploughing(min_time:max_time)>0);
num_ploughing=length(rploughing);
freq_ploughing=length(rploughing)/length(t_ploughing(min_time:max_time));

%Days and meteo data
num_days=length(year(min_time:max_time))*dt/24;
mean_RH=mean(RH(min_time:max_time));
mean_Ta=mean(T_a(min_time:max_time));
mean_cloud=mean(cloud_cover(min_time:max_time));
mean_short_rad=mean(short_rad_in(min_time:max_time));
mean_short_rad_net=mean(short_rad_net(min_time:max_time));

%Average ADT
mean_ADT_all(:,:)=mean(N(:,:,min_time:max_time),3)*24*dt;%(t,v)
mean_ADT(1,:)=sum(mean_ADT_all,1);%(v)
prop_studded=mean_ADT_all(st,:)./mean_ADT;%v
%Average speed
mean_speed(he)=sum(V_veh(he,min_time:max_time).*N_v(he,min_time:max_time))./sum(N_v(he,min_time:max_time));
mean_speed(li)=sum(V_veh(li,min_time:max_time).*N_v(li,min_time:max_time))./sum(N_v(li,min_time:max_time));

%Meteo
%total precipitation
total_precip=sum(Snow(min_time:max_time)+Rain(min_time:max_time));
%frequency
rsnow=find(Snow(min_time:max_time)>0);rrain=find(Rain(min_time:max_time)>0);
freq_snow=length(rsnow)/length(Snow(min_time:max_time));freq_rain=length(rrain)/length(Rain(min_time:max_time));freq_precip=freq_rain+freq_snow;
%proportion wet/dry roads
rwet=find(f_q_road(min_time:max_time)<0.5);
prop_wet=length(rwet)/length(f_q_road(min_time:max_time));


%plot emissions
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig);
%ploty1=[total_emissions dust_emissions sand_emissions salt_emissions exhaust_emissions];
ploty1=[total_emissions direct_dust_emissions suspension_dust_emissions salt_emissions exhaust_emissions];
hbar1=bar(ploty1,'g');
set(gca,'XTickLabel',{'Total','Suspension','Direct','Salt','Exhaust'})
title(['Mean emissions ',title_str],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Emission PM_1_0 (g/km/hr)');
for i=1:5,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.0f'),'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end
colormap summer

%plot concentrations
sp2=subplot(m_plot,n_plot,2);
set(gca,'fontsize',fontsize_fig);
%ploty1=[observed_concentrations total_concentrations dust_concentrations sand_concentrations salt_concentrations exhaust_concentrations];
%ploty2=[observed_concentrations 0 0 0 0 0];
ploty1=[observed_concentrations total_concentrations roadwear_concentrations tyrewear_concentrations brakewear_concentrations sand_concentrations salt_concentrations exhaust_concentrations];
ploty2=[observed_concentrations 0 0 0 0 0 0 0];
hbar1=bar(ploty1,'r');
%set(gca,'XTickLabel',{'Observed','Total','Dust','Sand','Salt','Exhaust'})
set(gca,'XTickLabel',{'Obs','Total','Road','Tyre','Brake','Sand','Salt','Exhaust'})
title(['Mean concentrations ',title_str],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Concentration PM_1_0 (\mug/m^3)');
%for i=1:6,
for i=1:8,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.1f'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize_text);
    end
end
hold on
hbar2=bar(ploty2,'k');
hold off

%colormap spring

%plot mass contribution
sp3=subplot(m_plot,n_plot,3);
set(gca,'fontsize',fontsize_fig);
ploty1=[roadwear_mean tyrewear_mean brakewear_mean salting_mean sussand_mean];
hbar1=bar(ploty1,'y');
set(gca,'XTickLabel',{'Road','Tyre','Brake','Salting','Sand'})
title(['Mean mass ',title_str],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Production (g/km)');
for i=1:5,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.0f'),'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end

%plot event frequencies
sp4=subplot(m_plot,n_plot,4);
set(gca,'fontsize',fontsize_fig);
ploty1=[freq_precip prop_wet comparable_hours]*100;
hbar1=bar(ploty1,'m');
set(gca,'XTickLabel',{'Precip','Wet road','Used'})
title(['Event frequency ',title_str],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Percentage of hours (%)');
for i=1:3,
    if ploty1(i)>0,
        text(i,ploty1(i),[num2str(ploty1(i),'%5.1f'),'%'],'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end

%tabulated values
sp5=subplot(m_plot,n_plot,5);
set(gca,'fontsize',fontsize_fig);
axis off
text(0.5,0.90,['Mean ADT (he) = ',num2str(mean_ADT(he),'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.90,['Mean ADT (li) = ',num2str(mean_ADT(li),'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.5,0.80,['Mean speed (he) = ',num2str(mean_speed(he),'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.00,0.80,['Mean speed (li) = ',num2str(mean_speed(li),'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.5,0.70,['Studded (he) = ',num2str(prop_studded(he)*100,'%4.1f'),'%'],'units','normalized','fontsize',fontsize_text);
text(0.00,0.70,['Studded (li) = ',num2str(prop_studded(li)*100,'%4.1f'),'%'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.50,['Number of days = ',num2str(num_days,'%4.1f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.40,['Number salting events = ',num2str(num_salting,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.30,['Number sanding events = ',num2str(num_sanding,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Number cleaning events = ',num2str(num_cleaning,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['Number ploughing events = ',num2str(num_ploughing,'%4.0f')],'units','normalized','fontsize',fontsize_text);
title(['Traffic and activity ',title_str],'fontsize',fontsize_title,'fontweight','bold');

%tabulated values
sp6=subplot(m_plot,n_plot,6);
set(gca,'fontsize',fontsize_fig);
axis off
text(0.0,0.90,['Mean Temperature = ',num2str(mean_Ta,'%4.2f'),' ^oC'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.80,['Mean RH = ',num2str(mean_RH,'%4.1f'),' %'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.70,['Mean global radiation = ',num2str(mean_short_rad,'%4.1f'),' W/m^2'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.60,['Mean cloud cover = ',num2str(mean_cloud*100,'%4.1f'),' %'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.50,['Total precipitation = ',num2str(total_precip,'%4.1f'),' mm'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.40,['Mean dispersion coefficient = ',num2str(mean_f_conc,'%4.3f'),' (\mug/m^3))/(g/km/hr)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Mean concentration obs and model = ',num2str(observed_concentrations,'%4.1f'),' and ',num2str(total_concentrations,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['90th percentile obs and model = ',num2str(obs_c_per,'%4.1f'),' and ',num2str(mod_c_per,'%4.1f'),' (\mug/m^3)'],'units','normalized','fontsize',fontsize_text);

title(['Meteorology ',title_str],'fontsize',fontsize_title,'fontweight','bold');

%--------------------------------------------------------------------------
%plot some mean values
clear PM10_obs_net_temp PM25_obs_net_temp C_ep_temp
PM10_obs_net_temp(1,:)=PM_obs_net(pm_10,min_time:max_time);
PM25_obs_net_temp(1,:)=PM_obs_net(pm_25,min_time:max_time);
C_ep_temp=C_ep(min_time:max_time);
r=find(PM10_obs_net_temp~=nodata&f_conc_temp~=nodata&PM25_obs_net_temp~=nodata&C_ep_temp);
PM10_obs_net_temp_mean=mean(PM10_obs_net_temp(r));
PM25_obs_net_temp_mean=mean(PM25_obs_net_temp(r));
C_ep_temp_mean=mean(C_ep_temp(r));

%fprintf('%5.2f\n',C_ep_temp_mean);
%fprintf('%5.2f\n',PM10_obs_net_temp_mean);
%fprintf('%5.2f\n',PM25_obs_net_temp_mean);
%fprintf('%5.1f\n',100*(PM25_obs_net_temp_mean-C_ep_temp_mean)/(PM10_obs_net_temp_mean-C_ep_temp_mean));

total_wear_factor=(W_0(roadwear,st,li)*h_pave(p_index)*f_PM_dir(pm_10,roadwear,st,li)*mean_ADT_all(st,li)+W_0(roadwear,wi,li)*h_pave(p_index)*f_PM_dir(pm_10,roadwear,wi,li)*mean_ADT_all(wi,li)+W_0(roadwear,su,li)*h_pave(p_index)*f_PM_dir(pm_10,roadwear,su,li)*mean_ADT_all(su,li))/sum(mean_ADT_all(:,li));
studded_wear_factor=W_0(roadwear,st,li)*h_pave(p_index)*f_PM_dir(pm_10,roadwear,st,li);
correction_wear=(roadwear_mean-tyrewear_mean-brakewear_mean)/roadwear_mean;
correction_wear=1;
%correction_concentration=(observed_concentrations-sand_concentrations-salt_concentrations-exhaust_concentrations)/(dust_concentrations);
correction_concentration=1+(observed_concentrations-total_concentrations)/(dust_concentrations);
emission_factor_studs=total_wear_factor/correction_wear*correction_concentration*studded_wear_factor/total_wear_factor;

%fprintf('%5.2f\n',emission_factor_studs);

end

if plot_figure(13),
scale=scale_all; %(pixels/mm on screen)
fig13=figure(13);
set(fig13,'Name','Summary','MenuBar','figure','position',[left_corner+9*shift_x bottom_corner+9*shift_y fix(260*scale_x) fix(260*scale_y)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
figure(fig13);
clf;
n_plot=1;
m_plot=3;

%plot concentrations
sp1=subplot(4,1,1);
set(gca,'fontsize',fontsize_fig);
title([title_str,': PM_1_0'],'fontsize',fontsize_title,'fontweight','bold');
hold on
ylabel_text='PM_1_0 concentration (\mug/m^3)';
xlabel_text='Date';
legend_text={'Observed','Modelled salt','Modelled dust','Modelled sand','Modelled+EP'};
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
temp=C_all_m(min(salt):max(salt),:,:);
clear C_salt_sum;
C_salt_sum(:,:)=sum(temp,1);
r=find(PM_obs_net_temp(pm_10,:)==nodata|f_conc==nodata);
%r=find(f_conc==nodata);
C_all_temp(pm_10,r)=NaN;
C_ep_temp=C_ep;
C_ep_temp(r)=NaN;
C_salt_sum(pm_10,r)=NaN;
C_all_m_temp(dust(sus),pm_10,r)=NaN;
C_all_m_temp(dust(sussand),pm_10,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;
r2=find(f_conc==nodata|C_ep_temp==nodata);
C_ep_temp(r2)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:)+C_ep_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_salt_sum(pm_10,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,C_all_m_temp(dust(sus),pm_10,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_all_m_temp(dust(sussand),pm_10,:),min_time,max_time,av);
%[x_str xplot yplot5]=Average_data_func(date_num,PM_obs_temp(pm_10,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',2);
plot(xplot,yplot3,'g:','linewidth',2);
plot(xplot,yplot4,'r:','linewidth',2);
plot(xplot,yplot5,'m--','linewidth',2);
plot(xplot,yplot1,'b-','linewidth',2);
%plot(xplot,yplot5,'b-','linewidth',1);
%plot(xplot,yplot6,'b:','linewidth',1);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);

axis tight
drawnow

%plot road mass
sp2=subplot(4,1,2);
set(gca,'fontsize',fontsize_fig);
fact=1/1000/b_road_lanes;
hold on
ylabel_text='Mass loading (g/m^2)';
legend_text={'Suspendable dust','Road salt','Dissolved salt','Suspendable sand'};
[x_str xplot yplot1]=Average_data_func(date_num,M_road(dust(sus),:)*fact,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,(M_road(salt(na),:)+M_road(salt(mg),:))*fact,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road(dust(sussand),:)*fact,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,(M_road_0_dissolved_salt(na,:)+M_road_0_dissolved_salt(mg,:))*fact,min_time,max_time,av);

max_plot=max(max([yplot1 yplot2 yplot3]));
[x_str xplot yplot4]=Average_data_func(date_num,t_cleaning,min_time,max_time,av);
r=find(t_cleaning~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',1);
    legend_text={'Cleaning','Suspendable dust','Road salt','Dissolved salt','Suspendable sand'};
end
plot(xplot,yplot1,'k-','linewidth',2);
plot(xplot,yplot2,'g--','linewidth',2);
plot(xplot,yplot5,'g:','linewidth',1);
plot(xplot,yplot3,'r--','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
ylabel_text='PM_1_0 observed concentration (\mug/m^3)';
xlabel_text='PM_1_0 modelled concentration (\mug/m^3)';
%legend_text={'Modelled','Observed','Modelled salt','Modelled dust'};
r=find(f_conc==nodata);
C_all_temp(pm_10,r)=NaN;
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
r=find(PM_obs_net_temp(pm_10,:)==nodata);
PM_obs_net_temp(pm_10,r)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
if EP_emis_available,
    C_ep_temp=C_ep;
    r2=find(f_conc==nodata|C_ep_temp==nodata);
    C_ep_temp(r2)=NaN;
end
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
if EP_emis_available,
    [x_str xplot yplot3]=Average_data_func(date_num,C_ep_temp,min_time,max_time,av);
    yplot1=yplot1+yplot3;
end
r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'bo','markersize',4);
ylabel(ylabel_text);
xlabel(xlabel_text);
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
x=pm_10;
dust_emissions=mean(E_all_m(dust(sus),x,min_time:max_time));

clear E_all_m_temp E_suspension_all_temp E_direct_all_temp E_all_temp
E_all_m_temp(:,1)=E_all_m(dust(sus),x,min_time:max_time);
dust_ef=mean(E_all_m_temp./N_total(min_time:max_time));
dust_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

suspension_emissions=mean(E_suspension_all(x,min_time:max_time));
E_suspension_all_temp(:,1)=E_suspension_all(x,min_time:max_time);
suspension_ef=mean(E_suspension_all_temp./N_total(min_time:max_time));
suspension_ef=mean(E_suspension_all_temp)./mean(N_total(min_time:max_time));

direct_emissions=mean(E_direct_all(x,min_time:max_time));
E_direct_all_temp(:,1)=E_direct_all(x,min_time:max_time);
direct_ef=mean(E_direct_all_temp./N_total(min_time:max_time));
direct_ef=mean(E_direct_all_temp)./mean(N_total(min_time:max_time));

sand_emissions=mean(E_all_m(dust(sussand),x,min_time:max_time));
E_all_m_temp(:,1)=E_all_m(dust(sussand),x,min_time:max_time);
sand_ef=mean(E_all_m_temp./N_total(min_time:max_time));
sand_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

salt_emissions=mean(E_all_m(salt(na),x,min_time:max_time)+E_all_m(salt(mg),x,min_time:max_time));
E_all_m_temp(:,1)=E_all_m(salt(na),x,min_time:max_time)+E_all_m(salt(mg),x,min_time:max_time);
salt_ef=mean(E_all_m_temp./N_total(min_time:max_time));
salt_ef=mean(E_all_m_temp)./mean(N_total(min_time:max_time));

if EP_emis_available,
    exhaust_emissions=mean(EP_emis(min_time:max_time));
else
    exhaust_emissions=0;
end
exhaust_ef=mean(EP_emis(min_time:max_time)./N_total(min_time:max_time));
exhaust_ef=mean(EP_emis(min_time:max_time))./mean(N_total(min_time:max_time));

total_emissions=suspension_emissions+direct_emissions+exhaust_emissions;
E_all_temp(:,1)=E_all(x,min_time:max_time);
%total_ef=mean((E_all_temp+EP_emis(min_time:max_time))./N_total(min_time:max_time));
total_ef=mean((E_all_temp+EP_emis(min_time:max_time)))./mean(N_total(min_time:max_time));

%concentrations
clear PM_obs_net_temp PM_obs_bg_temp f_conc_temp C_all_m_temp2 C_all_temp2 C_all_m_wearsource_temp C_ep_temp
PM_obs_net_temp(1,:)=PM_obs_net(pm_10,min_time:max_time);
PM_obs_bg_temp(1,:)=PM_obs_bg(pm_10,min_time:max_time);
f_conc_temp=f_conc(min_time:max_time);
C_all_m_temp2=C_all_m(:,:,min_time:max_time);
C_all_m_wearsource_temp=C_all_m_wearsource(:,:,min_time:max_time);
C_ep_temp=C_ep(min_time:max_time);
%r=find(PM_obs_net_temp(min_time:max_time)~=nodata&f_conc(min_time:max_time)~=nodata);
r=find(PM_obs_net_temp~=nodata&f_conc_temp~=nodata);
r_bg=find(PM_obs_net_temp~=nodata&f_conc_temp~=nodata&PM_obs_bg_temp~=nodata);
%f_conc_temp=f_conc;
rf_conc=find(f_conc_temp~=nodata);
clear temp;
temp(1,:)=C_all_m_temp2(dust(sus),x,r)+C_all_m_temp2(dust(sussand),x,r)+C_all_m_temp2(salt(na),x,r)+C_all_m_temp2(salt(mg),x,r);
C_all_temp2=temp+C_ep_temp(1,r);
dust_concentrations=mean(C_all_m_temp2(dust(sus),x,r));
sand_concentrations=mean(C_all_m_temp2(dust(sussand),x,r));
salt_concentrations=mean(C_all_m_temp2(salt(na),x,r)+C_all_m_temp2(salt(mg),x,r));
if EP_emis_available,
    exhaust_concentrations=mean(C_ep_temp(r));
else
    exhaust_concentrations=0;
    end
roadwear_concentrations=mean(C_all_m_wearsource_temp(x,roadwear,r));
tyrewear_concentrations=mean(C_all_m_wearsource_temp(x,tyrewear,r));
brakewear_concentrations=mean(C_all_m_wearsource_temp(x,brakewear,r));
total_concentrations=dust_concentrations+sand_concentrations+salt_concentrations+exhaust_concentrations;
observed_concentrations=mean(PM_obs_net_temp(r));
observed_concentrations_bg=mean(PM_obs_bg_temp(r_bg));
comparable_hours=length(rf_conc)./length(f_conc_temp);
mean_f_conc=mean(f_conc_temp(rf_conc));
%Percentiles and exceedances
clear PM10_obs_net_temp PM10_obs_bg_temp PM10_mod_net_temp
PM10_obs_net_temp(1,:)=PM_obs_net(pm_10,:);
PM10_obs_bg_temp(1,:)=PM_obs_bg(pm_10,:);
PM10_mod_net_temp(1,:)=C_all_m_temp(dust(sus),x,:)+C_all_m_temp(dust(sussand),x,:)+C_all_m_temp(salt(na),x,:)+C_all_m_temp(salt(mg),x,:);
if EP_emis_available,
    PM10_mod_net_temp(1,:)=PM10_mod_net_temp(1,:)+C_ep;
end
r_bg=find(PM10_obs_net_temp==nodata|f_conc==nodata|PM10_obs_bg_temp==nodata);
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
observed_ef=mean(PM_obs_net_temp(r)./f_conc_temp(r)/N_total(r)');


%production
%road wear
roadwear_mean=mean(WR_time(roadwear,min_time:max_time));
tyrewear_mean=mean(WR_time(tyrewear,min_time:max_time));
brakewear_mean=mean(WR_time(brakewear,min_time:max_time));
salting_mean=mean(P_road(salt(na),min_time:max_time)+P_road(salt(mg),min_time:max_time));
sussand_mean=mean(P_road(dust(sussand),min_time:max_time));


%sinks
%suspension
%drainage

%Number of salting days
%Number of sanding days
rsalting=find(M_salting(na,min_time:max_time)+M_salting(mg,min_time:max_time)>0);
num_salting=length(rsalting);
freq_salting=length(rsalting)/length(M_salting(na,min_time:max_time));
rsanding=find(M_sanding(min_time:max_time)>0);
num_sanding=length(rsanding);
freq_sanding=length(rsanding)/length(M_sanding(min_time:max_time));
rcleaning=find(t_cleaning(min_time:max_time)>0);
num_cleaning=length(rcleaning);
freq_cleaning=length(rcleaning)/length(t_cleaning(min_time:max_time));
rploughing=find(t_ploughing(min_time:max_time)>0);
num_ploughing=length(rploughing);
freq_ploughing=length(rploughing)/length(t_ploughing(min_time:max_time));

%Days and meteo data
num_days=length(year(min_time:max_time))*dt/24;
mean_RH=mean(RH(min_time:max_time));
mean_Ta=mean(T_a(min_time:max_time));
mean_cloud=mean(cloud_cover(min_time:max_time));
mean_short_rad=mean(short_rad_in(min_time:max_time));
mean_short_rad_net=mean(short_rad_net(min_time:max_time));

%Average ADT
mean_ADT_all(:,:)=mean(N(:,:,min_time:max_time),3)*24*dt;%(t,v)
mean_ADT(1,:)=sum(mean_ADT_all,1);%(v)
prop_studded=mean_ADT_all(st,:)./mean_ADT;%v
mean_AHT=sum(mean_ADT)/24;
%Average speed
mean_speed(he)=sum(V_veh(he,min_time:max_time).*N_v(he,min_time:max_time))./sum(N_v(he,min_time:max_time));
mean_speed(li)=sum(V_veh(li,min_time:max_time).*N_v(li,min_time:max_time))./sum(N_v(li,min_time:max_time));

%Meteo
%total precipitation
total_precip=sum(Snow(min_time:max_time)+Rain(min_time:max_time));
%frequency
rsnow=find(Snow(min_time:max_time)>0);rrain=find(Rain(min_time:max_time)>0);
freq_snow=length(rsnow)/length(Snow(min_time:max_time));freq_rain=length(rrain)/length(Rain(min_time:max_time));freq_precip=freq_rain+freq_snow;
%proportion wet/dry roads
rwet=find(f_q_road(min_time:max_time)<0.5);
rwet_obs=find(f_q_obs(min_time:max_time)<0.5);
rdry=find(f_q_road(min_time:max_time)>=0.5);
rdry_obs=find(f_q_obs(min_time:max_time)>=0.5);
prop_wet=length(rwet)/length(f_q_road(min_time:max_time));
prop_wet_mod=length(rwet)/length(f_q_road(min_time:max_time));
prop_wet_obs=length(rwet_obs)/length(f_q_obs(min_time:max_time));
%Wet dry score
clear r_wetscore
f_q_obs_temp=f_q_obs(min_time:max_time);
f_q_road_temp=f_q_road(min_time:max_time);
f_q_obs_temp(rwet_obs)=-1;
f_q_road_temp(rwet)=-1;
f_q_obs_temp(rdry_obs)=1;
f_q_road_temp(rdry)=1;
f_q_score=mean(f_q_obs_temp.*f_q_road_temp);
r_hits=find(f_q_obs_temp.*f_q_road_temp>0);
f_q_hits=length(r_hits)/length(f_q_road_temp);
rel_prop_wet=length(rwet)/length(rwet_obs);
rel_prop_dry=length(rdry)/length(rdry_obs);
r_wetscore(1)=sum(f_q_obs_temp<0&f_q_road_temp<0);
r_wetscore(2)=sum(f_q_obs_temp>0&f_q_road_temp<0);
r_wetscore(3)=sum(f_q_obs_temp>0&f_q_road_temp>0);
r_wetscore(4)=sum(f_q_obs_temp<0&f_q_road_temp>0);
rel_prop_wet_wet=length(find(f_q_obs_temp<0&f_q_road_temp<0))/length(find(f_q_obs_temp<0));
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
set(gca,'XTickLabel',{'Obs.','Mod.','Dir.','Sus.','Exh.'})
title(['Mean emission factor'],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Emission factor PM_1_0 (mg/km/veh)');
for i=1:5,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.0f'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize_text);
    end
end
colormap summer
hold on
hbar2=bar(ploty2,'k');
hold off
xlim([0 6])

%plot concentrations
sp2=subplot(4,3,9);
set(gca,'fontsize',fontsize_fig);
clear ploty1 ploty2
%ploty1=[observed_concentrations total_concentrations dust_concentrations sand_concentrations salt_concentrations exhaust_concentrations];
%ploty2=[observed_concentrations 0 0 0 0 0];
ploty1=[observed_concentrations total_concentrations roadwear_concentrations tyrewear_concentrations brakewear_concentrations sand_concentrations salt_concentrations exhaust_concentrations];
ploty2=[observed_concentrations 0 0 0 0 0 0 0];
hbar1=bar(ploty1,'r');
%set(gca,'XTickLabel',{'Observed','Total','Dust','Sand','Salt','Exhaust'})
set(gca,'XTickLabel',{'Obs.','Mod.','Road','Tyre','Brake','Sand','Salt','Exh.'})
title(['Mean concentrations'],'fontsize',fontsize_title,'fontweight','bold');
ylabel('Concentration PM_1_0 (\mug/m^3)');
%for i=1:6,
for i=1:8,
    if ploty1(i)>0,
        text(i,ploty1(i),num2str(ploty1(i),'%5.1f'),'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize_text);
    end
end
hold on
hbar2=bar(ploty2,'k');
hold off
xlim([0 9])

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
text(0.0,0.40,['Number salting events = ',num2str(num_salting,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.30,['Number sanding events = ',num2str(num_sanding,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.20,['Number cleaning events = ',num2str(num_cleaning,'%4.0f')],'units','normalized','fontsize',fontsize_text);
text(0.0,0.10,['Number ploughing events = ',num2str(num_ploughing,'%4.0f')],'units','normalized','fontsize',fontsize_text);
%title(['Traffic and activity'],'fontsize',fontsize_title,'fontweight','bold');

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
text(0.0,1,'Concentrations','fontweight','bold');
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
fprintf('Net and total concentration results\n');
fprintf('%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\n','Obs_mean','Mod_mean','Obs_per','Mod_per','Obs_36_high','Mod_36_high','Obs_exceed','Mod_exceed','R_sq','RMSE','NRMSE(%)','FB(%)');
fprintf('%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\n',observed_concentrations,total_concentrations,obs_c_per,mod_c_per,high36_obs,high36_mod,obs_c_dif_ex,mod_c_dif_ex,r_sq_net_pm10,rmse_net,nrmse_net,fb_net);
%fprintf('With background concentration results\n');
fprintf('%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\t%12.2f\n',observed_concentrations+observed_concentrations_bg,total_concentrations+observed_concentrations_bg,obs_c_bg_per,mod_c_bg_per,high36_obs_bg,high36_mod_bg,obs_c_bg_ex,mod_c_bg_ex,r_sq_bg_pm10,rmse_bg,nrmse_bg,fb_bg);
end

end%plot 13

%Special AE plotting routines
if plot_figure(8),
scale=scale_all; %(pixels/mm on screen)
fig8=figure(8);
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
if use_salting_data_flag,legend_text={'Observed','Modelled salt','Modelled+exhaust',};end
if use_sanding_data_flag,legend_text={'Observed','Modelled sand','Modelled+exhaust',};end
if use_sanding_data_flag&&use_salting_data_flag,legend_text={'Observed','Modelled sand','Modelled salt','Modelled+exhaust',};end
PM_obs_net_temp=PM_obs_net;
%PM_obs_temp=PM_obs;
temp=C_all_m(min(salt):max(salt),:,:);
clear C_salt_sum;
C_salt_sum(:,:)=sum(temp,1);
r=find(PM_obs_net_temp(pm_10,:)==nodata|f_conc==nodata);
%r=find(f_conc==nodata);
C_all_temp(pm_10,r)=NaN;
C_ep_temp=C_ep;
C_ep_temp(r)=NaN;
C_salt_sum(pm_10,r)=NaN;
C_all_m_temp(dust(sus),pm_10,r)=NaN;
C_all_m_temp(dust(sussand),pm_10,r)=NaN;
PM_obs_net_temp(pm_10,r)=NaN;
r2=find(f_conc==nodata|C_ep_temp==nodata);
C_ep_temp(r2)=NaN;
%r=find(PM_obs_temp(pm_10,:)==nodata);
%PM_obs_temp(pm_10,r)=NaN;
[x_str xplot yplot1]=Average_data_func(date_num,C_all_temp(pm_10,:)+C_ep_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,PM_obs_net_temp(pm_10,:),min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,C_salt_sum(pm_10,:),min_time,max_time,av);
[x_str xplot yplot4]=Average_data_func(date_num,C_all_m_temp(dust(sus),pm_10,:),min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,C_all_m_temp(dust(sussand),pm_10,:),min_time,max_time,av);
%[x_str xplot yplot5]=Average_data_func(date_num,PM_obs_temp(pm_10,:),min_time,max_time,av);
plot(xplot,yplot2,'k--','linewidth',2);
if use_salting_data_flag,plot(xplot,yplot3,'b:','linewidth',2);end
%plot(xplot,yplot4,'r:','linewidth',2);
if use_sanding_data_flag,plot(xplot,yplot5,'r:','linewidth',2);end
plot(xplot,yplot1,'b-','linewidth',2);
%plot(xplot,yplot5,'b-','linewidth',1);
%plot(xplot,yplot6,'b:','linewidth',1);
ylabel(ylabel_text);
%xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
set(l1,'fontsize',fontsize_legend);
xlim([xplot(1) xplot(end)]);
%axis tight
drawnow

%plot road mass
sp2=subplot(4,1,3);
set(gca,'fontsize',fontsize_fig);
title(['Mass loading'],'fontsize',fontsize_title,'fontweight','bold');
fact=1/1000/b_road_lanes;
hold on
ylabel_text='Mass loading (g.m^-^2)';
legend_text={'Suspendable dust'};
if use_salting_data_flag,legend_text={'Suspendable dust','Salt'};end
if use_sanding_data_flag,legend_text={'Suspendable dust','Suspendable sand'};end
if use_sanding_data_flag&&use_salting_data_flag,legend_text={'Suspendable dust','Road salt','Suspendable sand'};end

[x_str xplot yplot1]=Average_data_func(date_num,M_road(dust(sus),:)*fact,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,(M_road(salt(na),:)+M_road(salt(mg),:))*fact,min_time,max_time,av);
[x_str xplot yplot3]=Average_data_func(date_num,M_road(dust(sussand),:)*fact,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,(M_road_0_dissolved_salt(na,:)+M_road_0_dissolved_salt(mg,:))*fact,min_time,max_time,av);

max_plot=max(max([yplot1 yplot2 yplot3]));
[x_str xplot yplot4]=Average_data_func(date_num,t_cleaning,min_time,max_time,av);
r=find(t_cleaning~=0);
if ~isempty(r),
    stairs(xplot,yplot4/max(yplot4)*max_plot,'b-','linewidth',1);
    legend_text={'Cleaning','Suspendable dust','Salt','Dissolved salt','Suspendable sand'};
end
plot(xplot,yplot1,'k-','linewidth',2);
if use_salting_data_flag,plot(xplot,yplot2,'b:','linewidth',2);end
%plot(xplot,yplot5,'g:','linewidth',1);
if use_sanding_data_flag,plot(xplot,yplot3,'r:','linewidth',2);end
ylabel(ylabel_text);
%xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
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
clear N_total_temp f_conc_temp E_all_temp PM_obs_net_temp ef_temp
clear yplot1 yplot2 yplot3 yplot4 yplot4a yplot4b yplot5
N_total_temp(1,:)=N_total(1:max_time)';
f_conc_temp(1,:)=f_conc;
E_all_temp(1,:)=E_all(pm_10,1:max_time)+EP_emis(1:max_time)';
PM_obs_net_temp(1,:)=PM_obs_net(pm_10,:);
r=find(f_conc==nodata|PM_obs_net(pm_10,:)==nodata);
f_conc_temp(r)=NaN;
%r=find(PM_obs_net(pm_10,:)==nodata);
PM_obs_net_temp(r)=NaN;
N_total_temp(r)=NaN;
E_all_temp(r)=NaN;
E_obs_temp=PM_obs_net_temp./f_conc_temp;
%E_obs_temp=ef_temp.*N_total_temp;
%ef_mod_temp=E_all_temp./N_total_temp;
[x_str xplot yplot4a]=Average_data_func(date_num,PM_obs_net_temp,min_time,max_time,av);
[x_str xplot yplot4b]=Average_data_func(date_num,f_conc_temp,min_time,max_time,av);
%[x_str xplot yplot4]=Average_data_func(date_num,ef_temp,min_time,max_time,av);
[x_str xplot yplot1]=Average_data_func(date_num,E_all_temp,min_time,max_time,av);
[x_str xplot yplot5]=Average_data_func(date_num,E_obs_temp,min_time,max_time,av);
[x_str xplot yplot2]=Average_data_func(date_num,N_total_temp,min_time,max_time,av);
yplot3=yplot1./yplot2;
yplot4=yplot5./yplot2;
%yplot4=yplot4a./yplot4b;
plot(xplot,yplot3,'b-','linewidth',2);
%plot(xplot,yplot4./yplot2,'k--','linewidth',2);
plot(xplot,yplot4,'k--','linewidth',2);
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
end
l1=legend(legend_text,'location','NorthWest');
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
[x_str xplot yplot2]=Average_data_func(date_num,M_salting(na,:)+M_salting(mg,:),min_time,max_time,av);
%[x_str xplot yplot3]=Average_data_func(date_num,M_salting(mg,:),min_time,max_time,av);
%bar(xplot, [yplot1 yplot2 yplot3],'EdgeColor','none');
if av==2,m_scale=24;else m_scale=1;end
if use_salting_data_flag,stairs(xplot, yplot2*m_scale,'b-','linewidth',2);end
if use_sanding_data_flag,stairs(xplot, yplot1*m_scale,'r-','linewidth',2);end
%stairs(xplot, yplot3,'g:');
ylabel(ylabel_text);
xlabel(xlabel_text);
if (xplot(end)-xplot(1))>day_tick_limit,
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','mmm','keeplimits');end
else
    if av==3||av==5, set(gca,'XTick',xplot,'XTickLabel',x_str); else datetick('x','dd mmm','keepticks');end
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
if which_moisture_plot==0,
    set(fig14,'Name','Scatter temperature and moisture','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x/1.5) fix(260*scale_y/1.5)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
    n_plot=1;
    m_plot=1;
else
    set(fig14,'Name','Scatter temperature and moisture','MenuBar','figure','position',[left_corner+7*shift_x bottom_corner+7*shift_y fix(260*scale_x*1.5) fix(260*scale_y/1.5)],'paperorientation','portrait','paperpositionmode','auto','PaperType','A4');
    n_plot=2;
    m_plot=1;
end
figure(fig14);
clf;

%plot concentrations
sp1=subplot(m_plot,n_plot,1);
set(gca,'fontsize',fontsize_fig*1.5);
title([title_str,': temperature difference'],'fontsize',fontsize_title*1.2,'fontweight','bold');
hold on
%ylabel_text='T_s - T_a observed (C^o)';
%xlabel_text='T_s - T_a modelled (C^o)';
ylabel_text='\DeltaT_s observed (C^o)';
xlabel_text='\DeltaT_s modelled (C^o)';

T_a_temp2=T_a;
if ~isempty(T_a_nodata),T_a_temp2(T_a_nodata)=nodata;end
road_temperature_obs_temp2=road_temperature_obs;
if ~isempty(road_temperature_obs_missing),road_temperature_obs_temp2(road_temperature_obs_missing)=nodata;end
T_a_temp=T_a_temp2(min_time:max_time);
T_s_temp=T_s(min_time:max_time)';
road_temperature_obs_temp=road_temperature_obs_temp2(min_time:max_time);
date_num_temp=date_num(min_time:max_time);
r=find(T_a_temp==nodata|T_s_temp==nodata|road_temperature_obs_temp==nodata);
T_a_temp(r)=NaN;
T_s_temp(r)=NaN;
road_temperature_obs_temp(r)=NaN;
T_diff_mod=T_s_temp-T_a_temp;
T_diff_obs=road_temperature_obs_temp-T_a_temp;

[x_str xplot yplot1]=Average_data_func(date_num_temp,T_diff_mod,1,length(T_diff_mod),av);
[x_str xplot yplot2]=Average_data_func(date_num_temp,T_diff_obs,1,length(T_diff_mod),av);
r=find(~isnan(yplot1)&~isnan(yplot2));
plot(yplot1(r),yplot2(r),'ko','markersize',3,'linewidth',1);
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
fr_bias_T=(mean(yplot1(r))-mean(yplot2(r)))/(mean(yplot1(r))+mean(yplot2(r)))*2;
rfac=find(yplot1(r)<2*yplot2(r)&(yplot1(r)>0.5*yplot2(r)));
fac2_T=length(rfac)/length(r);
mean_obs_T=mean(yplot2(r));
mean_mod_T=mean(yplot1(r));
a_reg = polyfit(yplot1(r),yplot2(r),1);
if ~isempty(yplot2(r)),
    a_reg=linortfit2(yplot2(r),yplot1(r));a_reg=fliplr(a_reg);
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
    fprintf('%20s\t%20s\t%20s\t%20s\t%20s\t\n','Mean observed','Mean modelled','Corr (r^2)','Intercept','Slope');
    fprintf('%20.2f\t%20.2f\t%20.2f\t%20.2f\t%20.2f\t\n',mean_obs_T,mean_mod_T,r_sq_T,a_reg(2),a_reg(1));
    fprintf('%20s\t%20s\t%20s\t%20s\t\n','Wet road observed','Wet road modelled','Hits all conditions','Hits wet conditions');
    fprintf('%20.1f\t%20.1f\t%20.1f\t%20.1f\t\n',r_wetscore_temp2(1)*100,r_wetscore_temp2(2)*100,r_wetscore_temp2(3)*100,r_wetscore_temp2(4)*100);
    end
end
%return

if which_moisture_plot==2,
sp2=subplot(m_plot,n_plot,2);
r=find(f_q_obs==nodata|f_q_road==nodata);
road_wetness_obs_temp=road_wetness_obs(min_time:max_time);
g_road_temp=g_road(min_time:max_time)+s_road(min_time:max_time);
date_num_temp=date_num(min_time:max_time);

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
a_reg=linortfit2(yplot2(r),yplot1(r));a_reg=fliplr(a_reg);
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

end
%--------------------------------------------------------------------------

return

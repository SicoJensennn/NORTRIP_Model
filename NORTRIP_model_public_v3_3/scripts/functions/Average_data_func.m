function [av_date_str av_date_num av_val] = Average_data_func(date_num,val,i_min,i_max,index_in,varargin)
% Average_data_func: Averages input data along the lines of:
% 1: No averaging
% 2: Daily means
% 3: Daily cycles
% 4: 12 hourly means starting at av_start_hour=[6,18];
% 5: Weekly cycles
% 6: Daily running means
% 7: Weekly means
% 8: Monthly means
% 9: Hourly means

% varargin: text string to specify if min, max, medium etc. of averaging
% period is used. Currently only max supported
if isempty(varargin),varargin='';end
use_max=0;
if strcmp(varargin,'max')||strcmp(varargin,'Max'),
    use_max=1;
end
%Treats NaNs as non valid data
%Sets the first member of index array to the specification index. The other
%indexes, if they exist, are used to specify parameters in the averaging
index=index_in(1);
if length(index_in)==2,
    index2=index_in(2);
else
    index2=NaN;
end
   
%No averaging
if index==1,
    av_date_num=date_num(i_min:i_max);
    av_val(:,1)=val(i_min:i_max);
    av_date_str = datestr(av_date_num ,'HH:MM dd mmm');
end

%Hourly means
if index==9
    j=0;
    if ~isnan(index2),min_num=index2;else min_num=1;end
    av_date_vec=datevec(date_num);
    
    %date_num_hours=min(date_num):1/24:max(date_num);
    date_num_hours=date_num(i_min):1/24:date_num(i_max);
    for i=1:length(date_num_hours)
        date_num_hours_vec=datevec(date_num_hours(i));
        r=find(av_date_vec(:,1)==date_num_hours_vec(1)&av_date_vec(:,2)==date_num_hours_vec(2)&av_date_vec(:,3)==date_num_hours_vec(3)&av_date_vec(:,4)==date_num_hours_vec(4));
        r2=find((r>i_min&r<i_max));
        if length(r(r2))>=1
            j=j+1;
            val_temp=val(r(r2));
            r3=find(~isnan(val_temp));
            if ~isempty(r3)&&length(r3)>min_num%more than 1 available
                av_val(i,1)=mean(val_temp(r3));
                if use_max
                    av_val(i,1)=max(val_temp(r3));
                end
            else
                av_val(i,1)=NaN;
            end
            %av_date_num(j,1)=i_hour/24;
            %if j==33,
            %    fprintf('%f \n',length(val_temp(r3)));
            %    fprintf('%f \n',max(val_temp));
            %end
        else
        j=j+1;
        av_val(i,1)=NaN;
        %av_date_num(j,1)=i_hour;
        end
    end
    av_date_num=date_num_hours;
    av_date_str = datestr(av_date_num ,'dd mmm');
end

%Daily means
if index==2,
    j=0;
    if ~isnan(index2),min_num=index2;else min_num=6;end
    for i_day=floor(date_num(i_min)):floor(date_num(i_max)),
        r=find(i_day==floor(date_num));
        r2=find((r>i_min&r<i_max));
        if length(r(r2))>=12,
            j=j+1;
            val_temp=val(r(r2));
            r3=find(~isnan(val_temp));
            if ~isempty(r3)&&length(r3)>min_num,%more than 6 hours available
                av_val(j,1)=mean(val_temp(r3));
                if use_max,
                    av_val(j,1)=max(val_temp(r3));
                end
            else
                av_val(j,1)=NaN;
            end
            av_date_num(j,1)=i_day;
            %if j==33,
            %    fprintf('%f \n',length(val_temp(r3)));
            %    fprintf('%f \n',max(val_temp));
            %end
        else
        j=j+1;
        av_val(j,1)=NaN;
        av_date_num(j,1)=i_day;
        end
    end
    av_date_str = datestr(av_date_num ,'dd mmm');
end

%Daily cycle
if index==3,
    [Y, M, D, H, MN, S] = datevec(date_num(i_min:i_max));
    for j=0:23,
        r=find(H==j);
        if ~isempty(r),
            jj=j+1;
            val_temp=val(i_min-1+r);
            r2=find(~isnan(val_temp));
            if ~isempty(r2),
                av_val(jj,1)=mean(val_temp(r2));
            else
                av_val(jj,1)=NaN;
            end
            av_date_num(jj,1)=j;
        end
    end
    av_date_str = datestr(av_date_num/24,'HH');
end

%Daily 12 hour means
if index==4,
    av_start_hour=[6,18];
    %av_start_hour=[10,22];
    if length(index_in)==3,av_start_hour=[index_in(2),index_in(3)];end
    [Y, M, D, H, MN, S] = datevec(date_num(i_min:i_max));
    val_temp2=val(i_min:i_max);
    date_num_temp2=date_num(i_min:i_max);
    %Start at first whole 12 hours
    r1=find(H==av_start_hour(1));
    r2=find(H==av_start_hour(2));
    i_halfday_min=min(min(r1),min(r2));
    i_halfday_max=max(max(r1),max(r2));
    i_halfday=i_halfday_min:12:i_halfday_max-12;
    av_date_num=date_num_temp2(i_halfday);
    av_date_str = datestr(av_date_num ,'HH:MM dd mmm');
    for i=1:length(i_halfday),
        val_temp=val_temp2(i_halfday(i):i_halfday(i)+12);       
        rnan=find(~isnan(val_temp));
        if length(rnan)>6,
            av_val(i,1)=mean(val_temp(rnan));
            if use_max,
                av_val(i,1)=max(val_temp(rnan));
            end
        else
            av_val(i,1)=NaN;
        end
    end
end

%Week days
if index==5,
    [weekday_val, weekday_str] = weekday(date_num(i_min:i_max));
    [Y, M, D, H, MN, S] = datevec(date_num(i_min:i_max));
    for j=1:7,
       jj=j+1; if jj==8,jj=1;end;%moves sunday to the end
       r=find(weekday_val==jj);
        if ~isempty(r),
            val_temp=val(i_min-1+r);
            r2=find(~isnan(val_temp));
            if ~isempty(r2),
                av_val(j,1)=mean(val_temp(r2));
            else
                av_val(j,1)=NaN;
            end
            av_date_num(j,1)=j;
        end
        av_date_str(j,1:3) = weekday_str(r(1),:);
    end
end

%Daily running means. No NaN traps!
if index==6,
    av_date_num=date_num(i_min:i_max);
    av_date_str = datestr(av_date_num ,'HH:MM dd mmm');
    di=11;
    ii=0;
    for i=i_min:i_max
        ii=ii+1;
        i1=max(i-di,i_min);
        i2=min(i+di,i_max);
        i_num=i2-i1+1;
        av_val(ii,1)=mean(val(i1:i2));
    end
end

%Weekly means starting on monday
if index==7,
    [weekday_val, weekday_str] = weekday(date_num(i_min:i_max));
    [Y, M, D, H, MN, S] = datevec(date_num(i_min:i_max));
    n_av=24*7;
    r_monday=find(weekday_val==2&H==0);%Find all the mondays at 0 hours
    n_monday=length(r_monday);
    if n_monday>0,
    for j=1:n_monday+1,
        if j==1,%start on first day
            i_start=i_min;
            i_end=r_monday(1)+i_min-1;
        else
            i_start=r_monday(j-1)+i_min-1;
            i_end=min(i_start+n_av,i_max);
        end
        val_temp=val(i_start:i_end);
        r2=find(~isnan(val_temp));
        if length(r2)>n_av/4,
            av_val(j,1)=mean(val_temp(r2));
        else
            av_val(j,1)=NaN;
        end
        av_date_num(j,1)=date_num(i_start);
    end
    else
        av_val(1,1)=NaN;
        av_date_num(i,1)=date_num(i_start);
    end
    av_date_str = datestr(av_date_num ,'dd mmm');

end

%Monthly means
if index==8,
    date_num_temp=date_num(i_min:i_max);
    [Y, M, D, H, MN, S] = datevec(date_num_temp);
    val_temp=val(i_min:i_max);   
    n_av=24*30;
    start_year=Y(1);
    end_year=Y(end);
    jj=0;
    for k=start_year:end_year,
    for j=1:12,
        r_month=find(M==j&Y==k);
        if ~isempty(r_month),
           jj=jj+1;
           val_temp2=val_temp(r_month);
           date_num_temp2=date_num_temp(r_month);
            r2=find(~isnan(val_temp2));
            if length(r2)>n_av/4,
                if index2==2,
                    av_val(jj,1)=median(val_temp2(r2));
                else
                    av_val(jj,1)=mean(val_temp2(r2));
                end
            else
                av_val(jj,1)=NaN;
            end
            av_date_num(jj,1)=date_num_temp(r_month(1));
        else
            %av_val(jj,1)=NaN;
            %av_date_num(jj,1)=NaN;
        end
    end
    end
    r=find(~isnan(av_date_num));
    av_date_str = datestr(av_date_num(r) ,'mmm yyyy');

end


%calc_running_mean_temperature
function T_running = running_mean_temperature_func(T_a,num_hours,min_time,max_time,dt)

%Avergaing time is 1.5 - 3 days
use_normal=0;

T_running=T_a(min_time:max_time);

for ti=min_time:max_time 
    %specify the minimum index
    if (use_normal),
        min_running_index=max(1,ti-num_hours);
        T_running(ti)=mean(T_a(min_running_index:ti));
    else
        %Alternative formulation so as to preserve the initial value in min_time index.
        %Assumes a value in min_time already
        if (ti>min_time),
            T_running(ti)=T_running(max(1,ti-1))*(1.-dt/num_hours)+T_a(ti)*dt/num_hours;
        end
    end
    
end
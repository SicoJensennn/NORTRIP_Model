
function [melt_temp] = melt_func_antoine(solution_salt,saturated,melt_temperature_saturated,ai,bi,ci,a,b,c,afactor)

as=a+log10(afactor);
bs=b;
cs=c;
%Function find the melt temperature from:
%as-bs/(cs-T_melt)=ai-bi/(ci-T_melt)
%Which gives :
%AA(T_melt)^2+BBT+CC=0
%Solution
%T_melt=(-BB+-sqrt(BB^2-4*AA*CC))/(2*AA)
AA=ai-as;
BB=(ai-as)*(ci+cs)-bi+bs;
CC=(ai-as)*cs*ci-bi*cs+bs*ci;
%
discriminant=BB^2-4*AA*CC;
%
if solution_salt==0.0 %minimum solution(?) solution_salt/saturated < 
    melt_temp=0;
elseif discriminant<0.0 
    % imaginary roots        
    melt_temp=melt_temperature_saturated;
    %fprintf('Imaginary roots in melt_fuc_antoine\n');
    else
    melt_temp=(-BB-sqrt(BB^2-4*AA*CC))/(2*AA);
    %melt_temp=(-BB+sqrt(BB^2-4*AA*CC))/(2*AA);
 
end
  
if melt_temp < melt_temperature_saturated
    melt_temp=melt_temperature_saturated;
end
if melt_temp > 0
    melt_temp = 0;
end
%
end


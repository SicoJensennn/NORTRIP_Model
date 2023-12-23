function [vp] = antoine_func(a,b,c,TC)
% 
%TC: Degrees C
vp=10^(a-(b/(c+TC)));

end


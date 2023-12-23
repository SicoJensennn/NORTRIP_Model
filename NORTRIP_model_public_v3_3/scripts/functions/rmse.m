function result=rmse(a,b)

if (length(a)==length(b))&(length(a)>0)&(length(b)>0),
    r=find(~isnan(a)&~isnan(b));
    if ~isempty(r),
        result=(sum((a(r)-b(r)).^2)/length(a(r)))^.5;
    else
        result=NaN;
    end
else
    result=NaN;
end
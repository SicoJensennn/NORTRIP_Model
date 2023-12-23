function [val,available,missing_flag] = check_data_func(val,available,nodata)

missing_flag=[];
if available==1,
    r=find(val==nodata|isnan(val));
    if ~isempty(r),
    if length(r)==length(val),
        available=0;
    else
        %Fill in gaps backwards if the first number is not a value
        r1=find(val~=nodata&~isnan(val));
        if ~isempty(r1)&&r1(1)~=1,
            val(1:r1(1))=val(r1(1));
            %missing_flag(1:r1(1))=1:r1(1);
        end
        for i=1:length(r),
            if r(i)>1,
                val(r(i))=val(r(i)-1);
                missing_flag(i)=r(i);
            end
        end
            %Deals with nodata in the first row
            i=1;
            if r(i)==1,
                val(r(i))=val(r(i)+1);
                missing_flag(i)=r(i);
            end
    end
    end
end


end


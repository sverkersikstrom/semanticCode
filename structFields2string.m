function [t d]=structFields2string(info,field)
t='';d=[];
for i=1:length(info)
    tmp=eval(['info{i}.' field]);
    if isnumeric(tmp)
        if tmp==fix(tmp)
            t=[t sprintf('%d\t',tmp)];
        else
            t=[t sprintf('%.3f\t',tmp)];
        end
        d(i)=tmp;
    else
        j=findstr(tmp,char(13));
        if length(i)>0 tmp=tmp(1:j);end
        t=[t sprintf('%s\t',tmp)];
        d{i}=tmp;
    end
end

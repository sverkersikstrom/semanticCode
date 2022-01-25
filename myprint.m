function myprint(a,handles,both)
%global handles
if nargin<3
    both=0;
end
try
    b=get(handles.myprint,'string');
    if iscell(b)
        b=b{1};
    end
    set(handles.myprint,'string',strvcat(b ,a));
catch
end
fprintf('%s\n',a);

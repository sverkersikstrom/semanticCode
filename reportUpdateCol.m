function [d s c]=reportUpdateCol(s,d,c,word)
%global noUpdateCol

%if s.par.updateReportAutomatic==0; %noUpdateCol & 
%    return;
%elseif s.par.updateReportAutomatic==2;
%    return
%end
if not(isfield(s.handles,'report'))
    fprintf('Warning report field is missing!\n')
    return
end

if isempty(d)
    d=get(s.handles.report,'Data');
end
[Nr Nc]=size(d);
if isempty(c)
    c=find(strcmpi(d(1,:),word));
    if isempty(c)
        c=find(strcmpi(d(1,:),''));
        if isempty(c)
            c=Nc+1;
            d{1,c+1}='';
        end
        c=c(1);
    end
    for i=1:length(c)
        d{1,c(i)}=word;
    end
end

for i=1:length(c)
    [tmp, text, s]=getProperty(s,d{1,c(i)},d(2:Nr,1),getReportCommand(1,c(i)));
    for row=2:Nr
        if length(d{row,1})>0
            if length(getReportCommand(row,c(i)))>0
                [tmp, d(row,c(i)), s]=getProperty(s,d{1,c(i)},d{row,1},getReportCommand(row,c(i)));
            else
                d{row,c(i)}=text{row-1};
            end
        end
    end
end
setReportData(s.handles.report,d);


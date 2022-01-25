function s=setPropertyFromTimeFile(s,file,index,label,property)
if nargin<1
    s=getSpace;
end
if nargin<2
    fprintf('The time file most be orderd in increase time!\n')
    fprintf('A property, label _subject, represeting the row in the data file, will be inserted\n')
    [file,PathName]=uigetfile2('.*.txt;*.xlsx;*.xls','Choice a file with two columns (time (e.g. 2009-01-30 15:30) and property-data e.g(1.45))');
    if file==0 return; end
    file=[PathName file];
end
if nargin<3
    [o s]=getWordFromUser(s,'Choice words to add time properties to','_ericsson*');
    index=o.index;
end

[words data col name]=textread2(file);
[s N]=addX2space(s,property,[],[],1,[property ' read from file ' file]);

for i=1:length(data)
    if isnumeric(words{i,1})
        time(i)=datenum(num2str(data(i,1)),'yyyymmdd');
    else
        time(i)=NaN;
    end
end

for j=2:length(name)
    if name{j}(1)=='_'; name{j}=name{j}(2:length(name{j}));end
end

if nargin>=4
    col=find(strcmpi(name,label));
    if isempty(col)
        fprintf('Failed to find matching label\n')
        return
    end
else
    stop
end

if nargin<5
    property=lower(name{col});
end
if property(1)=='_';
    property=property(2:end);
end

for i=1:length(index)
    if isfield(s.info{index(i)},'time')
        index1=find(s.info{index(i)}.time>=time);
        index2=find(s.info{index(i)}.time<time);
        if length(index1)>0 & length(index2)>0
            if time(length(index1))<=s.info{index(i)}.time & time(index2(1))>s.info{index(i)}.time
                if 1
                    eval(['s.info{index(i)}.' property '=data(' num2str(index1(length(index1))) ',' num2str(col) ');']);
                else
                    for j=2:length(name)
                        eval(['s.info{index(i)}.' name{j} '=data(' num2str(index1(length(index1))) ',' num2str(j) ');']);
                        s.info{index(i)}.subject=index1(length(index1));
                    end
                end
            end
        end
    end
end
s=getSpace('set',s);

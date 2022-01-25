function struct=getContexts(s,text,target,contextSize)
[tmp targetCell]=text2index(s,target);
targetReplace=upper(['__' regexprep(target,' ','')]);
if contextSize>0
    [index t]=text2index(s,text);
    if strcmpi(target,'random')
        index=fix((length(t)-1)*rand)+1;
        index2=index;
    else
        if length(targetCell)<=1
            index=find(strcmpi(t,target));
            index2=index;
        else
            index=find(strcmpi(t,targetCell{1}));
            ok=[];
            for i=1:length(index)
                ok(i)=1==1;
                for j=1:length(targetCell)
                    if not(strcmp(targetCell{j},t{min(length(t),index(i)+j-1)}))
                        ok(i)=0;
                    end
                end
            end
            index=index(find(ok));
            index2=index+length(targetCell)-1;
        end
    end
    struct{1}='';
    for i=1:length(index)
        %struct{i}=cell2string(t(max(1,index(i)-contextSize):min(length(t),index2(i)+contextSize)));
        if strcmpi(s.par.contextType,'sentence')
            seperator=find(strcmpi(t,'.') | strcmpi(t,'!') | strcmpi(t,'?'));
            i1=min(length(t),seperator(find(index(i)>seperator))+1);if isempty(i1) i1=1; else i1=i1(end);end
            i2=seperator(find(index(i)<seperator));if isempty(i2) i2=length(t);end
            struct{i}=cell2string(t(i1(1):i2(1)));
        else
            struct{i}=cell2string([t(max(1,index(i)-contextSize):max(0,index(i)-1))' targetReplace t(min(length(t),index2(i))+1:min(length(t),index2(i)+contextSize))']);
        end
    end
else
    struct{1}=text;
end

function index=findSoft(s,t,target)
if s.par.contextFindstr
    a=strfind(t,lower(target));
    index=[];
    for i=1:length(t)
        if not(isempty(a{i}))
            index=[index i];
        end
    end
else
    index=find(strcmpi(t,target));
end

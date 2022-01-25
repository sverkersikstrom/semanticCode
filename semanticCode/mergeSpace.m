function sLang=mergeSpace(sLang,s)

if length(s.fwords)==0
    index=[];
else
    index=word2index(sLang,s.fwords);
end

s=fixIt(s);
sLang=fixIt(sLang);

%Add new data...
include=find(isnan(index));

indexOk=1:sLang.N;%size(sLang.x,1);
if length(include)>0
    sLang.fwords=[sLang.fwords(indexOk) s.fwords(include)];
end
for i=1:length(include)
    sLang.N=sLang.N+1;
    sLang.hash.put(lower(s.fwords{include(i)}),sLang.N);%CHANGED
end
if not(size(s.x,2)==size(sLang.x,2))
    fprintf('\nError, missmatch of sizes for s.x and sLang.x\n');
    if size(sLang.x,2)<=1
        sLang.x(1,size(s.x,2))=NaN;%Fix bug with empty s.x
    else
        s.x(1,size(sLang.x,2))=NaN;%Fix bug with empty s.x
    end
end
sLang.x=full([sLang.x(indexOk,:); s.x(include,:),]);
sLang.f=[sLang.f(indexOk) s.f(include)];
sLang.info=[sLang.info(indexOk) s.info(include)];
try
    if isfield(s,'var')
        if not(isfield(sLang,'var'))
            sLang.var.data=sparse(length(indexOk),0);
            sLang.var.hash=java.util.Hashtable;
        end
        found=0;includeVar=[];
        for i=1:size(s.var.data,2)
            if isempty(s.var.name{i})
                s.var.name{i}=' ';
            end
            tmp=sLang.var.hash.get(lower(s.var.name{i}));
            if isempty(tmp) 
                found=found+1;
                includeVar(i)=size(sLang.var.data,2)+found;
                sLang.var.name{includeVar(i)}=s.var.name{i};
                sLang.var.data(:,includeVar(i))=0;
                sLang.var.hash.put(lower(s.var.name{i}),includeVar(i));
            else
                includeVar(i)=tmp;
            end
        end
        %sLang.var.data=[sLang.var.data(indexOk,includeVar); s.var.data(include,:)];
        sLang.var.data(length(indexOk)+1:length(indexOk)+length(include),includeVar)=s.var.data(include,:);
        %sLang.var.text=[sLang.var.text(indexOk) s.var.text(include)];
    end
catch
    1;
end
try
    sLang.wordclass=[sLang.wordclass(indexOk) s.wordclass(include)];
end
if isfield(sLang,'keepInLanguageFile') & isfield(s,'keepInLanguageFile')
    sLang.keepInLanguageFile=[sLang.keepInLanguageFile(indexOk(indexOk<=length(sLang.keepInLanguageFile))) zeros(1,sLang.N-length(sLang.keepInLanguageFile))];% zeros(1,length(include))];
end

if isfield(sLang,'upper') & length(sLang.upper)<sLang.N
    sLang.upper=[sLang.upper(indexOk(indexOk<=length(sLang.upper))) nan(1,sLang.N-length(sLang.upper))];
end
if isfield(sLang,'wordclass') & length(sLang.wordclass)<sLang.N
    sLang.wordclass=[sLang.wordclass(indexOk) nan(1,sLang.N-length(sLang.wordclass))];
end

%Update old data...
include2=find(not(isnan(index)));
include=index(include2);
if not(isempty(include))
    sLang.x(include,:)=s.x(include2,:);
    sLang.info(include)=s.info(include2);
    if isfield(s,'var')
        if length(include2)>size(s.var.data,1)
            tmp=find(include2<size(s.var.data,1));
            sLang.var.data(include(tmp),includeVar)= s.var.data(include2(tmp),:);
        else
            sLang.var.data(include,includeVar)= s.var.data(include2,:);
        end
    end 
end
if isfield(s,'extraData');
    sLang.extraData=s.extraData;
end


function s=fixIt(s) %Remove later
N=size(s.fwords);
if N(1)>N(2)
    s.fwords=s.fwords';
end

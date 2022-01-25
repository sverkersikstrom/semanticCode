function spaceToDb(spaceName)
persistent tableOk
if nargin<1
    spaceName='spaceEnglish';
end
 
if isempty(find(strcmpi(tableOk,spaceName)))
    tableOk=[tableOk {spaceName}];
    maxTable=1000;
    if length(tableOk)>maxTable;tableOk=tableOk(1:maxTable-1);end
    
    if isempty(fetch(getDb,['show tables like "' spaceName '";']))
        fprintf('Adding space %s to database, this may take a while...\n',spaceName);
        s=getNewSpace(spaceName);
        info{1}=[];
        dbSpace(spaceName,'','save',{'xmean2'},s.xmean2,info,'w',0);
        
        if length(s.wordclass)<s.N s.wordclass(s.N)=0;end
        s.wordclass(isnan(s.wordclass))=0;
        step=10000;
        exec(getDb,'SET GLOBAL max_allowed_packet=2275280;',0);
        for j=1:step:s.N;
            i=j:min(s.N,j+step-1);
            [e]=dbSpace2(spaceName,s,i);
            %type='clear';
        end
    end
end

function [e]=dbSpace2(spaceName,s,i,split)
if nargin>3 & split
    isplit=fix(length(i)/2);
    i1=i(1:isplit);
    [e]=dbSpace2(spaceName,s,i1);
    i2=i(isplit+1:end);
    [e]=dbSpace2(spaceName,s,i2);
    return
end

fprintf('%d ',i(1))
tmp=s.info(i);
a=whos('tmp');
if a.bytes/1000000>1 & length(i)>1
    e=dbSpace2(spaceName,s,i,1);
    return
end    

tic;[x,info,f,id,wordclass,e]=dbSpace(spaceName,'','save',s.fwords(i),s.x(i,:),s.info(i),'w',s.f(i),s.wordclass(i));toc
if length(e.Message)>0 & length(i)>1
    e=dbSpace2(spaceName,s,i,1);
end



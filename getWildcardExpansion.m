function [t]=getWildcardExpansion(s,t);
persistent sSave
NWildcardExpansion=s.par.NWildcardExpansion; 
if s.par.excelServer
    file=[s.languagefile '-fwords.mat'];
    if exist('sSave','var') & not(isempty(sSave)) & strcmpi(s.languagefile,sSave.languagefile)
        sfwords=sSave;
    elseif exist(file)
        load(file);
    else
        s=getNewSpace(s.languagefile);
        sfwords.fwords=s.fwords;
        sfwords.f=s.f;
        sfwords.languagefile=s.languagefile;
        save(file,'sfwords');
    end
    %s=sfwords;
    sSave=sfwords;
else
    sfwords=s;
end
t2=[];
if NWildcardExpansion==0
    minf=-1;%Include all words
else
    [tmp tmpIndex]=sort(sfwords.f,'descend');minf=tmp(min(NWildcardExpansion,length(sfwords.f)));
end
for i=1:length(t)
    if strcmpi(t{i},'*')
        fprintf('Ignoring wildcard expansion to all words, ''*''\n')
    elseif findstr(t{i},'*')>0
        a=regexprep(t{i},'*','\\w*');
        if t{i}(end)=='*'
            a=['^' a];
        end
        select=find(not(cellfun(@isempty,regexp(sfwords.fwords(:),a))))';
        select=select(sfwords.f(select)>minf);
        for j=1:length(select);fprintf('%s ',sfwords.fwords{select(j)});end
        t2=[t2 regexprep(t(i),'*','') sfwords.fwords(select)];
    else
        t2=[t2 t(i)];
    end
end
if length(t2)>length(t) 
    fprintf('Removed words with frequency less than (%.5f) from expansions as specified in the parameter s.par.NWildcardExpansion=%d: ',full(minf),s.par.NWildcardExpansion)
    fprintf('Expanding from %d to %d words\t',length(t),length(t2))
    %if nargin>3 & not(isnan(index))
    %    fprintf('Replacing: ''%s'' with ''%s'' words\n',s.info{index}.context,cell2string(t2))
    %    s.info{index}.context=cell2string(t2);
    %end
    fprintf('\n');
end
t=t2;
function [id, categories, index,user,comments]=getIndexCategory(category,s,db2space);
%persistent d;
id=[];index=[];user=[];
categories{1}='Choose category of identifier:';
categories{2}='Functions';
categories{3}='Clusters';
categories{4}='Prediction';
categories{5}='LIWC';
categories{6}='Semantic dimensions';
categories{7}='Semantic scales';
categories{8}='Wordclasses';
categories{9}='Texts';
categories{10}='Words';
categories{11}='Stopwords';
categories{12}='Variables';
categories{13}='Norms';
categories{14}='User Defined';
if nargin==0
    return;
end
if ischar(category)
    category=find(strcmpi(categories,category));
end

if nargin<2
    s=getSpace;
end
if nargin<3
    db2space=s.par.db2space;
end
if db2space %Read from database
    table=regexprep(s.languagefile,'.mat','');
    name=[table '-' num2str(category)];
    query = ['select `id`, `user`, `info` from  `space2`.`' table '` where `specialword` = ' num2str(category) ' limit 2000' ];
disp(query);
    try
        r = fetch(getDb,query);
    catch
        r = fetch(getDb(1),query);
    end
    if istable(r); r=table2array(r); end
    comments=[];
    for i=1:size(r,1)
        try
            eval(r{i,3});
            comments{i}=d.comment;
        catch
            comments{i}='';
        end
    end
    
    if not(isempty(r))
        if istable(r) r=table2array(r);end
        id=r(:,1);
        user=r(:,2);
    end
    if size(id)>1998
        fprintf('Limit of 2000 id is reached\n')
    end
    index=word2index(s,id);
else
    
    j1=0;
    j2=0;
    
    if category==10 | category==11
        select=find(cellfun(@isempty,regexp(s.fwords(:),'_')))';
    elseif category==14
        select=word2index(s,strread(s.par.plotCategoryUserDefined,'%s'));
    else
        select=find(not(cellfun(@isempty,regexp(s.fwords(:),'_'))))';
    end
    select=select(not(isnan(select)) & select<=s.N) ;
    id{1}='';
    for i=select
        if category==1
            j1=1;
            id{1}='';
            index(j1)=1;
        elseif category==10 | category==14
            j1=j1+1;
            id{j1}=s.fwords{i};
            index(j1)=i;
        elseif category==11 & isfield(s.info{i},'stopword')
            j1=j1+1;
            id{j1}=s.fwords{i};
            index(j1)=i;
        elseif isfield(s.info{i},'specialword') & (s.info{i}.specialword==category | (s.info{i}.specialword==0 & category==9))
            skip=0;
            if category==2 %Remove junk
                if (not(isfield(s.info{i},'persistent')) | (isfield(s.info{i},'comment') & findstr(s.info{i}.comment,'wordclass')>0))
                    skip=1;
                elseif find(strcmpi(s.fwords{i},{'_previous','_change','_seqdist','_context','_frequencyweightedmean','_randomword','_date','_time','_nan','_n','_p','_nday','_nmonth','_p','_r','_weight'}))
                    skip=1;
                end
            end
            if not(skip)
                j1=j1+1;
                id{j1}=s.fwords{i};
                index(j1)=i;
                if category==9 & isfield(s.info{i},'context')
                    id{j1}=[id{j1} ' : ' s.info{i}.context(1:min(end,30))];
                elseif isfield(s.info{i},'comment')
                    id{j1}=[id{j1} ' : ' s.info{i}.comment];
                end
            end
        end
    end
end

[idSort, indexSort]=sort(id);
id=id(indexSort);
if exist('comments','var')
    comments=comments(indexSort);
else
    comments=[];
    if not(isempty(index))
        index=index(indexSort);
        if nargout>4
            [~,comments,s]=getProperty(s,'_comment',index);
        end
    end
end


function [x,info,f,id,wordclass,e] =dbSpace(lang,document,type,id,x,info,textType,f,wordclass,public,user)
persistent tableOk
t0=now;
e=[];
if 0 %debugging code for testing that it works
    lang='spaceenglish';
    s=getNewSpace(lang)
    
    text={'Volvo is a good car','Saab is a car. He is great','Fruit is good','Dinner will be served'};
    normId='_myNormTest';
    s.par.db2space=1;%This saves norms,clusters,train or semantic scales to a database
    s.par.public=1;%Make it public, or save it to 'Norms' (or 'Clusters' when using clusterSpace ,or 'Prediction' when using train,'Semantic scales' when using semanticScales
    
    [s nomrId normName]=addNorm(s,normId,text{1},'Comment: This is my test morm')%,normSubtractionText,public)
    
    %This retrieves the 
    file='Norms';%Read public from 'Norms'
    file=regexprep(s.filename,'\.mat','');%Read from non-public s.filename
    [s2.x,s2.info,s2.f,s2.fwords,s2.wordclass] =dbSpace(regexprep(s.languagefile,'\.mat',''),file,'get',{normId});
    s=mergeSpace(s,s2);%Merge to current space
end


if nargin<1
    lang='sv';
end
if nargin<2
    document='';
end
if nargin<3
    type='get';
end
if nargin<4
    id='1';
end
if nargin<7
    if length(document)==0
        textType='w';%Old default
    else    
        textType='t';
    end
end
if nargin<8
    f=zeros(1,length(id));
end
if nargin<9
    wordclass=zeros(1,length(id));
end
if nargin<10
    public=zeros(1,length(id));
end
if nargin<11
    user=zeros(1,length(id));
end

 %Create table
if textType=='w' | length(document)==0
    table=lang;
else
    table=[lang '-' document  ];%'-' textType 
end

db=getDb;
 
if isempty(find(strcmp(tableOk,table)))
    spaceToDb(lang);

    query=['select `f` from  `space2`.`' table '`  limit 1'];
    e=exec(db,query);
    tableOk=[tableOk {table}];
    maxTable=1000;
    if length(tableOk)>maxTable;tableOk=tableOk(1:maxTable-1);end
    if strcmpi(e.Message,'Invalid connection.')
        db=getDb(1);
        e=exec(db,query);
    elseif ~isempty(e.Message)
        createTable(db,table,textType,lang);
    end
end

if strcmpi(type,'get') | strcmpi(type,'get*')  %| strcmpi(type,'getDate') 
    %SELECT * FROM `space2` WHERE `id` LIKE 'sv1'
    %SELECT * FROM `space2` WHERE `id` LIKE '1'
    %w='';
    w =[' `document` = ''' document '''  AND ('];%AND  `type` = ''' textType '''
    useStar=not(isempty(strfind(id{1},'liwc*')));
    if useStar
        if strcmp(id{1},'*')
            w =[w ' 0 ) '];
        else
            w =[w ' `id` REGEXP ''' regexprep(id{1},'*','') ''' ) '];
        end
    else
        for j=1:length(id)
            w =[w ' `id` = ''' regexprep(id{j},'''','\\''') ''' OR'];
        end
        w=[ w(1:end-2) ')'];
    end
    query = ['select `id`,`xdata`,`info`,`f`,`wordclass` from  `space2`.`' table '` where ' w  ];
    try
        r = fetch(db,query);
    catch
        db=getDb(1);
        r = fetch(db,query);
    end
    if useStar
        if isempty(r)
            id2=[];
        else
            id2=r(:,1);
        end
    else
        id2=id;
    end
    N=length(id2);
    if isempty(r);
        clear r; r{1,1}='';
    end
    x=nan(N(1),1);
    f=nan(1,N(1));
    wordclass=nan(1,N(1));
    if N(1)==0
        info=[];
    else
        info{N(1)}=[];
    end
    if istable(r)
        for i=1:size(r,1)
            tmp{i}=r{i,1}{1};
        end
    else
        tmp=r(:,1);
    end
    for j=1:N(1)
        k=find(strcmpi([id2{j}],tmp));
        if not(isempty(k))
            k=k(1);
            if iscell(r{k,1})
                id{j}=r{k,1}{1};
            else
                id{j}=r{k,1};
            end
            if ischar(r{k,2})
                x0=str2num(r{k,2});
            else
                x0=str2num(r{k,2}{1});
            end
            f(j)=r{k,4};
            wordclass(j)=r{k,5};
            x(j,1:length(x0))=x0;
            try
                clear d;
                if length(r{k,3})>0
                    if ischar(r{k,3})
                        eval(regexprep(r{k,3},char(13),''))
                    else
                        eval(regexprep(r{k,3}{1},char(13),''))
                    end
                    if not(exist('d','var')); d.empty=1;end
                    if isfield(d,'index')
                        d=rmfield(d,'index');
                    end
                    info{j}=d;
                end
            catch
                fprintf('Error, could not interpret command: %s',r{k,3})
                try;fprintf(', on row=%d\n',k);end
            end
        end
    end
else
    query =['DELETE FROM `space2`.`' table '` WHERE `document` = ''' document ''' AND ( ']; 
    if strcmpi(type,'clear')
        exec(db,[query '1)'],0);return
    end
    f(isnan(f))=0;
    for j=1:length(id)
        if length(id{j})>50
            id{j}=id{j}(1:50);
            fprintf('To long Id (max 50 char), truncating it to: %s\n',id{j})
        end
        data{j,1}=id{j};
        data{j,2}=[num2str(x(j,:))];
        if isfield(info{j},'results') info{j}=rmfield(info{j},'results'); end
        data{j,3}=[struct2text(info{j},'d',0)];
        %I AM NOT ABLE TO STORE THESE CHAR 126 - 160 WHICH IS A PROBLEM!!!
        data{j,3}(find(data{j,3}>126 & data{j,3}<160 ))=' ';
        %data{j,3}(find(data{j,3}==151))=' ';
        data{j,4}=lang;
        data{j,5}=textType;
        data{j,6}=datestr(now);
        data{j,7}=f(j);
        data{j,8}=document;
        if isfield(info{j},'specialword')
            data{j,9}=info{j}.specialword;
        else
            data{j,9}=10;
        end
        if nargin<9
            data{j,10}=0;
        else
            data{j,10}=wordclass(j);
        end
        data{j,11}=public(j);
        data{j,12}=user(j);
        query =[query '`id` = ''' id{j} ''' OR'];
    end
    query=[query(1:end-2) ')'];
    
    exec(db,query,0);
    names={'id','xdata','info','lang','type','datestr','f','document','specialword','wordclass','public','user'};
    e=insert2(db, table ,names,data,100);
    1;
end
fprintf('t=%.2f,N=%d,%s. ',(now-t0)*24*3600,length(id),type);


function createTable(db,table,textType,lang);
fprintf('\nCreating table %s\n',table);
query=['CREATE TABLE `' table '` ( `document` text NOT NULL, `id` char(51) NOT NULL, `lang` text NOT NULL,`f` float NOT NULL, `datestr` text NOT NULL, `xdata` text NOT NULL, `info` mediumtext NOT NULL, `type` text NOT NULL, `wordclass` int NOT NULL, `specialword` int NOT NULL, `public` int NOT NULL, `user` char(50) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;'];
exec(db,query,0);

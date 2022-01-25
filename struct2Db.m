function struct2Db(database,table,d,unique,createtable)
%Write a struct to a database
%d struct to write
if nargin<4
    unique=[];
end

if isfield(d,'x')
    [~,Ndim]=size(d.x);
    for i=1:Ndim
        eval(['d.x' num2str(i) '=d.x(:,i);']);
    end
    d=rmfield(d,'x');
    try
        d=rmfield(d,'Ns');
    end
    try
        d=rmfield(d,'Np');
    end
    try
        d=rmfield(d,'Ndim');
    end
end

exec(database,['CREATE DATABASE IF NOT EXISTS `' database.Instance '` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;']);

try
    columnsOld = fetch2Cache(database,['SHOW COLUMNS FROM  `' database.instance '`.`' table '`'],1);
catch
    columnsOld ='';
end
[cOld tmp]=size(columnsOld);

names=fieldnames(d);
[c,~]=size(names);

q='';
for i=1:c
    if eval(['iscell(d.' names{i} ')'])
        type='text';
        q=[q '`' names{i} '` text, '];
        data(:,i)=eval(['d.' names{i} ';']);
    elseif eval(['ischar(d.' names{i} ')']);
        type='text';
        q=[q '`' names{i} '` text, '];
        data{:,i}=eval(['d.' names{i} ';']);
    else
        type='float';
        q=[q '`' names{i} '` float, '];
        data(:,i)=eval(['(num2cell(d.' names{i} '));']);
    end
    if isempty(columnsOld) | isempty(find(strcmp(columnsOld(:,1),names{i})))
        exec(database,['ALTER TABLE `' table '` ADD ' names{i} ' ' type ';']);
    end
end

if cOld<=c %Create missing fields...
    if length(q)>2
        q=q(1:length(q)-2);
    end
    
    if isempty(findstr(q,'auto_increment')) %forces an autoincrement to all tables!
        q=['`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL,' q];
    end
    
    if nargin<5
        createtable=['CREATE TABLE IF NOT EXISTS `' database.Instance '`.`' table '` (' q ') ENGINE=MyISAM DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'];
    end
    exec(database,createtable);
end

[d Nd columns]=structCorrect(database,table,d);
 
if not(isempty(unique)) & 1
    com='';
    comAll='';
    jUnique=find(strcmp(unique,names));
    jId=find(strcmp('id',names));
    for i=1:Nd 
        com=[com 'UPDATE `' database.Instance '`.`' table '` SET '];
        for j=1:length(names)
            if isnumeric(data{i,j})
                d1=num2str(data{i,j});
            else
                d1=data{i,j};
            end
            if not(j==jUnique) & not(j==jId)
                if isnan(data{i,j})
                    com=[com '`' names{j} '`=NULL, '];
                else
                    com=[com '`' names{j} '`=''' d1 ''', '];
                end
            end
        end
        com=com(1:end-2);
        com=[com ' WHERE `'  table '`.`' unique '`='''  num2str(data{i,jUnique}) ''';' char(13) char(10)];
        a=exec(database,com);
        if length(a.Message)>0
            fprintf('%s\n',a.Message);
        end                     
        %comAll=[comAll com];
        com='';        
    end
    return
    %a=exec(database,comAll);
    %end
elseif not(isempty(unique))
    com='';
    for i=1:Nd
        j=eval(['d.' unique '{i};']);
        if isnumeric(j) j=num2str(j);end
        com=[com '`' unique '` = ''' j ''' OR '];
    end
    com=com(1:end-3);
    exec(database,['DELETE FROM `' database.Instance '`.`' table '` WHERE ' com  ]);
end

insert2(database, table ,names,data,100);
end

function [def Nd columns]=structCorrect(database,toTable,def)
%Before writing struct to database, make error checks:
%1)Missing dates are set to current date
%2)Removing primary keys
%3)Making lengths=1 to the length of the first field
columns=fetch2Cache(database,['SHOW columns from `' database.Instance '`.`' toTable '`'],1);
if not(isempty(columns))
    [N,~]=size(columns);
    try
        Nd=eval(['length(def.' getCell(columns{4,1}) ');']);
    catch
        try
            Nd=eval(['length(def.' getCell(columns{1,1}) ');']);
        catch
            Nd=eval(['length(def.' getCell(columns{2,1}) ');']);
        end
    end
    for i=1:N
        if strcmp(getCell(columns{i,2}),'datetime')
            for j=1:Nd
                try
                    a=isnan(eval(['datenum(def.' getCell(columns{i,j}) ');']));
                catch
                    eval(['def.' getCell(columns{i,1}) '{' num2str(j) '}=datestr(now,''yyyy-mm-dd HH:MM:SS'');']);
                end
            end
        elseif strcmp(getCell(columns{i,6}),'auto_increment') %strcmp(columns{i,4},'PRI') | strcmp(columns{i,4},'UNI')
            try
                eval(['def=rmfield(def,''' getCell(columns{i,1}) ''');']);
            end
        elseif Nd>1 && eval(['isfield(def,''' getCell(columns{i,1}) ''')==1'])
            c=getCell(columns{i,2});
            if (strcmp(c(1:3),'var')==0 && strcmp(c(1:3),'tex')==0)
                try
                    eval(['def.' getCell(columns{i,1}) '=ones(1,Nd).*def.' getCell(columns{i,1}) ';'])
                catch
                    eval(['def.' getCell(columns{i,1}) '=ones(Nd,1).*def.' getCell(columns{i,1}) ';'])
                end
            end
        end
    end
else
    Nd=length(fieldnames(def));
end
end

function c=getCell(c)
if iscell(c)
    c=c{1};
end
end
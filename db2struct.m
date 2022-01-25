function [d databaseName]=db2struct(databaseName,table,where,select_struct)
    % Read struct from database with optitional where statment
    if ischar(databaseName)
        databaseName = database(databaseName,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/' databaseName ]);
    end
    query = ['SHOW COLUMNS FROM  `' databaseName.Instance '`.`' table '`'];
    columns = fetch(databaseName,query);
 
    if nargin < 3 
        where = ' 1'; 
    end
    if isempty(where)
        where = ' 1'; 
    end
    if nargin<4 
        select_struct = [];
    end
    if isempty(select_struct)
        select='*';
    else
        select = '`';
        for i=1:length(select_struct);
            select = [select select_struct{i},'`,`'];
            index(i) = find(strcmp(columns(:,1),select_struct{i}));
        end
        select = select(1:length(select)-2);
        columns = columns(index,:);
    end
    query = ['select ' select ' from  `' databaseName.Instance '`.`' table '` where ' where];
    data = fetch(databaseName,query);
    [c,~] = size(columns);
    if isempty(data)
        for i=1:c;
            if strcmp(columns{i,2},'text')
                data{1,i} = '';                
            else
                data{1,i} = [];
            end
        end
    end
    d = [];
    for i=1:c
        columns{i,2} = [columns{i,2} '        '];
        if strcmp(columns{i,2}(1:7),'varchar') || strcmp(columns{i,2}(1:7),'datetim') || strcmp(columns{i,2}(1:4),'text') || strcmp(columns{i,2}(1:8),'longtext') || strcmp(columns{i,2}(1:10),'mediumtext')
            eval(['d.' columns{i,1} '=' 'data(:,' num2str(i) ');']);
        else
            eval(['d.' columns{i,1} '=' 'cell2mat(data(:,' num2str(i) '));']);
        end
    end

    if isfield(d,'x1')
        i = 0;
        ok = 1;
        while ok
            i = i + 1;
            try
                eval(['d.x(:,i)=d.x' num2str(i) ';']);
                d = rmfield(d,['x' num2str(i);]);
            catch
                ok = 0;
            end
        end
        [d.Ns d.Ndim] = size(d.x);
    end
end
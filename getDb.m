function db=getDb(update,db_instance)
persistent dbSave 
 
if nargin<1
    update=0; 
end
if nargin<2
    db_instance = 'DB_INSTANCE';
end
if not(isempty(dbSave)) & not(strcmp(dbSave.Instance,db_instance))
    update=1;
end
if isempty(dbSave) | update | length(dbSave.Message)>0
    if 0
        %     server: DB_HOST
        %     username: YOUR_USERNAME
        %     password: YOUR_PASSWORD
        
        
        %
        
        %DB_HOST:PORT
        db_host='DB_HOST:PORT';
        db_instance = 'DB_INSTANCE';
        db_username = 'DB_USERNAME';
        db_password = 'DB_PASSWORD';
        dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://' db_host '/' db_instance ]);
        
        
        dbSave = database('DB_INSTANCE','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST'/'DB_INSTANCE]);
        dbSave =database('DB_INSTANCE','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST'/'DB_INSTANCE]);
        %dbSave = database('DB_INSTANCE','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST'/'DB_INSTANCE]);
        dbSave = database('survey_stage','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST'/'DB_INSTANCE]);
    end
    if not(isempty(dbSave))
        close(dbSave);
    end
     
    if findstr(pwd,'/Users/sverkersikstrom')>0 %Sverker use
        db_host='DB_HOST';
        db_username = 'DB_USERNAME';
        db_password = 'DB_PASSWORD';
        dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://' db_host '/' db_instance ]);
        if length(dbSave.Message)>0
            fprintf('Using local DB for Sverker: %s\n',dbSave.Message)
            %elseif 0 & findstr(pwd,'/Users/sverkersikstrom/')>0 %Use local for Sverker
            db_username='DB_USERNAME';
            db_password='DB_PASSWORD';%I guess it should be: DB_PASSWORD?
            %dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST':'PORT'/' db_instance ]);
            
            dbSave = database(db_instance,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST':' PORT '/'DB_INSTANCE ])
            if length(dbSave.Message)>0
                %SET GLOBAL time_zone='+01:00'
                fprintf('Failed open local DB, start MAMP, also consider: SET GLOBAL time_zone=''+01:00''!\n')            
            end
        end
    else %Use on server
        db_instance='DB_INSTANCE';
        db_username='DB_USERNAME';
        db_password='DB_PASSWORD';%I guess it should be: DB_PASSWORD?    
        dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://'DB_HOST':'PORT'/' db_instance ]);
    end
    if length(dbSave.Message)>0
        fprintf('%s\n',dbSave.Message)
    end

end
db=dbSave;

% TODO: refactor handleDatabaseReconnects to handle both types of
% reconnects. I.e., reconnects coming from getDatabaseObject() and fetch2()
% TODO: refactor name fetch2() to something more describing.
% TODO: optimize try catch handling in fetch2 (slightly recursive and 
% small chance of a crash if all error controls fails)
% TODO: add insert2() functionality

function [r,status] = fetch2(databaseName,sqlQuery,operationMode,useMymConn,useJavaCon)
    
    if(nargin < 3) 
        operationMode = 1;
    end    
    
    if(nargin < 4)
        useMymConn = 1;
    end
    
    if(nargin < 5)
        useJavaCon = 0;
    end
    
    if(useJavaCon == 1)
        [r,status] = javaFetcher(sqlQuery, operationMode);
        return;
    elseif(useMymConn == 1)
        [r,status] = queryDatabase(databaseName,sqlQuery,operationMode);
        return;
    end
    
    r = [];
    status = 1;
    
    if(nargin < 4)
        % TODO: Disable reconnecting database object
        failSafeMode = 0;
    end
        
    % fprintf('%s\n', sqlQuery);    
    connObj = connectDatabase(databaseName,1); 
        
    if( operationMode == 1 ) 
        %%% Get (e.g, select,create table,delete) operations %%%
        try
            % expect return data
            r = fetch(connObj.connection,sqlQuery);
        catch ME                                
            if( strcmp(ME.message,'Invalid Result Set') == 1 )
                % rethrow(ME);
            elseif( isempty(strfind(ME.message,'doesn''t exist')) == 0 )                                                           
                status = 0;  
            elseif( strfind(ME.message,'Unknown column') == 1 )
                status = 0;
                printException(ME,1);
            else
                % Try again
                connObj = handleDatabaseReconnects(ME.message,databaseName);

                try  
                    fetch(connObj.connection,['USE ' databaseName ';'],0);
                    r = fetch(connObj.connection,sqlQuery);
                catch ME
                    printException(ME,1);
                    
                    if( strcmp(ME.message,'Invalid Result Set') == 1 )
                        % rethrow(ME);
                    end
                end    
            end                                                                                   
        end       
    elseif( operationMode == 0 ) 
        %%% Set (e.g, insert,update,truncate) operations %%%
        
        try
            % expect no return data
            fetch(connObj.connection,sqlQuery); 
        catch ME   
            if( strcmp(ME.message,'Invalid Result Set') == 1 )
                % rethrow(ME);
            elseif( strfind(ME.message,'Data truncated') == 1 )
                status = 0;
                printException(ME,1);                
            elseif( strfind(ME.message,'Unknown column') == 1 )
                status = 0;
                printException(ME,1);
            elseif( isempty(strfind(ME.message,'doesn''t exist')) == 0)
                status = 0;
                printException(ME,1);
            elseif( strfind(ME.message,'Duplicate entry') == 1 )    
                printException(ME,1);
            else
                printException(ME,1);
                connObj = handleDatabaseReconnects(ME.message,databaseName);                
                % TODO: improve handling if fetch failes again (not with two try
                % statements in row)
                try
                    fetch(connObj.connection,['USE ' databaseName ';'],0);
                    fetch(connObj.connection,sqlQuery);
                catch ME 
                    printException(ME,1);
                    if( strcmp(ME.message,'Invalid Result Set') == 1 )
                        % rethrow(ME);
                    elseif( strfind(ME.message,'Data truncated') == 1 )
                        status = 0;
                        printException(ME,1);
                        % rethrow(ME);
                    elseif( strfind(ME.message,'No constructor') == 1 )
                        % abort ??
                    end                    
                end                    
            end  
        end
    end  

    % Optimize memory usage
    connObj = [];
    ME = [];
    sqlQuery = [];
end

function connObj = handleDatabaseReconnects(errorMessage,databaseName)
    reconnects = 0;
    retries = 0;
         
    while( length(errorMessage) ~= 0 && reconnects <= 2 )
        try            
            connObj = connectDatabase(databaseName,4); 
            errorMessage = '';
            par = get_default_parameter;
            if( par.debuggingMode > 2 )
                fprintf(' --> RECONNECTION SUCCEDED: \n');
            end
        catch ME    
            errorMessage = ME.message;
            par = get_default_parameter;
            if( par.debuggingMode > 2 )
                fprintf(' --> RECONNECTION ERROR: \n');                    
            end
        end
        
        if( length(errorMessage) ~= 0 )
            if( strcmp(errorMessage,'Error:Commit/Rollback Problems') )
                 reconnects = reconnects + 1;
            elseif( strcmp(errorMessage,'Invalid or closed connection') )            
                 reconnects = reconnects + 1;
            elseif( strcmp(errorMessage,'Communications link failure') )
                 reconnects = reconnects + 1;                    
            else  
                fprintf('%s\n',errorMessage);                              
            end                                                                                                  

            if(reconnects <= 2 && retries <= 2)
                if(retries == 0)
                    fprintf('RECONNECTION FAILED: SERVICE WILL SLEEP 30 SECONDS!\n');               
                end
                fprintf('Reconnect attempts before sleep=%d, Retried reconnecting %d times (reconnects * retries)\n',reconnects,retries);
                reconnects = 0;
                retries = retries + 1;            
                % SLEEP 30 SECONDS            
                pause(30);            
            elseif(reconnects >= 3 && retries >= 3)
                if(retries == 3)
                    fprintf('RECONNECTING FAILED AGAIN: SERVICE WILL SLEEP 60 SECONDS!\n');  
                end
                fprintf('Reconnect attempts before sleep=%d, Retried reconnecting %d times (reconnects * retries)\n',reconnects,retries);
                reconnects = 0;
                retries = retries + 1;
                % SLEEP 1 MINUTE
                pause(60);
            end
        else
            errorMessage = '';
        end        
    end
end

function connObj = connectDatabase(databaseName,operationMode,skipFreeMem)
    % Used for connection to a database
    
    if(nargin < 2)
        operationMode = 0; 
        skipFreeMem = 0;
    end
    
    if(nargin < 3)
        skipFreeMem = 0; 
    end
        
    persistent connectionPool;   
    persistent lastOpen;
    
    % Each calculation engine is restricted to two DBMS connections
    % (usually only one is needed though if a server "park" is down it must
    % check for connectivity at backup DBMS). 
    
    if( isempty(connectionPool) ) 
        % Create DBMS 1 (primary)
        connectionPool = [];        
        connObj = getConnectionObject(databaseName);        
        connectionPool{1} = connObj;            
        % TODO: Create DBMS 1 (backup)        
    elseif( isempty(connectionPool{1}.connection) )
         connObj = getConnectionObject(databaseName);
         connectionPool{1} = connObj;     
    end    

    % Check for memory problems; and try to free memory if problem is detected
    if( ~isempty('connectionPool') )
        if( skipFreeMem == 0 )
            if(isempty(lastOpen) == 1)
                lastOpen = now;       
                initNow = 1;
            else
                initNow = 0;
            end
            
            if( print_mem(1) < .20 )
                if(abs((lastOpen-now))*24*3600 > 5 || initNow == 1)
                    % reopen DBMS connections when heap space is below 35%
                    % And that a least 1 second have passed since last
                    % check.
                    
                    fprintf(' --> Less than 35 % heap space left (%.2f), manaully starting java garbage collector!\n',print_mem(1));                        
                    java.lang.System.gc;

                    fprintf('Memory operation completed: %.2f left\n',print_mem(1));                    
                    lastOpen = now;
                elseif(print_mem(1) < .10)
                    fprintf(' --> Less than 10 % heap space left (%.2f), manaully starting java garbage collector!\n',print_mem(1));                        
                    java.lang.System.gc;

                    fprintf('Memory operation completed: %.2f left\n',print_mem(1));                    
                    lastOpen = now;                    
                end
            end
            
            connObj = connectionPool{1};            
        end
    end

    % Various options for closing database connections (ver 1, 2 and 3 were
    % replaced/removed)
    if( operationMode == 1 ) 
        % Init connectionPool (already executed in code above)
        return;
    elseif( operationMode == 4 ) 
        fprintf(' --> Reconecting to database!\n');  
        % Reconnect to database if database is down
        if ( ~isempty(connectionPool) ) 
            if(connectionPool{1}.validConnection == 1)
                close(connectionPool{1}.connection);                    
            end
            connectionPool{1}.connection = [];
        end

        connObj = getConnectionObject(databaseName);
        connectionPool{1} = connObj;         
    elseif( operationMode == 0 )
        % If connection exist; reuse it
        if ( ~isempty(connectionPool) ) 
            connObj = connectionPool{1}; 
        end
    end
       
end

function connObj = getConnectionObject(databaseName)

    extendedURL = [databaseName '?allowMultiQueries=true'];

    persistent dbPreferences    
    if(isempty(dbPreferences) == 1)
        dbPreferences.host = '127.0.0.1';
        dbPreferences.port = '3306';
        dbPreferences.user = 'ml_online';
        dbPreferences.passw = ...
            '6393AB62AF156D8CCA12DA30433AE60118D5C5848ED46C80F9BE593D75506E1D';
        dbPreferences.driver = 'com.mysql.jdbc.Driver';        
    end            

    [connObj.connection,connObj.validConnection] ...
        = getDatabaseObject(extendedURL,dbPreferences.user,...
        dbPreferences.passw, dbPreferences.driver,['jdbc:mysql://' ...
        dbPreferences.host ':' dbPreferences.port '/' extendedURL]);                   
    
    connObj.DBMS = 1;
    connObj.databaseName = databaseName;
    
    if(connObj.validConnection == 1)
        query = 'SET SESSION wait_timeout = 1200;';
        fetch(connObj.connection,query,0);
        query = 'SET NAMES UTF8;';
        fetch(connObj.connection,query,0);
        query = ['USE ' databaseName ';'];
        fetch(connObj.connection,query,0);        
        query = [];
        
        initPrepareStatments(connObj.connection);
    end
        
    fprintf(' --> INITIAL DATABASE CONNECTION OBJECT CREATED (clearing database chache): \n');         
    fetch2Cache('','',[],'clearCache')
    extendedULR = [];
    databaseName = [];
end

function [databaseObject,validConnection] = ...
    getDatabaseObject(databaseName,db_user,db_password,driver,url)
    
    reconnects = 0;
    retries = 0;

    try
        % db_user='DB_USERNAME';db_password='DB_PASSWORD';
        % url=['jdbc:mysql://DB_HOST:' 'PORT' '/stock'];
        databaseObject = database(databaseName,db_user,db_password,driver,url);

        % set(databaseObject,'AutoCommit','off')        
        % setdbprefs('DataReturnFormat','cellarray')
        % dbmeta = dmd(conn_queue.connection)
        % v = get(dbmeta)
        validConnection = 1;
    catch ME
        fprintf('\n --> ERROR: database object failed to intialize (databaseName,UserName,Password,Driver,URL)\n');
        validConnection = 0;        
    end
    
    % ERROR HANDLING: will try to create database object X times and also
    % handles how to deal with situations when no database can be created
    % at all (e.g., "server down" situations).
    while( length(databaseObject.message) ~= 0 && reconnects <= 4 )
        try
            databaseObject = database(databaseName,db_user,db_password,driver,url);
            % set(databaseObject,'AutoCommit','off')            
            % setdbprefs('DataReturnFormat','cellarray')
            validConnection = 1;
        catch ME
            fprintf('STILL RECONNECTION ERROR: database object failed to intialize (databaseName,UserName,Password,Driver,URL)\n');            
            validConnection = 0;            
        end

        if( length(databaseObject.message) ~= 0 )
            if( regexp(databaseObject.message,'Access denied for user') == 1 )
                 validConnection = 0;
                 reconnects = reconnects + 1;
                 % TODO: notify that calc_engine has no access rights to
                 % database                    
            elseif( regexp(databaseObject.message,'Communications link failure') == 1 )
                 validConnection = 0;
                 reconnects = reconnects + 1;
            elseif( regexp(databaseObject.message,'Invalid or closed connection') == 1 )                   
                 validConnection = 0;
                 reconnects = reconnects + 1;
            elseif( regexp(databaseObject.message,'JDBC Driver Error:') == 1 )
                 % E.g., check if mysql jdbc driver is added to classpath.txt
                 % in /toolbox/local/                       
                 validConnection = 0;
                 reconnects = reconnects + 1;
            elseif( regexp(databaseObject.message,'Too many connections') == 1 ) 
                 reconnects = 5;                    
                 validConnection = 0;
            else
                fprintf('%s\n',databaseObject.message);
                validConnection = 0;
                reconnects = reconnects + 1;
            end 

            if(reconnects >= 4 && retries < 4)
                if(retries == 0)
                    fprintf('DATABASES ARE DOWN: SERVICE WILL SLEEP 30 SECONDS BETWEEN CONNECTION ATTEMPTS!\n') 
                    retries = 1;
                end
                fprintf('Reconnection attempts before sleep=%d, Retried %d times (reconnects * retries)\n',reconnects,retries);
                reconnects = 0;
                retries = retries + 1;
                % SLEEP 30 SECONDS 
                pause(30);            
            elseif(reconnects >= 4 && retries == 4)
                if(retries == 4)
                    fprintf('DATABASES ARE STILL DOWN: SERVICE WILL SLEEP 60 SECONDS BETWEEN CONNECTION ATTEMPTS!\n')                
                end
                fprintf('Reconnection attempts before sleep=%d, Retried %d times (reconnects * retries)\n',reconnects,retries);
                reconnects = 0;
                retries = retries + 1;
                % SLEEP 60 SECONDS
                pause(60);
            end    
        end
    end      
end

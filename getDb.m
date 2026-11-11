function db=getDb(update,db_instance)
persistent dbSave 
% The database password is read from a file outside the code, so it is never in the repository.
 
if nargin<1
    update=0; 
end
if nargin<2
    db_instance = 'space2';
end
if not(isempty(dbSave)) & not(strcmp(dbSave.Instance,db_instance))
    update=1;
end
if isempty(dbSave) | update | length(dbSave.Message)>0
    if not(isempty(dbSave))
        close(dbSave);
    end
     
    if findstr(pwd,'/Users/sverkersikstrom')>0 %Sverker use
        db_host='semanticexcel.com';
        db_username = 'sverker';
        db_password = readDbPassword(fullfile(getenv('HOME'), '.semanticexcel-secrets', 'db_password'));
        dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://' db_host '/' db_instance ]);
        if length(dbSave.Message)>0
            fprintf('Using local DB for Sverker: %s\n',dbSave.Message)
        end
    else %Use on server
        db_instance='space2';
        db_username='root';
        db_password = readDbPassword('/etc/semanticexcel/db_password');
        dbSave = database(db_instance,db_username,db_password,'com.mysql.jdbc.Driver',['jdbc:mysql://localhost:3306/' db_instance ]);
    end
    if length(dbSave.Message)>0
        fprintf('%s\n',dbSave.Message)
    end

end
db=dbSave;

function password=readDbPassword(file)
% Reads the database password from a file that only the server can read
password=strtrim(fileread(file));

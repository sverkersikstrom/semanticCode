save2file=exist('save2file.txt');
if isfield(s,'error') & isstruct(s.error)
    s=rmfield(s,'error');
end
if (findstr(answer,'Error')==1 & abs(d.ErrorTime-now)>.02/24) | (save2file & length(answer)>0) | isfield(s,'error')
    %Check that database connection works
    con=getDb(1);
    %     try
    %         query=['SELECT `id` FROM `spaceSwedish2` limit 1'];
    %         r=fetch(getDb,query);
    %         %Database ok
    %     catch
    %         %Database problem, resetting database!
    %         con=getDb(1);
    %         if length(con.Message)>0
    %             fprintf('Database error: %s\n',con.Message);
    %         end
    %     end
    d.ErrorTime=now;
    try
        try
            if isfield(s,'handles')
                s=rmfield(s,'handles');
            end
        end
        clear('meexcel');
        h=[];
        clear out1
        warning off
        if 1
            nowString='';
        else
            nowString=datestr(now,'yyyymmDDHHMM');
        end
        if exist('err','var')
            a=err;
        else
            a=lasterror;
        end
        for i=1:size(a.stack,1)
            fprintf('%d\t%s\n%s\t%d\n',i,a.stack(i).file,a.stack(i).name,a.stack(i).line)
            %a.stack(i)
        end
        a
        fprintf('save2file=%d, Answer=%s\n',save2file,answer);

        if isfield(s,'error') & ischar(s.error)
            file=['MatlabError' fixpropertyname(s.error) nowString];
            fprintf('Saving error matlab file s.error: %s\n',file);
            s.error=rmfield(s,'error');
        elseif save2file & isempty(findstr(answer,'Error')==1)
            file=['MatlabData' nowString '-' num2str(fix(rand*1000))];
            fprintf('Saving data matlab file without errors: %s\n',file);
        else
            file=['MatlabError' fixpropertyname(a.message) nowString];
            fprintf('Saving error matlab file:%s\n',file);
        end
        try
            save(file)
        catch
            save('MatlabError')
        end
        if isfield(s,'error')
            s=rmfield(s,'error');
        end
        warning on
    catch
        fprintf('Error saving error matlab file\n');
    end
    meexcel = semantic.semanticExcelABunction();
    clear('err')
end
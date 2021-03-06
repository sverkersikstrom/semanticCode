
function excelServer(parServer)
global rootPath
getPar([],'clear');%Clear stored variables
setenv('PATH',[getenv('PATH') ':/usr/local/bin'])%Needed for making call the R that used to for BERT integration
if nargin<1
    parServer.parallel=0;
end
if parServer.parallel
    parallel=gcp;
    if isempty(parallel)
        parallel = parpool;
    end
end

d=config;
if not(exist(d.spaceCache))
    mkdir(d.spaceCache)
end

if findstr(pwd,'sverker')>0 %| isdeployed
    fprintf('Do not forget to start MAMP and to type in a terminal window: \nredis-server\n');
    %Put specific variables related to Sverker here
    fprintf('Setting variabeles specific to Sverkers machine\n');
    d.matlab_error_log='mat_error.txt';
    d.download_plot_dir='';
    d.words_plot_dir='';
    
    %warning off
    mypath='/Users/semantic/';
    %mypath='/Users/semantic/';
    if not(isdeployed)
        addpath([mypath '']);
        addpath([mypath 'semanticCode']);
        addpath([mypath 'matlabjarfiles/jsonlab']);
        dbstop in excelServer at 130
    end
    javaaddpath([mypath 'matlabjarfiles/jsonlab']);
    javaaddpath([mypath 'matlabjarfiles/json_simple-1.1.jar'])
    javaaddpath([mypath 'matlabjarfiles/jedis-2.1.0.jar'])
    javaaddpath([mypath 'matlabjarfiles/final.jar'])
    %javaaddpath([mypath 'matlabjarfiles/mysql-connector-java-5.1.34-bin.jar'])
    %javaaddpath('/mysql-connector-java-5.1.34-bin.jar')
    
    %javaaddpath([mypath 'matlabjarfiles/mysql-connector-java-8.0.11.jar'])
    javaaddpath(['/Users/.../mysql-connector-java-5.1.6-bin.jar']);

else
    javaaddpath('/home/semantic/matlabjarfiles/json_simple-1.1.jar')
    javaaddpath('/home/semantic/matlabjarfiles/jedis-2.1.0.jar')
    javaaddpath('/home/semantic/matlabjarfiles/final.jar')
    javaaddpath('/home/semantic/matlabjarfiles/jdbc-driver.jar')
    
    rootPath = '/home/semantic/semanticmatlab';
    addpath('/home/semantic/semanticmatlab');
    addpath('/home/semantic/semanticmatlab/semanticCode');
    addpath('/home/semantic/semanticmatlab/jsonlab');
    
end
d.print2console=1;

d.fid=fopen(d.matlab_error_log,'a');

%Set persistent/default parameters
setPar.excelServer=1;
%setPar.handels=getHandles;
setPar.persistent=1;
if findstr(char(java.net.InetAddress.getLocalHost.getHostName),'semanticexcel')>0
    setPar.callfrom='SE';
    callfrom='SE';
else
    setPar.keywordsPlotPvalue=1;
    setPar.plotBonferroni=0;
    callfrom='';
end
setPar.plotSignificantColors=6;%Colormap
%setPar.Ncluster=4;
getPar(setPar);
%semantic;


f=dir('MatlabError*');
if size(f,1)>0
    fprintf('PLEASE CORRECT THE FOLLOWING %d ERRORS:\n',size(f,1));
    dir('MatlabError*')
end
fprintf('Running in mood: %s\n',callfrom)

%x = 0;
meexcel = semantic.semanticExcelABunction();
%command = '';
s=[];
%s.par.updateReportAutomatic=2;
count=0;
t0=now;
d.ErrorTime=0;
h=[];

con=getDb(1);
if length(con.Message)>0 
    fprintf('Database error: %s\n',con.Message);
    stop
end

% if isempty(fetch(getDb,'show tables like "spaceEnglish";'))
%     spaceToDb('spaceEnglish')
% end
% if isempty(fetch(getDb,'show tables like "spaceSwedish";'))
%     spaceToDb('spaceSwedish')
% end
pauseMaxTime=.2;
pauseTime=pauseMaxTime;
answer='';
while true
    try
        if length(answer)>0
            answer='';
            pauseTime=0;
        else
            pauseTime=min(pauseTime+.02,pauseMaxTime);
        end
        if abs(t0-now)*3600*24<pauseTime
            if exist('debugCode.m')
                pause(2);fprintf('Running debugCode.m!\n')
                debugCode;
            end
            pause(pauseTime);
        else
            1;%No need to pause after running a command lasting for more then pauseTime seconds
        end
        t0=now;
        
        if even(count,50)
            fprintf('.');
        end
        tic;
        command = '';
        
        %getPredictionDEtail command
        command=meexcel.getPredictionDEtail();
        if not(isempty(command.get('refkey')))
            if parServer.parallel
                parfeval(parallel,@getPredictionDEtail,0,meexcel,command,d);
            else
                answer=getPredictionDEtail(meexcel,command,d);
            end
        end
        
        %getProperty command
        command = meexcel.getCommand();
        if not(isempty(command.get('singlemultiple')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommand,0,meexcel,command,d);
                toc
            else
                answer=getCommand(meexcel,command,d);
            end
        end
        
        %-----------------------------------------------
        %start setProperty API Function
        command = meexcel.getPropertyCommand();
        if not(isempty(command.get('documentlanguage')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getPropertyCommand,0,meexcel,command,d);
                toc
            else
                answer=getPropertyCommand(meexcel,command,d);
            end
        end
        
        
        
        %---------------------------------------
        %start getProperty API Function
        command = meexcel.getGetPropertyCommand();
        if not(isempty(command.get('identifierOrText')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getGetPropertyCommand,0,meexcel,command,d);
                toc
            else
                answer=getGetPropertyCommand(meexcel,command,d);
            end
        end
        
        
        %--------------------------------------------------------
        %semantictest command
        command = meexcel.getCommandSemantictest();
        if not(isempty(command.get('wordset1')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandSemantictest,0,meexcel,command,d);
                toc
            else
                answer=getCommandSemantictest(meexcel,command,d);
            end
        end
        
        %Create space
        try
            command = meexcel.getCommandCreateSpace();
        catch
            fprintf('Error in getCommandCreateSpace\n')
        end
        
        if not(isempty(command.get('createSpace')))
            %Do we have support for Matlab paralell programming? (see code above)
            if parServer.parallel
                parfeval(parallel,@getCommandCreateSpace,0,meexcel,command,d);
            else
                answer=getCommandCreateSpace(meexcel,command,d);
            end
        end
        
        
        %clusterspace function
        command = meexcel.getCommandClusterspace();
        if not(isempty(command.get('wordset')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandClusterspace,0,meexcel,command,d);
                toc
            else
                answer=getCommandClusterspace(meexcel,command,d);
            end
        end
        %end clusterspace function
        
        %similarity function
        command = meexcel.getCommandSimilarity();
        if not(isempty(command.get('refkey')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandSimilarity,0,meexcel,command,d);
                toc
            else
                answer=getCommandSimilarity(meexcel,command,d);
            end
        end
        
        %predict function
        command = meexcel.getCommandPredict();
        if not(isempty(command.get('items')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandPredict,0,meexcel,command,d);
                toc
            else
                answer=getCommandPredict(meexcel,command,d);
            end
        end
        
        %stdev function - (fast: not parellized)
        command = meexcel.getCommandStdev();
        if isempty(command.get('items')) == false
            try
                refkey  = command.get('refkey');
                refitems    = command.get('refitems');
                prefix      = command.get('prefix');
                selectioncriteria = command.get('selectioncriteria');
                selectioncell = command.get('selectioncell');
                if isempty(selectioncriteria) == false
                    x=javaLinkedList2double(selectioncell);
                    formula=selectioncriteria;%Choice formula to select
                    eval(['selection=find(' formula ');']);
                    answer=num2str(std(javaLinkedList2double(selection)),'%.2f');
                else
                    answer=num2str(std(javaLinkedList2double),'%.2f');
                end
                m = java.util.HashMap;
                answer=answer;
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setStdev(m);
            catch err
                m = java.util.HashMap;
                answer='Error during calculating';
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setStdev(m);
                disp(getReport(err));
                fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
            end
        end
        %end stdev function
        
        %ttest function - (fast: not parellized)
        command = meexcel.getCommandTtest();
        if isempty(command.get('items1')) == false
            try
                items1 = command.get('items1');
                refkey = command.get('refkey') ;
                items2    = command.get('items2');
                tail  = command.get('tail');
                selectioncriteria = command.get('selectioncriteria');
                selectioncell = command.get('selectioncell');
                if isempty(selectioncriteria) == false
                    x=javaLinkedList2double(selectioncell);
                    formula=selectioncriteria;%Choice formula to select
                    eval(['selection=find(' formula ');']);
                    [h, p, ci, stats]=ttest2(javaLinkedList2double(selection),javaLinkedList2double(selection),.05,tail);
                else
                    [h, p, ci, stats]=ttest2(javaLinkedList2double(items1),javaLinkedList2double(items2),.05,tail);
                end
                answer=sprintf('t(%d)=%.3f, p=%.4f\n',stats.df,stats.tstat,p);
                m = java.util.HashMap;
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setTtest(m);
            catch err
                m = java.util.HashMap;
                answer='Error during calculating';
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setTtest(m);
                disp(getReport(err));
                fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
            end
        end
        %end ttest function
        
        %corr function - (fast: not parellized)
        command = meexcel.getCommandCorr();
        items1    = command.get('items1');
        try
            if isempty(items1) == false
                document=command.get('documentid');
                refkey  = command.get('refkey')   ;
                items2    = command.get('items2');
                selectioncriteria = command.get('selectioncriteria');
                selectioncell = command.get('selectioncell');
                if isempty(selectioncriteria) == false
                    x=javaLinkedList2double(selectioncell);
                    formula=selectioncriteria;%Choice formula to select
                    eval(['selection=find(' formula ');']);
                    [r p]=nancorr((javaLinkedList2double(selection))',(javaLinkedList2double(selection))');
                else
                    %Use javaLinkedList2double to conver to numeric value:
                    [r p]=nancorr(javaLinkedList2double(items1)',javaLinkedList2double(items2)');
                end
                answer=sprintf('r=%.2f, p=%.4f\n',r,p);
                m = java.util.HashMap;
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setCorr(m);
            end
        catch err
            m = java.util.HashMap;
            answer='Error during calculating';
            m.put('results',answer);
            m.put('refkey',refkey);
            meexcel.setCorr(m);
            disp(getReport(err));
            fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
        end
        %end corr function
        
        %wordstest function
        command = meexcel.getCommandKeywordstest();
        if not(isempty(command.get('wordset1')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandKeywordstest,0,meexcel,command,d);
                toc
            else
                answer=getCommandKeywordstest(meexcel,command,d);
            end
        end
        
        %semantictestproperty function
        command = meexcel.getCommandSemantictestpropertymany();
        if not(isempty(command.get('datas1')))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandSemantictestpropertymany,0,meexcel,command,d);
                toc
            else
                answer=getCommandSemantictestpropertymany(meexcel,command,d);
            end
        end
        
        %plotspace function
        command = meexcel.getCommandPlotspace();
        wordset  = command.get('wordset');
        if not(isempty(wordset))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandPlotspace,0,meexcel,command,d);
                toc
            else
                answer=getCommandPlotspace(meexcel,command,d);
            end
        end
        
        %plotwordcount function
        command = meexcel.getCommandPlotWordcount()	;
        wordset  = command.get('wordset');
        if not(isempty(wordset))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommandPlotWordcount,0,meexcel,command,d);
                toc
            else
                answer=getCommandPlotWordcount(meexcel,command,d);
            end
        end
        
        %plotwordcountcategory function - (fast: not parellized)
        command = meexcel.getPlotWordcountCategory();%Chintan: Please change the name 'plotwordcountcategory' to get 'getIndexCategory'
        c = command.get('category');
        if isempty(c) == false
            try
                refkey = command.get('refkey');
                document=command.get('documentid');
                documentlanguage=command.get('documentlanguage');
                s=initSpace(command);
                [s, index2] =getSfromDB(s,documentlanguage,document,[],[],'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
                s.languagefile=getSpaceName(documentlanguage);
                disp(s);
		disp(c);
                [id, categories, index,user,comments]=getIndexCategory(str2double(c),s,1);
                id=id(1:min(2000,length(id)));
                identifier='';commentStr='';
                for j=1:length(id)
                    if isempty(comments{j}) comments{j}=id{j};end
                    comments{j}=regexprep(comments{j},'_',' ');
                    if j==1
                        identifier=strcat(identifier,id{j});
                        commentStr=strcat(commentStr,comments{j});
                    else
                        identifier=strcat(identifier,'|',id{j});
                        commentStr=strcat(commentStr,'|',regexprep(comments{j},'|',''));
                    end
                end
                m = java.util.HashMap;
                answer=identifier;%CHINTAN: In the output meny show commentStr! However in the call to matlab call with str
                m.put('results',answer);
                meexcel.setPlotWordcountInstances(m,refkey);
            catch err
                m = java.util.HashMap;
                answer='Error during calculating';
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setPlotWordcountInstances(m,refkey);
                disp(getReport(err));
                fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
            end
        end
        %end plotwordcountcategory function
        
        %getParams function - (fast: not parellized)
        command = meexcel.getGetParams();
        refkey = command.get('refkey');
        if isempty(refkey) == false
            try
                opt.Compact=1;
                [temp1 temp2] = getPar;
                info1.field=temp2.field;
                info1.comment = temp2.comment;
                info1.commentValue = temp2.commentValue;
                info1.options = temp2.optionsLong;
                info1.category = temp2.category;
                temp.info = info1;
                temp.result = temp1;
                answer=savejson('',temp,opt);%On the meny use the variable commentValue (rather than comment)
                m = java.util.HashMap;
                m.put('results', answer);
                meexcel.setGetParams(m,refkey);
            catch err
                m = java.util.HashMap;
                answer='{msg: Error during calculating}';
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setGetParams(m,refkey);
                disp(getReport(err));
                fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
            end
        end
        %getParams end function
        
        %3woords function
        command = meexcel.getCommand3wordsNew();
        wordset  = command.get('data');
        if not(isempty(wordset))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommand3wordsNew,0,meexcel,command,d);
                toc
            else
                answer=getCommand3wordsNew(meexcel,command,d);
            end
        end
        
        %spell check function Is this function used?
        command = meexcel.getCommandSpellCheck();
        wordset  = command.get('data');
        try
            if isempty(wordset) == false
                refkey  = command.get('refkey');
                document=command.get('documentSpace');
                documentlanguage=command.get('documentlanguage');
                errormessage='';
                s=initSpace(command);
                result = {};
                for j=1:wordset.size,
                    [ok suggestion minError]=spellCheck(s,wordset.get(j-1));
                    result{j} = [suggestion minError];
                end
                m = java.util.HashMap;
                answer=savejson(result);
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setCommandSpellCheck(m);
            end
        catch err
            m = java.util.HashMap;
            if isempty(errormessage) == false
                answer=strcat('Error: ',errormessage,' unknown word');
                m.put('results',answer);
            else
                answer='Error during calculating';
                m.put('results',answer);
            end
            m.put('refkey',refkey);
            meexcel.setCommandSpellCheck(m);
            fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
        end
        %end spellcheck function
        
        %------------------------------------
        % 3woords semantic function. The Semantic Function with JSON does
        % not have any call to this function. Is it used?
        command = meexcel.getCommand3wordsSemantic();
        wordset  = command.get('wordset');
        if not(isempty(wordset))
            if parServer.parallel
                tic;
                parfeval(parallel,@getCommand3wordsSemantic,0,meexcel,command,d);
                toc
            else
                answer=getCommand3wordsSemantic(meexcel,command,d);
            end
        end
        
        %plotSemantic function The Semantic Function with JSON does
        % not have any call to this function. Is it used?
        command = meexcel.getPlotSemanticDistance();
        wordSD = command.get('word');
        if isempty(wordSD) == false
            try
                refkey = command.get('refkey');
                documentlanguage=command.get('documentlanguage');
                s=initSpace(command);
                [h out]=plotSemanticDistance(s,wordSD);
                saveas(h,strcat(d.download_plot_dir,refkey,'.png'))
                answer = strcat(d.download_plot_url,refkey,'.png');
                m = java.util.HashMap;
                m.put('results', answer);
                meexcel.setPlotSemanticDistance(m,refkey);
            catch err
                m = java.util.HashMap;
                answer='Error during calculating';
                m.put('results',answer);
                m.put('refkey',refkey);
                meexcel.setPlotSemanticDistance(m,refkey);
                disp(getReport(err));
                fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet demo ', getReport(err)));
            end
        end
        %end semantic semanticDistance
        
        %wordnorm
        command = meexcel.getWordnorms();
        norm_text = command.get('norm_text');
        if not(isempty(norm_text))
            if parServer.parallel
                tic;
                parfeval(parallel,@getWordnorms,0,meexcel,command,d);
                toc
            else
                answer=getWordnorms(meexcel,command,d);
            end
        end
        if d.print2console
            fprintf('%s',answer);
            if length(answer)>0;
                toc
            end
        end
        excelServerErrors;
        count=count+1;
        if count>60*5; count=0; fprintf('\n');end
    catch err
        fprintf('Matlab General Error\n')
        fprintf(d.fid, '%s\n', getReport(err));
        answer='Error';
        excelServerErrors;
    end
end
fprintf('Matlab stops here, restarting in 1 s\n')
pause(1)
exit %This ends Matlab and it should restart

function answer=getGetPropertyCommand(meexcel,command,d)
try
    if isempty(command) == false
        rowidentifierOrText = command.get('identifierOrText');
        %if not(isempty(rowidentifierOrText))
disp('------')
disp(command.get('languagecode'));
disp('------')
        document = command.get('documentSpace');
        refkey  = command.get('refkey');
        documentlanguage=command.get('documentlanguage');
        %end
        
        s=initSpace(command);
        parameterType =  command.get('parameterType');
        parameterValue =  command.get('parameterValue');
        
        for j=1:parameterType.size,
            s.par.(parameterType.get(j-1)) = parameterValue.get(j-1);
        end
        
        property = command.get('property');
        ref=[];
        identifierOrText = {};
        
        for j=1:rowidentifierOrText.size,
            identifierOrText{j} = rowidentifierOrText.get(j-1);
            ref{j}=['_ref' num2str(j)];
        end
        [s, index2] =getSfromDB(initSpace(command),documentlanguage,document,ref,identifierOrText,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        if property(1)=='_' %Assume a function
            [s, index1] =getSfromDB(initSpace(command),documentlanguage,document,{property},{property},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        else %Assume a text
            [s, index1] =getSfromDB(initSpace(command),documentlanguage,document,{'_reftext'},{property},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        end
        [~, stringOrNumber, s]=getProperty(s,index1,index2);%getProperty
        m = java.util.HashMap;
        answer=cell2string(stringOrNumber);
        m.put('answer',answer);
        
        m.put('refkey',refkey);
        meexcel.setGetPropertyAPICommand(m);
    end
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('answer',answer);
    m.put('refkey',refkey);
    meexcel.setGetPropertyAPICommand(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', getReport(err));
    excelServerErrors;
end


function answer=getCommandSimilarity(meexcel,command,d)
try
    refkey  = command.get('refkey');
    
    
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    %filename='';
    singlemultiple  = command.get('singlemultiple');
    s=initSpace(command);
    %norm text comes here in semanticNorm
    semanticNorm = command.get('semanticNorm');
    
    word=[];ref=[];
    if strcmpi(singlemultiple,'singletext');
        word{1}    = command.get('word1');
        ref{1}    = command.get('ref1');
        
        if(isempty(semanticNorm))
            word{2}    = command.get('word2');
            ref{2}    = command.get('ref2');
        else
            word{2}    = fixpropertyname(semanticNorm);
            ref{2}    = fixpropertyname(semanticNorm);
        end
        
        [s, index]=getSfromDB(initSpace(command),documentlanguage,document,ref,word,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        s.par.getPropertyShow=command.get('semanticDistance');
        [~, answer,s] = getProperty(s,index(2),index(1)); %similarity(ref1,ref2);
        m = java.util.HashMap;
        answer=answer{1};
        m.put('results',answer);
        m.put('refkey',refkey);
        meexcel.setSimilarity(m);
    else
        text1    = command.get('text1');
        reftext1    = command.get('reftext1');
        text2    = command.get('text2');
        reftext2    = command.get('reftext2');
        prefix    = command.get('prefix');
        
        setword1 = {};
        refword1 = {};
        setword2 = {};
        refword2 = {};
        textword1 = {};
        textword2 = {};
        
        wordindexes = [];
        for j=1:text1.size,
            setword1{j} = text1.get(j-1);
            refword1{j} = strcat(prefix,reftext1.get(j-1));
            textword1{j}='_text';
        end
        
        if(isempty(semanticNorm))
            for j=1:text2.size,
                setword2{j} = text2.get(j-1);
                refword2{j} = strcat(prefix,reftext2.get(j-1));
                textword2{j}='_text';
            end
        else
            setword2{1} = fixpropertyname(semanticNorm);
            refword2{1} = fixpropertyname(semanticNorm);
            %refword2{1} = 'ref2';
            textword2{1} = '_text';
        end
        
        [s, index1]=getSfromDB(initSpace(command),documentlanguage,document,refword1,setword1,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        [s, index2]=getSfromDB(s,documentlanguage,document,refword2,setword2,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        s.par.getPropertyShow=command.get('semanticDistance');
        if length(index2)==1
            [~, answer1,s]= getProperty(s,index2,index1);
        else
            for i=1:length(index1)
                [~, answer1(i),s]= getProperty(s,index2(i),index1(i));
            end
        end
        answer='';
        for i=1:length(index1)
            if i==1
                answer = strcat(answer,answer1{i});
            else
                answer = strcat(answer,';',answer1{i});
            end
        end
        getSpace('set',s);
        
        m = java.util.HashMap;
        m.put('results',answer);
        m.put('refkey',refkey);
        meexcel.setSimilarity(m);
    end
    
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setSimilarity(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors
end
%end similarity function

function answer=getCommand3wordsNew(meexcel,command,d)
global figureNote
try
    wordset  = command.get('data');
    
    
    refwordset = command.get('identifier');
    refkey  = command.get('refkey');
    valence = command.get('valence');
    document=command.get('documentSpace');
    documentlanguage=command.get('documentlanguage');
    errormessage='';
    
    s=initSpace(command);
    
    compareData  = command.get('compareData');
    compareIde  = command.get('compareIde');
    plottype=command.get('plotType');
    plotCloudType=command.get('plotCloudType');
    plotCluster=command.get('plotCluster');
    plotWordcloud=command.get('plotWordcloud');
    plotTestType=command.get('plotTestType');
    
    userIdeNames=command.get('userIdeNames');
    userIdentifier=command.get('userIdentifier');
    numbersParam=command.get('numbersData');
    xaxel=command.get('xaxel');
    yaxel=command.get('yaxel');
    zaxel=command.get('zaxel');
    justTakenSurvey = command.get('justTakenSurvey');
    
    
    plotNominalLabels=command.get('plotNominalLabels');
    for i=1:plotNominalLabels.size
        s.par.plotNominalLabels{i}=plotNominalLabels.get(i-1);
    end
    s.par.plotNominal=command.get('plotWordcloudType');%Consider renaming to plotNominal
    
    setword={};
    refword={};
    textword={};
    %index=[];
    for j=1:wordset.size,
        setword{j} = wordset.get(j-1);
        refword{j} = refwordset.get(j-1);
        textword{j}='_text';
    end
    [s, index] =getSfromDB(s,documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    
    userCallId='';
    advanceParamJson=command.get('advanceParam');
    advanceParam=[];
    if isempty(advanceParamJson) == false & not(strcmpi(advanceParamJson,'[]')) %Never call with [], use '' instead!   
        advanceParam = loadjson(advanceParamJson);
        if isfield(advanceParam,'plotProperty3') %Do NOT use plotProperty3, use plotProperty instead.
            advanceParam.plotProperty=advanceParam.plotProperty3;
        end        
        s=advancedOption(s,advanceParam);
        
        if isfield(s.par, 'diagnosUserId')
            userCallId=s.par.diagnosUserId;
            fprintf('Setting userCallId to: %s\n',userCallId)
        end 
    end
    
    setword1={};
    refword1={};
    textword1={};
    for j=1:compareData.size,
        setword1{j} = compareData.get(j-1);
        refword1{j} = compareIde.get(j-1);
        textword1{j}='_text';
    end
    
    userIdes={};
    userIdNames={};
    for j=1:userIdentifier.size,
        userIdes{j} = userIdentifier.get(j-1);
        userIdNames{j} = userIdeNames.get(j-1);
    end
    
    %number calculation
    numbers = []; %default single dimension
    xdata = {};
    ydata = {};
    zdata = {};
    if isempty(xaxel) == false
        for j=1:xaxel.size,
            xdata{j}=str2double(xaxel.get(j-1));
        end
    end
    xdata=cell2mat(xdata);
    indexNaN=find(isnan(xdata));
    if length(indexNaN)>0 fprintf('Warning: Missing xdata on %d datapoints\n',length(indexNaN)); end
    
    if isempty(yaxel) == false
        for j=1:yaxel.size,
            ydata{j}=str2double(yaxel.get(j-1));
        end
    end
    ydata=cell2mat(ydata);
    indexNaN=find(isnan(ydata));
    if length(indexNaN)>0 fprintf('Warning: Missing ydata on %d datapoints\n',length(indexNaN)); end
    
    if isempty(zaxel) == false
        for j=1:zaxel.size,
            zdata{j}=str2double(zaxel.get(j-1));
        end
    end
    zdata=cell2mat(zdata);
    indexNaN=find(isnan(zdata));
    if length(indexNaN)>0 fprintf('Warning: Missing zdata on %d datapoints\n',length(indexNaN)); end
    
    if isempty(setword1) == false
        [s, index1] =getSfromDB(s,documentlanguage,document,refword1,setword1,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        xdata=[ones(1,length(index)) zeros(1,length(index1))];
        index=[index index1];
        index1=[];
    end
    if isempty(xdata) == false
        numbers = {};
        numbers{1} = xdata;
        if not(length(xdata)==length(index)) & length(index)>0
            fprintf('Error: Length of xdata MUST match length of index\n');
        end
    end
    if isempty(ydata) == false
        numbers{2} = ydata;
    end
    if isempty(zdata) == false
        numbers{3} = zdata;
    end
    
    
    refwordCompare=[];
    s.par.plotCloudType=plotCloudType;
    s.par.plotCluster=str2num(plotCluster);
    s.par.plotWordcloud=str2num(plotWordcloud);
    
    if isfield(s.par,'units')
        labels=s.par.units;
    else
        labels={'x-axis','y-axis','z-axis'};%We need to add labels to the numerical values here!
    end
    
    if ischar(s.par.plotProperty)
        tmp=s.par.plotProperty;
        s.par.plotProperty=[];
        s.par.plotProperty{1}=tmp;
    end
    
    s.par.userIndex=find(strcmpi(userCallId,userIdNames));
    if isempty(s.par.userIndex) && justTakenSurvey == '1'
        if length(index)==0
            if length(numbers)>0 & length(numbers{1})>0
                s.par.userIndex=length(numbers{1});
            else
                s.par.userIndex=[];
            end
        else
            s.par.userIndex=length(index);
        end
        s.par.userCallId='Last respondent';
    else
        s.par.userCallId=userCallId;
    end
    
    for i=1:3
        par{i}=s.par;
        %Get plotProperty
        if isfield(advanceParam,'plotProperty');
            if length(s.par.plotProperty)>=i
                s.par.plotProperty{i}=fixpropertyname(s.par.plotProperty{i});
                par{i}.plotProperty=s.par.plotProperty{i};
                if length(par{i}.plotProperty)>0
                    par{i}.plotTestType='property';
                    labels{i}=regexprep(par{i}.plotProperty,'_pred','');
                    if findstr(documentlanguage,'sv') & strcmpi(par{i}.plotProperty,'_predvalence')
                        par{i}.plotProperty='_predvalencestenberg';
                    end
                    [s, indexPlotProperty] =getSfromDB(initSpace(command),documentlanguage,document,{par{i}.plotProperty},{par{i}.plotProperty},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
                    if isnan(s.x(indexPlotProperty,1))
                        fprintf('Error: Could not find plotProperty %s in space\n',s.par.plotProperty{i})
                    end
                end
            end
        end
    end
    
    
    for i=1:length(refwordCompare)
        if length(refwordCompare{i})>0
            'THERE IS A BUG HERE, SETWORDCOMPARE IS NEVER SET!!!'
            [s, indexAxis] =getSfromDB(s,documentlanguage,document,refwordCompare{i},setwordCompare{i},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
            d1=getX(s,indexAxis);
            x=average_vector(s,d1.x);
            s=addX2space(s,'_tmp',x);
            numbers{i}=getProperty(s,par{i}.plotProperty,index);
        end
    end
    
    if strcmpi(plotCloudType,'diagnos') && isfield(s.par,'plotProperty')
        j=s.par.userIndex;
        out1.pSemanticScale='';
        if isempty(j)
            fprintf('Error: can not find userCallId=%s in userIdNames for the diagnos function\n',userCallId);
        else
            if length(j)>1
                fprintf('Warning: the user has made several inputs, using the last input (%s).\n',getText(s,index(j(end))));
            end
            if length(index)>0
                disp(index(j(end)));
                h=diagnos(s,index(j(end)),s.par.plotProperty);
            end
        end
    else
        [out1,h,s]=plotWordCloud(s,index, numbers,par,labels,userIdNames);
        figureNote = out1.figureNote;
    end
    
    
    %replace users to real names
    if strcmpi(plotCloudType,'users')
        %Highligth current user by making it Bold and Tilted
        %highLightWords(h,userIdes);%This should ONLY be the user that acces the WordCloud
        
        %Maps userIdes to userIdNames
        %highLightWords(h,userIdes,userIdNames)%This should be ALL the user that have contributed to the wordcloud
    else
        %Highligth current users WORDS by making it Bold and Tilted
        %Find current user!
        MostReecentWords=[];
        j=s.par.userIndex;%find(strcmpi(userCallId,userIdNames));
        if length(userIdNames)==length(refword)
            for i=1:length(j)
                tmp=textscan([getText(s,index(j(i))) ' '],'%s');
                highLightWords(h,tmp{1});%This should ONLY be the user that acces the WordCloud
                
            end
        else
            fprintf('Warning: the length of userIdNames and refword should be the same!\n')
            if j>0
                j=find(strcmpi(userIdNames{j(1)},refword));
                if j>0
                    MostReecentWords=textscan(getText(s,index(j(1))),'%s');
                end
            end
            if length(index)>0 & length(MostReecentWords)==0 %If no user found, take the last user
                MostReecentWords=textscan(getText(s,index(end)),'%s');
            end
            if length(MostReecentWords)>0
                highLightWords(h,MostReecentWords{1});%This should ONLY be the user that acces the WordCloud
            end
        end
    end
    
    plotUrlStr='Missing plot';
    randNummer='';
    for i=1:length(h)
        if length(h)>1
            figure(h(i));
        end
        randNummer=['-',num2str(fix(rand*10000))];
        plotUrlStr=strcat(d.words_plot_dir, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(i),randNummer, '.png');
        hgx(h(i),plotUrlStr);%Saves the figure to an .eps file!
    end
    %plotUrlStr =[plotUrlStr num2str(fix(rand*10000))];%Add random number in the end of the name to make the file unique
    
    plotUrlStr = strcat( d.words_plot_url, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(i),randNummer,'.png');
    j=0;
    if length(h) > 1
        plotUrlStr = '';
        for j=1:length(h)-1
            plotUrlStr = strcat(plotUrlStr, d.words_plot_url, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(j),'-',num2str(fix(rand*10000)),'.png|');
        end
    end
    %plotUrlStr = strcat(plotUrlStr, d.words_plot_url, refkey,plottype, plotCloudType, num2str(plotCluster), num2str(j+1),'.png');
    %plotUrlStr = strcat(plotUrlStr, '~',out1.pSemanticScale);
    m = java.util.HashMap;
    answer=plotUrlStr;
    m.put('results',answer);
    m.put('refkey',refkey);
    m.put('figureNote', figureNote);
    meexcel.setCommand3words(m);
    %            end
catch err
    m = java.util.HashMap;
    if isempty(errormessage) == false
        answer=strcat('Error: ',errormessage,' unknown word');
        m.put('results',answer);
    else
        answer='Error during calculating';
        m.put('results',answer);
    end
    m.put('refkey',refkey);
    meexcel.setCommand3words(m);
    e=sprintf('%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    fprintf(d.fid, '%s\n',e);
    fprintf(	 '%s\n',e);
    excelServerErrors
    
end
%end 3words function

function answer=getCommandPredict(meexcel,command,d);
items    = command.get('items');
try
    %if isempty(items) == false
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    refkey  = command.get('refkey');
    assigned = command.get('assigned');
    cv    = command.get('cv');
    name     = command.get('name');
    activatetimeserie     = command.get('activatetimeserie');
    
    refitems    = command.get('refitems');
    refassigned    = command.get('refassigned')  ;
    numericaldata    = command.get('numericaldata') ;
    prefix      = command.get('prefix');
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    covariates = command.get('covariatesdata');
    s=initSpace(command);
    
    %s.par.trainTextLabels={'textharmony','textHappy','textLuck'}
    %s.par.trainNumericLabels={'numerigGender','numericAge'}
    
    s.par.trainTextLabels=LinkedList2cell(command.get('trainTextLabels'));
    s.par.trainNumericLabels=LinkedList2cell(command.get('trainNumericLabels'));
    
    s.par.db2space=1;
    s.par.user=command.get('userIdentifier');%'USER IS A MISSING INPUT HERE'
    if isempty(s.par.user) s.par.user=0;end
    if isempty(activatetimeserie) == false && activatetimeserie=='1'
        s.par.timeSerie=1;
    else
        s.par.timeSerie=0;
    end
    setword = {};
    refword = {};
    textword = {};
    wordindexes = [];
    if 0 %OLD, one dimensional array of inputs
        for j=1:items.size,
            setword{j} = items.get(j-1);
            refword{j} = strcat(prefix,refitems.get(j-1));
            textword{j}='_text';
        end
        [s, wordindexes] =getSfromDB(initSpace(command),documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    else %New, two dimensional array of inputs
        for j=1:items.size,
            tmp = items.get(j-1);
            for i=1:tmp.size
                setword{j,i}=tmp.get(i-1);
            end
            tmp = refitems.get(j-1);
            for i=1:tmp.size
                refword{j,i}=strcat(prefix,tmp.get(i-1));
            end
            %refword{j} = strcat(prefix,refitems.get(j-1));
            %textword{j}='_text';
        end
        [s, wordindexes] =getSfromDB(initSpace(command),documentlanguage,document,reshape(refword,1,size(refword,1)*size(refword,2)),reshape(setword,1,size(setword,1)*size(setword,2)),'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        wordindexes=reshape(wordindexes,size(refword,1),size(refword,2));
    end
    group = [];
    for j=1:cv.size,
        group=[group,str2double(cv.get(j-1))];
    end
    trainData = [];
    for j=1:assigned.size,
        trainData=[trainData,str2double(assigned.get(j-1))];
    end
    
    numericalDatas = [];
    if isempty(numericaldata) == false
        for j=1:numericaldata.size,
            numericaldata1=numericaldata.get(j-1);
            for k=1:numericaldata1.size,
                numericalDatas(j,k)=str2double(numericaldata1.get(k-1));
            end
        end
    end
    
    covariatesData = [];
    if isempty(covariates) == false
        for j=1:covariates.size,
            covariates1=covariates.get(j-1);
            for k=1:covariates1.size,
                covariatesData(j,k)=covariates1.get(k-1);
            end
        end
    end
    
    rng('default');
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        [s info]=train(s,trainData(selection)',name,wordindexes(selection)',group(selection),numericalDatas(selection),covariatesData(selection));
    else
        [s info]=train(s,trainData',name,wordindexes,group,numericalDatas,covariatesData);
    end
    if iscell(info)
        info=info{end};
    end
    m = java.util.HashMap;
    m.put('p',info.p);
    m.put('r',info.r);
    answer=info.results;
    m.put('results',info.results);
    m.put('refkey',refkey);
    meexcel.setPredict(m);
    %end
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setPredict(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors
end
%end predict function


function answer=getCommand(meexcel,command,d);
try
    %if isempty(singlemultiple) == false
    singlemultiple = command.get('singlemultiple');
    
    document=command.get('documentid');
    refkey  = command.get('refkey');
    documentlanguage=command.get('documentlanguage');
    disp(command.get('languagecode'));
    s=initSpace(command);
disp('a');
    
    if strcmpi(singlemultiple,'singletext')
disp('b');
        w1 = command.get('word1');
        w2 = command.get('word2');
        ref1 = command.get('refword');
        textIdentifier=[];%Here add an input for textIdentier!
disp('b1');
        [s, index12] =getSfromDB(initSpace(command),documentlanguage,document,[{ref1} {w2}],[{w1} {w2}],'update',s.par,textIdentifier);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
disp('b2');
        index=index12(1:end-1);
        index2=index12(end);
        
        [a,answer,s] = getProperty(s, index2, index);
        answer=answer{1};
        
    elseif strcmpi(singlemultiple,'multipletext')
disp('c')
        wordset1    = command.get('wordset1');
        refwordset1    = command.get('refwordset1');
        word2    = command.get('word2');
        ref='';
        currws=[];
        textIdentifier=[];
        for j=1:wordset1.size,
            currws{j} = wordset1.get(j-1);
            textIdentifier{j}='_text';%%Here add an input for textIdentier!
            ref{j}=strcat('_ref',document,refwordset1.get(j-1));
        end
        textIdentifier=[textIdentifier {'_text'}];
        [s, index12]=getSfromDB(initSpace(command),documentlanguage,document,[ref {word2}],    [currws {word2}], 'update',s.par,textIdentifier);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        index=index12(1:end-1);
        index2=index12(end);
        [~,answer1,s] = getProperty(s, index2, index);
        
        answer='';
        for j=1:wordset1.size,
            if j==1
                answer = strcat(answer,answer1{j});
            else
                answer = strcat(answer,';',answer1{j});
            end
        end
        
    elseif strcmpi(singlemultiple,'properties')
        word1    = command.get('word1');
        word2    = command.get('word2');
        [s, index] =getSfromDB(initSpace(command),documentlanguage,document,{word1 word2},{word1 word2},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        [~, answer,s] = getProperty(s, index(1), index(2));
        answer=answer{1};
    end
disp('d');
    m = java.util.HashMap;
    m.put('answer',answer);
    m.put('refkey',refkey);
    meexcel.setCommand(m);
    %end
catch err
    m = java.util.HashMap;
    answer='Error during calculation';
    m.put('answer',answer);
    m.put('refkey',refkey);
    meexcel.setCommand(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
end

function answer=getCommandClusterspace(meexcel,command,d);

try
    wordset          = command.get('wordset');
    %if isempty(wordset) == false
    %                        if not(isempty(wordset))
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    refkey  = command.get('refkey');
    clusteramount    = command.get('amount');
    clustercategory  = command.get('clustername');
    refwordset       = command.get('refwordset');
    prefix           = command.get('prefix');
    %       end
    
    s=initSpace(command);
    s.par.db2space=1;
    s.par.user=command.get('userIdentifier');%'USER IS A MISSING INPUT HERE'
    %s.filename=getSpaceName(documentlanguage);
    s.languagefile=getSpaceName(documentlanguage);
    
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    
    if isempty(clustercategory) == false
        clustercategory = strcat('_',clustercategory);
    else
        clustercategory = '';
    end
    clusteramount   = str2double(clusteramount);
    setword = {};
    refword = {};
    textword = {};
    myindex = [];
    
    for j=1:wordset.size,
        setword{j} = wordset.get(j-1);
        refword{j} = strcat(prefix,refwordset.get(j-1));
        textword{j}='_text';
    end
    [s, myindex] =getSfromDB(s,documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        [s info]=clusterSpace(s,myindex(selection),clusteramount,clustercategory);
    else
        [s info]=clusterSpace(s,myindex,clusteramount,clustercategory);
    end
    m = java.util.HashMap;
    answer=info.results;
    m.put('results', answer);
    m.put('infoy', mat2str(info.y));
    m.put('refkey',refkey);
    meexcel.setClusterspace(m);
    %end
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setClusterspace(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
end


function answer=getCommandPlotspace(meexcel,command,d);

try
    wordset  = command.get('wordset');
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    refkey  = command.get('refkey');
    
    xaxel    = command.get('xaxel');
    yaxel  = command.get('yaxel');
    
    refwordset  = command.get('refwordset');
    prefix  = command.get('prefix');
    %end
    
    
    s=initSpace(command);
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    
    setword = {};
    refword = {};
    textword = {};
    for j=1:wordset.size,
        setword{j} = wordset.get(j-1);
        refword{j} = strcat(prefix,refwordset.get(j-1));
        textword{j}='_text';
    end
    [s, index] =getSfromDB(initSpace(command),documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    
    data{1}=index;
    
    [s, indexAxel] =getSfromDB(initSpace(command),documentlanguage,document,{'_reference1','_reference2'},{xaxel,yaxel},'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        if isempty(yaxel) == false
            [h s]=plotSpace(s,data(selection),indexAxel(1),indexAxel(2));
        else
            [h s]=plotSpace(s,data(selection),indexAxel(1));
        end
    else
        if isempty(yaxel) == false
            [h s]=plotSpace(s,data,indexAxel(1),indexAxel(2));
        else
            [h s]=plotSpace(s,data,indexAxel(1));
        end
    end
    saveas(h,strcat(d.download_plot_dir,refkey,'.png'));%Saves the figure to an .eps file!
    m = java.util.HashMap;
    answer=strcat(d.d.download_plot_url,refkey,'.png');
    m.put('results', answer);
    m.put('refkey',refkey);
    meexcel.setPlotspace(m);
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setPlotspace(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
end
%end plotspace function


function answer=getCommandPlotWordcount(meexcel,command,d);

try
    wordset  = command.get('wordset');
    
    singlemultiple = command.get('singlemultiple') ;
    refkey  = command.get('refkey')  ;
    refwordset       = command.get('refwordset');
    prefix           = command.get('prefix');
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    
    errormessage='';
    
    s=initSpace(command);
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    plotwordparam = command.get('keywordsplot');
    figuretypeparam = command.get('figuretype');
    figuretype = 1:7; %set defaualt
    if isempty(figuretypeparam) == false
        figuretype = loadjson(figuretypeparam);
    end
    
    s.par.figureType=figuretype;
    
    s.par.plotOnSemanticScale=0;
    
    if plotwordparam == '1'
        s.par.plotwordCountCorrelation=0;
    elseif plotwordparam == '2'
        s.par.plotwordCountCorrelation=1;
    elseif plotwordparam == '3'
        s.par.plotOnSemanticScale=1;
        s.par.plotwordCountCorrelation=0;
    end
    setword={};
    refword={};
    textword={};
    index=[];
    for j=1:wordset.size,
        setword{j} = wordset.get(j-1);
        refword{j} = strcat(prefix,refwordset.get(j-1));
        textword{j}='_text';
    end
    [s, index] =getSfromDB(initSpace(command),documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if strcmpi(singlemultiple,'SINGLEVALUE')
        axes={strcat('_',lower(command.get('instancex'))), strcat('_',lower(command.get('instancey')))};
        [s, indexAxel] =getSfromDB(initSpace(command),documentlanguage,document,{'_reference1','_reference2'},axes,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        
        if isempty(selectioncriteria) == false
            x1= {};
            for j=1:selectioncell.size,
                x1{j}=selectioncell.get(j-1);
            end
            x=str2double(x1);
            formula=selectioncriteria;%Choice formula to select
            eval(['selection=find(' formula ');']);
            if isempty(command.get('instancey')) == false
                [s h out1]=plotWordcount(s,index(selection),indexAxel(1),indexAxel(2)); %wordset1=words to plot, wordd1=propery defining median split on x-axel, wordd2=propery defining median split on y-axel,
            else
                [s h out1]=plotWordcount(s,index(selection),indexAxel(1));%wordd1.index); %wordset1=words to plot, wordd1=propery defining median split on x-axel, wordd2=propery defining median split on y-axel,
            end
        else
            if isempty(command.get('instancey')) == false
                [s h out1]=plotWordcount(s,index,indexAxel(1),indexAxel(2)) ;%wordset1=words to plot, wordd1=propery defining median split on x-axel, wordd2=propery defining median split on y-axel,
            else
                [s h out1]=plotWordcount(s,index,indexAxel(1)); %wordset1=words to plot, wordd1=propery defining median split on x-axel, wordd2=propery defining median split on y-axel,
            end
        end
    elseif strcmpi(singlemultiple,'MULTIPLEVALUE')
        %plotWordCount can also be called with the xdata and ydata as input (given
        %that either one of them has a lenght longer than 1)
        xaxel  = command.get('xaxel');
        yaxel  = command.get('yaxel');
        xdata = {};
        ydata = {};
        for j=1:xaxel.size,
            xdata{j}=str2double(xaxel.get(j-1));
        end
        xdata=cell2mat(xdata);
        if isempty(yaxel) == false
            for j=1:yaxel.size,
                ydata{j}=str2double(yaxel.get(j-1));
            end
            ydata=cell2mat(ydata);
        end
        if isempty(selectioncriteria) == false
            x1= {};
            for j=1:selectioncell.size,
                x1{j}=selectioncell.get(j-1);
            end
            x=str2double(x1);
            formula=selectioncriteria;%Choice formula to select
            eval(['selection=find(' formula ');']);
            if isempty(yaxel) == false
                [s h out1 out2]=plotWordcount(s,index(selection),xdata(selection),ydata(selection));
            else
                [s h out1]=plotWordcount(s,index(selection),xdata(selection));
            end
        else
            if isempty(yaxel) == false
                [s h out1 out2]=plotWordcount(s,index,xdata,ydata);
            else
                [s h out1]=plotWordcount(s,index,xdata);
            end
        end
    end
    
    for i=1:length(h)
        saveas(h(i),strcat(d.download_plot_dir,refkey,num2str(i),'.png'));%Saves the figure to an .eps file!
        saveas(h(i),strcat(d.download_plot_dir,refkey,num2str(i),'.fig'));
    end
    
    plotUrlStr = '';
    for j=1:length(h)-1
        plotUrlStr = strcat(plotUrlStr, d.download_plot_url,refkey,num2str(j),'.png|');
    end
    plotUrlStr = strcat(plotUrlStr, d.download_plot_url,refkey,num2str(j+1),'.png');
    
    plotText = '';
    for j=1:length(h)-1
        plotText = strcat(plotText, out1.figureText{h(j)},'|');
    end
    plotText = strcat(plotText, out1.figureText{h(j+1)});
    
    
    m = java.util.HashMap;
    results = out1.results;
    if isempty(yaxel) == false
        results = strcat(results,'|',out2.results);
    end
    
    answer = strcat(plotUrlStr,'||',results,'||',plotText);
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setPlotWordcount(m);
    %end
catch err
    m = java.util.HashMap;
    if isempty(errormessage) == false
        answer=strcat('Error: ',errormessage,' unknown word');
        m.put('results',answer);
    else
        answer='Error during calculating';
        m.put('results',answer);
    end
    m.put('refkey',refkey);
    meexcel.setPlotWordcount(m);
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
end
%end plotwordcount function

function answer=getCommandSemantictestpropertymany(meexcel,command,d);

try
    datas1    = command.get('datas1');
    clear('data');
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    refkey  = command.get('refkey');
    
    properties1    = command.get('properties1');
    refdatas1    = command.get('refdatas1');
    labels1    = command.get('labels1');
    datas2    = command.get('datas2');
    properties2    = command.get('properties2');
    refdatas2    = command.get('refdatas2');
    labels2    = command.get('labels2');
    
    prefix      = command.get('prefix');
    %end
    s=initSpace(command);
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    
    setword1 = {};
    refword1 = {};
    textword1 = {};
    setindex1 = [];
    for j=1:datas1.size,
        setword1{j} = datas1.get(j-1);
        refword1{j} = strcat(prefix,refdatas1.get(j-1));
        textword1{j}='_text';
    end
    
    [s, setindex1]=getSfromDB(initSpace(command),documentlanguage,document,refword1,setword1,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        data{1}=setindex1(selection);
    else
        data{1}=setindex1;
    end
    setword2 = {};
    refword2 = {};
    textword2 = {};
    setindex1 = [];
    for j=1:datas2.size,
        setword2{j} = datas2.get(j-1);
        refword2{j} = strcat(prefix,refdatas2.get(j-1));
        textword2{j}='_text';
    end
    [s, setindex1]=getSfromDB(initSpace(command),documentlanguage,document,refword2,setword2,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        data{2}=setindex1(selection);
    else
        data{2}=setindex1;
    end
    setproperties = {};
    setlabels = {};
    setproperties{1} = properties1;
    setproperties{2} = properties2;
    setlabels{1} = labels1;
    setlabels{2} = labels2;
    for k=3:20,
        dataset=command.get(strcat('datas',int2str(k)));
        refdataset=command.get(strcat('refdatas',int2str(k)));
        if isempty(dataset) == false
            setword = {};
            refword = {};
            textword = {};
            setindex = [];
            for j=1:dataset.size,
                setword{j} = dataset.get(j-1);
                refword{j} = strcat(prefix,refdataset.get(j-1));
                textword{j}='_text';
            end
            [s, setindex1]=getSfromDB(initSpace(command),documentlanguage,document,refword,refword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
            if isempty(selectioncriteria) == false
                x1= {};
                for j=1:selectioncell.size,
                    x1{j}=selectioncell.get(j-1);
                end
                x=str2double(x1);
                formula=selectioncriteria;%Choice formula to select
                eval(['selection=find(' formula ');']);
                data{k}=setindex1(selection);
            else
                data{k}=setindex1;
            end
            
            setproperties{k} = command.get(strcat('properties',int2str(k)));
            setlabels{k} = command.get(strcat('labels',int2str(k)));
        else
            break;
        end
    end
    property=setproperties;label=setlabels;
    datas2=data;property2=property;label2=label;
    [answer out]=semanticTestPropertyMany(s,data,property,label,datas2,property2,label2);
    
    m = java.util.HashMap;
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setSemantictestpropertymany(m);
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setSemantictestpropertymany(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
end
%end semantictestproperty function

function answer=getCommandSemantictest(meexcel,command,d);

try
    wordset1    = command.get('wordset1');
    document=command.get('documentid');
    refkey  = command.get('refkey');
    documentlanguage=command.get('documentlanguage');
    wordset2    = command.get('wordset2');
    pairedsemantictest     = command.get('pairedsemantictest') ;
    refwordset1    = command.get('refwordset1');
    refwordset2    = command.get('refwordset2')  ;
    prefix      = command.get('prefix') ;
    
    s=initSpace(command);
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    
    setword1 = {};
    setword2 = {};
    refword1 = {};
    refword2 = {};
    textword1 = {};
    textword2 = {};
    setindex1 = [];
    setindex2 = [];
    
    for j=1:wordset1.size,
        setword1{j} = wordset1.get(j-1);
        refword1{j} = strcat(prefix,refwordset1.get(j-1));
        textword1{j}='_text';
    end
    for j=1:wordset2.size,
        setword2{j} = wordset2.get(j-1);
        refword2{j} = strcat(prefix,refwordset2.get(j-1));
        textword2{j}='_text';
    end
    
    [s, setindex1] =getSfromDB(s,documentlanguage,document,refword1,setword1,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    [s, setindex2] =getSfromDB(s,documentlanguage,document,refword2, setword2,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if isempty(pairedsemantictest) == false && pairedsemantictest=='1'
        s.par.match_paired_test_on_subject_property=1;
    else
        s.par.match_paired_test_on_subject_property=0;
    end
    
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');'])
        if s.par.match_paired_test_on_subject_property
            group1=1:length(setindex1(selection));%User input, with a length that must macth the first set of indexes
            group2=1:length(setindex2(selection));%User input, with a length that must macth the second set of indexes
            [out,s]=semanticTest(s,setindex1(selection),setindex2(selection),'','',group1,group2);
        else
            [out,s]=semanticTest(s,setindex1(selection),setindex2(selection));
        end
    else
        if s.par.match_paired_test_on_subject_property
            group1=1:length(setindex1);%User input, with a length that must macth the first set of indexes
            group2=1:length(setindex2);%User input, with a length that must macth the second set of indexes
            [out,s]=semanticTest(s,setindex1,setindex2,'','',group1,group2)
        else
            [out,s]=semanticTest(s,setindex1,setindex2);
        end
    end
    
    m = java.util.HashMap;
    answer=out.results;
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setSemantictest(m);
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setSemantictest(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
end


function answer=getCommandKeywordstest(meexcel,command,d);

try
    wordset1    = command.get('wordset1');
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    refkey  = command.get('refkey');
    
    wordset2    = command.get('wordset2');
    refwordset1    = command.get('refwordset1');
    refwordset2    = command.get('refwordset2') ;
    
    prefix      = command.get('prefix')  ;
    correction  = command.get('correction') ;
    %        end
    
    s=initSpace(command);
    selectioncriteria = command.get('selectioncriteria');
    selectioncell = command.get('selectioncell');
    
    
    if isequal(correction,'NONE')
        s.par.keywordCorrectionType=2;%=2 not corrected
    elseif isequal(correction,'HOLMES')
        s.par.keywordCorrectionType=1;%=1 Holmes correction,
    elseif isequal(correction,'BONFERRONI')
        s.par.keywordCorrectionType=0;%=0 Bonferroni correction,
    end
    setword1 = {};
    setword2 = {};
    refword1 = {};
    refword2 = {};
    textword1 = {};
    textword2 = {};
    setindex1 = [];
    setindex2 = [];
    for j=1:wordset1.size,
        setword1{j} = wordset1.get(j-1);
        refword1{j} = strcat(prefix,refwordset1.get(j-1));
        textword1{j}='_text';
    end
    [s, setindex1] =getSfromDB(initSpace(command),documentlanguage,document,refword1,setword1,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    if wordset2.size == 0
        setindex2=NaN;
    else
        for j=1:wordset2.size,
            setword2{j} = wordset2.get(j-1);
            refword2{j} = strcat(prefix,refwordset2.get(j-1));
            textword2{j}='_text';
        end
        [s, setindex2] =getSfromDB(initSpace(command),documentlanguage,document,refword2,setword2,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    end
    
    if isempty(selectioncriteria) == false
        x1= {};
        for j=1:selectioncell.size,
            x1{j}=selectioncell.get(j-1);
        end
        x=str2double(x1);
        formula=selectioncriteria;%Choice formula to select
        eval(['selection=find(' formula ');']);
        [out s]=keywordsTest(s,setindex1(selection),setindex2(selection));
    else
        [out s]=keywordsTest(s,setindex1,setindex2);
    end
    m = java.util.HashMap;
    answer=out.results;
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setKeywordstest(m);
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setKeywordstest(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
    
end
%wordstest function


function answer=getWordnorms(meexcel,command,d);
try
    norm_text = command.get('norm_text');
    documentlanguage = command.get('documentlanguage');
    name = command.get('name');
    
    str='';
    refkey = command.get('refkey');
    documentlanguage=command.get('documentlanguage');
    norm_subtraction_text = command.get('norm_subtraction_text');
    
    ref=[];
    word=[];
    word{1}=norm_text;
    word{2}=norm_subtraction_text;
    ref{1}=fixpropertyname(name);
    ref{2}=[fixpropertyname(name) 'subtract'];
    document='norms';
    [s, index]=getSfromDB(initSpace(command),documentlanguage,document,ref,word,'update');%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    
    comment = command.get('comment');
    %s.par.public = command.get('public_access');
    s.par.public = 1; %always save publicly, we manage it on front side
    s.par.db2space=1;
    [s N answer]=addNorm(s,name,norm_text,comment,norm_subtraction_text,s.par.public);
    m = java.util.HashMap;
    m.put('results', answer);
    meexcel.setWordnorms(m,refkey);
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setWordnorms(m,refkey);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet demo ', getReport(err)));
    excelServerErrors;
end
%wordnorm end

function answer=getPropertyCommand(meexcel,command,d);
try
    documentlanguage=command.get('documentlanguage');
    
    %if isempty(documentlanguage) == false
    document = command.get('documentSpace');
    refkey  = command.get('refkey');
    
    s=initSpace(command);
    rowdata = command.get('data');
    rowidentifier = command.get('identifier');
    rowdatalabel = command.get('datalabel');
    
    data = cell(rowdata);
    identifier = cell(rowidentifier);
    datalabel=cell(rowdatalabel);
    
    [s, index] =getSfromDB(initSpace(command),documentlanguage,document,identifier,data,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    
    m = java.util.HashMap;
    answer='saved successfully';
    m.put('answer',answer);
    m.put('refkey',refkey);
    meexcel.setPropertyCommand(m);
    %end
catch err
    m = java.util.HashMap;
    answer='Error during calculating';
    m.put('answer',answer);
    m.put('refkey',refkey);
    meexcel.setPropertyCommand(m);
    disp(getReport(err));
    fprintf(d.fid, '%s\n', getReport(err));
    excelServerErrors;
end
%end setProperty function


function answer=getCommand3wordsSemantic(meexcel,command,d);
global figureNote
try
    wordset  = command.get('wordset');
    
    %if isempty(wordset) == false
    refwordset = command.get('refwordset');
    refkey  = command.get('refkey');
    document=command.get('documentid');
    documentlanguage=command.get('documentlanguage');
    errormessage='';
    
    s=initSpace(command);
    prefix=command.get('prefix');
    plottype=command.get('plotType');
    plotCloudType=command.get('plotCloudType');
    plotCluster=command.get('plotCluster');
    plotWordcloud=command.get('plotWordcloud');
    plotTestType=command.get('plotTestType');
    xaxel=command.get('xaxel');
    yaxel=command.get('yaxel');
    zaxel=command.get('zaxel');
    refxaxel=command.get('refxaxel');
    refyaxel=command.get('refyaxel');
    refzaxel=command.get('refzaxel');
    
    setword={};
    refword={};
    textword={};
    index=[];
    for j=1:wordset.size,
        setword{j} = wordset.get(j-1);
        refword{j} = strcat(prefix, refwordset.get(j-1));
        textword{j}='_text';
    end
    [s, index] =getSfromDB(s,documentlanguage,document,refword,setword,'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    
    %number calculation
    numbers = []; %default single dimension
    xdata = {};
    ydata = {};
    zdata = {};
    if isempty(xaxel) == false
        for j=1:xaxel.size,
            xdata{j}=str2double(xaxel.get(j-1));
        end
    end
    xdata=cell2mat(xdata);
    
    if isempty(yaxel) == false
        for j=1:yaxel.size,
            ydata{j}=str2double(yaxel.get(j-1));
        end
    end
    ydata=cell2mat(ydata);
    
    if isempty(zaxel) == false
        for j=1:zaxel.size,
            zdata{j}=str2double(zaxel.get(j-1));
        end
    end
    zdata=cell2mat(zdata);
    
    if isempty(xdata) == false
        numbers = {};
        numbers{1} = xdata;
    end
    
    if isempty(ydata) == false
        numbers{2} = ydata;
    end
    if isempty(zdata) == false
        numbers{3} = zdata;
    end
    
    
    s.par.plotCloudType=plotCloudType;
    s.par.plotCluster=str2num(plotCluster);
    s.par.plotWordcloud=str2num(plotWordcloud);
    s.par.plotTestType=plotTestType;
    for i=1:plotTestType.size
        s.par.plotTestType=plotTestType.get(i-1);
        par{i}=s.par;
    end
    
    [out1,h,s]=plotWordCloud(s,index,numbers,par);
    figureNote = out1.figureNote;
    %fprintf('PLEASE PRINT THIS TEXT ON THE CELL AFTER THE FIGURE!!!! \nIT IS NOT ACCEPTABLE THAT A CHANGE LIKE THIS SHOULD TAKE SO LONG TIME.\nIT REALY STOPS SEVERLA PROJECT THAT THIS IS NOT WORKING!!!!!\n%s\n',figureNote)
    
    for i=1:length(h)
        figure(h(i));
        hgx(h(i),strcat(d.download_plot_dir, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(i), '.png'));%Saves the figure to an .eps file!
        hgx(h(i),strcat(d.download_plot_dir, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(i), '.fig'));%Saves the figure - By Chintan
    end
    
    plotUrlStr = '';
    plotFigUrlStr = ''; %By Chintan
    j=0;
    if length(h) > 1
        for j=1:length(h)-1
            plotUrlStr = strcat(plotUrlStr, d.download_plot_url, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(j), '.png|');
            plotFigUrlStr = strcat(plotUrlStr, d.download_plot_url, refkey, plottype, plotCloudType, num2str(plotCluster), num2str(j), '.fig|'); %By Chintan
        end
    end
    plotUrlStr = strcat(plotUrlStr, d.download_plot_url, refkey,plottype, plotCloudType, num2str(plotCluster), num2str(j+1),'.png');
    plotUrlStr = strcat(plotUrlStr, '~',out1.pSemanticScale);
    
    % Added by Chintan for fig file
    plotFigUrlStr = strcat(plotFigUrlStr, d.download_plot_url, refkey,plottype, plotCloudType, num2str(plotCluster), num2str(j+1),'.fig');
    plotFigUrlStr = strcat(plotFigUrlStr, '~',out1.pSemanticScale);
    
    m = java.util.HashMap;
    answer=plotUrlStr;
    m.put('results',answer);
    m.put('refkey',refkey);
    m.put('figUrl', plotFigUrlStr); % By Chintan
    m.put('figureNote', figureNote); % By Chintan
    meexcel.setCommand3wordsSemantic(m);
    %end
catch err
    m = java.util.HashMap;
    if isempty(errormessage) == false
        answer=strcat('Error: ',errormessage,' unknown word');
        m.put('results',answer);
    else
        answer='Error during calculating';
        m.put('results',answer);
    end
    m.put('refkey',refkey);
    meexcel.setCommand3wordsSemantic(m);
    fprintf(d.fid, '%s\n', strcat(datestr(now),'  in sheet ',document,' ', getReport(err)));
    excelServerErrors;
    
end
%end 3woords semantic


function answer=getCommandCreateSpace(meexcel,command,d);
try
    wordset = command.get('createSpace');
    if not(isempty(wordset))
        refkey  = command.get('refkey');
        documentlanguage=command.get('documentlanguage');
        spaceName=command.get('spaceName');
        
        %Make the space file
        par=getPar;
        par.documentlanguage=documentlanguage;
        par.languageCode=documentlanguage; %CHINTAN ADD LANGUAGE CODE HERE, i.e. 'en'
        fprintf('Creating space from file: %s, with language=%s\n',spaceName,documentlanguage)
        s=createSpace(spaceName,'','',par);
        fprintf('Saving space to database: %s\n',documentlanguage)
        i=findstr(s.filename,'/');
        if length(i)>0 i=i(end)+1;else i=1;end
        spaceToDb(s.filename(i:end)); %Saves the space in the database
        
        m = java.util.HashMap;
        answer=sprintf('Space created\n%s',s.spaceInfo);
        m.put('results', answer);
        m.put('refkey',refkey);
        meexcel.setCreateSpace(m);
        if length(answer)>100;answer=answer(1:100);end;%Make the output shorter, to look nice on the prinout below!
    end
catch err
    m = java.util.HashMap;
    answer='Error during calculating of createSpace';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setCreateSpace(m);%It this needed?
    disp(getReport(err));
end
%end createSpace function


function answer=getPredictionDEtail(meexcel,command,d);
try
    predictionModel = command.get('predictionModel');
    if not(isempty(predictionModel))
        s=initSpace(command);
        refkey  = command.get('refkey');
        %predictionModel=predictionModel;
        textReference=command.get('textReference');
        s.par.getPropertyShow= command.get('getPropertyShow');
        documentlanguage = 'en';
        document = 'WDNEWPRED';
        disp(document);
        s.par.getPropertyShow= command.get('getPropertyShow');
        [s, index2] =getSfromDB(s,documentlanguage,document,textReference,predictionModel,'update',s.par);
        [~,answer,s]=getProperty(s,predictionModel,textReference);
        disp(answer);
        m = java.util.HashMap;
        m.put('results', answer);
        m.put('refkey',refkey);
        meexcel.setPredectionDetail(m);
    end
catch err
    m = java.util.HashMap;
    answer='Error during calculation';
    m.put('results',answer);
    m.put('refkey',refkey);
    meexcel.setPredectionDetail(m);%It this needed?
    disp(getReport(err));
end
%end getPredictionDEtail function

function cell=LinkedList2cell(LinkedList)
cell=[];
for i=1:LinkedList.size
    cell{i}=LinkedList.get(i-1);
end


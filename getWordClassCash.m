function [info s]=getWordClassCash(s,i,context,byWordCash)
if nargin<3
    context=[];
end
if nargin<4
    byWordCash=s.par.NgramPOS;
end
if not(isempty(context)) %Use string input, no index
    info.context=context;
    [info s]=getWordClassCash2(s,info,byWordCash,[]);
elseif isfield(s.info{i},'wordclass') & not(byWordCash) %Use cashed data, buy not while useing Google N-gram 
    info=s.info{i};
else %
    [info s]=getWordClassCash2(s,s.info{i},byWordCash,i);
    s.info{i}=info;
end

end

function [info s]=getWordClassCash2(s,info,byWordCash,i)
persistent hunposWorks
if isempty(i)
    context=info.context;
else
    context=getText(s,i);
end
if isfield(info,'index')
    index=info.index;
else
    [index t]=text2index(s,context);
end

ok=0;
if byWordCash | not(hunposWorks) %Use Google Ngram classifier
    if isfield(s,'wordclassHunpos')
        missing=(isnan(index) | index>length(s.wordclassHunpos)) | index==0;
        info.wordclass(missing)=length(s.classlabel)+1;
        info.wordclass(not(missing))=s.wordclassHunpos(index(not(missing)));
        ok=1;
    elseif isfield(s,'wordclass')
        missing=(isnan(index) | index>length(s.wordclass)) | index==0;
        info.wordclass(missing)=length(s.classlabel)+1;
        info.wordclass(not(missing))=s.wordclass(index(not(missing)));
        ok=1;
    else
    end
end
if not(ok)
    info.index=index;
    [index t]=text2index(s,context);
    localStat=getWordclass2(s,t);
    if isempty(hunposWorks)
        hunposWorks=not(isfield(localStat,'error'));
        if not(hunposWorks)
            fprintf('Hunpos has a problem, using Google n-grams instead\n');
        end
    end
    if isfield(localStat,'error')
        try
            fprintf('Could not calculate wordclass for %s, %s\n',context,localStat.error);
        catch
            fprintf('Could not calculate wordclass\n');
        end
        localStat.wordClass=zeros(1,length(context));
        index2=find(not(isnan(index)));
        try
            localStat.wordClass(index2)=s.wordclass(index2);
        end
    end
    info.wordclass=localStat.wordClass;
    indexOk=find(index>0);
    if 1
        if not(isfield(s,'wordclassHunpos')) | length(s.wordclassHunpos)<s.N; s.wordclass(s.N)=0;end
        s.wordclassHunpos(index(indexOk))=info.wordclass(indexOk);
    end
    if 0
        s.wordclass(index(indexOk))=info.wordclass(indexOk);
        if length(s.wordclass)<s.N; s.wordclass(s.N)=0;end
    end
    if isfield(localStat,'classlabel')
        s.classlabel=localStat.classlabel;
    end
end
end

% Classifies words into classes; according to language

% TODO: move tmp txt file away from nfs in case of compiled mode

function localStat = getWordclass2(s,t)%,par,localStat
if isempty(t)
    localStat.wordClass=[];
    localStat.subClass=[];
    return
end
index=find(strcmpi(t,'.'));
i1=1;
for i=1:length(index)+1
    if i>length(index)
        i2=length(t);
    else
        i2=index(i)-1;
    end
    if isempty(t(i1:i2)) & i2>0
        wordClass(i2)=0;
        subClass(i2)=0;
    else
        indexT=i1:i2;
        include=find(not(strcmpi(t(indexT),'"')) & not(strcmpi(t(indexT),'-')) & not(strcmpi(t(indexT),'%'))  & not(strcmpi(t(indexT),'`')) );%HUNPOS DOES NOT WORK WITH " NEEDS TO BE FIXED!
        try
            localStat = getWordclass3(s,t(indexT(include)));%,par,localStat
            wordClass(indexT(end))=0;
            subClass(indexT(end))=0;
            wordClass(indexT(include))=localStat.wordClass;
            subClass(indexT(include))=localStat.subClass;
        catch
            fprintf('Could not calculate wordclass for: %s\n',cell2string(t(indexT(include))));
            wordClass(indexT(include))=0;
            subClass(indexT(include))=0;
            %wordClass=zeros(1,length(context));
            %index2=find(not(isnan(index)));
            %wordClass(index2)=s.wordclass(index2);
            
        end
    end
    i1=i2+2;
end
localStat.wordClass=wordClass;
localStat.subClass=subClass;
end

function localStat = getWordclass3(s,t)%,par,localStat

if nargin<1
    s=getSpace;
end
try
    language =s.metaInfObj.langId;
catch
    if findstr(s.languagefile,'english')>0
        language=1804;
    else
        language = 6029;
    end
end
par=[];
par.debuggingMode=0;
par.sessObj=[];
par.envObj.library='';


if( isfield(par,'hunposIsInitialized') == 0 )
    par.hunposIsInitialized = 0;
end

if(par.debuggingMode > 1)
    fprintf(' --> GET WORD CLASSES FOR TEXT, Hunpos word classifier is used:\n');
end

if(isfield(par.sessObj,'taskId') == 0)
    par.sessObj.taskId = 1;%randi([1 10000],1,1);
end

% Each process/started program gets a random filename, so that
% processes with each other...localStat
persistent random_filename;

if( isempty(random_filename) )
    random_filename = 'tempwordclass';%num2str(par.sessObj.taskId);
end

% Get object containing all special chars
% (with index/string format for each pattern) etc
%codeWordObj = getCodeWordObj(s);

%%% Format text input to Hunpos %%%
%t = localStat.tokenizedText;
hunposFormattedText = '';
count = 0;
wholeWord = '';
for(k=1:length(t))
    if 1; %(localStat.isCodeWord(k) == 1 && localStat.isPartOfWholeWord(k) == 0 ...
        %   && localStat.isPartOfWholeWordAll(k) == 0)
        %t{k} = '';
        hunposFormattedText = [hunposFormattedText t{k} '\n'];
    elseif(localStat.isPartOfWholeWord(k) == 1)
        count = count + 1;
        if(localStat.isCodeWord(k) == 1)
            t{k} = ...
                char(codeWordObj.allCodeWordsTranslation(localStat.globalWordIndex(k) == ...
                codeWordObj.allCodeWordsIdx));
        end
        
        % Handle words separated by special chars (e.g., U.K.
        if(k < length(t) && localStat.isPartOfWholeWord(k+1) == 1)
            hunposFormattedText = [hunposFormattedText t{k}];
            wholeWord = [wholeWord t{k}]; % CRAP
        else
            % End of a whole word with special chars in it
            hunposFormattedText = [hunposFormattedText t{k} '\n'];
            wholeWord = [wholeWord t{k} '\n']; % CRAP
            
            % THIS IS UGLY SHIT ! BUT IT WORKS -- anders
            for(i=1:count-1)
                % Add same word a few more times
                hunposFormattedText = [hunposFormattedText wholeWord];
            end
            count = 0;
            wholeWord = '';
        end
    elseif(localStat.isPartOfWholeWordAll(k) == 1)
        count = count + 1;
        if(localStat.isCodeWord(k) == 1)
            t{k} = ...
                char(codeWordObj.allCodeWordsTranslation(localStat.globalWordIndex(k) == ...
                codeWordObj.allCodeWordsIdx));
        end
        
        % Handle words separated by special chars (e.g., U.K.
        if(k < length(t) && localStat.isPartOfWholeWordAll(k+1) == 1)
            hunposFormattedText = [hunposFormattedText t{k}];
            wholeWord = [wholeWord t{k}]; % CRAP
        else
            % End of a whole word with special chars in it
            hunposFormattedText = [hunposFormattedText t{k} '\n'];
            wholeWord = [wholeWord t{k} '\n']; % CRAP
            
            % THIS IS UGLY SHIT ! BUT IT WORKS -- anders
            for(i=1:count-1)
                % Add same word a few more times
                hunposFormattedText = [hunposFormattedText wholeWord];
            end
            count = 0;
            wholeWord = '';
        end
    else
        hunposFormattedText = [hunposFormattedText t{k} '\n'];
    end
end
hunposFormattedText=regexprep(hunposFormattedText,'\.','');

% Debug print-out:
% hunposFormattedText(length(hunposFormattedText)-40:length(hunposFormattedText))

%%% Set what wordclasses to return %%%
% 1 = hunpos will not return word classes
% 0 = word classes will be used
if(language == 6029) % ISO code XXXX = Swedish
    localStat.enabledClasses = ones(1,17);
    localStat.wordClassMaxNo = 17;
    localStat.subClassMaxNo = 13;
    % http://spraakbanken.gu.se/parole/
    % Set trainded model to use for this language
    model='suc2_parole_utf8.hunpos';
    % Definitions of wordClass labels for this langauge
    localStat.enabledClasses(1) = 1;    localStat.classlabel{1}='particip';
    localStat.enabledClasses(2) = 1;    localStat.classlabel{2}='adjective'; %1
    localStat.enabledClasses(3) = 1;    localStat.classlabel{3}='conjunction etc';
    localStat.enabledClasses(4) = 1;    localStat.classlabel{4}='determinerare';
    localStat.enabledClasses(5) = 1;    localStat.classlabel{5}='countingwords';
    localStat.enabledClasses(6) = 0;    localStat.classlabel{6}='nouns'; %0
    localStat.enabledClasses(7) = 0;    localStat.classlabel{7}='proper name'; %0
    localStat.enabledClasses(8) = 1;    localStat.classlabel{8}='pronouns';
    localStat.enabledClasses(9) = 1;    localStat.classlabel{9}='adverb';
    localStat.enabledClasses(10) = 1;   localStat.classlabel{10}='verb';
    localStat.enabledClasses(11) = 1;   localStat.classlabel{11}='prepositions';
    localStat.enabledClasses(12) = 1;   localStat.classlabel{12}='other';
    localStat.enabledClasses(13) = 1;   localStat.classlabel{13}='errors';
    localStat.enabledClasses(14) = 1;   localStat.classlabel{14}='partikel';
    localStat.enabledClasses(15) = 0;   localStat.classlabel{15}='foreign word';
    localStat.enabledClasses(16) = 1;   localStat.classlabel{16}='interpunktion';
    localStat.enabledClasses(17) = 1;   localStat.classlabel{17}='interjektion';
elseif(language == 9609 || 1804) % ISO code 9609 = English
    localStat.enabledClasses = ones(1,13);
    localStat.wordClassMaxNo = 13;
    localStat.subClassMaxNo = 13;
    % Set trainded model to use for this language
    model='english.model';
    % Definitions of wordClass labels for this langauge
    localStat.enabledClasses(1) = 1;    localStat.classlabel{1}='temporal';
    localStat.enabledClasses(2) = 1;    localStat.classlabel{2}='adjective'; %1
    localStat.enabledClasses(3) = 1;    localStat.classlabel{3}='conjunction etc';
    localStat.enabledClasses(4) = 1;    localStat.classlabel{4}='determinerare';
    localStat.enabledClasses(5) = 1;    localStat.classlabel{5}='countingwords';
    localStat.enabledClasses(6) = 0;    localStat.classlabel{6}='nouns'; %0
    localStat.enabledClasses(7) = 0;    localStat.classlabel{7}='proper name'; %0
    localStat.enabledClasses(8) = 1;    localStat.classlabel{8}='pronouns';
    localStat.enabledClasses(9) = 1;    localStat.classlabel{9}='adverb';
    localStat.enabledClasses(10) = 1;   localStat.classlabel{10}='verb';
    localStat.enabledClasses(11) = 1;   localStat.classlabel{11}='prepositions';
    localStat.enabledClasses(12) = 1;   localStat.classlabel{12}='other';
    localStat.enabledClasses(13) = 1;   localStat.classlabel{13}='errors';
else
    fprintf('ABORTING GET WORDCLASS: Hunpos for current language is not installed\n');
    localStat.wordClass = [];
    return;
end

if(par.hunposIsInitialized == 1)
    % Used so we can do predifined functions for different wordclasses.
    localStat.enabledClasses = par.enabledClasses;
end

%%% Run Hunpos and send results to random text file %%%
if 0 %(par.compiledMode == 1)
    % 1) Create unixCommand and execute external program
    unixCommand = ['echo -n > ' par.envObj.library random_filename...
        ' && printf "' hunposFormattedText '" >> ' par.envObj.library random_filename...
        ' && ' par.envObj.library 'hunpos-tag ' par.envObj.library model...
        ' < ' par.envObj.library random_filename];
else
    % Set program directory (based on operating system used)
    if ismac
        systemName='mac';
    else
        systemName='linux';
    end
    
    global rootPath
    
    extDir = [rootPath '/ext_programs/' systemName '/'];
    % 1) Create unixCommand and execute external program
    unixCommand = ['echo -n > ' par.envObj.library random_filename...
        ' && printf "' hunposFormattedText '" >> ' random_filename...
        ' && ' extDir 'hunpos-tag ' extDir model...
        ' < ' par.envObj.library random_filename];
    
    test = 0;
    if(test == 1)
        % 1) Create unixCommand and execute external program
        unixCommand = ['printf "' hunposFormattedText '" -v test30 && ' ...
            extDir 'hunpos-tag ' extDir model ' < ' par.envObj.library 'test30'];
    end
    
    % TESTING RAMDRIVE (reduces time for getting wordclasses)
    % extDir = '/tmp/ramdisk/';
    % unixCommand = [extDir 'hunpos-tag ' extDir model ' < ' extDir random_filename];
end
[status,output] = system(unixCommand);

%%% Error handling %%%
if(status == 1)
    % Try again to get results (fail-safe 1)
    [status,output] = system(unixCommand);
end

%%% Error handling %%%
if(status == 1)
    fprintf('Error in hunpos, may not be installed\n If Permission denied, try chmod +x hunpos-tag\n');
    localStat.wordClass = [];
    localStat.subClass = [];
    return;
else
    test = 0;
    while(test < 1)
        %%% Handle Hunpos results %%%
        % Remove bash-output not needed/wanted and format
        % classification as a list (with every second result/class code =
        % classification of previous word)
        resultList = string2cell(output(1,:));
        posIndex = find(strcmpi(resultList,'compiled')); % find where results begin
        
        if(posIndex ~= 0)
            break;
        else
            %%% Error handling %%%
            % Try again to get results (fail-safe 2)
            [status,output] = system(unixCommand);
            
            % Remove bash-output not needed/wanted and format
            % classification as a list (with every second line =
            % classification of previous word)
            resultList =string2cell(output(1,:));
            posIndex = find(strcmpi(resultList,'compiled')); % find where results begin
            test = test + 1;
            break;
        end
    end
    
    %%% Extract word/sub-classes from hunpos result %%%
    if isempty(posIndex)
        localStat.error=['Error: ' resultList{2}];
        return
    end
    resultList = resultList(posIndex(1)+1:length(resultList));
    localStat.wordClass = ...
        length(localStat.classlabel)*ones(1,length(t)); % Set default/missing to 'other'!
    localStat.subClass = localStat.wordClass;
    i = 1;
    r = length(t);
    j = 1;
    while(i <= r)
        if(isempty(t{i}) == 0)
            word = resultList{j};
            j = j + 1;
            
            hunposCode = resultList{j};
            j = j + 1;
            [localStat.wordClass(i),localStat.subClass(i)] = ...
                determineWC(hunposCode,word,language);
            i = i + 1;
        else
            % not a real word, special chars or other
            localStat.wordClass(i) = 0;
            localStat.subClass(i) = 0;
            i = i + 1;
        end
    end
end

t = [];
end

function [wordClass,subClass] = determineWC(hunposCode,word,language)
test = length(hunposCode);
subClass = 13;

if (language == 6029)
    if(test == 1)
        if strcmpi(hunposCode(1),'I')
            wordClass = 17; % interjektion
            
            % Extract subclass
            subClass = 13;
        else
            wordClass = 12; % O, missing...
            
            % Extract subclass
            subClass = 13;
        end
    else
        % language PAROLE codes http://spraakbanken.gu.se/parole/
        if strcmpi(hunposCode(1:2),'AF') || strcmpi(hunposCode(1:2),'AP')
            wordClass = 1; % particip ...
            
            % Extract subclass
            if(strcmpi(hunposCode(3:7),'00000'))
                subClass = 1; % particip f??rkortning
            elseif(strcmpi(hunposCode(3:7),'00PG0'))
                subClass = 2; % particip perfekt utrum/neutrum pluralis obest??md/best??md genitiv
            elseif(strcmpi(hunposCode(3:7),'0OPN0'))
                subClass = 3; % particip perfekt utrum/neutrum pluralis obest??md/best??md nominativ
            elseif(strcmpi(hunposCode(3:7),'00SGD'))
                subClass = 4; % particip perfekt utrum/neutrum singularis best??md genitiv
            elseif(strcmpi(hunposCode(3:7),'00SND'))
                subClass = 5; % particip perfekt utrum/neutrum singularis best??md nominativ
            elseif(strcmpi(hunposCode(3:7),'0MSGD'))
                subClass = 6; % particip perfekt maskulinum singularis best??md genitiv
            elseif(strcmpi(hunposCode(3:7),'0MSND'))
                subClass = 7; % particip perfekt maskulinum singularis best??md nominativ
            elseif(strcmpi(hunposCode(3:7),'0NSNI'))
                subClass = 8; % particip perfekt neutrum singularis obest??md nominativ
            elseif(strcmpi(hunposCode(3:7),'0USGI'))
                subClass = 9; % particip perfekt utrum singularis obest??md genitiv
            elseif(strcmpi(hunposCode(3:7),'0USNI'))
                subClass = 10; % particip perfekt utrum singularis obest??md nominativ
            elseif(strcmpi(hunposCode(3:7),'000G0'))
                subClass = 11; % particip presens utrum/neutrum singularis/pluralis obest??md/best??md genitiv
            elseif(strcmpi(hunposCode(3:7),'000N0'))
                subClass = 12; % particip presens utrum/neutrum singularis/pluralis obest??md/best??md nominativ
            else
                subClass = 13;
            end
        elseif strcmpi(hunposCode(1:2),'AQ')
            wordClass = 2; % adjective...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'C')
            wordClass = 3; % conjuction etc...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'D')
            wordClass = 4; % determinerare...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'M')
            wordClass = 5; % number...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'NC')
            wordClass = 6; % noun...
            
            % Extract subclass
            if(strcmpi(hunposCode(3:8),'USN@DS'))
                subClass = 1;
            elseif(strcmpi(hunposCode(3:8),'USG@DS'))
                subClass = 4;
            elseif(strcmpi(hunposCode(3:8),'USN@IS'))
                subClass = 3;
            elseif(strcmpi(hunposCode(3:8),'NPN@IS'))
                subClass = 2;
            elseif(strcmpi(hunposCode(3:8),'NSN@DS'))
                subClass = 5;
            else
                subClass = 13;
            end
        elseif strcmpi(hunposCode(1),'N')
            wordClass = 7; % proper name...
            
            % Extract subclass
            if strcmpi(hunposCode(3:8),'00N@0S')
                subClass = 1;
            elseif strcmpi(hunposCode(3:8),'00G@0S')
                subClass = 2;
            else
                subClass = 13;
            end
        elseif strcmpi(hunposCode(1:2),'PS') || strcmpi(hunposCode(1:2),'PF') || strcmpi(hunposCode(1:2),'PI') || strcmpi(hunposCode(1:2),'PH') || strcmpi(hunposCode(1:2),'PE')
            wordClass = 8; % pronouns...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'R') || strcmpi(hunposCode(1:2),'QS')
            wordClass = 9; % adverb...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'V')
            wordClass = 10; % verb...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'S')
            wordClass = 11; % preposition...
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'QC') || strcmpi(hunposCode(1:2),'PL')
            wordClass = 14; % partikel
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'XF')
            wordClass = 15; % Foreign word
            
            % Extract subclass
            subClass = 13;
        elseif strcmpi(hunposCode(1),'F')
            wordClass = 16; % interpunktion
            subClass = 13;
        else
            wordClass = 13;
            
            % Extract subclass
            subClass = 13;
        end
    end
elseif(language == 1804)
    % Codes as in http://www.comp.leeds.ac.uk/ccalas/tagsets/lob.html
    % Check if this is a common week/day/month entity etc
    
    if(isTemporalWord(word) == 1)
        wordClass = 1; % temporal ... 'TXX'
        subClass = 13;
        return;
    end
    
    if(test == 1)
        wordClass = 12; % F, I, O,  X (forigen) missing...
        subClass = 13;
    elseif(test >= 3)
        if strcmpi(hunposCode(1:2),'JJ')
            wordClass = 2; % adjective...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'CC') || strcmpi(hunposCode(1:2),'TO'))
            wordClass = 3; % conjuction etc...
        elseif (strcmpi(hunposCode(1:2),'DT') || strcmpi(hunposCode(1:3),'WDT') || strcmpi(hunposCode(1:3),'PDT') || strcmpi(hunposCode(1:2),'EX'))
            wordClass = 4; % determinerare...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'CD') || strcmpi(hunposCode(1:2),'OD'))
            wordClass = 5; % number...
            subClass = 13;
        elseif strcmpi(hunposCode(1:3),'NNP')
            wordClass = 7; % noun...
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'NN')
            wordClass = 6; % proper name...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'PR') || strcmpi(hunposCode(1:2),'WP'))
            wordClass = 8; % pronouns...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'RB') || strcmpi(hunposCode(1:3),'WRB') || strcmpi(hunposCode(1:2),'RP'))
            wordClass = 9; % adverb...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'VB') || strcmpi(hunposCode(1:2),'MD'))
            wordClass = 10; % verb...
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'IN')
            wordClass = 11; % preposition...
            subClass = 13;
        else
            wordClass = 12; % UH, LS  missing...
            subClass = 13;
        end
    else
        if strcmpi(hunposCode(1:2),'JJ')
            wordClass = 2; % adjective...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'CC') || strcmpi(hunposCode(1:2),'TO'))
            wordClass = 3; % conjuction etc...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'DT') || strcmpi(hunposCode(1:2),'EX'))
            wordClass = 4; % determinerare...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'CD') || strcmpi(hunposCode(1:2),'OD'))
            wordClass = 5; % number...
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'NN')
            wordClass = 6; % proper name...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'PR') || strcmpi(hunposCode(1:2),'WP'))
            wordClass = 8; % pronouns...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'RB') || strcmpi(hunposCode(1:2),'RP'))
            wordClass = 9; % adverb...
            subClass = 13;
        elseif (strcmpi(hunposCode(1:2),'VB') || strcmpi(hunposCode(1:2),'MD'))
            wordClass = 10; % verb...
            subClass = 13;
        elseif strcmpi(hunposCode(1:2),'IN')
            wordClass = 11; % preposition...
            subClass = 13;
        else
            wordClass = 12; % UH, LS  missing...
            subClass = 13;
        end
    end
else
    % TODO: ???
    wordClass = 0;
    subClass = 13;
end
end

function boolean = isTemporalWord(word)
boolean = 0;
cmp = cellstr(word);
weekDays = {'Monday';'Tuesday';'Wednesday';'Thursday';'Friday';'Saturday';'Sunday'...
    ;'Monday''s';'Tuesday''s';'Wednesday''s';'Thursday''s';'Friday''s'...
    ;'Saturday''''s';'Sunday''''s'};
if(sum(strcmpi(weekDays,cmp)))
    boolean = 1;
    return;
end

wAbbr = {'Mon';'Tue';'Wed';'Thu';'Fri';'Sat';'Sun'};
if(sum(strcmpi(wAbbr,cmp)))
    boolean = 1;
    return;
end

months = {'January';'February';'March';'April';'May';'June';'July';'August';'September';'October';'November';'December'};
if(sum(strcmpi(months,cmp)))
    boolean = 1;
    return;
end

mAbbr = {'Jan';'Feb';'Mar';'Apr';'Jun';'Jul';'Aug';'Sep';'Sept';'Oct';'Nov';'Dec'};
if(sum(strcmpi(mAbbr,cmp)))
    boolean = 1;
    return;
end
end
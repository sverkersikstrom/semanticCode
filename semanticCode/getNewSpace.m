function s=getNewSpace(filename,version,sLang);
if nargin<1
    s=getSpace;
    return
end
if nargin<2 version='';end

%Remove ending .mat in file name
filename=regexprep(filename,'\.mat','');

if not(exist([filename '.mat']))
    fprintf('\nLocate missing space-file: %s in %s\n',[filename '.mat'],pwd);
    i=findstr(filename,'/');
    if not(isempty(i))
        filename=[filename(i(end)+1:end)];
    end
    if not(exist([filename '.mat']))
        [file,PathName]=uigetfile2(['*'],['Please locate missing space-file:' char(13) filename]);
        filename=[PathName file];
        if file==0 | not(exist(filename))
            fprintf('\nCan not find file: %s, aborting!\n',filename);
            s=initSpace;
            return
        end
        filename=regexprep(filename,'\.mat','');
    end
end

fprintf('Reading %s file:\n',filename);

load([filename '.mat']);
if not(exist('s')==1)
    fprintf('Opening report: %s\n',filename);
    s=getReport([filename '.mat']);
    %fprintf('\n%s may not be a space file!\n',filename);
    %s=initSpace;
    return
end

if not(isfield(s,'data'))
    s.data=0;
end

s.filename=filename;

if s.data==1 %Load data-space
    fprintf('(data-space)');
    global spaceIsLoaded
    sLang=getSpace;
    if strcmp(version,'clearOldData') | isempty(sLang) | sLang.N==0 | not(isfield(sLang,'languagefile')) | not(strcmpi(s.languagefile,sLang.languagefile))
        sLang=getLanguageSpace(s);
    end
    %Merge sLang to the s space!
    s=mergeSpace(sLang,s);
    clear('sLang')
    s.datafile=filename;
    global spaceIsLoaded
    spaceIsLoaded=1;
else %Load language-space
    fprintf('(language-space)');
    filename2=which([filename '.mat']);
    if length(filename2)>0 filename=filename2;end
    filename=regexprep(filename,'\','/');
    i=findstr(filename,'/');
    if isempty(i)
        i=0;
        s.languagefilePath=pwd;
    else
        s.languagefilePath=filename(1:i(end));
    end
    s.filename=[ filename(i(end)+1:end)];
    s.languagefile=s.filename;
    s.path=pwd;
    s.datafile='';
    %try;s=rmfield(s,'datafile');end
    s.data=0;
    s.rand=rand;
end

s.par=getPar;
fprintf('done.\n');
[s.N, s.Ndim]=size(s.x);
s.handles=getHandles;
newReport_Callback([],[])

s=checkLanguageFile(s);
s.saved=1;
fprintf('%d words.\n',s.N);
s=getSpace('set',s);


function s=checkLanguageFile(s);

if std(s.x(1:s.N,s.Ndim))==0
    fprintf('Warning higher dimensions appears to have no variability!\n');
end

[s.N s.Ndim]=size(s.x);
if length(s.fwords)<s.N %Fix strange bug in Chinese file
    s.x=s.x(1:s.N,:);
    s.f=s.f(1:s.N);
    [s.N s.Ndim]=size(s.x);
end

if not(isfield(s,'xmean2')) | s.xmean2(1)==0  | isnan(mean(s.xmean2))
    fprintf('Creating s.xmean2\n')
    include=ones(1,s.N);
    s.xmean2=zeros(1,s.Ndim);
    fSum=0;
    for i=1:s.N
        if s.fwords{i}(1)=='_';
            include(i)=0;
        else
            f=s.f(i);
            tmp=s.x(i,:)*f;
            if not(isnan(mean(tmp)))
                fSum=fSum+f;
                s.xmean2=s.xmean2+tmp;
            end
        end
    end
    s.xmean2=s.xmean2/fSum;
    if not(isfield(s,'data')) s.data=1;end
    if s.data==0
        saveSpace(s,[s.languagefilePath s.filename],1);
    end
end

s.f=s.f/nansum(s.f);
if not(isfield(s,'info'))
    s.info{s.N}=[];
end
if not(isfield(s,'wordclass'))
    s.wordclass=zeros(1,s.N);
end


if word2index(s,s.fwords{min(length(s.fwords),s.N)})==s.N
    fprintf('Skipping indexing\n')
else
    s=mkHash(s,1);
end

i=word2index(s,'_liwcnon-fluencies');
if not(isnan(i)) %Fix weired bug in English space
    s.fwords{i}='_liwcnonfluencies';
end

%Add functions identifiers to the languagefile!
update=0;
if isnan(word2index(s,'_spaceInfo'))
    info=[];
    info.specialword=2;
    info.persistent=1;
    s=addX2space(s,'_spaceInfo',[],info,0,'Print information about the space');
end

s=spaceAddModels(s,1);

% update=isnan(word2index(s,'_translate'));
% if update %Move to other functions later
%     info.specialword=2;
%     info.persistent=1;
% end

update=isnan(word2index(s,'_concatenate'));
 
if update & s.data==0
    s=addFunctions2space(s);
    
    if not(isfield(s.info{1},'bigram'))
        s=calculate_bigram(s);
    end
    
    if 0
        try
            info.persistent=1;
            info.specialword=8;
            [tmp tmp  s]=getProperty(s,'_wordclass',1);%Sets s.classlabel
            for i=1:length(s.classlabel)
                s=addX2space(s,s.classlabel{i},[],info,0,['Words from wordclass: ' s.classlabel{i}]);
            end
            for i=1:length(s.classlabel)
                s=addX2space(s,[s.classlabel{i} 'probability'],[],info,0,['Ratio of wordclass: ' s.classlabel{i}]);
            end
        end
    end
    
    for i=1:s.N
        if not(isempty(s.fwords{i})) & regexp(s.fwords{i},'_liwc')==1
            fprintf('Initiating %s to LIWC type\n',s.fwords{i})
            s.info{i}.specialword=5;
        end
    end
    
    if s.data==0
        saveSpace(s,[s.languagefilePath s.filename],1);
    end
    %noUpdateCol=0;
end


function s=getLanguageSpace(s);
if not(isfield(s,'languagefilePath'))
    i=findstr(s.languagefile,'/');
    if not(isempty(i))
        s.languagefilePath=s.languagefile(1:i(end));
        s.languagefile=s.languagefile(i(end)+1:end);
    else
        s.languagefilePath='';
    end
end
if length(s.languagefilePath)>0
    file=[s.languagefilePath '/' s.languagefile];
else
    file=s.languagefile;
end
fprintf('\nReading language file:\n%s\n...',file);
if not(exist([regexprep(file,'.mat',''),'.mat'])) |  length(s.languagefile)==0
    i=findstr(file,'/');
    s.languagefile=[file(i(end)+1:end) ];
    if exist(s.languagefile)
        file=s.languagefile;
    else
        helptext=['Please locate missing language file: ' char(13) file];
        fprintf('%s\n',helptext);
        [s.languagefile,s.languagefilePath]=uigetfile('space*',helptext,'');
        file=[s.languagefilePath  s.languagefile];
    end
end
%languagefilePath=s.languagefilePath;
languagefile=s.languagefile;
load(file);
s.N=length(s.fwords);
s.keepInLanguageFile=ones(1,s.N);
s.languagefilePath=which(file);
i=findstr(s.languagefilePath,'/');
if not(isempty(i)) s.languagefilePath=s.languagefilePath(1:i(end));end
%s.languagefilePath=languagefilePath;
s.languagefile=languagefile;
if not(isfield(s,'hash'))
    s=mkHash(s,1);;
end


function s=addFunctions2space(s);
info=[];
info.specialword=2;
info.persistent=1;

s.par.fastAdd2Space=1;

s=addX2space(s,'_translate',[],info,0,'Translates text from a language to a language. Set languages codes in various settings');
s=addX2space(s,'_sort',[],info,0,'Sort several texts in the multiple input from low to high');
s=addX2space(s,'_concatenate',[],info,0,'Concatenates several texts in the multiple input to a single text in the first output');
s=addX2space(s,'_text2sentences',[],info,0,'Maps the text in the first input to single sentences in the multiple outpus');
s=addX2space(s,'_text2words',[],info,0,'Maps the text in the first input to single words in the multiple outpus');
s=addX2space(s,'_getcategoryid',[],info,0,'Get identifiers from the category specified in the variable par.getcategoryid');
s=addX2space(s,'_liwcall',[],info,0,'Calculates all LIWC categories in a text. If text is empty, list LIWC variables');
s=addX2space(s,'_text',[],info,0,'Text defining the semantic representation');
s=addX2space(s,'_context',[],info,0,'Text defining the semantic representation');
s=addX2space(s,'_associates',[],info,0,'Generates a list of words with most similiar semantic representations');
s=addX2space(s,'_furthestassociates',[],info,0,'Generates a list of words with most dissimiliar semantic representations');
s=addX2space(s,'_word',[],info,0,'Identfier or label of a text');
s=addX2space(s,'_identifier',[],info,0,'Identifier or label of a text');
s=addX2space(s,'_comment',[],info,0,'Prints this comment/description of a text');
s=addX2space(s,'_sentencelength',[],info,0,'Number of words per sentence, requires a _text');
s=addX2space(s,'_language',[],info,0,'Positive values indicates that the text has the same language as the space');

s=addX2space(s,'_dictionary',[],info,0,'Sorts words according to decreasing frequenceis in the text.');
s=addX2space(s,'_wildcardexpansion',[],info,0,'Expandes words including *, i.e. lov* exands to love.');
s=addX2space(s,'_figurenote',[],info,0,'Prints figure note to the most recent created figure.');
s=addX2space(s,'_listproperty',[],info,0,'Prints a list of variables associated to the identifier');
s=addX2space(s,'_listpropertydata',[],info,0,'Prints a list of variables  and associated values associated with the identifier');
s=addX2space(s,'_wordclass',[],info,0,'Wordclass of word, does not work for text');
s=addX2space(s,'_results',[],info,0,'Results from training of a model');
s=addX2space(s,'_variabilitypairwise',[],info,0,'Pairwise semantic distance');
s=addX2space(s,'_clusterdistance',[],info,0,'Mean distiance to cluster centroid, based on k-means clustering, k=2, and first 6 words');
s=addX2space(s,'_weight',[],info,0,'weight of wordcount');
s=addX2space(s,'_printidentifiers',[],info,0,'Print identifiers using wildcards; e.g., child* => children child');
s=addX2space(s,'_frequencyweightedmean',[],info,0,'Frequency weigthed value of all words in the space');
s=addX2space(s,'_semanticsimilarity',[],info,0,'Measure semanitc similiarity to the variable variableToCompareSemanticSimliarity');

s=addX2space(s,'_space',[],info,0,'Print values on all dimension in the space' );
s=addX2space(s,'_spacelabel',[],info,0,'Print labels on all dimension in the space' );
s=addX2space(s,'_nwords',[],info,0,'Number of words in the text');
s=addX2space(s,'_nwordsfound',[],info,0,'Number of words in text that also are found in the space');
s=addX2space(s,'_frequency',[],info,0,'Mean frequency of words [part per million]');
s=addX2space(s,'_logfrequency',[],info,0,'Mean log frequency of a word(s)');
s=addX2space(s,'_wordlength',[],info,0,'Mean number of character in word(s)');
s=addX2space(s,'_bigram',[],info,0,'Mean bigram frequency(ies)');

s=addX2space(s,'_typetokenratio',[],info,0,'Type / token ratio');
s=addX2space(s,'_coherence',[],info,0,'Calculates a sliding window of the semantic difference over the context' );
s=addX2space(s,'_varcoherence',[],info,0,'A number of tab seperated coherence measures; _cohfirst4	_cohlast4	_cohstdfirst4	_cohdistword1n	_meanswitch	_sumswitch	_cohnoswitch	_cohswitch	_clustersize	_identical	_samefirstchar _coh1	_coh2	_coh3	_coh4	_coh5	_coh6	_coh7	_coh8	_coh9	_coh10	_coh11	_coh12	_coh13	_coh14	_coh15' );
s=addX2space(s,'_variability',[],info,0,'Calculates variability of the for the context words' );

s=addX2space(s,'_p',[],info,0,'p-values in regression statistics');
s=addX2space(s,'_r',[],info,0,'correlation in regression statistics');
s=addX2space(s,'_n',[],info,0,'number of datapoints in regression statistics');
%s=addX2space(s,'_nmonth',[],info,0,'Number of words per month (Requires a set time-properity)');
%s=addX2space(s,'_nday',[],info,0,'Number of words per day (Requires a set time-properity)');
s=addX2space(s,'_randomword',[],info,'Picks a random word from the corpora');
s=addX2space(s,'_randomvector',[],info,0,'Picks a random vector in the space');
s=addX2space(s,'_rand',[],info,0,'Picks a random number between 0 and 1');
s=addX2space(s,'_change',[],info,0,'Measure the semantic distance between 10 words after/following current words');
s=addX2space(s,'_seqdist',[],info,0,'Average Semantic distance between word1-word2, word2-word3,....' );
s=addX2space(s,'_time',[],info,0,'time in numeric data' );
s=addX2space(s,'_date',[],info,0,'date, format yyyy-mm-dd HH:MM, e.g., 2012-03-10 12:32' );
%s=addX2space(s,'_previous',[],info,0,'Semantic similiarty between current word (i) and the previous word (i-1)' );
s=addX2space(s,'_NAN',[],info,0,'Dummy word');
s=addX2space(s,'_category',[],info,0,'Get cluster category number. Only applies to cluster identifiers.');
s=addX2space(s,'_neighbour',[],info,0,'Number of identifiers/words that are with a simantic simliarity above 0.8');
s=addX2space(s,'_textbyword',[],info,0,'Text, seperated by spaces, defining the semantic representation');
info.specialword=6;
for i=1:s.Ndim
    x=zeros(1,s.Ndim);
    x(i)=1;
    s=addX2space(s,['_dim' num2str(i)],x,info,0,['Dimension ' num2str(i)]);
end

s.par.fastAdd2Space=2;%Now store information in s!
s=addX2space(s);




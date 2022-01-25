function s=spaceAddModels(s,save)
if nargin<2
    save=0;
end

s=addFunctions2space(s);

update=isnan(word2index(s,'_predvalence'));
if not(s.data==0 & update) %& isempty(findstr(s.languagefile,'Facebook')))
    return
end

langcode='';
if length(s.par.languageCode)>0
    langcode=s.par.languageCode;
elseif isfield(s,'languageCode')
    langcode=s.languageCode;
else
    [space,langcode,languageNames]=getSpaceName(s.languagefile);
end
if length(langcode)==0
    fprintf('No language code found! Will not make LIWC, and training on Valence, Abstractness, and Familarity\n')
else
    if strcmpi(langcode,'rn'); langcode='ro';end
    if length(langcode)>2 & langcode(3)>='0' & langcode(3)<='9';langcode=langcode(1:2);end
    
    %Add training of valence, arousal and dominance
    %/Users/sverkersikstrom/Dropbox/semantic/English/English wordlists/ANEWsemantic.txt'
    global rootPath
    file=[rootPath '/DefaultTrainedModels.txt'];
    s=spaceAddTrain(s,file,save,langcode);
    
    %Add LIWC identifieras
    if isnan(word2index(s,'_liwcdeath'))
        fprintf('Reading LIWC data from the spaceEnglish file\n')
        spaceEnglish=getNewSpace('spaceEnglish');
        [~,categories,indexC]=getIndexCategory(5,spaceEnglish);
        info=[];
        info.persistent=1;
        info.specialword=5;
        s.par.fastAdd2Space=1;
        i1=1;
        for i=i1:length(indexC);
            fprintf('.')
            text1=getText(spaceEnglish,indexC(i),'_text');
            text1=regexprep(text1,' ',['. ']);
            textTranslated = gtranslate([],text1, langcode, 'en',[],1);
            info.context=regexprep(textTranslated,'\.','');
            x=text2space(s,textTranslated);
            s=addX2space(s,spaceEnglish.fwords{indexC(i)},x,info,0,spaceEnglish.info{indexC(i)}.comment);
        end
        s.par.fastAdd2Space=2;%Now store information in s!
        s=addX2space(s);
        %indexSave=word2index(s,spaceEnglish.fwords(indexC));
    end
    if save
        if s.data==0
            saveSpace(s,[s.languagefilePath s.filename],1);
        end
    end
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


function s=spaceAddTrain(s,file,save,langcode);

if not(exist(file))
    fprintf('Missing module file: %s\n',file);
else
    [words, data, dim, labels]=textread2(file,0);
    wordsDot=regexprep(cell2string(words(:,1)),' ','. ');
    wordsDot=wordsDot(2:end);
    textTranslatedDot = gtranslate([],wordsDot, langcode, 'en');
    wordsTranslated=textscan(textTranslatedDot,'%s','delimiter','.');
    wordsTranslated=wordsTranslated{1};
    if not(length(wordsTranslated)==length(words(:,1)))
        wordsTranslated=[];
        for i=1:length(words(:,1))
            if even(i,10); fprintf(':');end
            wordsTranslated{i} = gtranslate([],words{i,1}, langcode, 'en');
        end
    end
    indexTrans=word2index(s,wordsTranslated);
    
    propertySave=regexprep(labels,'_','');
    %indexSave=word2index(s,propertySave);
    for i=2:length(propertySave)
        propertySave{i}=['_pred' propertySave{i}];
        if isnan(word2index(s,propertySave{i}))
            y=data(:,i)';
            if not(length(y)==length(indexTrans))
                fprintf('Error: Missmatch length during adding models\n');
            end
            [s info]=train(s,y,propertySave{i},indexTrans);
            ok=word2index(s,propertySave{i});
            if not(isnan(ok))
                s.info{word2index(s,propertySave{i})}.persistent=1;
            end
        end
    end
    %info=[];
    %indexSave=word2index(s,propertySave);
end


function [s info xnorm]=predictionMake(s,words,y,propertySave,wordsIndex,group,numericalData,covariates,indexSubtract)
%predctionMake makes a prediction (linear regresson) on s.x(wordsIndex,:) to predict y, and outputs the information in the info structure.
%Optionally i groups the data in the group variable and adds extra prediction in the numericalData
if nargin<1
    s=getSpace('s');
end
if nargin<2
    [wordset s]=getWordFromUser(s,'Choose text identifier to predict from','_price_dp7');
    if wordset.N==0; return; end
    wordsIndex=wordset.index;
    words=wordset.word;
end

if not(isempty(s.par.trainModelName))
    propertySave={s.par.trainModelName};
elseif nargin<4
    propertySave='';
end

if nargin<3
    [propertyPredict s]=getWordFromUser(s,'Choice identifier(s) to predict','_doc*');
    if propertyPredict.N==0; return; end
    for i=1:length(propertyPredict.index)
        [yTmp, ~,~,s]=getProperty(s,propertyPredict.index(i),wordsIndex);
        y(:,i)=yTmp;
        if nargin<4
            propertySave{i}=fixpropertyname(['pred' s.par.trainModelName propertyPredict.word{i} s.par.variableToCreateSemanticRepresentationFrom ]);
        end
    end
end

if nargin<5
    wordsIndex=word2index(s,words);
end

if nargin<6 %Set group parameter from par.groupingProperty
    group=[];
end
if nargin<7
    numericalData=[];
end
if nargin<8
    covariates=[];
end
if nargin<9
    if strcmpi(get(s.handles.subtractSemanticRepresenationOnTrain,'Checked'),'on');
        [subtract s]=getWordFromUser(s,'Choose text identifier to subtract semantic representation from (must have the same lenght as the trained identifiers)','_price_dp7');
        indexSubtract=subtract.index;
    else
        indexSubtract=[];
    end
end
xnorm=[];

Ny=size(y);
if Ny(2)>1 & Ny(1)==length(wordsIndex) %Do multiple predictions

    if ischar(propertySave)
        propertySave=textscan(propertySave,'%s');
        propertySave=propertySave{1};
    end
    
    r='';
    s.par.trainPropertySave=propertySave;
    if s.par.variableToCreateSemanticRepresentationFromRepeted
        variableToCreateSemanticRepresentationFrom=textscan(s.par.variableToCreateSemanticRepresentationFrom,'%s');
        variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{1}';
    else
        variableToCreateSemanticRepresentationFrom={s.par.variableToCreateSemanticRepresentationFrom};
    end
    res='';
    resR=sprintf('Summary of r-values:\nTextvariabel\t');
    if nargin<4 
        resR=[resR cell2string(propertyPredict.word,char(9))];
    else
        resR=[resR cell2string(propertySave,char(9))];
    end
    for l=1:length(variableToCreateSemanticRepresentationFrom)
        s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{l};
        resR=[resR sprintf('\n%s\t',s.par.variableToCreateSemanticRepresentationFrom)];

        for i=1:Ny(2)
            if nargin<4
                propertySave{i}=fixpropertyname(['pred' s.par.trainModelName propertyPredict.word{i} s.par.variableToCreateSemanticRepresentationFrom ]);
            end
            s.par.i=i;
            if length(propertySave)<i propertySave{i}=['_prediction' num2str(i)];end
            fprintf('Training %d (of %d) on text %s %d (of %d): %s\n',i,length(propertySave),variableToCreateSemanticRepresentationFrom{l},l,length(variableToCreateSemanticRepresentationFrom),propertySave{i});
            [s info{i}]=predictionMake(s,words,y(:,i), propertySave{i},wordsIndex,group,numericalData,covariates,indexSubtract);
            p(i)=info{i}.p;
            corr(i)=info{i}.r; 
            resR=[resR sprintf('%.3f\t',info{i}.r)];
            pred(i,:)=info{i}.pred;
            r=[r info{i}.results];
        end
        s.par.i=0;
        res=[res sprintf('Summary statistics\n')];
        if s.par.trainSortOutput
            [tmp, index]=sort(corr,'descend');
        else
            index=1:length(corr);
        end
        
        f=fields(info{1});
        res=[res sprintf('Modelname\t')];
        for k=1:length(f)
            res=[res sprintf('%s\t', f{k})];
        end
        res=[res sprintf('\n')];
        
        
        for j=1:length(info)
            i=index(j);
            if not(isempty(info{i}))
                data(i,:)=info{i}.data;
                try
                    pred(i,:)=1.0*(info{i}.pred>info{i}.binaryThreshold);
                catch
                    pred(i,:)=NaN;
                end
                try
                    if not(isfield(info{i},'modelName'))
                        info{i}.modelName='';
                    end
                    res=[res sprintf('%s\t',info{i}.modelName)];
                catch
                    res=[res sprintf('%s\t','Missing')];
                end
                for k=1:length(f)
                    tmp=NaN;
                    try
                        tmp=eval(['info{i}.' f{k}]);
                        matris(i,k)=tmp;
                    catch
                        matris(i,k)=NaN;
                    end
                    if isnumeric(tmp) & not(isempty(tmp))
                        if strcmp(f{k},'p') %Four digits for p-values
                            if tmp(1)<.05/length(info)
                                sig='**';
                            elseif tmp(1)<.05
                                sig='* ';
                            else
                                sig='  ';
                            end
                            res=[res sprintf('%.4f %s\t',tmp(1),sig)];
                        elseif tmp(1)<.002
                            res=[res sprintf('%.7f\t',tmp(1))];
                        else
                            res=[res sprintf('%.3f\t',tmp(1))];
                        end
                    else
                        try
                            tmp=regexprep(tmp,char(13),' ');
                            tmp=regexprep(tmp,char(9),' ');
                            tmp=regexprep(tmp,char(10),' ');
                            if length(tmp)>150; tmp=tmp(1:150);end
                        catch
                            tmp='';
                        end
                        res=[res sprintf('%s\t',tmp)];
                    end
                end
                res=[res sprintf('\n')];
            end
        end
        res=[res sprintf('* p<.05 (uncorrected), ** p<.05 (Bonferroni)\n')];
        
        if length(info)>1
            res=[res sprintf('\nMean\t')];
            for k=1:length(f)
                res=[res sprintf('%.3f\t',nanmean(matris(:,k)))];
            end
            res=[res sprintf('\n')];
            try
                res=[res sprintf('Global accuracy measure: %.3f\n',mean(mean(data==pred)==1))];
            end
        end
        if length(variableToCreateSemanticRepresentationFrom)==1
            res=[res char(13) r];
            i=length(info)+1;
            info{i}.p=p;
            info{i}.r=corr;
            info{i}.results=res;
        end
        if not(s.par.excelServer)
            showOutput({res},'Train');
            s=getSpace('set',s);
        end
    end
    showOutput({[resR char(13) res]},'Train');
    return
end


if isempty(y)
    fprintf('No data, exiting\n')
    info=[];
    return
end

N=size(y);%Make y a vertical array!
if N(2)>N(1);y=y';end

if iscell(propertySave) propertySave=propertySave{1}; end
if isempty(propertySave) propertySave=''; end


propertySave=fixpropertyname(propertySave);

if not(s.par.excelServer)
    fprintf('Training model %s\n',propertySave);
end

par=s.par;
par.fastTrain=1;
par.trainModelName=propertySave;

%Make random trainings - should give non-significant results
if par.randomizeTraining
    fprintf('RANDOMIZING TRAINING SHOULD YIELD INSIGNIFICANT RESULTS!\n');
    resetRandomGenator(s,1);
    [tmp indexRand]=sort(rand(1,length(y)));
    y=y(indexRand);
end
if isempty(words) %words does not need to be set, wordsIndex is the important input variable!
    words=index2word(s,wordsIndex);
end

%predict on crossvalidated data.
if 1 & length(s.par.trainOnCrossValidationOfMultipleTexts)>0 
    par=s.par;
    trainOnCrossValidationOfMultipleTexts=s.par.trainOnCrossValidationOfMultipleTexts;
    trainOnCrossValidationOfMultipleTexts=strread(trainOnCrossValidationOfMultipleTexts,'%s');
    s.par.trainOnCrossValidationOfMultipleTexts='';
    numericalDataAll=[];
    propertySave=regexprep(propertySave,s.par.variableToCreateSemanticRepresentationFrom(2:end),'');
    propertySave=regexprep(propertySave,s.par.trainModelName,'');
    labels=[];
    for i=1:length(trainOnCrossValidationOfMultipleTexts)
        s.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
        propertySave2=fixpropertyname([propertySave s.par.variableToCreateSemanticRepresentationFrom]);
        info.pred=getInfo(s,wordsIndex,word2index(s,[propertySave2 'crossvalidation']));
        if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
            %I THINK numericalData SHOULD BE REPLACED WITH [] HERE, BUT IT NEEDS TO BE TESTED FIRST
            %AND THEN ADD numericalData TO numericalDataALL AFTER THIS FOR
            %LOOP
            if 0 %s.par.excelServer
                [s info xnorm]=predictionMake(s,words(i,:),y,propertySave2,wordsIndex(i,:),group,numericalData,covariates,indexSubtract);                
            else
                [s info xnorm]=predictionMake(s,words,y,propertySave2,wordsIndex,group,numericalData,covariates,indexSubtract);
            end
        else
            fprintf('Reading %s ',propertySave2);
            info.r=s.info{word2index(s,propertySave2)}.r;
        end
        labels=[labels trainOnCrossValidationOfMultipleTexts(i)];
        numericalDataAll=[numericalDataAll info.pred'];
        
        if 0
            s.par.space2='spaceEnglish';
            [d, s2,y]=getX(s,wordsIndex,s.par,[],y,group);
            s2.par.trainOnCrossValidationOfMultipleTexts='';
            s2.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
            [d, s2,y]=getX(s2,word2index(s2,words),s2.par,[],y,group);
            info.pred=getInfo(s2,word2index(s2,words),word2index(s2,[propertySave2 'crossvalidation']));
            if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                [s2 info xnorm]=predictionMake(s2,words,y,propertySave2,word2index(s2,words),group,numericalData,covariates,indexSubtract);
                getSpace('set2',s2);
            else
                fprintf('Reading %s from %s',propertySave2,s2.languagefile);
                info.r=s2.info{word2index(s2,propertySave2)}.r;
            end
            labels=[labels {[trainOnCrossValidationOfMultipleTexts{i} 'space2']}];
            numericalDataAll=[numericalDataAll info.pred'];
            s.par.space2='';
        end
    end
    
    if s.par.trainOnDiffCrossValidationOfMultipleTexts
        for i=1:length(trainOnCrossValidationOfMultipleTexts)
            s.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
            for j=i+1:length(trainOnCrossValidationOfMultipleTexts)
                s.par.subtractSemanticRepresentation=trainOnCrossValidationOfMultipleTexts{j};
                propertySave2=fixpropertyname([propertySave s.par.variableToCreateSemanticRepresentationFrom s.par.subtractSemanticRepresentation]);
                info.pred=getInfo(s,wordsIndex,word2index(s,[propertySave2 'crossvalidation']));

                if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                    [s info xnorm]=predictionMake(s,words,y,propertySave2,wordsIndex,group,numericalData,covariates,indexSubtract);
                else
                    fprintf('Reading Difference %s ',propertySave2);
                    info.r=s.info{word2index(s,propertySave2)}.r;
                end
                numericalDataAll=[numericalDataAll info.pred'];
            end
        end
    end
    
    if s.par.trainOnWFSVDCrossValidationOfMultipleTexts
        parWFSVD=s.par;
        s.par.trainOnWordFrequency=1;
        s.par.preprocessWithSVD=1;
        for i=1:length(trainOnCrossValidationOfMultipleTexts)
            s.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
            propertySave3=fixpropertyname([propertySave s.par.variableToCreateSemanticRepresentationFrom 'WFSVD']);
            info.pred=getInfo(s,wordsIndex,word2index(s,[propertySave3 'crossvalidation']));

            if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                [s info xnorm]=predictionMake(s,words,y,propertySave3,wordsIndex,group,numericalData,covariates,indexSubtract);
            else
                fprintf('Reading WF-SVD %s ',propertySave3);
                info.r=s.info{word2index(s,propertySave3)}.r;
            end
            numericalDataAll=[numericalDataAll info.pred'];
        end
        s.par=parWFSVD;
    end
    s.par=par;
    s.par.trainOnCrossValidationOfMultipleTexts='';
    if isfield(s.par,'trainPropertySave') & 0
        for i=1:length(s.par.trainPropertySave)
            [info.pred,~,~,s]=getProperty(s,[s.par.trainPropertySave{i} 'crossvalidation'],wordsIndex);
            if mean(isnan(info.pred))<.6 & not(strcmp(s.par.trainPropertySave{i},propertySave))
                numericalDataAll=[numericalDataAll info.pred'];
            end
        end
    end
    s.par.trainOnCrossValidationOfMultipleTextsRecall=trainOnCrossValidationOfMultipleTexts;
    s.par.trainSemanticKeywordsFrequency=0;
    %s.par.preprocessWithSVD=1;
    s.par.variableToCreateSemanticRepresentationFrom='';
    s.par.numericalDataLabels=labels;
    [s info xnorm]=predictionMake(s,words,y,[propertySave s.par.trainModelName],wordsIndex,group,numericalDataAll,covariates,indexSubtract);
    
    s.par=par;
elseif par.predictOnWordClass
    %Loop over wordclasses...
    data=[];
    [tmp indexTmp]=sort(rand(1,length(y)));
    if 0
        fprintf('Spliting into a train and a test group!\n')
        index1=indexTmp(1:fix(length(indexTmp)/2));
        index2=indexTmp(fix(length(indexTmp)/2)+1:end);
        s.par.wordClassTwoGroups=1;
    else
        fprintf('Using all data!\n')
        index1=1:length(indexTmp);
        index2=index1;
        s.par.wordClassTwoGroups=0;
    end
    if not(isempty(numericalData))
        numericalData1=numericalData(index1);
        numericalData2=numericalData(index2);
    else
        numericalData1=[];
        numericalData2=[];
    end
    if not(isempty(covariates))
        covariates1=covariates(index1);
        covariates2=covariates(index2);
    else
        covariates1=[];
        covariates2=[];
    end
    for wc=1:length(s.classlabel)
        par.wc=wc;
        if isempty(group); group2=group;else; group2=group(index1);end
        [s info]=predictionMake2(s,words(index1),y(index1),propertySave,wordsIndex(index1),par,group2,numericalData1,covariates1,indexSubtract(index1));
        infoWC{wc}=info;
        if isnan(info.p) %training failed!
            pred2=nan(1,length(index2));
        else
            pred2=info.pred;%getProperty(s,'_predd00age',words(index2));
        end
        m=nanmean(pred2);
        if isnan(m); m=0;end
        pred2(find(isnan(pred2)))=m;
        if not(isempty(pred2))
            data(:,wc)=pred2;
        end
        p(wc)=info.p;
        r(wc)=info.r;
        n(wc)=info.n;
        d.Nwordsfound(wc)=info.nWordsFound;
    end
    %Reording so the important wordclasses comes first (a priory judgments)
    if 0
        try
            classOrdered={'nouns','adjective','proper name','verb','adverb','particip','pronouns','conjunction etc','determinerare','countingwords','partikel','prepositions','foreign word','interpunktion','interjektion','other','Unknown','errors'};
            for i=1:length(s.classlabel)
                index(find(strcmp(classOrdered,s.classlabel{i})))=i;
            end
            
            data=data(:,index);
        catch
            fprintf('Failed rearranging the order of the wordclasses\n');
        end
    end
    
    %Predict on the prediction from wordclasses....
    par.wc=0;
    par.data=data;
    [tmp par.dim]=size(data);
    par.optimzeDimensions=0;
    par.optimzeDimensionsConservative=0;
    if isempty(group); group2=group;else; group2=group(index2);end
    [s info]=predictionMake2(s,words(index2),y(index2),propertySave,wordsIndex(index2),par,group2,numericalData2,covariates2,indexSubtract(index2));%0,data)
    info.pWC=p;
    info.rWC=r;
    info.results= sprintf('wordclass         \tp\tr\tNtexts\tNwordsfound\n');
    for wc=1:length(s.classlabel)
        info.results=[info.results sprintf('%s\t%.3f\t%.3f\t%d\t%d\n',fixStringLength(s.classlabel{wc}),p(wc),r(wc),n(wc),d.Nwordsfound(wc))];
    end
    fprintf('%s',info.results);
    
elseif par.regressionCategory %Regress on categorical data...
    %ANOVA prediction
    %subject=getProperty(s,'_subject',wordsIndex);
    uSubject=unique(group);
    par.bootstrapSubject=0;
    par.leaveOutCounterbalanced=1;
    
    pred=nan(1,length(group));
    for i=1:length(uSubject)
        fprintf('Predicting subject group: %d\n',uSubject(i));
        index=group==uSubject(i);
        regBin=(2*(index)-1)';
        if length(find(index))<=1
            pred(find(index))=NaN;
        else
            [s info]=predictionMake2(s,words,regBin,propertySave,wordsIndex,par,group,numericalData,covariates,indexSubtract);
            pred(find(index))=info.pred(find(index))-nanmean(info.pred(find(not(index))));
        end
    end
    [sig p]=ttest(pred',zeros(1,length(pred))',.05,'right');
    fprintf('m=%.3f\tp=%.4f\tN=%d\n',nanmean(pred),p,length(find(not(isnan(pred)))))
    1;
    %Performane as a function of N data points, N number of words, or serial position 
elseif par.trainPerformanceDependingOnNWords | par.trainPerformanceDependingOnNRandomWords | par.trainPerformanceDependingOnSerialPosition 
    parTemp=s.par;
    j=1;
    if not(isempty(par.trainPerformanceDependingOnXData)) & not(par.trainPerformanceDependingOnXData==0)
        Nwords=par.trainPerformanceDependingOnXData;
    elseif par.trainPerformanceDependingOnSerialPosition
        Nwords=1:10;
    else
        Nwords=2.^(1:10-1);
    end
    for i=1:length(Nwords)%1:10
        if par.trainPerformanceDependingOnSerialPosition
            label='Performance for serial position number N\nr\tstd(r)\tp\tN\tNsim\n';
            s.par.weightWordPosition=i;
            %Nwords(i)=i;
        else
            label='Performance as a function of N-first-words\nr\tstd(r)\tp\tN\tNsim\n';
            %Nwords(i)=2^(i-1);
            if par.trainPerformanceDependingOnNRandomWords
                s.par.weightRandomNWords=Nwords(i);
            else
                s.par.weightFirstNWords=Nwords(i);
            end
        end
        [s infoN{i}  xnorm]=predictionMake2(s,words,y,propertySave,wordsIndex,par,group,numericalData,covariates,indexSubtract);
        r(i,j)=infoN{i}.r;
        p(i,j)=infoN{i}.p;
    end
    s.par=parTemp;
    res=sprintf(label);
    for i=1:length(infoN)
        res=[res sprintf('%.3f\t%.3f\t%.3f\t%d\t%d\n',nanmean(r(i,:)),nanstd(r(i,:)),nanmedian(p(i,:)),Nwords(i),length(find(not(isnan(r(i,:))))))];
    end
    info=infoN{i};
    info.results=[res infoN{i}.results];
    fprintf('%s\n',res);
    %Performane as a function of N
elseif par.trainPerformanceDependingOnN 
    N=4;i=0;
    while N<length(y)
        N=min(length(y),N*2);
        i=i+1;
        [tmp indexFull]=sort(rand(1,length(y)));
        Nt=6;
        for j=1:Nt
            if N*j<=length(indexFull)
                if j==1
                    p(i,1:Nt)=NaN;
                    r(i,1:Nt)=NaN;
                end
                index=indexFull(1+N*(j-1):N*j);
                if isempty(indexSubtract)
                    indexSubtract2=[];
                else
                    indexSubtract2=indexSubtract(index);
                end
                if isempty(numericalData)
                    numericalData2=[];
                else
                    numericalData2=numericalData(index,:);
                end
                if isempty(group); group2=group;else; group2=group(index);end
                [s infoN{i} xnorm]=predictionMake2(s,words(index),y(index),propertySave,wordsIndex(index),par,group2,numericalData2,covariates,indexSubtract2);
                r(i,j)=infoN{i}.r;
                p(i,j)=infoN{i}.p;
            end
        end
    end
    res=sprintf('Performance as a function of N\nr\tstd(r)\tp\tN\tNsim\n');
    for i=1:length(infoN)
        Ni(i)=infoN{i}.n;
        res=[res sprintf('%.3f\t%.3f\t%.3f\t%d\t%d\n',nanmean(r(i,:)),nanstd(r(i,:)),nanmedian(p(i,:)),Ni(i),length(find(not(isnan(r(i,:))))))];
    end
    info=infoN{i};
    info.results=[res infoN{i}.results];
    fprintf('%s\n',res);
    figure;
    plot(Ni,nanmean(r(:,:)'))
    h=errorbar(1:size(r,1),nanmean(r(:,:)'),nanstd(r(:,:)'));
    set(gca,'XTickLabel',[NaN Ni])
    set(gca,'Ylim',[0 1])
    title(['Performance (r) as a function of number of data points for ' propertySave])
    xlabel('N');ylabel('r(N)');
elseif length(par.trainPerformanceOnVariabel)>0
    par.trainSavePrediction=0;%Improves speed
    par.optimzeDimensionsConservative=0;%Improves speed
    trainPerformanceOnVariabel=eval(par.trainPerformanceOnVariabel);
    par.trainPerformanceOnVariabel='';
    variabel=trainPerformanceOnVariabel{1};
    values=str2num(trainPerformanceOnVariabel{2});
    if length(par.trainingSets)>0
       trainingSets=strread(par.trainingSets,'%s');
    else
        trainingSets={''};
    end
    res=sprintf('Performance as a function variables:\ndate\tspace\tdataset\ttrainedOn\tvariabel\tvalue\tr\tp\tN\n');
    try;close(1);end
    figure(1);hold on

    for j=1:max(1,length(trainingSets))
        
        if length(trainingSets{j})>0
            [select s]=getWord(s,trainingSets{j});
            words=select.word;
            wordsIndex=select.index;
            [y, ~,~,s]=getProperty(s,regexprep(propertySave,'_pred','_'),wordsIndex);y=y';
        end
        
        for i=1:length(values)
            evalString=['par.' variabel '=values(i)'];
            fprintf('%s=%.4f\n',variabel,values(i));
            eval([evalString ';']);
            [s infoN{i} xnorm]=predictionMake2(s,words,y,propertySave,wordsIndex,par,[],numericalData,covariates,indexSubtract);
        end
        for i=1:length(infoN)
            r(j,i)=infoN{i}.rOutlinersRemoved;
            n(j,i)=infoN{i}.n;
            res=[res sprintf('%s\t%s\t%s\t%s\t%s\t%.3f\t%.3f\t%.3f\t%d\n',datestr(now,'yyyy-mm-dd HH:MM'),regexprep(s.filename,'\.mat',''),trainingSets{j},propertySave,variabel,values(i),infoN{i}.r,infoN{i}.p,infoN{1}.n)];
        end
        [~,iMax]=max(r(j,:));
        info=infoN{iMax};
        
        info.results=res;
        for i=1:length(infoN)
            info.results=[res infoN{i}.results];
        end
        
        figure(1);
        %plot(values,r(j,:)')
        %sqrt((1-r.^2)./(n-2))
        h=errorbar(values,r(j,:),sqrt((1-r(j,:).^2)./(n(j,:)-2)));
        %h=errorbar(1:size(r,1),nanmean(r(:,:)'),nanstd(r(:,:)'));
        %set(gca,'XTick',1:length(values));
        %set(gca,'XTickLabel',values)
        %set(gca,'Ylim',[min([0 r]) 1])
        title(['Performance (r) as a function of variabel '  regexprep(propertySave,'_','') '-' variabel])
        xlabel(variabel);ylabel('r');
    end
    %plot(values,mean(r'),'linewidth',4)
    if size(r,1)>1
        h=errorbar(values,nanmean(r(:,:)),nanstd(r-repmat(r(:,1),1,size(r,2))),'linewidth',4);
        legend(regexprep([trainingSets; {'mean'}],'_',''));
    end
    
    [a b]=getPar;
    text(min(values),nanmean(nanmin(r)),struct2text(b.setParPersistent))
    fprintf('%s\n',res);
    f=fopen('results optimizie training.txt','a');
    fprintf(f,'%s\n',res,regexprep(struct2text(b.setParPersistent),char(13),''));
    fclose(f);
    saveas(1,['Optimize-' regexprep(s.filename,'\.mat','') '-' propertySave '-' variabel])

else
    [s info xnorm]=predictionMake2(s,words,y,propertySave,wordsIndex,par,group,numericalData,covariates,indexSubtract);
end

function [s info xnorm]=predictionMake2(s,words,y,propertySave,wordsIndex,par,group,numericalData,covariatesData,indexSubtract);
%Make random groups
if isempty(group)
    resetRandomGenator(s);
    [temp group]=sort(rand(1,length(y)));%Changed 2013-05-29
    if par.bootstrapSubject;
        [group,~,~,s]=getProperty(s, fixpropertyname(par.groupingProperty),wordsIndex);
        Nerror=length(find(isnan(group)));
        if Nerror>0 & not(s.par.excelServer)
            fprintf('Missing %s property on N=%d identifiers\n',par.groupingProperty,Nerror)
        end
    end
    group(isnan(group))=sort(rand(1,length(find(isnan(group)))));
end

%Matching groups to minimize variabiliy in trained vales...
if s.par.optimizeTrainingGroups & not(s.par.timeSerie) & length(group)>2*s.par.NleaveOuts
    Ugroup=unique(group);%Unique groups
    clear Ureg;
    for i=1:length(Ugroup) %Mean value of groups
        Ureg(i)=nanmean(y(find(Ugroup==Ugroup(i))));
    end
    [tmp Uindex]=sort(Ureg);%Sort groups according to mean value
    for j=1:length(Ugroup)/2
        i=Uindex(j);
        indexLow=find(Ugroup==Ugroup(i));
        i=Uindex(length(Ugroup)-j+1);
        group(indexLow)=group(i);%Move from on group to another
    end
    Ugroup=unique(group);
    for i=1:length(Ugroup)
        UregNew(i)=nanmean(y(find(group==Ugroup(i))));
    end
    fprintf('Minimings variability in groups from %.3f (N=%d) to %.3f (N=%d)\n',nanstd(Ureg),length(Ureg),nanstd(UregNew),length(UregNew))
end



info=[];
if s.par.trainOnSingleWords>0
    fprintf('Mapping to singel words\n');
    if s.par.trainOnSingleWords==2
        j=0;
        [tmp indexRand]=sort(rand(1,length(y)));
        for i2=1:length(wordsIndex)
            i=indexRand(i2);
            if isfield(s.info{wordsIndex(i)},'index')
                index=s.info{wordsIndex(i)}.index;
            else
                index=wordsIndex(i);
            end
            index=index(index>0);
            for k=1:length(index)
                j=j+1;
                y2(j)=y(i);
                words{j}=s.fwords{index(k)};
                wordsIndex2(j)=index(k);
                group(j)=i;
            end
        end
        y=y2';
        wordsIndex=wordsIndex2;
    else
        y2=zeros(1,s.N);
        N2=zeros(1,s.N);
        for i=1:length(wordsIndex)
            if isfield(s.info{wordsIndex(i)},'index')
                index=s.info{wordsIndex(i)}.index;
            else
                index=wordsIndex(i);
            end
            index=index(index>0);
            y2(index)=y2(index)+y(i);
            N2(index)=N2(index)+1;
        end
        index=find(N2>0);
        words=s.fwords(index)';
        y=(y2(index)./N2(index))';
        wordsIndex=index;
        group=1:length(index);
        numericalData=[];
    end
end
if not(isempty(wordsIndex))
    index=wordsIndex;
else
    index=word2index(s,words);
end

if nargin<6
    par=[];
end
if not(isfield(par,'wc'))
    par.wc=0;
end
if not(isfield(par,'zTransform'))
    par.zTransform=0;
end
if not(isfield(par,'leaveOutCounterbalanced'))
    par.leaveOutCounterbalanced=0;
end
%if not(isfield(par,'extendedOutput'))
%    par.extendedOutput=1;
%end



%Take care of covariates
y=covariates(s,y,par.covariateProperties,index,covariatesData);

%create xnorm vector starts here!

par.numericalData=numericalData;
par.indexSubtract=indexSubtract;
[d, s,y]=getX(s,index,par,[],y,group);

if not(isfield(d,'Nwordsfound'))
    d.Nwordsfound=getInfo(s,d.index,'_nwordsfound');
    d.Nwords=getInfo(s,d.index,'_nwords');
end

xnorm=d.x;
index=d.index;
label=d.label;
N=size(xnorm);
if isempty(par.dim) | par.dim<=0
    par.dim=1:N(2);
end
dimUsed=par.dim;


isNotNan=not(isnan(y'+mean(shiftdim(xnorm,1))) | isinf(y'+mean(shiftdim(xnorm,1))));
Nremoved=length(y)-length(find(isNotNan));

indexWithNaN=index;
if not(isempty(index))
    index=index(isNotNan);
    %index=wordsIndex(isNotNan);
end
d.Nwords=d.Nwords(isNotNan);
d.Nwordsfound=d.Nwordsfound(isNotNan);
xnorm=xnorm(isNotNan,:);
if length(group)*2==length(y);group=[group group];end
y=y(isNotNan);
group=group(isNotNan);
if not(isempty(numericalData))
    numericalData=numericalData(isNotNan,:);
end

propertySave=lower(propertySave);

%If no data exit
if isempty(xnorm) | length(y)<1 %<=
    info.results='Missing data';
    fprintf('Missing data\n')
    info.data=nan(1,length(isNotNan));
    info.pred=nan(1,length(isNotNan));
    info.p=NaN;info.c=NaN;info.r=NaN;info.n=NaN;info.ndim=NaN;info.nWordsFound=NaN;
    info.w.z=[];
    info.w.f=[];
    info.w.p=[];
    info.w.word=[];
    return
end


if par.timeSerie
    fprintf('Time serie analysis: Do not including words that occurs at time t-%.2f (i.e., in the future)\n',par.timeSerieOffset)
    time=group;
    isorder=1;
    for i=1:length(y)
        if i>2 & time(i-1)>time(i)
            isorder=0;
        end
    end
    if not(isorder)
        fprintf('Comment: Time series are not in increasing order, sorting\n');
        %return
        %if 0
        [tmp indexTime]=sort(group,'ascend');
        %index2=index2(indexTime);%1:length(find(indexTime));
        index=index(indexTime);
        xnorm=xnorm(indexTime,:);
        %wordsIndex=wordsIndex(indexTime);
        y=y(indexTime);
        time=time(indexTime);
        group=group(indexTime);
        if not(isempty(numericalData))
            numericalData=numericalData(indexTime,:);
        end
        %end
    end
end


%Diminshes the number of groups to 20!
subjectOrginal=group;
group(isnan(group))=rand(1,length(find(isnan(group))));
uSubject=unique(group);
if par.timeSerie & par.timeSerieGrouping>0
    group=par.timeSerieGrouping*fix(group/par.timeSerieGrouping);
    uSubject=unique(group);
elseif length(uSubject)>par.NleaveOuts
    j=0;
    while j<length(uSubject)
        i=j+1;
        for k=1:max(2,round(length(uSubject)/par.NleaveOuts))
            j=j+1;
            if j<=length(uSubject)
                group(find(group==uSubject(j)))=uSubject(i);
            end
        end
    end
    uSubject=unique(group);
    %fprintf('Diminishing the groups from %d to %d\n',length(group),length(uSubject))
end


[tmp Ndim]=size(xnorm);
if par.optimzeDimensions
    %Finding optimal number of dimensions
    [dimUsed  c_o par]=optimize_dim(xnorm,y,1:length(y),group,par,label);
else
    fprintf('Using dimensions: %s\n',num2str(dimUsed));
end

modelSave=regress2(xnorm(1:length(y),dimUsed),y,par);
x=modelSave.x;stats=modelSave.stats;
modelSave=regression(xnorm(1:length(y),dimUsed),y,par,'',group,dimUsed,N(2));
x=modelSave.x;c=modelSave.r;p=modelSave.p;
if strcmp(s.par.model,'logistic') x=nan(1,s.Ndim); end
%fprintf('Correlation predictor and regressor when test and train set overlap: r=%.3f\n',c)


if par.trainRemoveOutLiners
    for i=1:N(2)
        xTemp=xnorm(:,i);
        zCrit=4;
        indexZ1=find(zTransform(xTemp)>zCrit)';
        xTemp(indexZ1)=nanmean(xTemp)+zCrit*nanstd(xTemp);
        indexZ2=find(zTransform(xTemp)<-zCrit)';
        xTemp(indexZ2)=nanmean(xTemp)-zCrit*nanstd(xTemp);
        xnorm(:,i)=xTemp;
        if not(isempty([indexZ1 indexZ2]))
            fprintf('Removing %d outliers on rows on dimension %s. ',length([indexZ1 indexZ2]),label{i})
        end
    end
    fprintf('\n')
end


dimSaved=dimUsed;
pred=nan(length(y),1);
predWord=sparse(length(y),s.N);
predWall=[];indexWall=[];
predictionMade=zeros(1,length(y));

if par.optimzeDimensionsConservative & strcmp(par.model,'lasso')
    fprintf('par.optimzeDimensionsConservative is disabeled in Lasso regression for speed issues\n')
    par.optimzeDimensionsConservative=0;
end
for i=1:length(y)
    if predictionMade(i)==0
        %Create test-train groups
        includeTrain=ones(1,length(y));%Intialize to include all data
        includeTrain(i)=0;%Remove current data-point
        if par.leaveOutCounterbalanced
            %Counterbalance removeal, assumes binary 0/1 coding
            includeTested=find(not(includeTrain));%None-trained data is tested on
            if includeTrain(i)==1
                remove=-1;
            elseif includeTrain(i)==0
                remove=1;
            end
            includeRemove=find(y==remove);
            includeTrain(includeRemove(fix(rand*length(find(includeRemove))+1)))=not(remove);
        else
            includeTrain(find(group==group(i)))=0;%Remove all data-points with idential subject property
            includeTested=find(not(includeTrain));%None-trained data is tested on
        end
        
        if par.timeSerie
            includeTrain(find(time>time(i)-par.timeSerieOffset & not(isnan(time))))=0;%removes data points in the future...
        end
        isNotNanI=not(isnan(mean(shiftdim(xnorm,1))));
        includeTrain=find(includeTrain & isNotNanI);
        if par.optimzeDimensionsConservative
            %if par.NleaveOuts2>0 
            %    NleaveOuts=par.NleaveOuts; par.NleaveOuts=par.NleaveOuts2;
            %end
            [dimUsed  c_o(i) par]=optimize_dim(xnorm(includeTrain,:),y(includeTrain),1:length(includeTrain),group(includeTrain),par,label);
            %if par.NleaveOuts2>0 
            %    par.NleaveOuts=NleaveOuts;
            %end
        else
            if par.forceMaxDimToN2
                dimUsed=dimSaved(1:min(end,fix(length(includeTrain)/2)));%Forces the number of dimensions to be half of the values in the prediction!
                if length(dimUsed)<dimSaved & i==1;
                    fprintf('Forcing the number of used dimension to N/2\n');%,num2str(dimUsed));
                end
            end
        end
        dimarray(includeTested)=length(dimUsed);
        regTrain=y(includeTrain);
        if par.zTransform %z-Transform training data
            regTrain=(regTrain-mean(regTrain))/std(regTrain);
        end
        model=regression([xnorm(includeTrain,dimUsed)],regTrain,par);
        xr=model.x;
        for j=1:length(includeTested)
            try
                [pred(includeTested(j),1) predMutinomial(includeTested(j),:)]=predictReg(model,xnorm(includeTested(j),dimUsed),par);
                if s.par.trainSemanticKeywordsFrequency==10
                    [~, indexW]=getText(s,index(includeTested(j)));
                    indexW=indexW(find(indexW>0));
                    indexW=indexW(indexW<=s.N);
                    predW=predictReg(model,s.x(indexW,dimUsed),par);
                    %predW=getProperty(s,propertySave,s.fwords(indexW));
                    %for i=1:length(indexW)
                    predWall=[predWall predW];
                    indexWall=[indexWall indexW];
                    %end
                end
                
                if s.par.trainSemanticKeywordsFrequency>=3 
                    [~, indexWord]=getText(s,index(includeTested(j)));
                    indexWord=indexWord(indexWord>0);
                    predWord(includeTested(j),indexWord)=predictReg(model,s.x(indexWord,dimUsed),par);
                    indexZero=find(predWord(includeTested(j),indexWord)==0);
                    predWord(includeTested(j),indexWord(indexZero))=0+1^15;
                end
                predictionMade(includeTested(j))=1;
            catch
                fprintf('No predicition made....\n')
            end
        end
    end
end
if s.par.trainRemoveOutLiners
    indexOutliners=find(abs((pred-nanmean(pred))/nanstd(pred))>4);
    if not(isempty(indexOutliners))
        fprintf('Removing %d outerliners in the predicted dataset\n',length(indexOutliners))
        pred(indexOutliners)=NaN;
    end
end
    
[propertyCrossValidation2,propertyCrossValidation]=fixpropertyname([propertySave 'crossvalidation']);

%propertyCrossValidation=[propertySave(2:length(propertySave)) 'crossvalidation'];
if not(s.par.excelServer)
    fprintf('Saving crossvalidation data in property: _%s\n',propertyCrossValidation);
end
for i=1:length(y)
    if par.zTransform %reverse z-Transform, based all data!
        pred(i,1)=pred(i,1)*std(y)+mean(y);
    end
    if isfield(s.par,'trainSavePrediction') & s.par.trainSavePrediction==0
        %Do not save prediction....faster
    else
        if length(predMutinomial(i,:))>1
            [~,s]=getInfo(s,index(i),propertyCrossValidation,num2str(predMutinomial(i,:)));
            %eval(['s.info{index(i)}.' propertyCrossValidation '=''' num2str(predMutinomial(i,:)) ''';']);
        else
            [~,s]=getInfo(s,index(i),propertyCrossValidation,num2str(pred(i,1)));
            %eval(['s.info{index(i)}.' propertyCrossValidation '=' num2str(pred(i,1)) ';']);
        end
    end
    context{i}=getText(s,index(i));
end

include=find(not(isnan(pred)));

if par.extendedOutput
    textPredHigh=printList(sprintf('Sorted by prediction\npred\tdata\ttext'),pred(include),y(include),context(include),'descend');
    textPredLow =printList(sprintf('Sorted by prediction\npred\tdata\ttext'),pred(include),y(include),context(include),'ascend');
    textDataHigh =printList(sprintf('Sorted by data\ndata\tpred\ttext'),y(include),pred(include),context(include),'descend');
    textDataLow =printList(sprintf('Sorted by data\ndata\tpred\ttext'),y(include),pred(include),context(include),'ascend');
end

if isempty(include) | std(y(include))==0
    c=NaN;p=NaN;rOutlinersRemoved=NaN; pOutlinersRemoved=NaN;crank=NaN;prank=NaN;
    pRankOrder=NaN;rRankOrder=NaN;
    rVersusN='';
else
    [c p]=nancorr(pred(include),y(include),'tail','gt');
    [rOutlinersRemoved pOutlinersRemoved]=nancorr(min(max(y(include)),max(min(y(include)),pred(include))),y(include),'tail','gt');
    try
        [ ~, ~,~,rVersusN]=nancorr2(pred(include),y(include),d.Nwordsfound(include)); %,'tail','gt'
    catch
        rVersusN='';
    end
    %[tmp rankOrder]=sort(pred(include));
    %[tmp rankOrderY]=sort(y(include));
    [rRankOrder pRankOrder]=nancorr(pred(include),y(include),'tail','gt','Type','Spearman');
end
info.comment1='Information';
info.modelName=propertySave;
if isfield(s.par,'i') & s.par.i>0
    info.modelNumber=s.par.i;
end
info.space=s.filename;
info.algorithm=s.par.model;
info.date=datestr(now);
if length(par.covariateProperties)>0 info.covarites=par.covariateProperties;end
if length(par.predictionProperties)>0 info.predictors=par.predictionProperties;end
if strcmp(par.model,'lasso')
    info.Lambda=par.Lambda;
end
info.comment2='Main descriptive statistics';
info.n=length(include);
info.nWordsFound=nansum(d.Nwordsfound);
info.nWords=nansum(d.Nwords);

info.comment3='Main inferential statistics';
info.p=p;
if strcmp(par.model,'logistic')
    Nnominal=size(predMutinomial);
    [~,correctMulinomial]=max(predMutinomial');
    MuliNominalText=sprintf('Category\tcorrect\tr\tp\t');
    MuliNominalText=[MuliNominalText  sprintf('Overall correct: %.3f',mean(correctMulinomial==y'))];
    info.MuliNominalLabel=sprintf('%s\n',MuliNominalText);
    for i=1:Nnominal(2)
        [rNominal,pNominal]=nancorr(y==i,predMutinomial(:,i),'tail','gt');
        [~,correctMulinomial]=max(predMutinomial');
        %info.pMuliNominal=[info.pMuliNominal sprintf('%d: correct=%.3f r=%.3f p=%.4f ',i,mean((correctMulinomial'==i)==(y==i)),rNominal,pNominal)];
        tmp=sprintf('%d\t%.3f\t%.3f\t%.4f',i,mean((correctMulinomial'==i)==(y==i)),rNominal,pNominal);
        MuliNominalText=[MuliNominalText sprintf('\n%s',tmp)];
        eval(['info.MultiNominal' num2str(i) '=tmp;']);
    end
end
info.r=c;
info.rStd=((1-info.r^2)/(info.n-2))^.5;
infoSave=info;
info.rVersusN=rVersusN;
if not(isempty(s.par.trainMengz))
    [predMengz,~,~,s]=getProperty(s,index,s.par.trainMengz);
    [~,pMengs,~] =mengz(info.r, nancorr(predMengz,y), nancorr(predMengz,pred), info.n);
    info.pMengs=sprintf('p=%.4f, r(y-%s)=%.3f',pMengs,s.par.trainMengz,nancorr(predMengz,y));
end
if par.extendedOutput & length(unique(y))==2 & s.par.excelServer==0
    [XROC,YROC,TROC,info.AUC] = perfcurve(y>mean(y),pred,1>0);
    figure(99);
    plot(XROC,YROC)
    xlabel('False positive rate')
    ylabel('True positive rate')
    title(sprintf('ROC curves for %s, AUC=%.3f', regexprep(info.modelName,'_',''),info.AUC))
end

info.comment4='Information about regression';
info.c=x(1);
info.Nremoved=Nremoved;
info.ndim=mean(dimarray);
info.comment5='Supplementary aspects of the results';
info.nStddim=std(dimarray);

if par.timeSerie
    i=0;
    if length(s.par.timeSerieExpand)>1
        tClock=s.par.timeSerieExpand(2)-fix(s.par.timeSerieExpand(2));
        tLoop=s.par.timeSerieExpand(1):s.par.timeSerieAverage:s.par.timeSerieExpand(2);
        indexT=find(time<s.par.timeSerieExpand(1));
        [~, tmpindex]=max(time(indexT));
        lIndextT=indexT(tmpindex);
        if isempty(lIndextT) lIndextT=1;end
    else
        tClock=0;
        tLoop=min(time):s.par.timeSerieAverage:max(time);
    end
    tLoop=tLoop+tClock;
    for t=tLoop
        indexT=find(time>t-s.par.timeSerieAverage & time<=t);
        timeNnow=length(pred(indexT));
        if not(isempty(s.par.timeSerieExpand)) & isempty(indexT)
            indexT=lIndextT;
        end
        if not(isempty(indexT)) | length(s.par.timeSerieExpand)>1
            i=i+1;
            info.time(i)=t;
            info.timepred(i)=nanmean(pred(indexT));
            info.timedata(i)=nanmean(y(indexT));
            info.timeN(i)=timeNnow;
            if length(indexT)>1
                info.timex(i,:)=mean(xnorm(indexT,dimUsed));
            else
                info.timex(i,:)=xnorm(indexT,dimUsed);
            end
        else
            info.timex(i,:)=nan(1,length(dimUsed));
        end
        lIndextT=indexT;
    end
    info.xpred=x([1 1+dimUsed]);
    if 0
        figure(10);
        Nt=3923;
        tmp=repmat(info.xpred,Nt,1).*[ones(Nt,1) info.timex];
        mean(tmp)
        std(tmp)
        plot(tmp)
    end
    %isNotNaN=find(not(isnan(info.timepred+info.timedata)));
    [info.timer info.timep]=nancorr(info.timepred',info.timedata');
    isNotNaN4=find(not(isnan(info.timepred+info.timedata)) & info.timeN>=4);
    [info.time4r info.time4p]=nancorr(info.timepred(isNotNaN4)',info.timedata(isNotNaN4)');
end
binaryY=length(unique(y))==2;
if 1 %binaryY
    ybinary=y>mean(y);
    threshold=mean(ybinary);
    %weight=0.05;
    %f = @(ybinary,pred,threshold) (-mean((pred>threshold)==ybinary)-0*sum(ybinary==max(ybinary) & (pred>threshold)==ybinary)/sum(ybinary==max(ybinary)));  % The parameterized function.
    %    -weight*sum(ybinary==max(ybinary) & (pred>threshold)==ybinary)/sum(ybinary==max(ybinary)));  % ..and recall  function.
    %f = @(ybinary,pred,threshold) -sum((pred>threshold)==ybinary & (pred>threshold))/sum(pred>threshold);  % Naximise precision.
    if not(isnan(s.par.trainBinaryThreshold))
        threshold=s.par.trainBinaryThreshold;
    else
        if s.par.trainBinaryOptimizeMethod % Weight precision and recall  function.
            weight=s.par.trainBinaryOptimizeWeight;
            %fprintf('Optimizing on prescion (1-w) and recall (w), where w=%.3f\n', weight)
            f = @(ybinary,pred,threshold) (-(1-weight)*sum((pred>threshold)==ybinary & (pred>threshold))/sum(pred>threshold)... % Weight precision
                -weight*sum(ybinary==max(ybinary) & (pred>threshold)==ybinary)/sum(ybinary==max(ybinary)));  % ..and recall  function.
        else % PercentageCorrect
            %fprintf('Optimizing on PercentageCorrect\n')
            f = @(ybinary,pred,threshold) -mean((pred>threshold)==ybinary);  % PercentageCorrect
        end
        X = fminsearch(@(threshold) f(ybinary,pred,threshold),[threshold]);%,[0.3;1]
        threshold=X;
    end
    
    correct=(pred>threshold)==ybinary;
    info.binaryCorrect=mean(correct);
    %info.binaryPrecision=mean(correct);
    info.binaryPrecision=sum((pred>threshold)==ybinary & (pred>threshold))/sum(pred>threshold);%r?tta & antal predicerade 1/antal predicerade 1
    info.binaryRecall=sum(ybinary==max(ybinary) & (pred>threshold)==ybinary)/sum(ybinary==max(ybinary));%r?tta & antal verkliga 1/antal verkliga 1
    info.binaryHit=mean(correct & ybinary==max(ybinary));
    info.binaryCorrectRejection=mean(correct & ybinary==min(ybinary));
    info.binaryFA=mean(not(correct) & ybinary==min(ybinary));
    info.binaryMisses=mean(not(correct) & ybinary==max(ybinary));
    info.binaryThreshold=threshold;
    info.binaryNHigh=sum(ybinary==max(ybinary));
    %info.percentageGuessing=max([mean(ybinary) 1-mean(ybinary)]);
end

infoSave.specialword=4;
infoSave.trainBinaryOutput=par.trainBinaryOutput;
infoSave.binaryThreshold=info.binaryThreshold;
modelSave.train=d.train;
infoSave.model=modelSave;
infoSave.y=y;
infoSave.pred=pred;
infoSave.trainDataStat=[nanmean(y) nanstd(y) nanmin(y) nanmax(y) skewness(y) ];
infoSave.predDataStat=[nanmean(pred) nanstd(pred) nanmin(pred) nanmax(pred) skewness(pred) ];
infoSave.c=x(1);
if strcmp(s.par.model,'logistic')
    x=nan(1,s.Ndim+1);
end
description=['Prediction of ' propertySave '(r=' num2str(info.r) ', p=' num2str(info.p) ', N=' num2str(info.n) ')' ];
if s.par.plotNetWorkAnalysis | 1
    infoSave.model.xTrain=d.x;
end
[s,~,propertySave]=add2space(s,propertySave,x(2:min(s.Ndim,N(2))+1),infoSave,0, description);
infoSave=rmfield(infoSave,'model');

if not(s.par.excelServer)
    infoSave.specialword=12;
    s=add2space(s,propertyCrossValidation2,[],infoSave,0,['Crossvalidation of ' description ] );
    
    %Needs to be placed after adding to space!
    [a associatesHigh]=getProperty(s,'_associates',propertySave);
    [a associatesLow]=getProperty(s,'_furthestassociates',propertySave);
    info.associatesHigh=associatesHigh{1};
    info.associatesLow=associatesLow{1};
    
    if par.extendedOutput %Remove this?
        Nmax=min(N(2)+1,length(x));
        try
            [~,~,info.associatesOther]=print_nearest_associations_s(s,'noprint',shiftdim(x(2:min(s.Ndim+1,Nmax)),1),'descend','Associates');
        catch
            fprintf('Can not print associates\n')
        end
    end
    
end


if par.bootstrapSubject
    uniqueSubject=unique(subjectOrginal);
    warning off
    for i=1:length(uniqueSubject)
        indexGroup=find(uniqueSubject(i)==subjectOrginal);
        Ngroup(i)=length(indexGroup);
        predSubject(i)=nanmean(pred(indexGroup));
        reg2Subject(i)=nanmean(y(indexGroup));
        if isempty(indexGroup)
            rGroup(i)=NaN;
        else
            rGroup(i)=nancorr(pred(indexGroup),y(indexGroup));
        end
        if binaryY
            predGroup1(i)=nanmean(pred(find(y(indexGroup)==min(y))));
            predGroup2(i)=nanmean(pred(find(y(indexGroup)==max(y))));
        end
    end
    if binaryY
        [h info.pTtestRGroup2]=ttest2(predGroup2-predGroup1,0,.05,'right');
    end
    warning on
    indexNotNaN=find(not(isnan(reg2Subject)));
    [info.rGroup info.pGroup]=nancorr(predSubject(indexNotNaN)',reg2Subject(indexNotNaN)','tail','gt');
    info.NTestedGroups=length(uniqueSubject);
    info.NGroups=length(uSubject);
    [h info.pTtestRGroup]=ttest(rGroup,0,.05,'right');
end


if par.preprocessWithSVD
    fprintf('Preprocessing can currently not make predictions for other semantic representations.\n')
    x=x*NaN;
end
if length(x)>s.Ndim+1
    fprintf('Only _semantic properties can be predicted.\n')
    x=x*NaN;
end

%Calculate additional regression statistics, if needed (may be omitted)
try
    info.beta=NaN;
    if not(par.fastTrain)
        warning off;stats=regstats(y,xnorm(1:length(y),dimUsed));warning on;
        info.beta=stats.beta;
    end
catch
    fprintf('Could not calculate regressions statistics (beta)\n')
end

%global noUpdateCol
%noUpdateCol=1;
if length(unique(y))==2
    if y(1)==min(y)
        side='left';
    else
        side='right';
    end
    try
        d1=pred(find(y==min(y)));
        d2=pred(find(y==max(y)));
        N1=length(d1);
        N2=length(d2);
        s1=(((N1-1)*var(d1)+(N2-1)*var(d2))/(N1+N2-2))^.5;
        info.z=(mean(d1)-mean(d2))/s1;
        [h info.pTtest stat]=ttest2(d1,d2,.05,'right');
        info.m1=mean(d1);info.m2=mean(d2);info.stdPool=s1;info.n1=N1;info.n2=N2;
    end
end

%fprintf('correlation removing outliers; r=%.2f p=%.5f, rankorder test:  r=%.2f p=%.5f\n\n',rOutlinersRemoved,pOutlinersRemoved,info.rRankOrder,info.pRankOrder);

if s.par.trainMedianSplitKeywordAnalysis
    l1=length(find(y<median(y)));
    l2=length(find(y<=median(y)));
    if abs(l1-length(y)/2)<abs(l2-length(y)/2)
        indexL=find(y<median(y));
        indexH=find(y>=median(y));
    else
        indexL=find(y<=median(y));
        indexH=find(y>median(y));
    end
    [info.keywords, s]=keywordsTest(s,index(indexL),index(indexH),0,'low','high');
end

info.trainDataStat=infoSave.trainDataStat;
info.predDataStat=infoSave.predDataStat;
info.pred=nan(1,length(isNotNan));
info.data=nan(1,length(isNotNan));

info.pred(isNotNan)=pred;
info.data(isNotNan)=y;



try
    info.textPredHigh=textPredHigh;
    info.textPredLow=textPredLow;
    info.textDataHigh=textDataHigh;
    info.textDataLow=textDataLow;
end

try
    [tmp1, parPersistent]=getPar;
    parPersistent.setParPersistent;
    info.noneDefaultParameters=regexprep(struct2text(parPersistent.setParPersistent),char(13),' ');
    %info.par=regexprep(struct2text(par),char(13),' ');
end

%List and order significant dimensions
for i=1:Ndim
    [rDim(i), pDim(i)]=nancorr(y,xnorm(:,i));
end
indexKeep=find(pDim<.05);
label=label(indexKeep);
pDim=pDim(indexKeep);
[tmp indexDim]=sort(pDim);
info.significantDimensions=cell2string(label(indexDim));

if s.par.trainSemanticKeywordsFrequency>0
    if s.par.trainSemanticKeywordsFrequency==10
        indexW=unique(indexWall);
    else
        [stmp,f1,f1WC]= mkfreq(s,indexWithNaN);
        indexW=find(f1>0);
        [predW,~,~,s]=getProperty(s,propertySave,indexW);
        
        %Here we should use leave-out-predictions!
        %indexW=indexW(indexW<=s.N);
        %predW=getProperty(s,propertySave,s.fwords(indexW));
        predWall=[];indexWall=[];
        for i=1:length(indexW)
            fW(i)=f1(indexW(i));
            predWall=[predWall predW(i)*ones(1,f1(indexW(i)))];
            indexWall=[indexWall i*ones(1,f1(indexW(i)))];
        end
    end
    indexNonZero=find(not(predWord(:,:)==0));
    predWordMean=nanmean(predWord(indexNonZero));
    predWordVar=nanvar(predWord(indexNonZero));
    for i=1:length(indexW)
        indexI=not(indexWall==i);
        if s.par.trainSemanticKeywordsFrequency==10 %Takes care of one-leave out. Not tested
            %Here we assume that the variance is the same for all items!
            %Consider using a t-test directly here instead - with equal variance assumption.
            indexI=not(indexWall==indexW(i));
            f1=length(find(not(indexI)));
            z(i)=(nanmean(predWall(not(indexI)))-nanmean(predWall(indexI)))/(nanvar(predWall)/(length(predWall)-f1)+nanvar(predWall)/f1)^.5;
            
        elseif s.par.trainSemanticKeywordsFrequency>=3 %WRONG Leavout
            N2=size(predWord);
            if indexW(i)>N2(2)
                z(i)=NaN;
            else
                indexNonZeroI=find(not(predWord(:,indexW(i))==0));
                z(i)=(nanmean(predWord(indexNonZeroI,indexW(i))) -predWordMean)/(predWordVar/(length(indexNonZero)-length(indexNonZeroI))+predWordVar/length(indexNonZeroI))^.5;
                if s.par.trainSemanticKeywordsFrequency==4 & length(indexNonZeroI)>0
                    z(i)=(nanmean(predWord(indexNonZeroI,indexW(i))) -predWordMean)/(predWordVar/(length(indexNonZero)-length(indexNonZeroI))+nanvar(predWord(indexNonZeroI,indexW(i)))/length(indexNonZeroI))^.5;
                end
            end
        elseif s.par.trainSemanticKeywordsFrequency==1 %Standard
            %Here we assume that the variance is the same for all items!
            %Consider using a t-test directly here instead - with equal variance assumption.
            z(i)=(predW(i)-nanmean(predWall(indexI)))/(nanvar(predWall)/(length(predWall)-f1(indexW(i)))+nanvar(predWall)/f1(indexW(i)))^.5;
        elseif s.par.trainSemanticKeywordsFrequency==2 %Standard without frequency
            z(i)=(predW(i)-nanmean(predWall(indexI)))/(nanvar(predWall)/(length(predWall)-f1(indexW(i))))^.5;
        end
    end
    if 0 %Mapping back data from words to texts
        z2(indexW)=z;
        predW2(indexW)=predW;
        for i=1:length(y)
            indexTmp=s.info{index(i)}.index;
            indexTmp=indexTmp(indexTmp>0);
            if 1
                tmp=predWord(not(i==1:length(y)),indexTmp);
                tmp=tmp(tmp>0);
                predByZ(i)=nanmean(nanmean(tmp));
            else
                %predByZ(i)=nanmean(z2(indexTmp));
                %predByZ(i)=nanmean(predW2(indexTmp));
                w=2*(normcdf(abs(z2(indexTmp)))-.5);
                w=w.^.75;
                w=w/sum(w);
                predByZ(i)=sum(predW2(indexTmp).*w);
            end
        end
        %This seems to give somewhat better preditions, i.e. r=0.64 rather
        %than 0.60
        fprintf('%.3f\n',nancorr(y,predByZ'));
    end
    
    if s.par.trainSemanticKeywordsFrequency==5
        index1=find(y<nanmean(y));
        index2=find(y>=nanmean(y));
        pred1=mean(predW(index1));
        pred2=mean(predW(index2));
        z(index1)=(predW(index1)-pred2)/(std(pred)/length(predW)^.5);
        z(index2)=(predW(index2)-pred1)/(std(pred)/length(predW)^.5);
    end
    w.pTrain=info.p;w.r=info.r;
    w.p=tcdf(-abs(full(z)),length(predWall)-2);
    if s.par.keywordCorrectionType==0 %bonferroni
        pW=w.p*length(predWall);
    elseif s.par.keywordCorrectionType==2 %uncorrected
        pW=w.p;
    else %Holme's
        [~,indexSort ]=sort(f1(indexW),'descend');
        for i=1:length(indexSort)
            pW(indexSort(i))=w.p(indexSort(i))/i;
        end
    end
    [ ~,indexSort]=sort(z,'descend');
    i=0;
    info.wordsHigh='';
    indexSort=indexSort(length(find(isnan(z)))+1:end);
    try
        while i<length(indexSort) & pW(indexSort(i+1))<.05;
            i=i+1;
            info.wordsHigh=[info.wordsHigh s.fwords{indexW(indexSort(i))} ' ' sprintf('%.4f',pW(indexSort(i))) ' ' ];
        end
    catch
        1;
    end
    z(isnan(z))=0;
    [ ~,indexSort]=sort(z);
    i=0;
    info.wordsLow='';
    try
        while i<length(z) & pW(indexSort(i+1))<.05;
            i=i+1;
            info.wordsLow=[info.wordsLow s.fwords{indexW(indexSort(i))} ' ' sprintf('%.4f',pW(indexSort(i))) ' '];
        end
    end
    w.z1=z;
    w.pcorrected=pW;
    w.p=w.p;
    w.word=stmp.fwords(indexW);
    w.q=z;%Should be NaN?
    w.z=z;%Should be NaN?
    w.indexW=indexW;
    w.f=fW;
    w.pred=predW;
    if not(s.par.excelServer)
        i=word2index(s,propertySave);
        indexSave=not(z==0);
        s.info{i}.z=z(indexSave);
        s.info{i}.zIndex=indexW(indexSave);
        s.info{i}.zM=nanmean(predWall);
        s.info{i}.zS=(nanvar(predWall)/length(predWall)+nanvar(predWall))^.5;
    end
    %w.f1=f1(indexW);
    %w.f2=0*f1(indexW);
    %z1 q pcorrected p word
end

info.pOutlinersRemoved=pOutlinersRemoved;
info.rOutlinersRemoved=rOutlinersRemoved;
info.results=regexprep(struct2text(info,[],0),'par.','');
info.results=addComments(info.results,s);

if not(s.par.excelServer) %Add stepwisefit
    [b,se,pval,inmodel,stats,nextstep,history] = stepwisefit(xnorm,y);
    [~,iSort]=sort(stats.TSTAT,'descend');
    info.results=[info.results sprintf('\nStepwise regression: %s\n',propertySave)];
    info.results=[info.results sprintf('i\tmodel\tp\tt\tinmodel\tr\n')];
    for j=1:min(20,length(inmodel))
        i=iSort(j);
        info.results=[info.results sprintf('%d\t%s\t%.4f\t%.4f\t%d\t%.4f\n',i,d.label{i},stats.PVAL(i),stats.TSTAT(i),inmodel(i),nancorr(xnorm(:,i),y))];%,infoAll{i}.r
    end
end

if s.par.excelServer
else %if par.extendedOutput
    %fprintf('%s',info.results);
    showOutput({info.results},['Train: ' info.modelName])
%else
%    fprintf('p=%.4f model=%s\n',info.p,info.modelName);
end
info.pRankOrder=pRankOrder;
info.rRankOrder=rRankOrder;
try;info.w=w;end

[info.resultNumeric info.resultsString]=resultsVariables(info,s.par.resultsVariables,info.p);
if length(info.resultsString)==0; info.resultsString=num2str(info.resultNumeric);end


function res=printList(label,num1,num2,text,type)
[tmp index]=sort(num1,type);
res=sprintf('\n%s (%s)\n',label,type);
for i=1:min(10,length(num1))
    tmp=regexprep(text{index(i)},char(13),char(32));
    tmp=tmp(1:min(1000,length(tmp)));
    s=sprintf('%.3f\t%.3f\t%s\n',num1(index(i)),num2(index(i)),tmp);
    res=[res s];
end
%fprintf('%s',res)

function [indexDim  correl par]=optimize_dim(xdata,y,index,subject,par,label)
if nargin<4
    subject=[];
end
if not(isempty(subject)) & std(subject)==0 %There has to be at least two groups!
    subject=rand(1,length(subject))>.5;
end
dim=0;i=0;
[tmp maxDim]=size(xdata);
[tmp Ndim]=size(xdata);
text='';
if maxDim>length(y)/2 & par.forceMaxDimToN2;
    maxDim=fix(.5+length(y)/2);
    text=[text sprintf('Setting maximal number of dimensions to N/2=%d : ',maxDim)];
end
%if par.forceMaxDim>0 & 0
%    maxDim=par.forceMaxDim;
%end

rDim=1;dim_op=1;
ok=1;
par.ridgeK=.01;
par.Lambda=1;%.04*2*2*2*2;
model.r=1;
modelSave=par.model;
if strcmp(par.model,'logistic')
    par.model='';
end

while ok
    i=i+1;
    if strcmp(par.model,'ridge')
        dim=maxDim;
        par.ridgeK=2*par.ridgeK;
        ok=par.ridgeK<25000;
        ridgeK(i)=par.ridgeK;
        text=[text sprintf('ridgeK=%.4f ',ridgeK(i))];
    elseif strcmp(par.model,'lasso')
        dim=maxDim;
        par.Lambda=par.Lambda/1.5;
        Lambda(i)=par.Lambda;
        ok=par.Lambda>.000625/2.2;
        if abs(max(rDim)*.85)>abs(model.r) & length(rDim)>2
            ok=0;
        end
        text=[text sprintf('Lambda=%.4f ',Lambda(i))];
    else
        dim=min(maxDim,round((dim+1)*1.3));    
        text=[text sprintf('d=%d ',dim)];
        ok=dim<maxDim;
    end
    dim_op(i)=dim;
    if isempty(xdata)
        rDim(i)=NaN;
        pDim(i)=NaN;
    else
        model=regression(xdata(:,1:dim),y,par,'oneleaveout',subject,1:dim,Ndim);
        x=model.x;
        rDim(i)=model.r;
        pDim(i)=model.p;
    end
    text=[text sprintf('r=%.3f ',rDim(i))];
    %text=[text sprintf('d=%d r=%.3f ',dim,rDim(i))];
end
[tmp i]=max(rDim);
correl=rDim(i);
dim=dim_op(i);

indexDim=1:dim;
par.model=modelSave;

if strcmp(par.model,'ridge')
    par.ridgeK=ridgeK(i);
elseif strcmp(par.model,'lasso')
    par.Lambda=Lambda(i);
elseif par.selectBestDimensions %Find dimension with higest correlation...
    r=nan(1,length(y));
    p=r;
    for i=1:Ndim
        if not(isempty(xdata(:,i)))
            [r(i) p(i)]=nancorr(xdata(:,i),y);
        else
            r(i)=NaN;
            p(i)=NaN;
        end
    end
    [tmp index]=sort(p);
    indexDim=index(1:dim);
    text=[text sprintf('\nSelecting dimensions: %s\n',cell2string(label(indexDim)))];
end

text=[text sprintf('Optimal: d=%d ',dim)];

if par.extendedOutput & par.excelServer==0
    fprintf('%s\n',text);
end




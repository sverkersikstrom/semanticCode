function [s par info texts]=scriptTrain(s,par,func);
%clear and set default paramters
%par.dataFile='projectEuropeOksmall2';
%par.langFile={'spaceEnglish2','lang projectEuropeEnglish'};
%par.variableToCreateSemanticRepresentationFrom='_Q20goodLeaderen _Q21importantIssuesen _Q22primeMinister _Q23feelingen';
%par.trainVariables='_QS3 _QS34';
info=[];texts='';
if isfield(par,'dataFile') & iscell(par.dataFile)
    dataFile=par.dataFile;
    for i=1:length(dataFile)
        par.dataFile=dataFile{i};
        [s, ~, info, texts]=scriptTrain([],par,func);
    end
    return
end
global useUnderScoreInName;
if isfield(par,'useUnderScoreInName') useUnderScoreInName=par.useUnderScoreInName;end
if not(isfield(par,'readDataFile')) par.readDataFile='';end
if not(isfield(par,'condition_string')) par.condition_string='';end
if not(isfield(par,'redo')) par.redo=0;end
if not(exist('results')==7) mkdir('results'); end
if nargin==0
    s=[];
    par=[];
end
if not(isempty(s)) 
    parSave=s.par; 
else
    getPar(par,'clear');
    parSave=getPar;
end
%getPar(par,'persistent');

if nargin<3 & not(isfield(par,'func'))
    par.func={'train'};
elseif nargin>=3
    par.func=func;
end

if isempty(par.func)
    par.func={'train'};
end
if ischar(par.func) par.func={par.func};end

if not(isfield(par,'dataFile'))
    dataFile=dir('*.xlsx');
    par.dataFile=regexprep(dataFile(1).name,'.xlsx','');
    fprintf('Missing data file, assuming: par.dataFile=''%s'';\n',par.dataFile);
    %fprintf(' exixting!\n'); return
end
if not(isfield(par,'langFile'))
    langFile=dir('lang *.mat');
    if isempty(langFile) 
        par.langFile=['lang ' par.dataFile];
    else
        par.langFile=regexprep(langFile(1).name,'.xlsx','');
    end
    if isempty(par.langFile)
        par.langFile=['lang ' par.dataFile];
    end
    fprintf('Missing space file, assuming: par.langFile=''%s'';\n',par.langFile);
    %return
elseif iscell(par.langFile)
    langFile=par.langFile;
    for i=1:length(langFile)
        par.langFile=langFile{i};
        [s par]=scriptTrain(s,par,func);
    end
    return
end

i=findstr('/',par.dataFile);
if isempty(i); i=0;end
i2=findstr('.',par.dataFile);
if isempty(i2)
    dataFileExtension='.xlsx';
else
    dataFileExtension=par.dataFile(i2:end);
    par.dataFile=par.dataFile(1:i2-1);
end

par.dataFilePath=par.dataFile;
par.dataFile=par.dataFile(i(end)+1:end);

%Set parameters:
if nargin<2
    %par.dataFile='PartiLedareExpSmall2';
    %dataFile='data';%Debug data
    %par.trainVariables='_sv1	_ss2	_sc3	_sl4	_sm5	_skd6	_smp7	_ssd8	_sfi9	_sannat10	_sblankt11	_sinte12	_svetej13';
    par.trainVariables='_rv1	_rs2	_rc3	_rl4	_rm5	_rkd6	_rmp7	_rsd8	_rfi9	_rannat10	_rblankt11	_rinte12	_rvetej13';
    %MP IL, L JB, KD EBT, M UK,
    par.variableToCreateSemanticRepresentationFrom='_textmpt1	_textlt1	_textkdt1	_textmt1	_textmpt2	_textlt2	_textkdt2	_textmt2	_textilt1	_textjbt1	_textebtt1	_textukt1 _textilt2	_textjbt2	_textebtt2	_textukt2	_fragorviktiga';
elseif ischar(par);
    warning off;par.dataFile=par;warning on;
end

parInit=par;

for k=1:length(parInit.func)
    fprintf('%s\n',par.func{k});
    if isfield(par,'par') & not(isempty(par.par)) & length(par.par)>=k
        par=structCopy(parInit,par.par{k});
    else
        par=parInit;
    end
    if strcmpi(par.func{k},'createSpace') %Create Space
        par.langFile=['lang ' par.dataFile];
        if not(exist([par.langFile '.mat'])) | par.redo
            s=createSpace([par.dataFile '.txt'],[],[],par);
            %movefile([s.languagefile '.mat'],[par.langFile '.mat']);
            showOutput({s.spaceInfo})
            getSpace('set',s);
            par.readData=1;
        end
    elseif nargin<1
        s=[];
    elseif ischar(s)
        par.spaceFile=s;s=[];
    end
    
    if not(isfield(par,'spaceFile'))
        par.spaceFile=['space ' par.langFile '-' par.dataFile];
        fprintf('Missing space file: par.spaceFile=''%s'';\n',par.spaceFile);
        %fprintf(' exixting!\n'); return
    end

    if not(isfield(par,'readData')) par.readData=0; end
    if not(isfield(par,'readNorm')) par.readNorm=0; end
    if not(isfield(par,'readDataAdd')) par.readDataAdd=[]; end
    
    if isfield(s,'x') & strcmp(s.languagefile,par.langFile) &  not(par.readData) & not(strcmpi(par.func{k},'createSpace')) & length(par.readDataFile)==0 %& strcmpi(s.datafile,[par.spaceFile '-' regexprep(par.langFile,'space','')])
        fprintf('Keeping space file: %s\n',s.datafile)
    elseif not(isfield(s,'x')) | (isfield(s,'data') & s.data==0)
        par.askForInput=0;
        %getPar(par,'persistent');
        par.langFile=regexprep(par.langFile,'.mat','');
        par.spaceFile=regexprep(par.spaceFile,'.mat','');
        dataFile=['report-' par.langFile '-' par.dataFile '.mat'];

        ok=not(exist([par.spaceFile '.mat']));
        if ok | par.readData %| strcmpi(par.func{k},'createSpace') %|?(isfield(par,'restart') & par.restart)
            s=getReport([par.dataFilePath dataFileExtension],par.langFile,0);
            saveReport(s,par.spaceFile);%par.spaceFile
        else
            %Load the report
            s=getReport(dataFile,[],0);
            %s=getReport([par.dataFile '.mat']);
        end
        if par.readNorm | length(par.readDataFile)>0
            if par.readNorm
                s.par.openNormFileMultipel=1;
                s.par.openNormFile='norm';
                par.readDataFile='norm.xlsx';
            end
            s=getReport(par.readDataFile,s,0);
            saveReport(s,par.spaceFile);%par.spaceFile
        end
    end
    s.par=structCopy(getPar,par);
    
    if not(isfield(par,'variableToCreateSemanticRepresentationFrom'))
        par.variableToCreateSemanticRepresentationFrom=s.par.variableToCreateSemanticRepresentationFrom;
    end
    variableToCreateSemanticRepresentationFrom=string2cell(par.variableToCreateSemanticRepresentationFrom);

    
    if not(isfield(par,'trainVariables'))
        ok=[];
        for i=1:length(s.var.name)
            ok(i)=isempty(findstr(s.var.name{i},'_pred'));
        end
        par.trainVariables=cell2string(s.var.name(find(ok)));%s.var.name
        %par.trainVariables=cell2string(getIndexCategory(12,s));%s.var.name
    end
    if strcmp(s.par.BERT,'LSA') 
        languagefile=regexprep(s.languagefile,'.mat','');
    else
        languagefile=s.par.BERT;
    end
    filename=[par.func{k} '-' languagefile '-' par.dataFile '-' s.par.condition_string '-' par.variableToCreateSemanticRepresentationFrom(1:min(end,30)) '-' par.trainVariables(1:min(20,length(par.trainVariables))) num2str(keyGenerator(par)) '.txt'];
    filename=regexprep(filename,char(9),' ');
    
    par.variableToCreateSemanticRepresentationFromRepeted=1;
    %par.extendedOutput=0;
    par.contextPrintLabels=0;
    
    %Set variables
    s.par.plotAutoSaveFigure=1;
    s.par=structCopy(s.par,par);
    %Load texts
    
    resultsExist=exist(['results-' filename]) & not(par.redo);
    if isfield(par,'texts')
        texts=par.texts;
    elseif not(resultsExist)
        [texts s]=getWord(s,[fixpropertyname(['_' par.dataFile],s) '*'],[],par.condition_string);
    else
        texts='';
    end
    
    if resultsExist 
        f=fopen(['results/results-' filename],'r','n','UTF-8');
        a=[];
        while not(feof(f))
            a=[a fgets(f)];
        end
        showOutput({a},par.func{k});
    elseif strcmpi(par.func{k},'getProperty') %getProperty
        properties=string2cell(par.properties);
        
        for l=1:length(variableToCreateSemanticRepresentationFrom)
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{l};
            
            r=getProperty(s,properties,texts.index)';
            
            %Print table data
            res=sprintf('text(%s)\t',s.par.variableToCreateSemanticRepresentationFrom);
            for i=1:length(properties)
                res=[res sprintf('%s\t',properties{i})];
            end
            res=[res sprintf('\n')];
            
            for i=1:length(texts.index)
                res=[res sprintf('%s\t',texts.fwords{i})];
                for j=1:length(properties)
                    res=[res regexprep(sprintf('%.4f\t',r(i,j)),'NaN','')];
                end
                res=[res sprintf('\n')];
            end
            warning off;mkdir('results');warning on;
            f=fopen(sprintf('results/getProperty-Table-%s-%s-%s.txt',languagefile, s.par.variableToCreateSemanticRepresentationFrom,datestr(now,'YYYY-mm-DD')),'w');
            fprintf(f,'%s',res);
            fclose(f);
            data.r{l}=r;
        end
        data.par=par;
        save(sprintf('results/getProperty-%s-%s',languagefile,datestr(now,'YYYY-mm-DD')),'data')
        showOutput({res},par.func{k});
    %'getProperty-correlation'
    %'getProperty-ttest'
    elseif strcmpi(par.func{k},'getProperty-correlation') | strcmpi(par.func{k},'getProperty-ttest')
        properties=string2cell(par.properties);
        
        %Mean and stderror
        res='';
        if isempty(variableToCreateSemanticRepresentationFrom)
            variableToCreateSemanticRepresentationFrom{k}='';
        end
        for l=1:length(variableToCreateSemanticRepresentationFrom)
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{l};
            res=[res sprintf('%s\t',variableToCreateSemanticRepresentationFrom{l})];
            resStd='';m='';labels='';N='';
            for i=1:length(properties)
                r{i}.r=getProperty(s,properties{i},texts.index);
                labels=[labels sprintf('%s\t',properties{i})];
                m=[m sprintf('%.3f\t',nanmean(r{i}.r))];
                resStd=[resStd sprintf('%.4f\t',nanstd(r{i}.r)/length(find(not(isnan(r{i}.r))))^.5)];
                N=[N sprintf('%.3f\t',sum(not(isnan(r{i}.r))))];
            end
            
            res=[res sprintf('\nlabels\t%s\n\nmean\t%s\nstd\t%s\nN\t%s\n\n%s matrix\nlabels\t%s\n',labels,m,resStd,N,par.func{k},labels)];
            p= sprintf('labels\t%s\n',labels);
            for i=1:length(properties)
                res=[res sprintf('%s\t',properties{i})];
                p=[p sprintf('%s\t',properties{i})];
                for j=1:i-1
                    if strcmpi(par.func{k},'getProperty-ttest')
                        [~,p2,ci,stats]=ttest2(r{i}.r',r{j}.r');
                        r2=stats.tstat;%regexprep(struct2text(stats),char(13),' ');
                    else
                        [r2,p2]=nancorr(r{i}.r',r{j}.r');
                    end
                    res=[res sprintf('%.3f\t',r2)];
                    p=[p sprintf('%.3f\t',p2)];
                end
                res=[res sprintf('\n')];
                p=[p sprintf('\n')];
            end
            res=[res sprintf('\np-values\n%s\n',p)];
        end
        showOutput({res},par.func{k})
    %'getProperty-ttest-mediansplit'
    elseif strcmpi(par.func{k},'getProperty-ttest-mediansplit') 
        %Ttest on the first variable (1), using median-split on the follwoing variabels (2:N) 
        properties=string2cell(par.properties);
        if isfield(par,'propertiesSplit')
            propertiesSplit=string2cell(par.propertiesSplit);
            propertiesTest=properties;
        else
            propertiesSplit=properties(2:end);
            propertiesTest{1}=properties{1};
        end
        
        %Mean and stderror
        res='';
        if isempty(variableToCreateSemanticRepresentationFrom)
            variableToCreateSemanticRepresentationFrom{k}='';
        end
        for l=1:length(variableToCreateSemanticRepresentationFrom)
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{l};
            for i=1:length(propertiesSplit)
                res=[res sprintf('T-test on numerical variable(s) %s, using texts in %s and median split on numerical varables: \t%s\n',cell2string(propertiesTest),variableToCreateSemanticRepresentationFrom{l},propertiesSplit{i})];
                resStd='';m='';m1='';m2='';mp1='';mp2='';labels='';N1='';N2='';
                rSplit{i}.r=getProperty(s,propertiesSplit{i},texts.index);
                index1=getMedianSplit(rSplit{i}.r');
                index2=not(index1);
                for j=1:length(propertiesTest)
                    rTest{j}.r=getProperty(s,propertiesTest{j},texts.index);
                    if not(isfield(par,'medianSplitCriteria')) par.medianSplitCriteria=nanmean(rTest{j}.r); end
                    labels=[labels sprintf('%s (high)\t',propertiesTest{j})];
                    m=[m sprintf('%.3f\t',nanmean(rTest{j}.r))];
                    m1=[m1 sprintf('%.3f\t',nanmean(rTest{j}.r(index1)))];
                    m2=[m2 sprintf('%.3f\t',nanmean(rTest{j}.r(index2)))];
                    mp1=[mp1 sprintf('%.3f\t',nanmean(rTest{j}.r(index1 & not(isnan(rTest{j}.r))')>par.medianSplitCriteria))];
                    mp2=[mp2 sprintf('%.3f\t',nanmean(rTest{j}.r(index2 & not(isnan(rTest{j}.r))')>par.medianSplitCriteria))];
                    resStd=[resStd sprintf('%.4f\t',nanstd(rSplit{i}.r)/length(find(not(isnan(rSplit{i}.r))))^.5)];
                    N1=[N1 sprintf('%.3f\t',sum(not(isnan(rSplit{i}.r(index1)+rTest{j}.r(index1)))))];
                    N2=[N2 sprintf('%.3f\t',sum(not(isnan(rSplit{i}.r(index2)+rTest{j}.r(index2)))))];
                end
                res=[res sprintf('labels\t%s\nmean\t%s\nmean(low)\t%s\nmean(high)\t%s\np(>mean)(low)\t%s\np(>mean)(high)\t%s\nSE\t%s\nN(low)\t%s\nN(high)\t%s\n\n%s matrix\nlabels\t%s\n',labels,m,m1,m2,mp1,mp2,resStd,N1,N2,par.func{k},labels)];
                p= sprintf('labels\t%s\n',labels);
                for i1=1:length(propertiesTest)
                    res=[res sprintf('%s(low)\t',propertiesTest{i1})];
                    p=[p sprintf('%s(low)\t',propertiesTest{i1})];
                    for j=1:length(propertiesTest)
                        %index1=getMedianSplit(rSplit{i1}.r');
                        %index2=not(getMedianSplit(rSplit{j}.r'));
                        [~,p2,ci,stats]=ttest2(rTest{i1}.r(index1)',rTest{j}.r(index2)');
                        r2=stats.tstat;%regexprep(struct2text(stats),char(13),' ');
                        res=[res sprintf('%.3f\t',r2)];
                        p=[p sprintf('%.3f\t',p2)];
                    end
                    res=[res sprintf('\n')];
                    p=[p sprintf('\n')];
                end
                res=[res sprintf('\np-values\n%s\n',p)];
                
            end
            
        end
        showOutput({res},par.func{k})
        
    elseif strcmpi(par.func{k},'cluster') %cluster
        clusterProperties=s.par.clusterProperties;
        s.par.clusterProperties=par.trainVariables;
        s.par.clusterQuality=1;
        s.par.clusterFuzzyKMeans=1;
        s.par.number_of_ass2=30;
        [s, info,resultTabel]=clusterSpace(s,texts.index);%,N,clustercategory)
        s.par.clusterProperties=clusterProperties;
        showOutput({info.results},['Cluster:']);
        f=fopen(['clusters-' filename],'w');fprintf(f,resultTabel);fclose(f);
    elseif strcmpi(par.func{k},'semanticTest') %semanticTest
        textId=textscan(s.par.variableToCreateSemanticRepresentationFrom,'%s');textId=textId{1};
        
        [yIndex s]=getWord(s,par.trainVariables);
        if length(yIndex)>0
            y=getProperty(s,texts.index,yIndex.index);
            results='';
            res=sprintf('Semantic test\nVariabel\tr\tp\n');
            for j=1:yIndex.N                
                if yIndex.N>0
                    index1=y(:,j)>nanmedian(y(:,j));
                    index2=y(:,j)>=nanmedian(y(:,j));
                    if abs(length(index1)/2-length(find(index2)))>abs(length(index1)/2-length(find(index1)))
                        index=index1;else index=index2;
                    end
                    [out,s]=semanticTest(s,texts.index(find(index)),texts.index(not(index)),['high ' yIndex.word_clean{j}],['Low ' yIndex.word_clean{j}]);
                    if out.p<.05/yIndex.N
                        sign='**';
                    elseif out.p<.05
                        sign='*';
                    else
                        sign='';
                    end                        
                    results=[results out.results];
                    res=[res sprintf('%s\t%.3f\t%.4f\t%s\n',yIndex.word_clean{j},out.r,out.p,sign)];
                    info{j}=out;
                end
            end
            res=[res results];
            showOutput({res},['Semantic tests:']);
        else
            for i=1:length(textId)
                parC{i}=s.par;
                texts.input_clean=[texts.input textId{i}];
                textsC{i}=texts;
                parC{i}.variableToCreateSemanticRepresentationFrom=textId{i};
            end
            semanticTestMultiple(s,textsC,parC)
        end
    elseif strcmp(par.func{k},'plotMap') | strcmp(par.func{k},'plotMapCorr')
        countries=getText(s,texts.index,par.plotCountry,0);
        u=unique(countries);uok=u;
        if not(isfield(par,'plotMapMedianSplit')) par.plotMapMedianSplit='';end
        if length(par.plotMapMedianSplit)>0
            rplotMapMedianSplit=getProperty(s,par.plotMapMedianSplit,texts.index);
        end
        for j=1:length(variableToCreateSemanticRepresentationFrom)
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{j};
            
            r=getProperty(s,par.properties,texts.index);
            z=(r-nanmean(r))/nanstd(r);
            res=[];
            if length(par.plotMapMedianSplit)>0
                [~,pAll,ci,stats]=ttest2(r(find(rplotMapMedianSplit==0)),r(find(not(rplotMapMedianSplit==0))));
                res=sprintf('Ttest p=%.5f, df=%d, t1=%.3f, t2=%.3f\n',pAll,stats.df,nanmean(r(find(rplotMapMedianSplit==0))),nanmean(r(find(not(rplotMapMedianSplit==0)))));
            end
            if strcmp(par.func{k},'plotMapCorr')
                [rAll, pAll]=nancorr(r',rplotMapMedianSplit');
                res=sprintf('Correlation r=%.3f p=%.5f, df=%d, t1=%.3f, t2=%.3f\n',rAll, pAll);
            end
            
            try;close(1);end;figure(1);
            bordersm;
            set(gca,'Xlim',[-1.03768e+06 3.02448e+06])
            set(gca,'Ylim',[3.5133e+06 8.0798e+06])
            res=[res sprintf('question\tcountry\tmean\tstdError\tcolorCode\tN\n')];
            for i=1:length(u)
                index=strcmpi(u{i},countries);
                if length(par.plotMapMedianSplit)>0
                    indexMedianSplit=index & rplotMapMedianSplit==0;
                    NindexMedianSplit=num2str(length(find(indexMedianSplit)));
                    p(i)=NaN;
                    if strcmp(par.func{k},'plotMapCorr')
                        [r(index) p(i)]=nancorr(r(index)',rplotMapMedianSplit(index)');
                        z(index)=r(index);
                    %elseif NindexMedianSplit<50 | length(find(index))-length(indexMedianSplit)<50
                    %    r(index)=NaN;%Not enough data
                    %    z(index)=NaN;
                    else
                        r(index)=r(index)-nanmean(r(indexMedianSplit));
                        z(index)=z(index)-nanmean(z(indexMedianSplit));
                        [crit, p(i)]=ttest2(r(indexMedianSplit),r(index & not(rplotMapMedianSplit==0)));
                    end
                else
                    NindexMedianSplit='';
                end
                zmean=nanmean(z(index));
                z01(i)=min(1,max(0.1,zmean*2+.5));
                if strcmpi(u{i},'Irland') uok{i}='Ireland';end
                if strcmpi(u{i},'Belgium (french)') uok{i}='Belgium';end
                if strcmpi(u{i},'Belgium (dutch)') uok{i}='Belgium';end
                N=length(not(isnan(r(find(index)))));
                res=[res sprintf('%s\t%s\t%.2f\t%.2f\t%.2f\t%d\t%s\t%.4f\n',s.par.variableToCreateSemanticRepresentationFrom,u{i},nanmean(r(index)),nanstd(r(index))/N^.5,z01(i),N,NindexMedianSplit,p(i))];
                if p(i)<=.05
                    bordersm(uok{i},'facecolor',[1 1-z01(i) 1])
                end
            end
            mapName=['figure/' par.func{k} '-' regexprep(languagefile,'.mat','') '-' s.par.variableToCreateSemanticRepresentationFrom '-'  par.properties '-' par.condition_string '-' par.plotMapMedianSplit ];
            fprintf(res);
            f=fopen([mapName '.txt'],'w');
            fprintf(f,res);
            fclose(f);
            title(regexprep([mapName '.png'],'_',''))
            hgx(1,'',mapName);
        end
    elseif not(isempty(findstr(par.func{k},'plot')))
        %Load text variables
        [yIndex s]=getWord(s,par.trainVariables);
        %Get training data
        [y,yWord]=getProperty(s,yIndex.index,texts.index);y=y';yWord=yWord';
        %[y,yWord]=getProperty(s,texts.index,yIndex.index);
        for i=1:size(y,2)
            yNorm(:,i)=(y(:,i)-nanmean(y(:,i)))/nanstd(y(:,i));
        end
        %s.par.plotTestType='semantic';%options semantic semanticTest train frequency frequency-correlation property%Choose how the semantic scale is calculated
        %s.par.plotCloudType='words';%options words users category histogram%Plot words, users, or categories
        %s.par.plotCategory='semanticLIWC' ;
        dataTabel='';
        for j=1:length(variableToCreateSemanticRepresentationFrom)
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom{j};
            
            %Plot word cloud of all words
            if strcmp(par.func{k},'plot0d') % | strcmpi(par.func{k},'plot')
                %s.par.plotWordcloud=1;
                [out,h,s]=plotWordCloud(s,texts.index);
            else   
                %s.par.plotWordcloud=0;
                %Plot one dimension based on trainvariables
                for i=1:yIndex.N %size(y,2)
                    if not(isempty(findstr(lower(par.func{k}),'nominal')))
                        plotNominal=s.par.plotNominal;
                        s.par.plotNominal='nominal';
                        [out,h,s]=plotWordCloud(s,texts.index,{y(:,i)'},[],yIndex.fwords(i));
                        s.par.plotNominal=plotNominal;
                    elseif 0 %Difference between one item and mean of all other items
                        [out,h,s]=plotWordCloud(s,texts.index,{y(:,i)' - mean(y(:,not(1:size(y,2)==i))')},[],{[yIndex.fwords{i} '-ALL']});
                    elseif strcmp(lower(par.func{k}),'plot2d') %2d plot
                        if i==1
                            [out,h,s]=plotWordCloud(s,texts.index,{y(:,1) y(:,2)},[],yIndex.fwords);
                        end
                    elseif strcmp(lower(par.func{k}),'plotliwc') %2d plot
                        s.par.plotCloudType='category';%options words users category histogram%Plot words, users, or categories
                        s.par.plotCategory='semanticLIWC';%options Functions Clusters Prediction semanticLIWC LIWC Semantic-dimensions Semantic-scales Wordclasses Texts Words Stopwords Variables Norms User-defined%Choose the category of identifiers to plot
                        [out,h,s]=plotWordCloud(s,texts.index,{y(:,i)'},[],yIndex.fwords(i));
                    else %plot1d
                        [out,h,s]=plotWordCloud(s,texts.index,{y(:,i)'},[],yIndex.fwords(i));
                    end
                    dataTabel=[dataTabel sprintf('\n%s\t%s\n%s\n\n',variableToCreateSemanticRepresentationFrom{j},yIndex.fwords{i},out.dataTabel);];
                end
            end            
        end
        f=fopen(['figure/dataTabel-' filename],'w');
        fprintf(f,'%s\n',dataTabel);fclose(f);
        
        if 0
            %Subtracting all pairwise measures:
            for i1=1:size(y,2)
                for i2=i1+1:size(y,2)
                    [out,h,s]=plotWordCloud(s,texts.index,{yNorm(:,i1)' - yNorm(:,i2)'},[],{[yIndex.fwords{i1} '-' yIndex.fwords{i2}]} );
                end
            end

            %Wordcloud (no axis)
            %s.par.plotCluster=1;%Use cluster
            %s.par.Ncluster=4;
            %s.par.plotTestType='frequency-correlation';%options semantic semanticTest train frequency frequency-correlation property%Choose how the semantic scale is calculated
            
            s.par.plotCloudType='words';
            s.par.plotWordcloud=1;
            [out,h,s]=plotWordCloud(s,texts.index );
            
            %Subtracting two measures:
            i1=1;i2=2;
            i1=2;i2=3;
            s.par.plotWordcloud=0;
            s.par.plotCloudType='words';
            [out,h,s]=plotWordCloud(s,texts.index,{yNorm(:,i1)' - yNorm(:,i2)'},[],{[yIndex.fwords{i1} '-' yIndex.fwords{i2}]} );
            
            %One measures for x-axis and one measure for y-axis:
            i1=3;i2=4;
            s.par.plotCloudType='words';
            [out,h,s]=plotWordCloud(s,texts.index,{y(:,i1)',y(:,i2)' },[],{[yIndex.fwords{i1}],[yIndex.fwords{i2}]} );
            
            %Subtracting two measures for x-axis and two measure for y-axis:
            i1=4;i2=3;i3=1;i4=4;s.par.plotCloudType='words';
            [out,h,s]=plotWordCloud(s,texts.index,{yNorm(:,i1)' - yNorm(:,i2)',yNorm(:,i3)' - yNorm(:,i4)'},[],{[yIndex.fwords{i1} '-' yIndex.fwords{i2}],[yIndex.fwords{i3} '-' yIndex.fwords{i4}]} );
            
        end
        
    elseif strcmpi(par.func{k},'train')
        %Load text variables
        [yIndex s]=getWord(s,par.trainVariables);
        %Get training data
        y=getProperty(s,texts.index,yIndex.index);
        if isfield(par,'train2medianSplit') & par.train2medianSplit
            y=1*(y>nanmedian(y));
        end
        %Set output variables
        if strcmpi(s.par.BERT,'LSA')
            predPrefix='_pred';
        else
            predPrefix='_predBERT';            
        end
        for i=1:length(yIndex.fwords)
            propertySave{i}=fixpropertyname([predPrefix yIndex.fwords{i} s.par.trainModelName],s);
        end
        s.par.trainModelName='';
        %Train texts on the y-variable for variables in propertysave
        if isfield(par,'trainAddNoise')
            y=y+par.trainAddNoise*(rand(length(y),1)-.5);
        end
        [s info xnorm resultTabel]=train(s,y,propertySave,texts.index);
        %filename=[regexprep(filename,'.txt','') par.trainVariables(1:min(25,length(par.trainVariables))) '.txt'];
        f=fopen(['results/predictions-' filename],'w');fprintf(f,resultTabel);fclose(f);
    elseif strcmpi(par.func{k},'IRT')
        [yIndex s]=getWord(s,par.trainVariables);
        y=getProperty(s,texts.index,yIndex.index);
        out=IRT(s,texts.index,y,yIndex.fwords); 
        %filename=[regexprep(filename,'.txt','') par.trainVariables(1:min(50,length(par.trainVariables))) '.txt'];
        saveas(2,['figure ' regexprep(filename,'.txt','')],'jpg')
        saveas(3,['figure Histogram ' regexprep(filename,'.txt','')],'jpg')
    elseif strcmpi(par.func{k},'save')
        s.par.askForInput=0;
        saveReport(s);
    end
    
    if not(resultsExist)
        %Save the results
        saveResult(['results/results-' filename]);
    end
end
s.par=parSave;
beep

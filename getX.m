function [d, s,y]=getX(s,index,par,train,y,group,numericalData)
%y=Only used in contextNorimalizeBySubject and then it z-transformed by
%subject
if not(isfield(s.par,'recursive')) s.par.recursive=0;end
xnorm=[];

if nargin<3 | isempty(par)
    s=updateContext(s,index);
    par=s.par;
else
    parSave=s.par;
    s.par=par;
    s=updateContext(s,index);
    s.par=parSave;
end
index(index>s.N)=NaN;



if nargin<4 train=[];end
if nargin<6 group=[];end
if nargin<7 numericalData=[];end

if not(isfield(par,'indexSubtract')) par.indexSubtract=[];end

if ischar(par.predictionProperties)
    par.predictionProperties=string2cell(par.predictionProperties);
end
d.train.par=par;
if s.par.semanticSelectWordsToSelectedWords>0
    f=[];
    text='';
    for i=1:length(index)
        [s,f]= mkfreq(s,index(i),f);
        text=[text ' ' getText(s,index(i))];
    end
    Nmin=2;
    text=cell2string(s.fwords(find(f>=s.par.semanticSelectWordsToSelectedWords)));
    fprintf('Limting possible associates to (Nmin=%d): %s\n',Nmin,text)
    s.par.semanticSelectWords=text;
end


label=[];
%if par.forceMaxDim<1 | par.forceMaxDim>s.Ndim
%    par.forceMaxDim=s.Ndim;
%end
s.par.SVDNleaveOut=0;

if length(s.par.space2)>0 %Read space2
    s2=getSpace('space2',s);
    s2.par.space2='';
    if s2.data==0
        %s2.par.variableToCreateSemanticRepresentationFrom='';
        index2=word2index(s2,s.fwords(index));
        for i=1:length(index)
            if length(s.par.variableToCreateSemanticRepresentationFrom2)>0
                text1{i}=getText(s ,index(i),s.par.variableToCreateSemanticRepresentationFrom2);
            else
                text1{i}=getText(s ,index(i),s.par.variableToCreateSemanticRepresentationFrom);
            end
            text2{i}=getText(s2,index2(i),s.par.variableToCreateSemanticRepresentationFrom);
            indexAdd(i)=not(strcmpi(text1{i},text2{i}));
            if indexAdd(i)
                info{i}=s.info{index(i)};
                info{i}.par.contextVariables='';
            else
                info{i}=s2.info{index(i)};
            end
            type{i}='_text';
        end
        [s2 newword]=setProperty(s2,s.fwords(index(indexAdd)),type(indexAdd),text1(indexAdd),info(indexAdd));
        index2=word2index(s2,s.fwords(index));
        s2=updateContext(s2,index2);
        [d2 s2]=getX(s2,index2,s2.par);
        getSpace('set2',s2);
        d=d2;
        s=s2;
        return
        
        xnorm2=d2.x;
        
        %Add labels
        N2=size(xnorm2);
        for i=1:length(d2.label)
            label{length(label)+1}=['space2' d2.label{i}];
        end
        
    else
        index2=word2index(s2,s.fwords(index));
        index2=word2index(s2,s.fwords(index));
        xnorm2=NaN(length(index2),s2.Ndim);
        notNan=find(not(isnan(index2)));
        xnorm2(notNan,:)=s2.x(index2(notNan),:);
        
        %Print errors
        if length(notNan)<length(index2)
            fprintf('Missing %d of %d identifiers in %s\n',length(index2)-length(notNan),length(index2),s.par.space2)
        end
        %Add labels
        N2=size(xnorm2);
        for i=1:N2(2)
            label{length(label)+1}=['dim' s.par.space2 num2str(i)];
        end
        
    end
    
    
    %Interleave space and space2
    xnorm=[xnorm xnorm2];
    clear index3
    for i=1:min([N(2) N2(2)])
        index3(i*2-1)=i;
        index3(i*2)=i+N(2);
    end
    index3=[index3 min([N(2) N2(2)])+1:max([N(2) N2(2)])];
    xnorm=xnorm(:,index3);
    label=label(index3);
end

if 0 & length(par.trainOnCrossValidationOfMultipleTexts)>0
    %par=s.par;
    trainOnCrossValidationOfMultipleTexts=par.trainOnCrossValidationOfMultipleTexts;
    trainOnCrossValidationOfMultipleTexts=strread(trainOnCrossValidationOfMultipleTexts,'%s');
    s.par.trainOnCrossValidationOfMultipleTexts='';
    numericalDataAll=[];
    propertySave3{1}=regexprep(par.trainModelName,s.par.variableToCreateSemanticRepresentationFrom(2:end),'');
    
    for i=1:length(trainOnCrossValidationOfMultipleTexts)
        s.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
        for j=1:length(propertySave3)
            propertySave2=fixpropertyname([propertySave3{j} s.par.variableToCreateSemanticRepresentationFrom]);
            label=[label {[propertySave2 'crossvalidation']}];
            info.pred=getInfo(s,index,word2index(s,[propertySave2 'crossvalidation']));
            
            if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                [s info xnorm]=train(s,y,propertySave2,index,group);%,numericalData,[]
            else
                fprintf('Reading %s ',propertySave2);
                info.r=s.info{word2index(s,propertySave2)}.r;
            end
            numericalDataAll=[numericalDataAll info.pred'];
        end
    end
    
    if s.par.trainOnDiffCrossValidationOfMultipleTexts
        for i=1:length(trainOnCrossValidationOfMultipleTexts)
            s.par.variableToCreateSemanticRepresentationFrom=trainOnCrossValidationOfMultipleTexts{i};
            for j=i+1:length(trainOnCrossValidationOfMultipleTexts)
                s.par.subtractSemanticRepresentation=trainOnCrossValidationOfMultipleTexts{j};
                propertySave2=fixpropertyname([propertySave s.par.variableToCreateSemanticRepresentationFrom s.par.subtractSemanticRepresentation]);
                label=[label {[propertySave2 'crossvalidation']}];
                info.pred=getInfo(s,index,word2index(s,[propertySave2 'crossvalidation']));
                
                if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                    [s info xnorm]=train(s,y,propertySave2,index,group,numericalData,covariates,indexSubtract);
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
            label=[label {[propertySave3 'crossvalidation']}];
            
            info.pred=getInfo(s,index,word2index(s,[propertySave3 'crossvalidation']));
            
            if mean(isnan(info.pred))>.6 | s.par.trainOnCrossValidationOfMultipleTextsRetrain
                [s info xnorm]=train(s,y,propertySave3,index,group,numericalData,covariates,indexSubtract);
            else
                fprintf('Reading WF-SVD %s ',propertySave3);
                info.r=s.info{word2index(s,propertySave3)}.r;
            end
            numericalDataAll=[numericalDataAll info.pred'];
        end
        s.par=parWFSVD;
    end
    %s.par=par;
    %s.par.trainOnCrossValidationOfMultipleTexts='';
    %s.par.predictionProperties=[regexprep(par.predictionProperties,'_semantic','') ''];
    if isfield(s.par,'trainPropertySave') & 0
        for i=1:length(s.par.trainPropertySave)
            [info.pred,~,s]=getProperty(s,[s.par.trainPropertySave{i} 'crossvalidation'],index);
            if mean(isnan(info.pred))<.6 & not(strcmpi(s.par.trainPropertySave{i},propertySave))
                numericalDataAll=[numericalDataAll info.pred'];
                %infoAll=[infoAll {info}];
            end
        end
    end
    %s.par.trainOnCrossValidationOfMultipleTextsRecall=trainOnCrossValidationOfMultipleTexts;
    %s.par.variableToCreateSemanticRepresentationFrom='';
    %s.par.numericalDataLabels=trainOnCrossValidationOfMultipleTexts;
    xnorm=numericalDataAll;
    
    %[s info xnorm]=train(s,y,propertySave,index,group,numericalDataAll,covariates,indexSubtract);
    
    
    %s.par=par;
    
elseif isfield(par,'data') %Add par.data
    xnorm=par.data;
    %elseif isempty(find(strcmpi(par.predictionProperties,'_semantic'))) & isempty(find(strcmpi(par.predictionProperties,'_space')))
    %Remove semantic data if _semantic is absent...
    %fprintf('Removing the semantic dimensions from the predictions! (use _semantic in prediction properties to include them');
    %    xnorm=[];
else
    %Add data from semantic representation
    if length(index)==1 & isnan(index)
        %index=[];
        xnorm=nan(length(index),1:s.Ndim);
        %xnorm=[];
    elseif s.par.SVDNleaveOut %SVD crossvalidation
        name=[ regexprep(s.datafile,'space','')];
        if exist(['countCorpus' name '.mat'])
            load(['countCorpus' name]);%load c
            c.par=s.par;
            c=mkHash(c,2);
            sNew=initSpace;
            sNew.par=s.par;
            sNew.par.LSAaddFeatureFile=[name(2:end) '.txt'];
            sNew.par.LSAIndex=index2word(s,index);
            sNew2=createSpaceSCD(c,sNew);
        else
            sNew2=createSpaceFromContext(s,index,name);
        end
        for i=1:length(index)
            xnorm(i,:)=text2space(sNew2,getText(s,index(i)));
        end
    elseif isempty(par.variableToCreateSemanticRepresentationFrom)
        xnorm=[];
    elseif not(strcmpi(s.par.BERT,'LSA'))
        %Creating hash table is needed
        [s xnorm]=getXBERT(s,index);
    else
        %if par.forceMaxDim>0 & par.forceMaxDim<s.Ndim
        %    xnorm=s.x(index,1:par.forceMaxDim);
        %    if s.par.normalizeSpace
        %        xnorm=normalizeSpace(xnorm);
        %    end
        %else
        xnorm=nan(length(index),size(s.x,2));
        indexOk=not(isnan(index)) & index<=s.N;
        xnorm(indexOk,:)=s.x(index(indexOk),:);
        if isnan(nanmean(nanmean(xnorm)))
            fprintf('Warning text variable: %s, has no semantic representations!\n',s.par.variableToCreateSemanticRepresentationFrom)
        end
        %         if par.forceMaxDim<s.Ndim & s.par.normalizeSpace
        %             xnorm=normalizeSpace(xnorm);
        %         end
    end
    %end
    %end
    
    if par.parametersForTrainUpperMedianSplit
        global parametersForTrainUpperMedianSplit;
        parTmp=s.par;
        s.par=parametersForTrainUpperMedianSplit;
        s=updateContext(s,index);
        s.par=parTmp;
        xnorm2=nan(length(index),size(s.x,2));
        xnorm2(indexOk,:)=s.x(index(indexOk),:);
        xnorm=[xnorm; xnorm2];
        y=[zeros(1,length(y)) ones(1,length(y))]';
        index=[index index];
    end
    
    N=size(xnorm);
    for i=1:N(2)
        label{i}=['dim' num2str(i)];
    end
    
    if not(isempty(par.indexSubtract))
        %Add subtract data from semantic representation
        if not(length(par.indexSubtract)==length(index))
            fprintf('The number of subtracted identifiers must match the number added identifiers,exiting\n')
            return
        end
        xnorm=xnorm-s.x(par.indexSubtract,:);
    end
    par.variableToCreateMultipleSemanticRepresentationFrom=string2cell(par.variableToCreateMultipleSemanticRepresentationFrom);
    for i=1:length(par.variableToCreateMultipleSemanticRepresentationFrom)
        for j=1:length(index)
            id=fixpropertyname([s.fwords{index(j)} par.variableToCreateMultipleSemanticRepresentationFrom{i}]);
            k=word2index(s,id);
            if isnan(k) & isfield(s.info{index(j)},par.variableToCreateMultipleSemanticRepresentationFrom{i}(2:end))
                text=eval(['s.info{index(j)}.' par.variableToCreateMultipleSemanticRepresentationFrom{i}(2:end) ';']);
                [s k id2]=addText2space(s,text,id,[]);
            end
            index2(j)=k;
        end
        index2(isnan(index2))=word2index(s,'_nan');
        xnorm=[xnorm  s.x(index2,:)];
        for j=1:s.Ndim
            label=[label {['_dim' num2str(j) par.variableToCreateMultipleSemanticRepresentationFrom{i}]} ];
        end
    end
end

if isfield(par,'wc') & par.wc>0 & s.par.recursive==0 %Prediction divided by wordclass....
    fprintf('\nSelecting wordclass: %s\n',s.classlabel{par.wc});
    d.Nwordsfound=0;
    weightWordClass=s.par.weightWordClass;
    s.par.weightWordClass=0;
    s.par.weightWordClass(par.wc)=1;
    s=updateContext(s,index);
    for i=1:length(index)
        xnorm(i,:)=s.x(index(i),:);
        if isfield(s.info{index(i)},'wordclass')
            d.Nwordsfound=d.Nwordsfound+length(find((s.info{index(i)}.wordclass==par.wc)));
        else
            d.Nwordsfound=NaN;
        end
    end
    s.par.recursive=1;
    [tmp,~,s]=getProperty(s,'_nwords',index);
    d.nWords=nansum(tmp);
    s.par.recursive=0;
    s.par.weightWordClass=weightWordClass;
elseif par.expandWordClass %Expand on wordclasses....
    xnorm=nan(length(index),length(s.classlabel)*s.Ndim);
    label{length(s.classlabel)*s.Ndim}='';
    for i=1:length(index)
        [a s]=getWordClassCash(s,index(i));
        for j=1:length(s.classlabel)
            indexWC=find(j==a.wordclass & not(isnan(a.index)));
            if not(isempty(indexWC))
                xnorm(i,(j-1)*s.Ndim+1:j*s.Ndim)=average_vector(s,s.x(a.index(indexWC),:));
            end
        end
    end
    if not(par.preprocessWithSVD)
        fprintf('Activating SVD preprocessing!\n')
        par.preprocessWithSVD=1;
    end
end

%Add word frequency vector....
if s.par.trainOnWordFrequency
    f=sparse(length(index),s.N);
    fN=sparse(length(index),s.N);
    for i=1:length(index)
        [s,tmp]= mkfreq(s,index(i));
        fN(i,1:length(tmp))=tmp;
        f(i,1:length(tmp))=tmp/(max(1,sum(tmp)));
    end
    d.train.fwords=s.fwords(s.N:s.N);
    if isempty(train)
        %d.train.indexWF=find(nansum(fN)>1);%THIS WORKS BETTER WITH SVD!!!
        d.train.indexWF=find(nansum(f)>0);
    else
        d.train.indexWF=train.indexWF;
    end
    N1=max(d.train.indexWF);
    N2=size(f);
    if N1>N2(2)
        f(1,N1)=0;
    end
    f=f(:,d.train.indexWF);
    for i=1:length(d.train.indexWF)
        label=[label [s.fwords(d.train.indexWF(i))]];
    end
    xnorm=[xnorm f];
end


%Add numerical data to the prediction
if length(par.predictionProperties)>0
    variableToPreprocessCreateSemanticRepresentationFrom=strread(par.variableToPreprocessCreateSemanticRepresentationFrom,'%s');
    for i=1:length(par.predictionProperties)
        if not(strcmpi(par.predictionProperties{i},'_semantic')) & not(strcmpi(par.predictionProperties{i},'_space'))
            label=[par.predictionProperties(i) label];
            fprintf('Adding properties to the prediction:');
            fprintf('%s\t',par.predictionProperties{i});
            if s.par.recursive==0
                s.par.recursive=1;
                [tmp,~,s]=getProperty(s,par.predictionProperties{i},index);tmp=tmp';
                if find(strcmpi(par.predictionProperties{i},variableToPreprocessCreateSemanticRepresentationFrom))
                    fprintf('Preprocessing by log+1.');
                    tmp=log(tmp+1);
                end
                if isnan(nanmean(tmp))
                    fprintf('Missing data on variabel: %s, setting this variable to zero: %s\t',par.predictionProperties{i});
                    tmp=zeros(length(tmp),1);
                end
                xnorm=[tmp xnorm];
                s.par.recursive=0;
            end
            fprintf('\n');
        end
    end
end

%Add numerical data, if any...
if not(isempty(train))
    %Retrieval - not training
    Ndata=size(train.par.numericalData);
    if mean(Ndata==size(s.par.numericalData))==1
        numericalData=s.par.numericalData;
    else
        %Move from getProperty here
        numericalData=nan(length(index),Ndata(2));
    end
elseif length(par.numericalData)>0
    Ndata=size(par.numericalData);
    numericalData=par.numericalData;
elseif size(numericalData)>0
    Ndata=size(numericalData);
else
    Ndata=[0 0];
end
if Ndata(2)>0
    if isfield(s.par,'numericalDataLabels') & length(s.par.numericalDataLabels)==Ndata(2)
        label=[s.par.numericalDataLabels label];
    else
        for i=1:Ndata(2)
            label2{i}=['data' num2str(i)] ;
        end
        label=[label2 label];
    end
    xnorm=[numericalData xnorm ];
end

if s.par.contextNorimalizeBySubject & s.par.recursive==0
    s.par.recursive=1;
    [group,~,s]=getProperty(s, fixpropertyname(par.groupingProperty),index);
    s.par.recursive=0;
    Ugroup=unique(group);
    for i=1:length(Ugroup)
        j=find(Ugroup(i)==group);
        xsubject=average_vector(s,xnorm(j,:));
        y(j)=y(j)-nanmean(y(j));
        for k=1:length(j)
            xnorm(j(k),:)=average_vector(s,xnorm(j(k),:)-xsubject);
        end
    end
end

%Remove NaNs...
if par.preprocessWithSVD & not(par.trainReplaceMissingDataWithMean) & isnan(mean(mean(xnorm)))
    fprintf('SVD requrires removing NaNs, doing that now....\n')
    par.trainReplaceMissingDataWithMean=1;
end

if par.trainReplaceMissingDataWithMean & isnan(mean(mean(xnorm)))
    N=size(xnorm);
    d.train.xmean(N(2))=NaN;
    count=0;rlabels=[];
    for i=1:N(2)
        isNaN=isnan(xnorm(:,i));
        if length(find(isNaN))>0
            rlabels=[rlabels ' ' label{i}];
            count=count+length(find(isNaN));
            if not(isempty(train))
                d.train.xmean(i)=train.xmean(i);
            else
                d.train.xmean(i)=nanmean((xnorm(:,i)));
            end
            if isnan(d.train.xmean(i)) d.train.xmean(i)=0;end
            xnorm(isNaN,i)=d.train.xmean(i);
        end
    end
    fprintf('Replacing %d of %d datapoints in variable(s): %s\n',count,N(1)*N(2),rlabels(1:min(length(rlabels),s.par.maxPrintedCharacters)));
end

%Add cluster
if isfield(s.par,'contextAddCluster') & not(isempty(s.par.contextAddCluster))
    if not(iscell(s.par.contextAddCluster))
        s.par.contextAddCluster={s.par.contextAddCluster};
    end
    xnorm0=xnorm;
    yFuzzy2=[];
    for j=1:length(s.par.contextAddCluster) %Loop of several layers
        yFuzzy2=[];
        for i=s.par.contextAddCluster{j}
            indexOk=not(isnan(mean(xnorm0')));
            yFuzzy=NaN(i,size(xnorm0,1));
            [clusterCentroid,yFuzzy(:,find(indexOk)),iterations] = fcm(xnorm0(indexOk,:),i,[s.par.clusterFuzzyKMeansUOverlapParmeter(min(end,j)) 500 1e-6 0]);
            yFuzzy2=[yFuzzy2 yFuzzy'];
            fprintf('Cluster %d mean(max(clustervalue))=%.2f\n',i,mean(max(yFuzzy)));
        end
        xnorm0=yFuzzy2;
    end
    for k=1:i;%Add labels on the last layer
        label=[{sprintf('Cluster%d-%d',i,i-k+1)} label];
    end
    xnorm=[yFuzzy2 xnorm];
end

%Save x prioer to preprocessing
if isfield(par,'trainSaveInfo') & par.trainSaveInfo
    d.xPre=xnorm;
end

%Preprocess with NNMF
if isfield(par,'preprocessWithNNMF') & par.preprocessWithNNMF
    fprintf('Preprocessing with Non-negative matrix factorization\n')
     xnorm(find(isnan(xnorm)))=nanmean(nanmean(xnorm));
    if not(isempty(train))
        fprintf('Prediction using Non-negative matrix factorization has not been tested\n')
        xnorm=xnorm(:,1:par.preprocessWithNNMF)*d.train.H;
    else
        [xnorm d.train.H] =nnmf(xnorm,par.preprocessWithNNMF);
    end
    N=size(xnorm);
    for i=1:N(2)
        label{i}=['NNMFdim' num2str(i)];
    end
end

%Preprocess with SVD
if par.preprocessWithPCA
    [coeff, xnorm, latent, tsquared, explained, mu] =pca(xnorm);
end

if par.preprocessWithSVD
    fprintf('Preprocessing with SVD...')
    N=size(xnorm);
    indexOk=not(isnan(mean(xnorm'))) & not(isinf(mean(xnorm')));
    if not(isempty(train))
        %xnorm=U* S* V';
        N=size(train.S);
        try
            tmp1=xnorm* inv(train.V');
        catch
            fprintf('Is this correct?\n')
            tmp1=xnorm(1:min(N),1:min(N))*inv(train.V(1:min(N),:)');
        end
        Sinv=inv(train.S(1:min(N),1:min(N)));
        U=tmp1(:,1:min(N))*Sinv;
    else
        [U d.train.S d.train.V]=svd(full(xnorm(indexOk,:)),'econ');
        d.train.S=sparse(d.train.S);
    end
    Ndim3=size(U);
    U=U(:,1:min(Ndim3(2),N(2)));
    xnorm=[];
    xnorm(not(indexOk),1:size(U,2))=NaN;
    xnorm(indexOk,1:size(U,2))=U;
    if N(1)<s.Ndim
        xnorm(1,s.Ndim)=0;
    end
    N=size(xnorm);
    for i=1:N(2)
        label{i}=['svddim' num2str(i)];
    end
    fprintf('done\n')
end



if 0 %Remove nans
    notNan=find(not(isnan(mean(xnorm'))));
    index=index(notNan);
    xnorm=xnorm(notNan,:);
end

if par.forceMaxDim>0 & s.par.normalizeSpace
    xnorm=normalizeSpace(xnorm(:,1:min(par.forceMaxDim,size(xnorm,2))));
end


d.x=xnorm;
d.label=label;
d.index=index;
if length(index)>0
    d.fwords{length(index)}='';
elseif size(d.x,1)>0
    d.fwords{size(d.x,1)}='';    
end
indexOk=not(isnan(index)) & index<=s.N;
d.fwords(indexOk)=s.fwords(index(indexOk));
for i=1:length(label)
    if length(d.label{i})>3 & strcmpi(d.label{i}(1:3),'dim')
        d.xInspace(i)=1;
    else
        d.xInspace(i)=0;
    end
end
[d.N tmp]=size(d.x);

if size(d.x,1)>0 & size(d.x,2)>0 & isnan(nanmean(d.x(1,1))) & isempty(nanmean(mean(d.x'))) & d.N>1
    fprintf('All predictors lacks have at least one missing variable!!!\nConsidering checking if there are text data in: %s\nif not change the parametes: s.par.variableToCreateSemanticRepresentationFrom\n',s.par.variableToCreateSemanticRepresentationFrom)
end

if s.par.contextPrintLabels & not(s.par.excelServer)
    fprintf('Dimensions (N=%d): ',length(label));
    for i=1:length(label)
        fprintf('%s ', label{i});
    end
    fprintf('\n');
end

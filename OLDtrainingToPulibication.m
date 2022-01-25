function pred=trainingToPublibiation
%save('myData')
load('myData')
for i=1:length(y)
    if predictionMade(i)==0
        %Create test-train groups
        includeTrain=ones(1,length(y));%Intialize to include all data
        includeTrain(i)=0;%Remove current data-point
%         if par.leaveOutCounterbalanced
%             %Counterbalance removeal, assumes binary 0/1 coding
%             includeTested=find(not(includeTrain));%None-trained data is tested on
%             if includeTrain(i)==1
%                 remove=-1;
%             elseif includeTrain(i)==0
%                 remove=1;
%             end
%             includeRemove=find(y==remove);
%             includeTrain(includeRemove(fix(rand*length(find(includeRemove))+1)))=not(remove);
%         else
            includeTrain(find(group==group(i)))=0;%Remove all data-points with idential subject property
            includeTested=find(not(includeTrain));%None-trained data is tested on
%        end
        
 %       if par.timeSerie
 %           includeTrain(find(time>time(i)-par.timeSerieOffset & not(isnan(time))))=0;%removes data points in the future...
 %       end
        isNotNanI=not(isnan(mean(shiftdim(xnorm,1))));
        includeTrain=find(includeTrain & isNotNanI);
        %if par.optimzeDimensionsConservative
            [dimUsed  c_o(i) par]=optimize_dim(xnorm(includeTrain,:),y(includeTrain),1:length(includeTrain),group(includeTrain),par,label);
        %else
        %    if par.forceMaxDimToN2
        %        dimUsed=dimSaved(1:min(end,fix(length(includeTrain)/2)));%Forces the number of dimensions to be half of the values in the prediction!
        %        if length(dimUsed)<dimSaved & i==1;
        %            fprintf('Forcing the number of used dimension to N/2\n');%,num2str(dimUsed));
        %        end
        %    end
        %end
        dimarray(includeTested)=length(dimUsed);
        regTrain=y(includeTrain);
        %if par.zTransform %z-Transform training data
        %    regTrain=(regTrain-mean(regTrain))/std(regTrain);
        %end
        model=regression([xnorm(includeTrain,dimUsed)],regTrain,par);
        xr=model.x;
        for j=1:length(includeTested)
            %try
                [pred(includeTested(j),1) predMutinomial(includeTested(j),:)]=predictReg(model,xnorm(includeTested(j),dimUsed),par);
                %if s.par.trainSemanticKeywordsFrequency==10
                %    [~, indexW]=getText(s,index(includeTested(j)));
                %    indexW=indexW(find(indexW>0));
                %    indexW=indexW(indexW<=s.N);
                %    predW=predictReg(model,s.x(indexW,dimUsed),par);
                %    %predW=getProperty(s,propertySave,s.fwords(indexW));
                %    %for i=1:length(indexW)
                %    predWall=[predWall predW];
                %    indexWall=[indexWall indexW];
                %    %end
                %end
                
                %if s.par.trainSemanticKeywordsFrequency>=3 
                %    [~, indexWord]=getText(s,index(includeTested(j)));
                %    indexWord=indexWord(indexWord>0);
                %    predWord(includeTested(j),indexWord)=predictReg(model,s.x(indexWord,dimUsed),par);
                %    indexZero=find(predWord(includeTested(j),indexWord)==0);
                %    predWord(includeTested(j),indexWord(indexZero))=0+1^15;
                %end
                predictionMade(includeTested(j))=1;
            %catch
            %    fprintf('No predicition made....\n')
            %end
        end
    end
end


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
if strcmpi(par.model,'logistic')
    par.model='';
end

while ok
    i=i+1;
    if strcmpi(par.model,'ridge')
        dim=maxDim;
        par.ridgeK=2*par.ridgeK;
        ok=par.ridgeK<25000;
        ridgeK(i)=par.ridgeK;
        text=[text sprintf('ridgeK=%.4f ',ridgeK(i))];
    elseif strcmpi(par.model,'lasso')
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

if strcmpi(par.model,'ridge')
    par.ridgeK=ridgeK(i);
elseif strcmpi(par.model,'lasso')
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

function [y yMultivariat]=predictReg(model,X,par);
if nargin<3 par.model='';end
if not(isfield(model,'model'))
    model.model='';
end
N=size(X);
yMultivariat=[];

if strcmpi(model.model,'logistic')
    if isempty(model.x)
        y=NaN(N(1),1);
    else
        N2=size(model.x);
        yMultivariat = mnrval(model.x,X(:,1:N2(1)-1));
        y=1-yMultivariat(:,1);
    end
elseif strcmpi(model.model,'ensemble') | strcmpi(model.model,'LDA')
    if not(isfield(model,'ens'))
        y=NaN;
    else
        y = predict(model.ens,X);
    end
elseif 1
    if isempty(model.x)
        y=NaN(N(1),1);
    else
        try
            y=[ones(N(1),1),X]*model.x;
        catch
            %if not(length(X)==length(model.x))
            y=NaN;fprintf('Miss-match of length of input (%d) to model/predictor (%d)\n',length(X)+1,length(model.x))
        end
    end
end
if isempty(yMultivariat)
    yMultivariat=y;
end

function [model pred]=regression(xdata,reg,par,ver,subject,dim,Ndim)
random=[];train=[];test=[];pred=[];
if nargin<3
    par=[];
end
if isempty(par)
    par.model='';
end 
if nargin<4
    ver='';
end
if nargin<5
    subject=[];
end
if nargin<6
    [N Ndim]=size(xdata);
    dim=1:Ndim;
end
if nargin<7
    [N Ndim]=size(xdata);
end

warning off all
if strcmpi(ver,'half') %Train half, test on other half
    [tmp random]=sort(rand(1,length(reg)));
    train=random(1:round(length(random)/2));
    test=random(round(length(random)/2+1:length(random)));
    clear tmp;clear random;
    x=[ones(length(train),1) xdata(train,:)]\reg(train);
    [r p]=nancorr([ones(length(test),1) xdata(test,:)]*x,reg(test),'tail','gt');
elseif strcmpi(ver,'oneleaveout') %Random mapping of words for bootstrapping  
    if isempty(subject)
        subject=1:length(reg);
    end
    uSubject=unique(subject);    
    pred=nan(length(reg),1);
    if not(isfield(par,'maxNleaveoutTesting'))
        par.maxNleaveoutTesting=length(uSubject);
    end
    for i=1:par.maxNleaveoutTesting
        include=not(uSubject(i)==subject);
        include_tested=find(not(include));
        include=find(include);
        model=regress2(xdata(include,:),reg(include),par);
        x=model.x;
        [pred(include_tested,1) predMultivariat(include_tested,:)]=predictReg(model, xdata(include_tested,:),par);
        %if not(isempty(temp))
        %    predMultivariat(include_tested,:) =temp;
        %end
    end
    include=find(not(isnan(pred+reg)));
    if isempty(include)
        r=NaN;p=NaN;x=NaN;
    elseif strcmpi(par.model,'logistic') & length(unique(reg(include)))>2
        N=size(predMultivariat(include,:));
        N2=size(predMultivariat);
        regM=zeros(N2);
        if min(reg(include))==0
            reg(include)=reg(include)+1;
        end
        for i=1:length(include)
            regM(include(i),reg(include(i)))=1;
        end
        [r p]=nancorr(reshape(predMultivariat(include,:),N(1)*N(2),1),reshape(regM(include,:),N(1)*N(2),1),'tail','gt');
    else
        [r p]=nancorr(pred(include),reg(include),'tail','gt');
    end
else %Real full regression
    model=regress2( xdata,reg,par);
    x=model.x;
    if isempty(reg)
        r=NaN;p=NaN;x=NaN;
    else
        %pred=[ones(length(reg),1) xdata]*(x);
        pred=predictReg(model,xdata,par);
        [r p]=nancorr(pred,reg,'tail','gt');
    end
end
warning on all
%xtmp=x;clear x;
%x([1 dim+1])=xtmp;
if length(x)<=Ndim & not(strcmpi(par.model,'logistic'));
    x(Ndim+1)=0;
end
model.x=x;model.r=r;model.p=p;


function model=regress2(X,Y,par)
if nargin<3
    par.model='';
end
x=[];stats=[];
if strcmpi(par.model,'logistic') %logistic regression
    try
        if min(Y)==0
            Y=Y+1;
        end
        [x dev stats]= mnrfit(X,Y) ;
    catch
        fprintf('Error during logistic fitting\n')
    end
elseif strcmpi(par.model,'ridge')  %Ridge regression 
    x = ridge(Y,[0*ones(1,length(Y))' X],par.ridgeK);
    stats=[];
elseif strcmpi(par.model,'similarity')  %Semantic similiarity 
    index=find(Y>mean(Y));
    if length(index)==1;
        x=X;
    else
        x = mean(X);
    end
    x=x/sum(x.^2)^.5;
    x=[0 x]';
    stats=[];
elseif strcmpi(par.model,'ensemble')  %Ensemble learning
    if isempty(Y)
        x=[];
    elseif strcmpi(par.trainEnsambleMethod,'bag')
        model.ens = fitensemble(X,Y,par.trainEnsambleMethod,par.trainNumberens,par.trainLearners,'type','regression');
    else
        model.ens = fitensemble(X,Y,par.trainEnsambleMethod,par.trainNumberens,par.trainLearners);
    end
elseif strcmpi(par.model,'lasso')  %Lasso
    %[x stats] = lasso([ones(1,length(Y))' X],Y,'CV',min(10,length(Y)));
    if not(isfield(par,'Lambda'))
        par.Lambda=.005;
    end
    %[x stats] = lasso(X,Y,'CV',min(10,length(Y)),'Lambda',par.Lambda);%'NumLambda',20);
    [x stats] = lasso(X,Y,'Lambda',par.Lambda,'RelTol',1e-6);%'NumLambda',20);
    %else
    %    [x stats] = lasso(X,Y,'CV',min(10,length(Y)),'NumLambda',20);
    %end
    model.x2=x;
    if not(isfield(stats,'IndexMinMSE'))
        stats.IndexMinMSE=1;
    end
    x=x(:,stats.IndexMinMSE);
    x=[stats.Intercept(stats.IndexMinMSE) ; x];
elseif strcmpi(par.model,'LDA')  %LDA
    model.ens = fitcdiscr(X,Y);
else %Regression is default
    warning off
    if isempty(Y)
        x=[];
    elseif nargout==1
        x = regress(Y,[ones(1,length(Y))' X]);
    else
        [x,BINT,R,RINT,STATS] = regress(Y,[ones(1,length(Y))' X]);
        warning on
        stats.beta=x;
        stats.p=STATS(3);
        stats.residd=R;
    end
    %x=X\Y;
end
model.x=x;
model.model=par.model;
model.stats=stats;

    





function [model pred]=regression(xdata,reg,par,ver,subject,Ndim,w)
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
if nargin<6 | isempty(Ndim)
    [~, Ndim]=size(xdata);
end
if nargin<7
    w=[];
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
    model=regress2( xdata,reg,par,w);
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
if length(x)<=Ndim & not(strcmpi(par.model,'logistic'));
    x(Ndim+1)=0;
end
model.x=x;model.r=r;model.p=p;




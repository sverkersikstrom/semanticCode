function [pred, modelSave]=trainToPublicationMini
%save('myData')
%Load data and make the call
load('myData')
[pred, modelSave]=trainToPublicationMini2(xnorm,y,par,group)

function [pred, modelSave]=trainToPublicationMini2(xnorm,y,par,group)

%train
dimUsed=optimize_dim(xnorm,y,1:length(y),group,par);
modelSave=regress2(xnorm(1:length(y),dimUsed),y,par);

%leavout cross validation
uGroup=unique(group);
for i=1:length(uGroup)
    %Divid into test and train dataset
    includeTrain=not(uGroup(i)==group);
    includeTested=find(not(includeTrain));%None-trained data is tested on
    isNotNanI=not(isnan(mean(shiftdim(xnorm,1))));
    includeTrain=find(includeTrain & isNotNanI);
    
    %Optimize dimensions
    dimUsed=optimize_dim(xnorm(includeTrain,:),y(includeTrain),1:length(includeTrain),group(includeTrain),par);
    
    %Train
    model=regression([xnorm(includeTrain,dimUsed)],y(includeTrain),par);
    
    %Make predictions
    pred(includeTested,1) =predictReg(model,xnorm(includeTested,dimUsed),par);
    predictionMade(includeTested)=1;
    
end
    

function indexDim =optimize_dim(xdata,y,index,subject,par)
dim=0;i=0;
[tmp maxDim]=size(xdata);
[tmp Ndim]=size(xdata);
if maxDim>length(y)/2 & par.forceMaxDimToN2;
    maxDim=fix(.5+length(y)/2);
end

while dim<maxDim
    i=i+1;
    dim=min(maxDim,round((dim+1)*1.3));
    dim_op(i)=dim;
    model=regression(xdata(:,1:dim),y,par,'oneleaveout',subject,1:dim,Ndim);
    rDim(i)=model.r;
    pDim(i)=model.p;
end
[tmp i]=max(rDim);
indexDim=1:dim_op(i);


function y =predictReg(model,X,par);
y=[ones(size(X,1),1),X]*model.x;

function [model pred]=regression(xdata,reg,par,ver,subject,dim,Ndim)
pred=[];
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

if strcmpi(ver,'oneleaveout') %Random mapping of words for bootstrapping
    if isempty(subject)
        subject=1:length(reg);
    end
    uSubject=unique(subject);
    pred=nan(length(reg),1);
    for i=1:length(uSubject)
        include=not(uSubject(i)==subject);
        include_tested=find(not(include));
        model=regress2(xdata(include,:),reg(include),par);
        pred(include_tested,1)=predictReg(model, xdata(include_tested,:),par);
    end
    include=find(not(isnan(pred+reg)));
    [model.r model.p]=nancorr(pred(include),reg(include),'tail','gt');
else %Real full regression
    model=regress2( xdata,reg,par);
    pred=predictReg(model,xdata,par);
    [model.r model.p]=nancorr(pred,reg,'tail','gt');
end
if length(model.x)<=Ndim & not(strcmpi(par.model,'logistic'));
    model.x(Ndim+1)=0;
end


function model=regress2(X,Y,par)
model.x = regress(Y,[ones(1,length(Y))' X]);
model.model=par.model;







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
elseif strcmpi(model.model,'trainRegression') 
    
    %Replace Nan with mean columnwise
    xTrainOk=model.xTrain;
    for c=1:size(model.xTrain,2)
        xTrainOk(isnan(model.xTrain(:,c)),c)=nanmean(model.xTrain(:,c));
    end
    
    %Regression
    for j=1:size(X,1)
        nan=isnan(X(j,:));
        leaveOut=true(1,size(X,1));leaveOut(j)=false;
        modelNew=regress2(xTrainOk(leaveOut,not(nan)),model.yTrain(leaveOut));
        %y(j)=predictReg(modelNew,X(j,not(nan)));
        y(j)=[1,X(j,not(nan))]*model.x;
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

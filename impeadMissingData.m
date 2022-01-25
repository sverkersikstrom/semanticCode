function [xImpedOk,N]=impeadMissingData(xTrain,xImped,type)
if nargin<3 type='imped';end
if strcmpi(type,'mean')
    %Replace Nan with mean columnwise
    xImpedOk=xImped;
    N=0;
    for c=1:size(xTrain,2)
        index=find(isnan(xImpedOk(:,c)));
        xImpedOk(index,c)=nanmean(xTrain(:,c));
        N=N+length(index);
    end
else
    %Replace Nan with mean columnwise
    xTrainOk=xTrain;
    for c=1:size(xTrain,2)
        xTrainOk(isnan(xTrain(:,c)),c)=nanmean(xTrain(:,c));
    end
    
    %Impead
    xImpedOk=xImped;
    N=0;
    for j=1:size(xImped,1)
        nan=isnan(xImped(j,:));
        for i=find(nan)
            model=regress2(xTrainOk(:,not(nan)),xTrainOk(:,i));
            N=N+1;
            xImpedOk(j,i)=predictReg(model,xImped(j,not(nan)));
        end
    end
end

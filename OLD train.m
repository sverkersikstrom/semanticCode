function [s info]= train(s,y,propertySave,wordsIndex,group,numericalData,covariates,indexSubtract)
if nargin<4
    group=[];
end 
if nargin<5
    group=[];
end
if nargin<6
    numericalData=[];
end
if nargin<7
    covariates=[];
end
if nargin<8
    indexSubtract=[];
end
[s info]=predictionMake(s,[],y',propertySave,wordsIndex,group,numericalData,covariates,indexSubtract);

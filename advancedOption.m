function s=advancedOption(s,parameters,weightTargetWord,weightWordClass,semanticDistance)
if not(isfield(s,'par')) s.par=getPar;end
if isempty(parameters) == false
    %s.par=structCopy(getPar,parameters,1);% s.par=parameters;
    s.par=structCopy(s.par,parameters,1);% s.par=parameters;
end

%If think we should the lines below, beacuse these variables should be set in parameters instead. And then also remove the inputs connected to them:
if nargin<3
    return
end

weightWordIndex='';
if isempty(weightTargetWord) == false
    s.par.weightTargetWord=weightTargetWord;
end
if isempty(weightWordClass) == false
    for i = 1:length(s.classlabel)
        s.par.weightWordClass(i)=0;
        if strcmp(s.classlabel(i),weightWordClass)
            weightWordIndex=i;
        end
    end
    s.par.weightWordClass(weightWordIndex)=1;
end
%Until here!

if isempty(semanticDistance) == false
    s.par.getPropertyShow=semanticDistance;
end
end
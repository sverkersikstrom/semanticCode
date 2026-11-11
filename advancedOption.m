function s=advancedOption(s,parameters,weightTargetWord,weightWordClass,semanticDistance)
if not(isfield(s,'par')) s.par=getPar;end
if isempty(parameters) == false
    %These parameters build shell commands, file paths or word splitting that keeps text out of
    %shell commands. They come from the web page here, so they are not accepted from it.
    if isstruct(parameters)
        names=fieldnames(parameters);
        blocked=names(strncmp(names,'DLATK',5) | ismember(names,{'parameterFile','rootPath','envObj','seperationCharacters'}));
        parameters=rmfield(parameters,blocked);
    end
    %s.par=structCopy(getPar,parameters,1);% s.par=parameters;
    s.par=structCopy(s.par,parameters,1);% s.par=parameters;
end
%A model name typed in BERTname overrides the model chosen in BERT
if isfield(s.par,'BERTname') && length(s.par.BERTname)>0
    s.par.BERT=strtrim(s.par.BERTname);
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
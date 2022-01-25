function par2=setInfoPar(par);
% par2.weightWordClass=par.weightWordClass;
% par2.weightTargetWord=par.weightTargetWord;
% par2.weightFrequency=par.weightFrequency;
% par2.stopwords=par.stopwords;
% par2.model=par.model;
% par2.xmeanCorrection=par.xmeanCorrection;
% par2.weightFirstNWords=par.weightFirstNWords;
% par2.weightRandomNWords=par.weightRandomNWords;
% par2.weightPrimacy=par.weightPrimacy;
if not(isfield(par,'weightByDate')) par.weightByDate='';end
%num2str(par.model) 
par2.contextVariables =[num2str(par.weightWordClass)  num2str(par.weightTargetWord) num2str(par.weightFrequency) num2str(par.stopwords) num2str(par.xmeanCorrection) num2str(par.weightFirstNWords) num2str(par.weightRandomNWords) num2str(par.weightPrimacy) num2str(par.weightWordPosition) num2str(par.weight) num2str(par.weightPower) num2str(par.weightLogNwords) num2str(par.updateNorms) par.variableToCreateSemanticRepresentationFrom par.weightByDate par.subtractSemanticRepresentation];
if length(par.variableToCreateSemanticRepresentationFrom)>0
    par2.variableToCreateSemanticRepresentationFrom=par.variableToCreateSemanticRepresentationFrom;
end
if length(par.subtractSemanticRepresentation)>0
    par2.subtractSemanticRepresentation=par.subtractSemanticRepresentation;
end



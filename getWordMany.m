function [o, s,par]=getWordMany(varargin)
N=1;i=0;par=[];
vararginMod=varargin;
o=[];
while N>0
    i=i+1;
    vararginMod{2}=[varargin{2} '. Set number ' num2str(i) '. Continue until Cancel.'];
    [wordset s]=getWordFromUser(vararginMod{:});
    par{i}=s.par;
    if length(wordset.input_clean)>30
        wordset.input_clean=['set' num2str(i)];
        if length(s.par.variableToCreateSemanticRepresentationFrom )>0
            wordset.input_clean=[wordset.input_clean '(' s.par.variableToCreateSemanticRepresentationFrom ')'];
        end
    end
    vararginMod{1}=s;
    N=wordset.N;
    if N>0
        o{i}=wordset;
    end
end
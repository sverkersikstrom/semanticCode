function [s N word]=addText2space(s,texts,word,info)
%Places 'texts' in the s-structure (and other data stored in info), using the identifier 'word', with text 'texts' 
N=[];
if nargin<4 info=[]; end

%if s.par.contextWildcardExpansion
%    textsExpanded=getWildcardExpansion(s, string2cell(texts));
%    texts=cell2string(textsExpanded);
%end

[x N Ntot t index s]=text2space(s,texts,word2index(s,word));

info.nwords=Ntot;
indexMissing=find(index==0);
if not(isempty(indexMissing)) & length(t)>0
    info.wordsMissing=t(indexMissing);
elseif isfield(info,'wordsMissing')
    info=rmfield(info,'wordsMissing');
end
if isfield(info,'wordclass')
    info=rmfield(info,'wordclass');
end
if not(isfield(info,'specialword'))
    info.specialword=9;
end
info.nwordsfound=N;
info.index=index;
%if s.par.contextWildcardExpansion & findstr(texts,'*')>0
%    info.context=cell2string(t);
%else
if length(s.par.variableToCreateSemanticRepresentationFrom)>0
    eval(['info.' s.par.variableToCreateSemanticRepresentationFrom(2:end) '=texts;']);
end
%else
%    info.context=texts;
%end
info.par=s.par;
[s,N,word]=addX2space(s,word,x,info);
s=updateContext(s,N);


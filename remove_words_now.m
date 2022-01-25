function [s sRest]=remove_words_now(s,include,quick);
if nargin<=2
    quick=0;
end

include=unique(include);
N=s.N-length(include);

exclude=ones(1,s.N);
exclude(include)=0;
if nargout>1
    sRest=remove_words_now(s,find(exclude));
    1;
end

if N==0; return; end

wordsRemove=s.fwords(find(exclude));
s.fwords=s.fwords(include);
s.x=s.x(include,:);
s.info=s.info(include);
s.f=s.f(include);
if s.par.variables & isfield(s,'var')
    if size(s.var.data,1)<max(include)
        s.var.data(max(include),:)=0;
    end
    s.var.data=s.var.data(include,:);
end
if isfield(s,'wordclass')
    if max(include)>length(s.wordclass) s.wordclass(max(include))=0;end
    s.wordclass=s.wordclass(include);
end
s.N=length(s.fwords);
%fprintf('Removed %d words\n',N);
if quick 
    try
        for i=1:length(wordsRemove)
            s.hash.remove(wordsRemove{i});
        end
        s=mkHash(s,2);
    catch
        fprintf('Error removing words %d\n',i);
        s=mkHash(s,1);
    end
else
    s=mkHash(s,1);
end


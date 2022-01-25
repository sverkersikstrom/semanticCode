function [indexWord t s]=text2index(s,texts,index);
if nargin>2  & length(s.info)<=length(index) & isfield(s.info{index},'index') & not(s.par.text2indexIgnore)
    indexWord=s.info{index}.index;
    indexOk=indexWord>0;
    ok=1;
    t(indexOk)=s.fwords(indexWord(indexOk));
    if isfield(s.info{index},'wordsMissing')
        if isfield(s,'wordsMissingIndex') & length(s.wordsMissingIndex)>=index & length(find(not(indexOk)))==length(s.wordsMissingIndex{index})
            indexWord(not(indexOk))=s.wordsMissingIndex{index};
        else
            indexWord(not(indexOk))=word2index(s,s.info{index}.wordsMissing);
        end
        s.wordsMissingIndex{index}=indexWord(not(indexOk));
        t(not(indexOk))=s.info{index}.wordsMissing;
    elseif length(find(not(indexOk)))>0
        ok=0;
    end
    if ok
        return
    end
end
t=text2token(s,texts);

indexWord=word2index(s,t);


function t=text2token(s,texts);
if isempty(texts) | isnan(texts);
    texts='';
end
t=regexprep(lower(texts),[char(9) '[^a-z??? 0-9_]'],'');
for i=1:length(s.par.seperationCharacters)
    t=regexprep(t,['\' s.par.seperationCharacters(i)],[' ' s.par.seperationCharacters(i) ' ']);
end
t=regexprep(t,'(\d)+\ +\.+\ (\d)','$1.$2');

if length(t)>0
    t=regexprep(t,char(160),' ');
    t=regexprep(t,char(255),' ');%Fixes strange bug, 2014-09-11
    t=string2cell(t);
end




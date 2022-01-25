function [index1 index2]=word2index(s,word,removeNaN)
try;word=lower(word);end
if ischar(word)
    temp=word;clear word;
    word{1}=temp;
end

if isempty(word)
    index1=NaN;
elseif iscell(word)
    out=nan(1,length(word));
    for i=1:length(word)
        if not(isempty(word{i})) & length(strtrim(word{i}))>0
            tmp=s.hash.get(strtrim(lower(word{i})));
            if isempty(tmp) & rand<0.001 %This code should be removed.... given that everything works fine!
                tmp=find(strcmpi(s.fwords,strtrim(word{i})));
                if not(isempty(tmp>0))
                    fprintf('This hash problem should NOT occur!: %s\n',word{i});
                    %stop
                end
            elseif not(isempty(tmp)) & (tmp>length(s.fwords) | not(strcmpi(s.fwords(tmp),word{i})) ) 
                tmp=find(strcmpi(s.fwords,strtrim(word{i})));
            end
            if length(tmp)>1
                tmp=tmp(1);
            end
            if not(isnan(tmp))
                out(i)=tmp;
            end
        end
    end
    index1=out;
else
    index1=word;
end
index2=1:length(index1);
if nargin>=3 & removeNaN
    index2=index2(not(isnan(index1)));
    index1=index1(not(isnan(index1)));
end


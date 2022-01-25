function [x,x1, wordOut, ok, index]=wordstring2vector(s,string);
%Takes a string of words and outputs vector & indexes!
word=string2cell(string);
x=nan(1,s.Ndim);
wordOut=word;

ok=0;index=[];
wordLoop=word;
for k=1:length(wordLoop)
    if findstr(wordLoop{k},'*')>0
        wordOut='';ok=0;select=[];
        a=regexprep(wordLoop{k},'*','\\w*');
        if wordLoop{k}(end)=='*'
            a=['^' a];
        end
        select=find(not(cellfun(@isempty,regexp(lower(s.fwords(:)),lower(a)))))';
        ok=length(select)>0;
        i=s.N;
        try
            word=[word(1:k-1) s.fwords(select) word(k+1:end)];
        catch
            word=[word(1:k-1)' s.fwords(select) word(k+1:end)'];
        end
    end
end

N=length(word);
ok=NaN(1,N);
index=ok;
x=NaN(N,s.Ndim);
for k=1:N
    if not(isempty(findstr(word{k},'*')))
    else
        [x(k,:) ok(k) index(k)]=getXword(s,word{k});
        wordOut{k}=word{k};
        index(k)=index(k);
    end
end
x1=average_vector(s,x);

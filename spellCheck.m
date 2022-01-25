function [ok suggestion minError]=spellCheck(s,word)
persistent d
i=word2index(s,word);
if not(isnan(i)) %Correct spelling
    ok=1;suggestion=word;minError=0;return
end

if isempty(d) | not(strcmpi(s.filename,d.filename))
    d.filename=s.filename;
    d.w=NaN(1,length(s.N));
    for i=1:s.N
        d.w(i)=s.fwords{i}(1);
    end
end
iCheck=find(word(1)==d.w);%Limit search to same first character
1;


ok=0;
value=100000;
minError=10000;


for i=iCheck %1:s.N
    newValue=error(word,s.fwords{i},value)-s.f(i);
    if minError>newValue
        j=i;minError=newValue;
    end
end
suggestion=s.fwords{j};

    
function value=error(word1,word2,stop)
value=max(0,length(word2)-length(word1));
i=0;ldiff=0;
while value<stop & i<length(word1)
    i=i+1;
    d=find(word1(i)==word2);
    if isempty(d) %Missing character add 1
        value=value+1;
    elseif 0 %Moved character add 1 per position
        tmp=min((d-i));
        if tmp<0
            diff1(i)=tmp;
        else
            diff2(i)=tmp;
        end
    else %Moved character add 1 per position
        diff=min(abs(d-i));
        if not(ldiff==diff)
            value=value+diff;
        end
    end
    ldiff=diff;
end

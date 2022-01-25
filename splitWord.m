function [ok, word1, word2]=splitWord(s,word)
%Split word into two best matching peaces
if nargin<1 
    s=getSpace;
end
if nargin<2
    word='himmelsgott';
end

f=zeros(1,length(word)-2);
f2=f;
for i=1:length(word)-3
    index1=word2index(s,word(1:i+1));
    index2=word2index(s,word(i+2:end));
    if not(isnan(index1)) & not(isnan(index2))
        f(i)=s.f(index1)+s.f(index2);
    end
    if word(i+2)=='s'
        index3=word2index(s,word(i+3:end));
        if not(isnan(index1)) & not(isnan(index3))
            f2(i)=s.f(index1)+s.f(index3);
        end
    end
end
[maxF,isplit]=max(f);
[maxF2,isplit2]=max(f2);
if maxF>0 | maxF2>0
    if maxF>maxF2
        word1=word(1:isplit+1);
        word2=word(isplit+2:end);
    else
        word1=word(1:isplit2+1);
        word2=word(isplit2+3:end);
    end
    ok=1;
else
    ok=0;
    word1=word;
    word2='';
end

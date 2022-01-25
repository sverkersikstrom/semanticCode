function [s i]=extractContext(s,targetWord,text,info,i);
[index word]=text2index(s,text);
[indexTarget]=text2index(s,targetWord);
indexT=find(index==indexTarget(1));

window=15;
for j=1:length(indexT);
    ok=1;
    if length(indexTarget)>1 
        for k=2:length(indexTarget)
            if indexT+k-1<=length(index) & not(indexTarget(k)==index(indexT+k-1))
                ok=0;
            end
        end
    end
    if ok
        if indexT(j)>1
            indexContext1=max(1,indexT(j)-window):indexT(j)-1;
        else
            indexContext1=[];
        end
        if indexT(j)<length(index)
            indexContext2=[indexT(j)+length(indexTarget):min(length(index),indexT(j)+window)];
        else
            indexContext2=[];
        end
        info.context=[struct2string(word(indexContext1)) ' _' upper(regexprep(targetWord,' ','_')) struct2string(word(indexContext2))] ;
        %info.context=struct2string(word([indexContext1 indexContext2]));
        [x N Ntot t indexContext2]=text2space(s,info.context);
        i=i+1;
        s=addX2space(s,[targetWord num2str(i)],x,info);
    end
end

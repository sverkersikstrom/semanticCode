function [s,f1,f1WC,fByIndex]= mkfreq(s,index,f1,f1WC,semVar);

fByIndex=sparse(NaN);
if nargin<2
    index=[];
end
if nargin<3
    f1=zeros(1,s.N);
end
if nargin<4
    f1WC=[];
end

if length(index)>1
    f0=0;
    for i=1:length(index);
        [s,f1,f1WC]= mkfreq(s,index(i),f1,f1WC);
        if nargout>3
            N=size(fByIndex);
            if N(2)<length(f1);fByIndex(i,length(f1))=0;end
            if length(f0)<length(f1);f0(1,length(f1))=0;end
            fByIndex(i,:)=sparse(f1-f0);
            f0=f1;
        end
    end
    return
end

if s.par.text2indexIgnore
    text=index2word(s,index);text=text{1};
elseif nargin>=5
    text=getText(s,index,semVar);    
else
    text=getText(s,index);
end
wordclass=nargin>4 & not(isempty(f1WC));


if length(text)>0
    [indexWord t s]=text2index(s,text,index);
    %Only include word in contexts...
    if length(s.par.weightTargetWord)>0
        keep=zeros(1,length(t));
        target=context_list(s.par.weightTargetWord,'%s');target=target{1};
        for k=1:length(target)
            tmp=find(strcmpi(target{k},t));
            contextSizeSet=15;
            keep(find(abs((1:length(t))-tmp)<contextSizeSet))=1;
        end
        t=t(find(keep));
        indexWord=indexWord(find(keep));
    end
    
    if wordclass
        [info s]=getWordClassCash(s,index);
        if not(isfield(info,'index'))
            info.index=index;
        end
        indexWC2=find(info.index>0);
        info.wordclass(find(info.wordclass==0 | isnan(info.wordclass)) )=length(s.classlabel)+1;
    end
    N=length(s.fwords);
    for k=1:length(t)
        if isnan(indexWord(k)) | indexWord(k)==0
            indexWord(k)=word2index(s,t{k});
            if isnan(indexWord(k))
                if 0 & s.N==length(s.fwords)
                    s.fwords{length(s.fwords)+1000}='';
                    f1(length(s.fwords))=0;
                end
                N=N+1;
                %s.N=s.N+1;
                s.fwords{N}=t{k};
                s.hash.put(lower(t{k}),N);
                indexWord(k)=N;
            end
        end
        s.N=length(s.fwords);

        if indexWord(k)>length(f1)
            f1(indexWord(k))=0;
        end
        f1(indexWord(k))=f1(indexWord(k))+1;
        indexWC(k)=indexWord(k);
        if wordclass & indexWord(k)>0
            Nwc=size(f1WC);
            if Nwc(1)<indexWord(k)
                f1WC(indexWord(k),1)=0;
            end
            if Nwc(2)<info.wordclass(k)
                f1WC(indexWord(k),info.wordclass(k))=0;
            end
            f1WC(indexWord(k),info.wordclass(k))=f1WC(indexWord(k),info.wordclass(k))+1;
        end
    end
    if length(s.f)<N %This will be slow....consider optimizing
        add=100;
        s.f(s.N+1:N+add)=NaN;
        s.x(s.N+1:N+add,:)=NaN;
        s.wordclass(s.N+1:N+add)=NaN;
        s.info{N+add}='';
        s.N=N;
    end
        
end

fByIndex=sparse(f1);

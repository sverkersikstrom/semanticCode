function [x,word,N]=getLIWC(s,index)
persistent sSave
persistent id
   
s.id=s.languagefile;
if isempty(id)
    k=0;
else
    k=strcmpi(s.id,id);
end
if not(isfield(s,'db')) s.db=0; end
  
if k<1 
    k=length(sSave)+1;
    id{k}=s.id;
    fprintf('Initiating LIWC %d,%s\n',k,id{k})
    file=[s.languagefile '-liwc.mat'];
    if exist(file)
        load(file);
        sSave{k}=sTmp;
    else
        sSave{k}=s;        
        if s.db
            if isnan(word2index(s,'_liwcfunctionwords'))
                [s2.x,s2.info,s2.f,s2.fwords,s2.wordclass] =dbSpace(regexprep(s.languagefile,'\.mat',''),'','get*',{'_liwc*'});
                s=mergeSpace(s,s2);
            end
        end
        i=5;
        [~,categories,indexC]=getIndexCategory(i,s);
        for i=1:length(indexC)
            if s.db & isfield(s.info{indexC(i)},'index')
                s.info{indexC(i)}=rmfield(s.info{indexC(i)},'index');
            end
        end
        variableToCreateSemanticRepresentationFrom=s.par.variableToCreateSemanticRepresentationFrom;
        s.par.variableToCreateSemanticRepresentationFrom='';
        [tmp,f1,~,fByIndex]=mkfreq(s,indexC);
        s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom;
        sSave{k}.x=[];
        sSave{k}.fwords=tmp.fwords;
        sSave{k}.hash=tmp.hash;
        sSave{k}.word=index2word(s,indexC);
        sSave{k}.fByIndex=fByIndex>0;
        sTmp=sSave{k};
        sTmp=rmfield(sTmp,'handles');
        save(file,'sTmp');
    end
end
  
if 1
    fByIndex2=sparse(length(index),length(sSave{k}.fwords));
    for i=1:length(index)
        [text indexWord]=getText(s,index(i));
        indexSave=word2index(sSave{k},s.fwords(indexWord(indexWord>0)));
        indexSave=indexSave(not(isnan(indexSave)));
        fByIndex2(i,indexSave)=fByIndex2(i,indexSave)+1;
    end
else
    [~,~,~,fByIndex2]=mkfreq(sSave{k},index);
end
if length(index)==1
    indexNotZero=find((fByIndex2)>0);
else
    indexNotZero=find(sum(fByIndex2)>0);
end
N=size(sSave{k}.fByIndex);
if N(2)<max(indexNotZero)
    sSave{k}.fByIndex(:,max(indexNotZero))=0;
end

for i=1:length(index)
    if length(indexNotZero)==1
        x(:,i)=((repmat(fByIndex2(i,indexNotZero),N(1),1).*sSave{k}.fByIndex(:,indexNotZero))')/max(1,sum(fByIndex2(i,indexNotZero)));
    else
        x(:,i)=sum((repmat(fByIndex2(i,indexNotZero),N(1),1).*sSave{k}.fByIndex(:,indexNotZero))')/max(1,sum(fByIndex2(i,indexNotZero)));
    end
end
word=sSave{k}.word;

%Keep max 200 Mb in memory, or max 30 spaces!
a=whos('sSave');
sSave{k}.time=now;
if (k>1 & a.bytes>200*10^6) | k>30
    fprintf('\nClearing LIWC-cash for %s %d \n',id{k},k)
    %Here we should remove the oldest used, not the oldest added!
    sSave=sSave(2:end);
    id=id(2:end);
end

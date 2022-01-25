function [x, xTarget,s,N]=average_vector(s,x,indexOrg,weight,j)
%Calculates a semantic representation (x), based on words in index (index), weighted
%by (weight), where j is the index of the representation where x is
%stored 
%The x representation is modified by parameters specified in s.par!

notNaN=find(not(isnan(sum(shiftdim(x,1)))));

[N Ndim]=size(x);
xTarget=[];
if nargin>=4 & not(isempty(weight))
    for i=1:N
        x(i,:)=x(i,:)*weight(i);
    end
end

%if N>1
x=x(notNaN,:);
if nargin>2
    index=indexOrg(notNaN);
end
%end

[N tmp2]=size(x);
Nsum=N;

%x(indexOrg>75,:)=0;'REMOVE'
if nargin>2
    if s.par.weightPrimacy>0
        if s.par.weightPower
            x=x.*(repmat((1:N).^-s.par.weightPrimacy,Ndim,1)');
        else
            x=x.*(repmat(s.par.weightPrimacy.^(1:N),Ndim,1)');
        end
    end
    
    %Select Dates based on 
    if isfield(s.par,'weightByDate') & length(s.par.weightByDate)>0 & not(isempty(x))
        Dates=textscan(s.par.weightByDate,'%s');Dates=Dates{1};
        Date1=0;Date2=10^9;
        if length(Dates)>0 Date1=datenum(Dates{1}); end
        if length(Dates)>1 Date2=datenum(Dates{2}); end
        [a b]=getText(s,j); 
        Date=textscan(getText(s,j,s.par.weightByDateVariabel),'%s');Date=Date{1};
        if not(length((indexOrg))==length(Date))
            fprintf('Datemissmatch %s\n',s.fwords{j})
            x=x*NaN;
        else
            Date=Date(indexOrg>0);
            for i=1:length(Date)
                DateNum(i)=datenum(Date{i}(1:min(end,19)),'yyyy-mm-ddTHH:MM:SS');
            end
            x(find(not(DateNum>=Date1 & DateNum<Date2)),:)=0;
        end
    end

    if isfield(s.par,'weightFirstNWords') & s.par.weightFirstNWords>0
        N2=min(N,s.par.weightFirstNWords);
        x=x.*[repmat(1, N2,Ndim,1); repmat(0, N-N2,Ndim,1)] ;
    end
    if isfield(s.par,'weightRandomNWords') & s.par.weightRandomNWords>0
        N2=min(N,s.par.weightRandomNWords);
        tmp=[repmat(1, N2,Ndim,1); repmat(0, N-N2,Ndim,1)] ;
        [~, tmp2]=sort(rand(1,N));
        tmp=tmp(tmp2,:);
        x=x.*tmp ;
    end
    
    if isfield(s.par,'weightWordPosition') & s.par.weightWordPosition>0
        tmp=zeros(N,Ndim);
        if s.par.weightWordPosition<=N
            tmp(s.par.weightWordPosition,:)=1;
        end
        x=x.*tmp;
    end
    
    if isfield(s.par,'weightLogNwords') & s.par.weightLogNwords>0
        tmp=zeros(N,Ndim);
        for i=1:length(index)
            tmp(i,:)=sum(index(i)==index);
            tmp(i,:)=1./log(tmp(i,:));
        end
        tmp(find(isinf(tmp)))=0;
        Nsum=sum(tmp(:,1));
        x=x.*tmp;
    end
    
    if isfield(s.par,'weightFrequency') & s.par.weightFrequency>0
        w=zeros(1,size(x,1));
        w(find(index>0))=full(s.f(index(find(index>0)))>s.par.weightFrequency);
        w=ones(1,size(x,1));
        w(1)=s.par.weightFrequency;
        %tmp=s.f(index(find(index>0)))-.0015;
        %w(find(index>0))=full(1./(1-s.par.weightFrequency*exp(-[tmp])));
        %w(find(indexOrg>0))=full(s.f(indexOrg(find(indexOrg>0))).^.5);
        x=x.*(repmat(ones(1,N).*w,Ndim,1)');
    end
    if isfield(s.par,'weightTargetWord') & length(s.par.weightTargetWord)>0
        [indexTarget ]=text2index(s,s.par.weightTargetWord);
        weight=zeros(1,N);
        k=0;
        for k=1:length(indexTarget)
            indexFound=find(indexTarget(k)==index);
            for i=1:length(indexFound)
                distance=abs((1:N)-indexFound(i))+1;
                if s.par.weightPower %Power-function (global context)
                    w=(distance).^-s.par.weight;
                else %Expontential function (local context)
                    w=s.par.weight.^distance;
                end
                if s.par.contextSizeSet>0
                    % w(find(distance>s.par.contextSizeSet))=0;
                end
                weight=weight+w;
                if nargout>1
                    k=k+1;
                    %Make contexts non-overlapping!
                    if i==1
                        index1=1;
                    else
                        index1=fix((indexFound(i) + indexFound(i-1))/2);
                    end
                    if i==length(indexFound)
                        index2=length(index);
                    else
                        index2=fix((indexFound(i) + indexFound(i+1))/2-1);
                    end
                    xTarget(k,:)=average_vector2(s,x(index1:index2,:).*(repmat(w(index1:index2),Ndim,1)'));
                end
            end
        end
        if not(isempty(x))
            x=x.*(repmat(weight,Ndim,1)');
        end
    end
    if not(isfield(s.par,'weightWordClass'))
    elseif length(s.par.weightWordClass)==1 & s.par.weightWordClass(1)==0
    elseif length(s.par.weightWordClass)>0  
        N2=size(x);
        if nargin<5
            %indexT=index(find(index>0));
            %[info s]=getWordClassCash(s,[],cell2string(s.fwords(index)));
            [info s]=getWordClassCash(s,[],cell2string(s.fwords(index)));
            wordclass=info.wordclass;
        elseif isfield(s.info{j},'wordclass') & N2(1)==s.info{j}.wordclass ; %Wordclass exists already
            wordclass=s.info{j}.wordclass;
        elseif isfield(s.info{j},'context')
            [info s]=getWordClassCash(s,j,s.info{j}.context);
            wordclass=info.wordclass;
            s.info{j}.wordclass=wordclass;
        end
        if not(N2(1)==length(wordclass))
            wordclass2=wordclass;
            wordclass=zeros(1,length(index));
            for i=1:length(index);
                k=find(info.index==index(i));
                if not(isempty(k))
                    wordclass(i)=k(1);
                end
            end
            if not(length(index)==N2(1))
                fprintf('Problem in wordclass calculation\n')
            end
        end
        wordclass(find(wordclass==0))=length(s.classlabel)+1;%Set missing WC to unknown...
        weightWordClass=s.par.weightWordClass;
        if length(weightWordClass)<max(wordclass);
            weightWordClass(max(wordclass))=0;
        end
        weight=zeros(1,length(index));
        weight=weightWordClass(wordclass);
        if not(isempty(x))
            x=x.*(repmat((weight),Ndim,1)');
        end
    end
    if not(s.par.stopwords(1)) | not(s.par.stopwords(2))
        if not(isfield(s,'xStopword'))
            s.xStopword=average_vector2(s,s.x(1:15,:));
            fprintf('Seeding stopword representation with: %s\n',cell2string(s.fwords(1:15)));
            [a indexStop]=semanticSearch(s.x,s.xStopword);
            fprintf('Stopwords: \n');
            for i=1:100
                if not(strcmpi(s.fwords{indexStop(i)}(1),'_'))
                    fprintf('%s ',s.fwords{indexStop(i)});
                    s.info{indexStop(i)}.stopword=1;
                end
            end
            fprintf('\n');
        end
        w=[];
        %index=index(not(isnan(index)));
        for i=1:length(index)
            if isnan(index(i)) | index(i)==0
                w(i)=0;
            else
                if s.par.stopwords(3)%Smooth
                    a =semanticSearch(x(i,:),s.xStopword);
                    norm =semanticSearch(x(i,:),x(i,:));
                    a=a/norm;
                    w1=1-(1-a)^2;
                else
                    w1=1;
                end
                
                if isfield(s.info{index(i)},'stopword')
                    stopword=1;
                else
                    stopword=0;
                end
                if index(i)==0
                    w(i)=1;
                else
                    
                    if not(s.par.stopwords(1))
                        %Remove stopwords
                        if stopword
                            w(i)=1-w1;%Well they are weighted very small...
                        else
                            w(i)=w1;
                        end
                    elseif not(s.par.stopwords(2))
                        %Remove non-stopwords
                        if stopword
                            w(i)=w1;
                        else
                            w(i)=1-w1;
                        end
                    else
                        stop
                    end
                end
            end
        end
        if length(w)>0
            x=x.*(repmat((1:N).*w,Ndim,1)');
        end
    end
end
N=length(find(not(sum(x(:,:)')==0)));
x=average_vector2(s,x,Nsum);

function x=average_vector2(s,x,Nsum);
%This is tricky. The mean of each dimension is typically not zero, which
%yeilds averaging artifacts. This rutin solves this problem by averaging
%over a space where the mean is subtracted, and the mean is later added on.
%if nargin<3 fprintf('averaging %d\n',length(x)); end

[N Ndim]=size(x);
if nargin>2
    N=Nsum;
end

%if Ndim==Ndim
xmean=getXmean(s);
%else
%    xmean=0;
%end

if not(s.par.normalizeSpace)
elseif N>1 %Should this not be N>0, otherwise N=1 is treated differently!!!!
    if length(s.par.BERT)>0 & not(size(x,2)==size(xmean,2))
        xmean=0;%Do not subtract using BERT
    end
    tmp=sum(x)-N*xmean;%(:,size(x,2));
    x=tmp/sum(tmp.*tmp)^.5;
elseif N==1
    %tmp=x - N*xmean;
    %x=tmp/sum(tmp.*tmp)^.5;
    x=x/sum(x.*x)^.5;%IS THIS CORRECT
elseif N==0
    x=nan(1,Ndim);
end


function xmean=getXmean(s)
if isfield(s,'xmean2') & s.par.xmeanCorrection;
    xmean=s.xmean2;
else
    %[~, Ndim]=size(s.x);
    xmean=zeros(1,s.Ndim);
end

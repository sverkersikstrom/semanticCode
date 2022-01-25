function [s sSUM qSVD qSUM qSVDVer2 qSUMVer2]=createSpaceSCD(c,s,d)
if nargin<2 | isempty(s)
    s=initSpace;
end
if nargin<3
    d=[];
end
sSUM=[]; 
qSVD=[];
qSVDVer2=[];
qSUM=[];
qSUMVer2=[];

if ischar(s);load(s);end
if ischar(c);load(c);end

if length(s.par.LSAaddFeatureFile)>0
    fprintf('Adding features from data file: %s\n',s.par.LSAaddFeatureFile);
    [words, data, dim, labels]=textread2(s.par.LSAaddFeatureFile,0);
    if isfield(s.par,'LSAIndex')
        index=zeros(1,length(words));
        for i=1:length(s.par.LSAIndex)
            index(i)=find(strcmp(s.par.LSAIndex{i},words(:,1)));
        end
        words=words(index,:);
        data=data(index,:);
    end
    f=zeros(size(words,1),length(c.fwords));
    
    %Get frequency wieghtings
    fprintf('Getting frequencies.')
    c.par=s.par;
    c=mkHash(c);
    for i=1:size(words,1)
        for j=1:dim
            index=text2index(c,words{i,j});
            index=index(not(isnan(index)));
            f(i,index)=f(i,index)+1;
        end
    end   
    
    %Make features
    count=NaN(size(f,2),dim);
    for i=1:size(f,2)
        for j=1:dim
            if not(sum(not(isnan(data(:,j).*f(:,i))))==0)
                count(i,j)=nansum(data(:,j).*f(:,i))/nansum(f(:,i));
            end
        end
    end
    
    %Replace NaNs with mean
    for i=1:size(count,1)
        for j=1:dim
            if isnan(sum(count(i,j)))
                count(i,j)=nanmean(count(:,j));
            end
        end
    end
    
    %Remove nan columns
    count=count(:,find(not(isnan(nanmean(count)))));
    s.par.SVDLogiStart=size(count,2)+1;
    
    %Z-transform count
    count=(count-repmat(nanmean(count),size(count,1),1))./repmat(nanstd(count),size(count,1),1);

    c.count=[count c.count];
end


try;s=rmfield(s,'wordHashMap');end
fprintf('Making space %s\n',s.filename)

%if isfield(s,'x') & 0 %If space already exist, evaluate quality!
%    [q s]=testSpaceQuality(s,d.synonymFile);
%end

% if 0
%     fprintf('Removing stopwords');
%     f=fopen('englishFiles/stopwordsEnglish.text','n', 'UTF-8');
%     s.stopword=zeros(1,s.N);
%     w=textscan(f,'%s');
%     i=word2index(s,w{1});
%     i2=i(find(not(isnan(i))));
%     c.count(i2,:)=0;
%     i3=i2(find(i2<d.Ncol));
%     c.count(:,i3)=0;
% end

%Create space
s.f=sum(c.count')/sum(sum(c.count));
s.fwords=c.fwords;
%s.hash=c.hash;
s.info(1:length(s.f))={''};
remove=find(s.f==0);
if length(remove)>0
    fprintf('Removing %d zero words\n',length(remove));
    s=structSelect(s,s.f>0);
    s.N=length(s.f);
    c.count=c.count(s.f>0,:);
end
s=mkHash(s,1);

countN=full(sum(sum(c.count)));
 if isfield(d,'tdidf') & d.tdidf
    fprintf('Normalizing with TD-IDF...');
    N=size(c.count);
    Nrow=sum(c.count(:,:)');
    Ncol=sum(c.count(:,:));
    Nrow=Nrow+1;
    Ncol=Ncol+1;
    if 1
        tic
        fprintf('Normalizing rows...');
        Ncol=log(Ncol)+1;
        for i=1:N(2)
            c.count(:,i)=c.count(:,i)/Ncol(i);
        end
        toc
        fprintf('\nDone');
    elseif 1 %Not working
        tic
        fprintf('Normalizing columns...');
        i2=1:N(1);
        f2=c.count(i2,:)>0;
        tmp=(repmat(Nrow(i2),N(2),1)');
        c.count(f2)=c.count(f2)./tmp(f2);
        fprintf(' Normalizing rows...');
        for i=1:N(2)
            c.count(:,i)=c.count(:,i)/Ncol(i);
        end
        toc
        fprintf('Done\n');
    end
else
    fprintf('Normalizing with Logaritm(f+1)...');
    N=size(c.count);
    if isfield(s.par,'SVDLogiStart')
        i=s.par.SVDLogiStart;
    else
        i=1;
    end
    Nstep=1000;
    while i<N(2)
        fprintf('.');
        index=i:min(N(2),i+Nstep-1);
        c.count(:,index)=log(c.count(:,index)+1);
        i=i+Nstep;
    end
    %c.count=log(c.count+1);
    fprintf('done!\n');
end

if 0
    m=mean(c.count);
    m=m/sum(m.*m)^.5;
    s.N=400
    dev=nan(1,s.N);
    for i=1:s.N
        dev(i)=sum((c.count(i,:)/sum(c.count(i,:).*c.count(i,:))).*m)^.5;
    end
    [tmp index]=sort(dev,'descend');
    s.fwords(index(1:50))
end


%Create SVD space
s3=s;
s3.q.svd=1;
%s3.f=f;
%s3.Ndim=d.NSVD;
%if not(isfield(d,'SVDsparse'))
%    d.SVDsparse=2;
%end
Ntmp=size(c.count);
s.par.Ncol=min(s.par.Ncol,Ntmp(2));
if s.par.SVDsparse==2 %Automatically set SVDsparse to an effecient parameter
    s.par.SVDsparse=Ntmp(1)*Ntmp(2)>=120000*3000;
end
if s.par.SVDsparse
    fprintf('Calculating SVD with %d dimensions...',s.par.Ncol);tic
    fprintf('(sparse approximation) ');
    [s3.x,s3.S,s3.V,flag] = svds(c.count(:,1:s.par.Ncol),512);
    if flag
        fprintf('Warning: no convergence')
    else
        fprintf('svds converged!');
    end
else
    indexOk=find(not(sum(abs(c.count))==0));
    s3.Ndim=length(indexOk);
    fprintf('Calculating SVD with %d dimensions...',s3.Ndim);tic
    fprintf('(full SVD)');
    [s3.x,s3.S,s3.V] = svd(full(c.count(:,indexOk)),0);
end
%s.x=c.count*s.V*s.S';
%i=1;
%x=full(c.count(i,1:s3.Ndim))*s3.V*inv(s3.S);
%max(max(abs(x-s3.x(i,1:s3.Ndim))))

%c.count(i,1:s3.Ndim)=s3.x*s3.S*s3.V;
if not(s.par.LSAsaveExtraFiles)
    s3=rmfield(s3,'V');
    s3=rmfield(s3,'S');
end
    
fprintf(' Done!\n');toc
s3.x=normalizeSpace(s3.x);
s3.Ndim=size(s3.x,2);

if isfield(d,'synonymFile2')
    fprintf('Synonym test type 2\n')
    [qSVDVer2 s3]=testSpaceQuality(s3,d.synonymFile2,0,[],1);
end

if not(isfield(d,'synonymFile'))
    d.synonymFile='';
end
[qSVD s3]=testSpaceQuality(s3,d.synonymFile);

N=size(s3.x);
s3.Ndim=N(2);
if not(isfield(s,'quality'))
    s.quality=NaN;
end
qSVD.countDensity=full(mean(mean(c.count>0)));
qSVD.countN=countN;
qSVD.synonymFile=d.synonymFile;
s3.q.meta=qSVD;
fprintf('New SVD space quality=%.4f, old space quality=%.4f\n',s3.q.optimalQuality,s.quality)
if s3.q.optimalQuality >s.quality
    fprintf('Old SVD space has higher quality (keeping old space)\n')
else
    fprintf('New SVD space has higher quality\n')
    s=s3;
end
clear s3;

if isfield(d,'mkSpaceSUM') & d.mkSpaceSUM
    %Create from summary of contexts....
    sSUM=s;
    %index=find(isnan(mean(sSUM.x')));
    sSUM.x=s.x*0;%(index,:)=0;%Remove nan-vectors
    sSUM.q.spaceSum=1;
    N=s.N;
    for i=1:N
        if even(i,1000); fprintf('.');end
        index=find(c.count(i,:)>0);
        if 0 %does not work well...
            x=sum(s.x(index,:).*repmat(c.count(i,index),s.Ndim,1)');
        else
            x=zeros(1,s.Ndim);
            for j=1:length(index);
                if not(i==j)
                    x=x+s.x(index(j),:)*c.count(i,index(j));
                end
            end
        end
        sSUM.x(i,:)=x;
    end
    sSUM.x=normalizeSpace(sSUM.x);
    
    [qSUM sSUM]=testSpaceQuality(sSUM,d.synonymFile);
    
    qSUM.countDensity=full(mean(mean(c.count>0)));
    qSUM.countN=countN;
    qSUM.synonymFile=d.synonymFile;
    if isfield(d,'synonymFile2')
        fprintf('Synonym test type 2\n')
        [qSUMVer2 sSUM]=testSpaceQuality(sSUM,d.synonymFile2,0,[],1);
    end
    
    %Save
    if sSUM.q.optimalQuality<s.q.optimalQuality
        fprintf('New SUM space (%.4f) has higher quality than old space (%.4f)\n',sSUM.qVer2.optimalQuality,s.q.optimalQuality)
        %save([s.filename 'SVD'],'s','-V7.3');
        %s=sSUM;
        %s.q=qSUM;
        %save(s.filename,'s','-V7.3');
        %fprintf('done\n')
    end
    
    if sSUM.q.optimalDim==sSUM.Ndim
        fprintf('SVD space: Quality may be improved by more dimensions\n')
    else
        sSUM.Ndim=sSUM.qVer2.optimalDim;
        fprintf('SVD space: Reducing the number of dimensions to %d\n',sSUM.Ndim)
        sSUM.x=normalizeSpace(sSUM.x(:,1:sSUM.Ndim));
        sSUM.q.quality=sSUM.q.optimalQuality;
        sSUM.quality=sSUM.q.quality;
    end
    
end

if s.q.optimalDim==s.Ndim
    fprintf('SVD space: Quality may be improved by more dimensions\n')
else
    s.Ndim=s.q.optimalDim;
    if isnan(s.Ndim)
        [~,tmp]=size(s.x);
        s.Ndim=min(300,tmp);
    end
    fprintf('SVD space: Reducing the number of dimensions to %d\n',s.Ndim)
    s.x=normalizeSpace(s.x(:,1:s.Ndim));
    s.q.quality=s.q.optimalQuality;
    s.quality=s.q.quality;
end
s.N=size(s.x,1);
try
    s.languageCode=s.par.languageCode;
    s.spaceInfo=sprintf('Space information:\nfile %s\nlanguage %s\ncreated on %s\nnumber of words in space %d\nnumber of dimensions in space %d\nquality %.4f\n',s.filename,s.par.languageCode,datestr(now),s.N,s.Ndim,s.quality);
    s.spaceInfo=[s.spaceInfo sprintf('Ocurrency density %.4f\nnumber of words in corpus %d\nnumber of rows in corpus %d\nsynonymFile %s\n',qSVD.countDensity,s.nWords,s.row, d.synonymFile)];
catch
    s.spaceInfo=sprint('Error in generating space information\n');
end
s.languagefile=s.filename;
s.languagefilePath=pwd;
s.par.languageCode=d.languageCode;
try
    s=spaceAddModels(s);
catch
    fprintf('Error during adding of moduls\n');
end
fprintf('%s',s.spaceInfo);
if isfield(s,'handles')
    s=rmfield(s,'handles');
end
end
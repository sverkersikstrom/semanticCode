function [out, in,par]= semanticChange(varargin)

if 0 %Semantic change paramters calls: F?rsta g?ngen skriv detta
    par.word='happiness'
    par.path='/Users/sverkersikstrom/Dropbox/ngram/' %HOWEVER CHANGE 'sverkersikstrom' to your user!!!
    [out,in,par]=ngram(par);
    %Andra anropet g?r snabbar om du skriver detta:
    [out,in,par]=ngram(par,in);
end


if 0 %Example settings of parameters...
    par.word='women men ship';
    par.yearGroup={[1801:1850],[1950:1960],[2005:2010]};
    par.plot=1;
    par.similarityType=1;%where...
    %1=Semantic Change compared to par.similarityWord,
    %2=Semantic distance to similiartyWord (time-independent)
    %3=Semantic distance to similiartyWord (time-dependent)
    %4=Coherency
    par.similarityWord='mother';
    par.similarityYear=[2005:2010];
    par.printSemAss=0;
    par.printKeyWords=1;
    par.years=1801:2013;
end
%d.user=1;
d.nouse=NaN;
d=getParNgram(d);

if length(varargin{1})==0
    varargin{1}{1}=[];
end
par=varargin{1}{1};
if ischar(par)
    warning off
    par.word=par;
    warning on
end
if not(isfield(par,'word'))
    %word=par.word;
    %else
    par.word='women men ship';
    par.word='harmony happiness';
end
if ischar(par.word)
    par.word=string2cell(par.word);
end

if not(isfield(par,'year'))
    par.yearGroup={[1801:1850],[1950:1960],[2005:2010]};
end
if not(isfield(par,'plot'))
    par.plot=1;
end
if not(isfield(par,'similarityType'))
    par.similarityType=1;
end
if not(isfield(par,'similarityYear'))
    par.similarityYear=[2005:2010];
end
if not(isfield(par,'aggregateYear'))
    par.aggregateYear=[1801:1850];
end
if not(isfield(par,'similarityWord'))
    par.similarityWord='';
end
if not(isfield(par,'printSemAss'))
    par.printSemAss=1;
end
if not(isfield(par,'printKeyWords'))
    par.printKeyWords=1;
end
if not(isfield(par,'coherencyStep'))
    par.coherencyStep=10;
end
if not(isfield(par,'years'))
    par.years=(1:d.tMax)+d.tStart;
end
if not(isfield(par,'smooth'))
    par.smooth=1;
end
if not(isfield(par,'path'))
    p=pwd;
    Nstart=findstr(p,'Dropbox/');
    if Nstart>0
        par.path=[p(1:Nstart+7) 'ngram/'];
    else
        par.path=pwd;
    end
end
years=par.years-d.tStart;
index=find(years>0 & years<=(year(now)-d.tStart));
years=years(index);
par.years=par.years(index);

if length(varargin{1})>1
    in=varargin{1}{2};
    clear varargin;
else
    in=[];
end

d.path=par.path;
d.datafiles=1;
if 0
    d.fileSpaceSVD='spaceEnglish kopia.mat';%This space does not keep SVD data
else
    d.fileSpaceSVD='spaceEnglish.mat';%This space has SVD data (S,V)
end
if 1 | d.datafiles & exist( [d.path d.fileSpaceSVD])==2 %New datafiles
    fprintf('Using new datafiles\n')
    d.fileSpaceSUM='spaceEnglishSUM';
    d.fileCount='countEnglishTimeSUM';%Summed time count files!
else %Old datafiles
    d.path='/Users/sverkersikstrom/Dropbox/ngram/';
    d.fileSpaceSVD='spaceImproved-English-2013-01-15SVD.mat';
    d.fileSpaceSUM='spaceImproved-English-2013-01-15SVD-SUM'
    d.fileCount=[d.name 'Working2'];
end

if not(isfield(in,'s'))
    fprintf('Semantic change, initalizing...')
    load([d.path d.fileSpaceSVD]);%load s
    %if sum(sum(s.wordclass))==0
    %    load('wordclassEnglish');
    %    s.wordclass=wc.wc;
    %    s.classlabel=wc.classlabel;
    %end
else
    s=in.s;
    in=rmfield(in,'s');
end

%filename=[d.path d.fileSpaceSUM];
if par.printSemAss
    if not(isfield(in,'sSUM'))
        load([d.path d.fileSpaceSUM ]);%sSUM
    else
        sSUM=in.sSUM;
        in=rmfield(in,'sSUM');
    end
end

logExt='-log';
logExt='';

if not(isfield(in,'count'))
    if exist([d.path d.fileCount logExt '.mat'])==2
        load([d.path d.fileCount logExt '.mat']);%load count (time-dependent, log)
        load([d.path d.fileSpaceSUM '-data']);%load data
    else
        load([d.path d.fileCount]);%load count (time-dependent, no-log)
        %countSum= sparse(s.N,d.Ncol);
        countSum=spalloc(s.N,d.Ncol,d.memorySize);
        
        for i=1:s.N
            countSum(i,:)=sum(reshape(count(i,:),d.Ncol,d.tMax)');
            if even(i,1000);fprintf('.');end
        end
        save([d.path d.fileSpaceSUM '-count'],'countSum','-V7.3');
        
        data.f=sum(countSum');
        for i=1:d.tMax
            data.ftime(i)=sum(sum(count(:,d.Ncol*(i-1)+(1:d.Ncol))));
        end
        data.ftimeWord=nan(s.N,d.tMax);
        for i=1:d.tMax
            data.ftimeWord(:,i)=sum(count(:,(i-1)*d.Ncol+ (1:d.Ncol))');
        end
        save([d.path d.fileSpaceSUM '-data'],'data','-V7.3');
        
        
        countSum=log(countSum+1);
        save([d.path d.fileSpaceSUM '-count-log'],'countSum','-V7.3');
        
        fprintf('\n')
        beep2(1);
        1;
        
        if exist('c')==1
            count=c.count;clear c;
        end
        for i=0:s.N/1000-1;
            fprintf('.');
            count(i*1000+(1:1000),:)=log(count(i*1000+(1:1000),:)+1);
        end
        %count=log(count+1);
        save([d.path d.fileCount '-log'],'count','-V7.3');
    end
    if exist('c')==1
        count=c.count;clear c;
    end
    fprintf('done.\n')
    if 0
        fprintf('Building summed countTime file.\n')
        f=dir([d.path 'EnglishTime']);
        %count= sparse(s.N,d.Ncol*d.tMax);
        count=spalloc(s.N,d.Ncol*d.tMax,d.memorySize);
        
        for i=1:length(f)
            if findstr(f(i).name,'countEnglishTime')>0
                load([d.path 'EnglishTime/' f(i).name]);
                count=count+c.count;
                fprintf('.');
            end
        end
        save([d.path 'countEnglishTimeatSUM'],'count','-V7.3');
    end
else
    count=in.count;
    in=rmfield(in,'count');
    data=in.data;
    in=rmfield(in,'data');
end

%load([d.path 'spaceImproved-English-2013-01-15.mat']);
%sSUM.x=s.x;
%clear s;
out.error='';

%s.xmean=zeros(1,s.Ndim);

if exist([d.path d.fileSpaceSUM '-count' logExt '.mat'])
    if not(isfield(in,'countSum'))%count (time-independent)
        fprintf('Using cached file, may not to be updated\n')
        load([d.path d.fileSpaceSUM '-count' logExt]);%load countSum
    else
        countSum=in.countSum;
        in=rmfield(in,'countSum');
    end
else
    %load([d.path d.fileSpaceSUM '-count']);%load count
    stop
    
    sSUM=s;
    if 0
        sSUM.x=createSpaceSum(s,countSum);
        %clear countSum;
        save([d.path d.fileSpaceSUM],'sSUM','-V7.3');
    end
    
    if 0 %Create simliarity files for all words... not used/neccessary
        fileSim=[d.path d.corpus 'similiarty'];
        if exist([fileSim '.mat'])
            load(fileSim)
        else
            data.sim=nan(s.N,d.tMax);
            data.findYear=[2005:2010];
            tic
            for i=1:s.N
                countI=reshape(full(count(i,:)),d.Ncol,d.tMax)';
                x=createSpaceSum(s,countI);
                xYear=average_vector(s,x(data.findYear-d.tStart,:));
                data.sim(i,:)=similarity(x,xYear)';
            end
            toc
            data.i=i;
            data.fwords=s.fwords;
            data.year=(1:d.tMax)+d.tStart;
            save(fileSim,'data','-V7.3')
            beep2(1);
            if 0
                load(fileSim)
                i=find(strcmpi(data.fwords,'people'))
                figure(3);
                subplot(2,1,1);
                plot(data.year,data.sim(i,:));ylabel('semantic change')
                title(data.fwords{i})
                subplot(2,1,2);
                plot(data.year,data.ftimeWord(i,:)./data.ftime);ylabel('relative frequency')
            end
        end
    end
end

color='rbgkmcy';
jIndex=[];
for m=1:length(par.word)
    fprintf('\n')
    
    out.word{m}.word=par.word{m};
    if strcmpi(par.word{m},'_high')
    else
        j=s.hash.get(lower(par.word{m}));
    end
    if isempty(j)
        fprintf('%s is missing\n',par.word{m})
    else
        jIndex=[jIndex m];
        %year=1801:2013
        %indexWnY=i*d.tMax+year-d.tStart;
        %index=j+(year-d.tStart-1)*d.Ncol
        countI=reshape(count(j,:),d.Ncol,d.tMax)';
        x=createSpaceSum(s,countI);
        
        
        if par.printKeyWords==1
            for m1=1:length(par.yearGroup)
                index1=(par.yearGroup{m1}-d.tStart);
                label1=[par.word{m} '(' num2str([par.yearGroup{m1}(1) par.yearGroup{m1}(end)]) ')'];
                f1=sum(countI(index1,:));
                for m2=1:length(par.yearGroup)
                    index2=(par.yearGroup{m2}-d.tStart);
                    label2=[par.word{m} '(' num2str([par.yearGroup{m2}(1) par.yearGroup{m2}(end)]) ')'];
                    f2=sum(countI(index2,:));
                    tmp=keyWordsWC(s,s.fwords,[f1; f2; data.f(1:d.Ncol)-f1-f2],1,2,label1,label2,0);
                    out.word{m}.keyWords{m1}{m2}=tmp;
                end
            end
            for m1=1:length(par.yearGroup)
                fprintf('Keywords: %s',out.word{m}.keyWords{m1}{1}.result1);
            end
        end
        
        %freqYear=sum(countI');%This is not actually the frequency, it is the number of context words that are in the dictionary
        %out.word{m}.relativeFrequency=full(freqYear(years)./data.ftime(years));
        out.word{m}.relativeFrequency=data.ftimeWord(j,years)./data.ftime(years);
        if par.plot
            figure(1)
            subplot(2,1,2);
            if m==1
                hold off
            else
                hold on
            end
            plot(par.years,out.word{m}.relativeFrequency,color(min(length(color),m)))
            ylabel('relative frequency')
            xlabel('year')
            title('Relative frequency')
        end
        
        if par.printSemAss
            x2=createSpaceSum(s,countSum(j,:));
            %x2=createSpaceSum(s,sum(countI));%Also works, but the line above is faster
            [~, indexS]=semanticSearch(s.x,average_vector(s,x2));
            fprintf('Associates (time-independent ngram) %s: %s\n',par.word{m},cell2string(s.fwords(indexS(1:10))))
            [~, indexS]=semanticSearch(s.x,s.x(j,:));
            fprintf('Associates (time-independent space) %s: %s\n',par.word{m},cell2string(s.fwords(indexS(1:10))))
            
            for i=1:length(par.yearGroup)
                findYear=par.yearGroup{i};
                countA=countI(findYear-d.tStart,:);
                Nc=size(countA);
                if Nc(1)>1
                    countA=sum(countA);
                end
                x2=createSpaceSum(s,countA);%Also works, but the line above
                [~, indexS]=semanticSearch(s.x,average_vector(s,x2));
                fprintf('Associates: %s (%s, N=%d): %s\n',par.word{m},num2str([par.yearGroup{i}(1) par.yearGroup{i}(end)]),full(sum(sum(countI(findYear-d.tStart,:)))), cell2string(s.fwords(indexS(1:10))))
            end
        end
        
        if par.similarityType==1 || par.similarityType==4
            xYear=average_vector(s,x(par.similarityYear-d.tStart,:));
        elseif par.similarityType==2 || par.similarityType==3
            jSim=s.hash.get(lower(par.similarityWord));
            if not(isempty(jSim))
                Ncount=size(count);
                if jSim>Ncount(1)
                    xYear=s.x(jSim,:);
                    %x=x(:,1:s.Ndim);
                else
                    countI2=sum(reshape(count(jSim,:),d.Ncol,d.tMax)');
                    xYear=createSpaceSum(s,countI2);
                end
                %xYear=createSpaceSum(s,countSum(jSim,:));
            else
                out.error=[out.error 'Missing word:' par.similarityWord];
                xYear=nan(1,s.Ndim);
            end
        end
        
        if par.similarityType==3
            if not(exist('xType3')) %Just do it once!
                if isempty(jSim)
                    out.error=['similarityWord: ' par.similarityWord '. is missing, aborting'];
                    fprintf('%s\n',out.error);
                    return
                end
                countI=reshape(count(jSim,:),d.Ncol,d.tMax)';
                xType3=createSpaceSum(s,countI);
            end
            sim=sum((x.*xType3)');
        elseif par.similarityType==4 %coherence
            N=size(x);
            for i=1:N(1)
                x1=average_vector(s,x(max(1,i-par.coherencyStep):i,:));
                x2=average_vector(s,x(i:min(N(1),i+par.coherencyStep),:));
                sim(i)=similarity(x1,x2)';
            end
        else
            sim=similarity(x,xYear)';
        end
        out.word{m}.similarity=sim(years);
        if par.plot
            subplot(2,1,1);
            if m==1
                hold off
            end
            plot(par.years,smooth(sim(years),par.smooth),color(min(length(color),m)))
            
            hold on
            x1to50=average_vector(s,x(par.aggregateYear-d.tStart,:));
            sim1to50(m)=similarity(x1to50,xYear)';
            if par.similarityType==1
                ylabel(['Simliarity relative to:' num2str(par.similarityYear(1)) '-' num2str(par.similarityYear(end)) ])
            elseif par.similarityType==2
                ylabel(['Simliarity relative to:' par.similarityWord ])
            elseif par.similarityType==3
                ylabel(['Simliarity relative to:' par.similarityWord ', across time'])
            elseif par.similarityType==4
                ylabel(['Coherence stepsize:' num2str(par.coherencyStep)])
            end
            xlabel('year')
            title('Semantic change')
        end
    end
end
if par.plot
    subplot(2,1,1);
    legend(par.word(jIndex))
    if min(par.years)<mean(par.aggregateYear)
        for m=jIndex
            plot(mean(par.aggregateYear),sim1to50(m),['o' color(min(length(color),m))])
        end
    end
    
    subplot(2,1,2);
    legend(par.word(jIndex))
end

out.timePeriods=par.yearGroup;
out.par=par;
out.years=par.years;

in.s=s;
in.count=count;
in.countSum=countSum;
in.data=data;
if isfield(in,'sSUM')
    in.sSUM=sSUM;
end
end

function x=createSpaceSum(s,countI,doLog)
if nargin<3
    doLog=1;
end
N=size(countI);
Nv=size(s.V);
%find(countI==-1)
%countI(1,1:2)
x=nan(N(1),s.Ndim);
VtS=(s.V*inv(s.S));
methodSVD=isfield(s,'S');
if methodSVD
    x=NaN(N(1),Nv(1));
else
    x=NaN(N(1),s.Ndim);
end
for i=1:N(1)
    if even(i,1000);fprintf('.');end
    index=find(countI(i,:)>0);
    if methodSVD %SVD method
        %x=c.count(i,1:s3.Ndim)*s3.V*inv(s3.S);
        %x=full(c.count(i,1:s3.Ndim))*s3.V*inv(s3.S);
        if doLog
            logCount=log(countI(i,1:Nv(1))+1);
        else
            logCount=countI(i,1:Nv(1));
        end
        x(i,:)=logCount*VtS;
    else %SUM method
        x(i,:)=0;
        for l=1:length(index)
            if not(isnan(s.x(index(l),1))) & not(i==l)
                x(i,:)=x(i,:)+s.x(index(l),:)*countI(i,index(l));
            end
            %x(i,:)=average_vector(s,s.x(index,:))*countI(i,index(j));
        end
    end
end
if methodSVD
    x=x(:,1:min(Nv(1),s.Ndim));
end
x=normalizeSpace(x);
if N(1)>1000;fprintf('\n');end
end
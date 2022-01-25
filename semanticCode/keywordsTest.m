function [out, s,in1,in2]=keywordsTest(s,index1,index2,NB,label1,label2,print,corrProperty)
%s=space, index1=Identifier 1, index2=Identifier 2, print=1/0 print-to-screen, 
%corrProperty=Correlate index1 with this property 
out=[];in1=[];in2=[];
if nargin<1
    s=getSpace('s');
end
progress(s,'keywords','Keywords');
if nargin<2
    %index1=[];
    %end
    %
    %if isempty(index1)
    [index1 s]=getWordFromUser(s,'Choice first word set','_m*');
    if index1.N==0 return; end;
end

if nargin<3;index2=[];end

if isnan(index2)
    index2=[];
elseif isempty(index2)
    [index2 s]=getWordFromUser(s,'Choice second word set','_m*');
    s=getSpace('set',s);
    if index2.N==0
        if not(strcmpi('yes',questdlg('Compare set 1 to a frequency distribution of the language?','Language comparision','yes','yes','no','no')))
            return;
        end
    end
end

in1=index1;
in2=index2;

if nargin<4; NB=0; end
if nargin<5; label1=''; end
if nargin<6; label2=''; end
if nargin<7; print=2;end

if isfield(index1,'index') %Syntax with wordset!
    label1=index1.input_clean;
    index1=index1.index;
end
if isfield(index2,'index') %Syntax with wordset!
    label2=index2.input_clean;
    index2=index2.index;
end
if isempty(index1) & isempty(index2)
    return
end
if nargin<8
    if length(s.par.keywordCorrProperty)>0
        [corrProperty,~,s]=getProperty(s,s.par.keywordCorrProperty,index1);
    else
        corrProperty=[];
    end
end

%Take care of covariates
if s.par.plotwordCountCorrelation
    covariatesData=[];
    corrProperty=covariates(s,corrProperty,s.par.covariateProperties,index1,covariatesData);
end


[out, s]=keywordsTest2(s,index1,index2,NB,label1,label2,print,corrProperty);



function [out, s]=keywordsTest2(s,index1,index2,NB,label1,label2,print2,corrProperty)

statsByText=NB | not(isempty(corrProperty));

print=print2==1;
out=[];


N=s.par.number_of_ass2;
p=NaN;z=NaN;

if print
    fprintf('Conducting a frequency count\n');
end

s.f=full(s.f);
fmin=min(s.f+10^6*(s.f==0));
f2=s.f+fmin*(s.f==0);
f2(find(isnan(f2)))=max(f2);




tic;
f1Previous=0;
fsum1(length(index1),1)=sparse(0);
if length(index2)>0
    fsum2(length(index2),1)=sparse(0);
end
if s.par.keywords_over_articles
    fprintf('Counting wheather words are present in the article or not\n')
end

f1tot=NaN;


f1=0;
f1WC=zeros(length(s.fwords),max(max(s.wordclass),length(s.classlabel))+1);
f2WC=f1WC;


for i=1:length(index1)
    progress(s,'keywords','set1',i,length(index2));
    [s,f1Temp, f1WC ]=mkfreq(s,index1(i),zeros(1,length(s.fwords)),f1WC);
    
    f1tot(i)=sum(f1Temp);
    if s.par.keywords_over_articles
        f1Temp=f1Temp>0;
    end
    if length(f1Temp)>length(f1)
        f1(length(f1Temp))=0;
    end
    f1=f1+f1Temp;
    if statsByText
        fsum1(i,1:length(f1))=f1Temp;
    end
end


minf=min(length(s.f),length(f1));
fnorm=s.f(1:minf)/min(s.f(find(s.f>0)));

if not(isempty(corrProperty)) %length(s.par.keywordCorrProperty)>0
    statsCorr1=print_res_freq(s.fwords,f1(1:minf),0,N,s,print,[],fsum1,+corrProperty);
    statsCorr2=print_res_freq(s.fwords,f1(1:minf),0,N,s,print,[],fsum1,-corrProperty);
else
    corrProperty=[];
end

warning off
selection=[];
if print
    fprintf('\nKeywords summarizing set1 %s relative a norm from language\n',label1);
    fprintf('Potentical bug: Only including words that are in the dic file! This is because stop words are excluded')
end
%if print2 | s.par.keywordSelectRelevance>0
if print
    fprintf('Keywords based on a contrast from the language:\n')
end
statsNorm1=print_res_freq(s.fwords,f1(1:minf),fnorm,N,s,print);
qNorm1=statsNorm1.q;
statsNorm1.q(isnan(statsNorm1.q))=0;
[tmp index]=sort(statsNorm1.q,'descend');
selectedNorm1=zeros(1,length(statsNorm1.q));
selectedNorm1(index(1:min(100,length(index))))=1;%Pick 100 top keywords....
if s.par.keywordSelectRelevance>0
    statsNorm1.q(isnan(statsNorm1.q))=0;
    [tmp index]=sort(statsNorm1.q,'descend');
    selection=zeros(1,length(statsNorm1.q));
    selection(index(1:min(s.par.keywordSelectRelevance,length(statsNorm1.q))))=1;
end

if length(f2)<length(f1) f2(length(f1))=0;end    
statsNorm12=print_res_freq(s.fwords,f1(1:minf)+f2(1:minf),s.f(1:minf)/min(s.f(find(s.f>0))),N,s,print);
statsNorm12.q(isnan(statsNorm12.q))=0;
[tmp index]=sort(statsNorm12.q,'descend');
selectedNorm2=zeros(1,length(statsNorm12.q));
selectedNorm2(index(1:min(100,length(index))))=1;%Pick 100 top keywords....
warning on

f2=[];f2(length(s.fwords))=0;
f2tot=NaN;


for i=1:length(index2)
    progress(s,'keywords','set2',i,length(index2));
    [s,f2Temp, f2WC ]=mkfreq(s,index2(i),zeros(1,length(f2)),f2WC);
    
    f2tot(i)=sum(f2Temp);
    
    if s.par.keywords_over_articles
        f2Temp=f2Temp>0;
    end
    if length(f2Temp)>length(f2)
        f2(length(f2Temp))=0;
    end
    f2=f2+f2Temp;
    if NB
        fsum2(i,1:length(f2))=f2Temp;
    end
end

if length(f2)>length(f1)
    f1(length(f2))=0;
end

indexF=find(f1+f2);
[tmp indexSort]=sort(f1(indexF)+f2(indexF),'descend');
indexF=indexF(indexSort);


if 1 %Cluster
    indexC=find(f1+f2>0);
    indexC=indexC(find(indexC<=s.N));
    global xdiff
    resetRandomGenator(s);
    if isfield(s.par,'clusterKeep') & s.par.clusterKeep==1
        [info.y,~,s]=getProperty(s,'_semanticCluster',indexC);
        outCluster.clusterDefinition='';
    else
        [s info]=clusterSpace(s,indexC,[],'_semanticCluster');
        outCluster.clusterDefinition=info.results;
    end
    xidf=[];
    Ntmp=size(fsum1);
    for i=1:s.par.Ncluster
        indexC1=find(i==info.y);
        f1c(i)=sum(f1(indexC(indexC1)));
        f2c(i)=sum(f2(indexC(indexC1)));
        if statsByText
            tmp=sum(fsum1(:,indexC(indexC1))');
            fsum1c(1:length(tmp),i)=tmp;
        else
            fsum1c=[];
        end
        fwordsCluster{i}=['cluster' num2str(i)];
    end
    statsCluster1=print_res_freq(fwordsCluster,f1c,f2c,N,s,print,selection,fsum1c,corrProperty);
    outCluster.clusterP=statsCluster1.p;
    outCluster.clusterQ=statsCluster1.q;
    outCluster.keywordsCluster1=statsCluster1.keyword;
    
    statsCluster2=print_res_freq(fwordsCluster,f2c,f1c,N,s,print,selection);
    outCluster.keywordsCluster2=statsCluster2.keyword;
    outCluster.clusterClass=(f1c/sum(f1c))>(f2c/sum(f2c));
    if length(indexF)>0
        outCluster.cluster(length(indexF))=0;
    end
    tmp=zeros(1,length(f1));
    tmp(indexC)=info.y;
    outCluster.cluster=tmp(indexF);
    tmp=zeros(1,length(f1));
    if isfield(info,'indexX')
        tmp(indexC)=info.indexX;
        outCluster.clusterPrototyp=tmp(indexF);
    elseif 0
        for i=1:N
            select=find(info.y==i);
            [info.y,~,s]=getProperty(s,'_tempCluster',indexC);

            [d indexS]=semanticSearch(x(i,:),o.x(select,:));
            info.indexX(select(indexS))=1:length(indexS);
        end
    else
        fprintf('Could not calculate cluster proptotype!\n')
        outCluster.clusterPrototyp=NaN(1,length(indexF));
    end
    %Wordslist of clusterinformation
    %w=sprintf('\nChi-square tests of differences in word frequencies within clusters:\n');
    w=sprintf('\ncluster\tp\tq\tclass\n');
    for i=1:length(outCluster.clusterP)
        w=[w sprintf('%d\t%.3f\t%.3f\t%d\n',...
           i,outCluster.clusterP(i),outCluster.clusterQ(i),outCluster.clusterClass(i))];
    end
    outCluster.WordList=w;
end


if length(index2)==0 %Use cached wordclasses
    indexTemp=find(s.wordclass>0);
    for i=1:length(indexTemp)
        temp=sum(f1WC(i,:));
        f1WC(i,:)=0;
        f1WC(i,s.wordclass(indexTemp(i)))=temp;
        f2WC(i,s.wordclass(indexTemp(i)))=fnorm(indexTemp(i));
    end
end


if NB
    fprintf('\nCalculating naivebaysian');
    
    
    if length(fsum2)>length(fsum1)
        fsum1(:,length(f2))=0;
    end
    r=length(index1)+length(index2);
    class=[0*ones(1,length(index1)) ones(1,length(index2)) ]+1;
    index12=[index1 ; index2];
    fsum12=[fsum1; fsum2];
    
    if 1 %Fast code with groups
        
        fprintf('Making 20 random groups, p-values varies depedning how groups are formed!\n');
        trySubject=s.par.match_paired_test_on_subject_property;
        try
            if trySubject
                fprintf('Grouping NB preditions over subjects!\n');
                for i=1:r
                    subject(i)=getInfo(s,index12(i),'subject');
                    %subject(i)=s.info{index12(i)}.subject;                   
                end
                uSubject=unique(subject);
                for i=1:length(uSubject)
                    groups(find(subject==uSubject(i)))=i;
                end
            end
        catch
            fprintf('Subject property not set, grouping randomly!\n');
            trySubject=0;
        end
        if not(trySubject)
            Ngroups=20;
            groups=fix((0:1/(r-1):1)*Ngroups)+1;
            [tmp indexRand]=sort(rand(1,r));
            groups=groups(indexRand);
        end
        
        groupsU=unique(groups);
        
        for k=1:length(groupsU)
            j=groupsU(k);
            fNB1=sum(fsum12(find(class==1 & not(groups==j)),:));
            fNB2=sum(fsum12(find(class==2 & not(groups==j)),:));
            fNB=[fNB1; fNB2];
            index2=find(fNB(1,:) + fNB(2,:)>0);
            [model ] = NaiveBayes.fit(fNB(1:2,index2),1:2,'dist','mn');
            
            index=find(j==groups);
            [p1(index,:) predClass(index) plog(index)]= model.posterior(fsum12(index,index2));
            %for i=index
            %    [p1(i,:) predClass(i) plog(i)]= model.posterior(fsum12(i,index2));
            %end
            fprintf('.');
        end
    else %Slow code one-leave out...
        for i=1:r
            fNB1=sum(fsum12(find(class==1 & not(i==1:r)),:));
            fNB2=sum(fsum12(find(class==2 & not(i==1:r)),:));
            fNB=[fNB1; fNB2];
            index2=find(fNB(1,:) + fNB(2,:)>0);
            [model ] = NaiveBayes.fit(fNB(1:2,index2),1:2,'dist','mn');
            [p1(i,:) predClass(i) plog(i)]= model.posterior(fsum12(i,index2));
            fprintf('.');
        end
    end
    
    fprintf('\n');
    m = 1e-15;
    % Z-trainsformation of the probabilities. Good to use when you want to
    % weigh these values with other values
    z = norminv(min(1-m,max(m,p1(:,1))));
    
    y(1,1)=sum(predClass==1 & class==1);
    y(1,2)=sum(predClass==1 & class==2);
    y(2,1)=sum(predClass==2 & class==1);
    y(2,2)=sum(predClass==2 & class==2);
    pChi2=chi2test(y);
    fprintf('Ratio correct=%.3f, N=%d,N1=%d,N2=%d,z1=%.3f, z2=%.3f, p(ch2)=%.3f, z=%.3f\n\n',mean(predClass==class),length(class),length(find(predClass==1)),length(find(predClass==2)),mean(z(class==1)),mean(z(class==2)),pChi2,tinv(pChi2,length(class)));
end


%fprintf('time %.5f\n',toc);beep2
%if not(isfield(o2,'index'))
    if length(f2)<length(f1) f2=[f2 ones(1,length(f1)-length(f2))]; end
%else
%    if length(f2)<length(f1) f2=[f2 zeros(1,length(f1)-length(f2))]; end
%end

if 0
    %Get wordclasses from all words in o1,o2, which is present in s...
    fprintf('Identifying wordclasses (slow)...\n')
    for i=1:length(index1)
        if rand<.1 fprintf('.');end
        [info s]=getWordClassCash(s,index1(i));
    end
    for i=1:length(index2)
        if rand<.1 fprintf('.');end
        [info s]=getWordClassCash(s,index2(i));
    end
    fprintf('\n')
    
    %Check for errors, 4%....
    wordclass=zeros(s.N,length(s.classlabel));
    for j=1:length(index2)
        i=index2(j);
        if isfield(s.info{i},'wordclass')
            indexWC=s.info{i}.wordclass;
            indexS=word2index(s,s.info{i}.words);
            indexOK=find(not(isnan(indexS)));
            for k=1:length(indexOK);
                wordclass(indexS(indexOK(k)),indexWC(indexOK(k)))=wordclass(indexS(indexOK(k)),indexWC(indexOK(k)))+1;
            end
        end
    end
    sum1=0;
    errors=0;
    for i=1:s.N
        [tmp indexWC]=max(wordclass(i,:));
        if tmp>0
            sum1=sum1+1;
            if not(s.wordclass(i)==indexWC)
                errors=errors+1;
                s.wordclass(i)=indexWC;
            end
        end
    end
end


if print
    fprintf('\n\nNumber of words in set1 %.0f and in set2 %.0f\n',sum(f1),sum(f2));
    fprintf('\nKeywords summarizing set1 (%s) relative to set2 (%s)',label1,label2);
end
statsPro1 =print_res_freq(s.fwords,f1,f2,N,s,print,selection,fsum1,corrProperty);
statsRelevant1 =print_res_freq(s.fwords,f1,f2,N,s,print,selectedNorm1);

if not(isempty(index2)) | not(isempty(corrProperty))
    if print
        fprintf('The result below is based on the following contrast words\n')
        fprintf('\nKeywords summarizing set2 (%s) relative to set1 (%s)',label2,label1);
    end
    if not(isempty(corrProperty))
        statsPro2=print_res_freq(s.fwords,f1,f2,N,s,print,selection,fsum1,-corrProperty);
    else
        statsPro2=print_res_freq(s.fwords,f2,f1,N,s,print);
    end
    statsRelevant2=print_res_freq(s.fwords,f2,f1,N,s,print,selectedNorm2);
end

if s.par.save_assocation_matrix 
    [FileName,PathName] =uiputfile('*.txt','Save frequency count table');
    if not(FileName(1)==0)
        f=fopen([PathName FileName],'w');
        fprintf(f,'word f1 f2 p q\n');
        print=1;
    end
else
    f=-1;
end
if length(f1)<length(f2) f1(length(f2))=0; end
if length(fnorm)<length(f2) fnorm(length(f2))=0; end
statsPro1.p(length(s.fwords)+1)=NaN;
[tmp index]=sort(f1+f2,'descend');

if print
    fprintf('Frequency list of 20 most frequenct words (use "options/save association matrix to file" to get a complete list\n');
    fprintf('\nword:\tf1:\tf2:\tp:\tq:\n');
    for j=1:length(s.fwords);
        i=index(j);
        if f1(i)+f2(i)>0
            if f>0
                if sum(f2)==0
                    fprintf(f,'%s\t%d\t%d\t%.4f\t%.2f\n',s.fwords{i},f1(i),fnorm(i),statsPro1.p(i),qNorm1(i));
                else
                    fprintf(f,'%s\t%d\t%d\t%.4f\t%.2f\n',s.fwords{i},f1(i),f2(i),statsPro1.p(i),statsPro1.q(i));
                end
            end
            if j<20
                fprintf('%s\t%d\t%d\t%.4f\t%.2f\n',s.fwords{i},f1(i),f2(i),statsPro1.p(i),statsPro1.q(i));
            end
        end
    end
    fprintf('\n')
end

if print;
    try;fclose(f);end
end



out.comment1='Descriptive statistics';
out.N1=sum(f1);
out.N2=sum(f2);
out.N1text=length(index1);
out.N2text=length(index2);
out.Nunique=length(find(f1+f2)>0);

out.comment4='Similiarity set1 and set2';
out.similarity=sum(f1/sum(f1.*f1)^.5.*f2/sum(f2.*f2)^.5);
[~,out.pN]=ttest2(f1tot,f2tot);


out.comment3='Keywords';
out.keywords1=statsPro1.keyword;
try;
    out.keywords2=statsPro2.keyword;
    out.keywokeywords2words;
end
try
    out.keywordsCorr1=statsCorr1.keyword;
    out.keywordsCorr2=statsCorr2.keyword;
end
out.relevantKeywords1=statsRelevant1.keyword;
try;out.relevantKeywords2=statsRelevant2.keyword;end

%Semantic keywords...
xdiff=average_vector(s,s.x(find(f1(1:minf)),:),1:minf,f1)-average_vector(s,s.x(find(f2(1:minf)),:),1:minf,f2);
semanticSelectWords=s.par.semanticSelectWords;
%Select keywords that are signifikant at 0.05 and order them semantically
pSemantic=.05;
s.par.semanticSelectWords=find(f1(1:minf)+f2(1:minf)>0 & (statsRelevant1.p(1:minf)<pSemantic | statsRelevant1.p(1:minf)>1-pSemantic) );
[tmp, tmp,out.semanticAssocates1]=print_nearest_associations_s(s,'noprint',xdiff,'descend');
[tmp, tmp,out.semanticAssocates2]=print_nearest_associations_s(s,'noprint',xdiff,'ascend');
s.par.semanticSelectWords=semanticSelectWords;

try;out.keywordsNorm1=statsNorm1.keyword;end

if s.par.keywordsWordclass %Wordclasses
    keywordsWCstring=sprintf([char(13) 'wordclass        \tN1\tN2\tp\tSignificant words1\tSignificant words2\n']);
    if print
        fprintf('\nWORDCLASS ANALYSIS\n',sum(f1),sum(f2));
    end
    wordclass=s.wordclass;
    if length(wordclass)<length(f1);wordclass(length(f1))=0;end
    for i=1:length(s.classlabel)
        if print | 1
            fprintf('%s:',s.classlabel{i});
        end
        
        statsWC1=print_res_freq(s.fwords,f1WC(:,i)',f2WC(:,i)',N,s,print,[],fsum1,+corrProperty);
        keywords1WC{i}=statsWC1.keyword;
        pkeywords1WC{i}=statsWC1.pkeyword;
        statsWC2=print_res_freq(s.fwords,f2WC(:,i)',f1WC(:,i)',N,s,print,[],fsum1,-corrProperty);
        keywords2WC{i}=statsWC2.keyword;
        pkeywords2WC{i}=statsWC2.pkeyword;
        
        Y(1,1)=sum(f1WC(:,i));
        Y(2,1)=sum(f2WC(:,i));
        Y(1,2)=sum(sum(f1WC))-sum(f1WC(:,i));
        Y(2,2)=sum(sum(f2WC))-sum(f2WC(:,i));
        
        
        keywordsWCstring=[keywordsWCstring sprintf('%s\t%d\t%d\t%.4f\t%s\t%s\n',fixStringLength(s.classlabel{i}),Y(1,1),Y(2,1),chi2test(Y),keywords1WC{i},keywords2WC{i})];
        if print
            fprintf('\n');
        end
    end
    fprintf('\n');
    
    if print
        fprintf('%s',keywordsWCstring);
    end
    
    out.comment2='Statistics of frequency of wordclasses';
    out.keywordsWCstring=keywordsWCstring;
    
end


s.par.categoryLabel{1}='Semantic clusters';
[out,s]=statisticOnGroupsOfIdentifers(s,index1,index2,out,corrProperty,indexF);
s.par=rmfield(s.par,'categoryLabel');

out.comment10='Clusters that differs between set1 and set 2';
out.keywordsCluster1=outCluster.keywordsCluster1;
out.keywordsCluster2=outCluster.keywordsCluster2;
out.comment8='Chi-square tests of differences in word frequencies within clusters';
out.clusterCategoreis=outCluster.WordList;

out.comment6='Descriptions of the clusters';
out.clusterDefinition=outCluster.clusterDefinition;

%All words
%Wordslist output in text order by columns
%if 1
Nprint=min(length(indexF),50);
w=sprintf('Listing %d most common words of a total of %d  words\n',Nprint,length(indexF));
%else
%    Nprint=length(indexF);
%    w='';
%end

w=[w sprintf('word\tp\tpcorrected\tq\tqnorm1\tf1\tf2\fNorm\tfNorm\tcluster\tclusterClass\n')];
for i=1:Nprint
    w=[w sprintf('%s\t%.3f\t%.3f\t%.3f\t%.3f\t%d\t%d\t%.3f\t%d\t%d\n',...
        s.fwords{indexF(i)},statsPro1.p(indexF(i)),statsPro1.pcorrected(indexF(i)),statsPro1.q(indexF(i)),qNorm1(indexF(i)),f1(indexF(i)),f2(indexF(i)),fnorm(indexF(i)),outCluster.cluster(i),outCluster.clusterPrototyp(i))];
end
out.comment5='Table of most common words and related statistics';
out.wordlist=w;


s.par.maxPrintedCharacters;
maxPrintedCharacters=2000;
out.results=regexprep(struct2text(out,[],maxPrintedCharacters,1),'par.','');
out.results=addComments(out.results);

out=structCopy(out,outCluster);%Add cluster information

%Wordlist output in variables
out.word=s.fwords(indexF);
out.p=statsPro1.p(indexF);
out.pcorrected=statsPro1.pcorrected(indexF);
out.q=statsPro1.q(indexF);
out.qNorm1=qNorm1(indexF(find(indexF<=length(qNorm1))));
out.f1=f1(indexF);
out.f2=f2(indexF);
out.fNorm=fnorm(indexF);




try
    out.keywords1WC=keywords1WC;
    out.pkeywords1WC=pkeywords1WC;
    out.keywords2WC=keywords2WC;
    out.pkeywords2WC=pkeywords2WC;
end

if print2==2 & not(s.par.excelServer)
    showOutput({out.results},'Keywords');
    %fprintf('\n%s\n',out.results);
end

%progress(s,'keywords','Done keywords');


warning on;
return

figure(1);
[fsort fsortindex]=sort(f1,'descend');
plot(fsort(find(fsort>0))/sum(fsort))
hold on;
[fsort fsortindex]=sort(f2,'descend');
plot(fsort(find(fsort>0))/sum(fsort),'r')

s1=[];s2=[];
for i=1:length(f1)
    w=length(find(f1(i)+f2(i)<f1+f2));
    %w=(f1(i)+f2(i));
    if f1(i)>0
        s1(i)=f1(i)*w;
    end
    if f2(i)>0
        s2(i)=f2(i)*w;
    end
end
sum(s1)/sum(f1)
sum(s2)/sum(f2)
[t1 t2 ]=ttest2(s1(find(s1)>0),s2(find(s2>0)))
fall=fall/sum(fall);
[t1 t2 ]=ttest2(fall(find(f1)>0),fall(find(f2>0)))



function stats=print_res_freq(dic,f1,f2,N,s,print,selection,fsum1,corrData)
stats.p=NaN;
stats.q=NaN;
stats.pkeyword=[];
stats.keyword=[];
stats.selected=[];

if nargin<6
    print=1;
end
if nargin<7
    selection=[];
end
if nargin<8
    fsum1=[];
end
if nargin<9
    corrData=[];
end
warning off;
if length(f1)<length(f2) f1=[f1 zeros(1,length(f2)-length(f1))]; end
if length(f2)<length(f1) f2=[f2 zeros(1,length(f1)-length(f2))]; end
if not(isempty(selection))
    if length(selection)<length(f1) selection(length(f1))=0;end
    f1(find(not(selection)))=0;
    f2(find(not(selection)))=0;
end
indexs=find(f1>0 | f2>0);

stats.p=nan(1,length(dic));
stats.q=nan(1,length(dic));

dic=dic(indexs);
f1=f1(indexs);
f2=f2(indexs);

sum1=nansum(f1);
sum2=nansum(f2);
if not(isempty(fsum1)) & not(isempty(corrData)) % length(s.par.keywordCorrProperty)>0 %P-values based on correlation with corrData! (f2 ignored)
    if length(f1)>0
        p(length(f1))=0;q=p;
    end
    fsumNorm1=spalloc(length(corrData),length(fsum1(1,:)),length(fsum1>0));
    if 1
        for i=1:length(corrData)
            fsumNorm1(i,:)=fsum1(i,:)/nansum(fsum1(i,:));
        end
    else %faster but memory problems..
        n=size(fsum1);
        fsumNorm1=fsum1/repmat(nansum(fsum1'),n(2))';
    end
    %index=not(isnan(corrData'+fsumNorm1(:,indexs(i))));
    index=not(isnan(corrData'));
    index=not(isnan(corrData'+fsumNorm1(:,1)));
    if s.par.keywordsPointBiSerialCorrelation
        for i=1:length(f1)
            try
                [q(i),h,p(i),ci] = pointbiserial(fsumNorm1(index,indexs(i))>0,corrData(index)',.05);%,'right'
            catch
                q(i)=NaN;p(i)=NaN;
            end
        end
    else
        for i=1:length(f1)
            [q(i) p(i)]=nancorr(corrData(index)',fsumNorm1(index,indexs(i)));
        end
    end
elseif 1 %Quick optimized using arrays
    [p q]=chi2testArray(f1,f2);
else %P-values based on chi2 test on f1 and f2!
    %Slow for loop, use chi2testArray instead
    p(length(f1))=0;q=p;
    for i=1:length(f1)
        y(1,1)=f1(i);y(2,1)=f2(i);y(1,2)=sum1-f1(i);y(2,2)=sum2-f2(i);
        [p(i) q(i)]=chi2test(y);
    end
end

stats.p(indexs)=p;
stats.q(indexs)=q;
psave=p;

if isempty(corrData)
    p(find(f1/sum1<f2/sum2))=1;
    q(find(f1/sum1<f2/sum2))=0;
end

if print
    fprintf('\nChi2 test on relative frequency (N1=%d, N2=%d, N1(unique)=%d, N2(unique)=%d, N1+2(unique)=%d)\n',sum1,sum2,length(find(f1>0)),length(find(f2>0)), length(f1));
end

data.p=p;
data.q=q;
data.r=q;
data.N1=f1;
data.N2=f2;

crit=q;
direction='descend';

%Bonferroni
pcorr=length(p);
stats.pBonferroni=nan(1,length(stats.p));
stats.pBonferroni(indexs)=psave.*pcorr;
include =ones(1,length(stats.p));
include(indexs)=p<1;
%Holmes
[tmp index]=sort(f1+f2,'descend');
pcorr(index)=1:length(index);
stats.pholmes=nan(1,length(stats.p));
stats.pholmes(indexs)=psave.*pcorr;

if s.par.keywordCorrectionType==0 %Bonferroni
    stats.pcorrected=stats.pBonferroni;
elseif s.par.keywordCorrectionType==2 %Uncorrected
    stats.pcorrected=nan(1,length(stats.p));
    stats.pcorrected(indexs)=p;    
else %=1, Holmes
    stats.pcorrected=stats.pholmes;
end

[stats.keyword, keywordsMini, stats.pkeyword, stats.selected]=print_res(s,data,'Keywords (p is Bonferroni corrected):  ',dic,crit,length(find(stats.pcorrected<.05 & include)),[],direction,print);




function [keywords keywordsMini tmp selected]=print_res(s,data,label,dic,crit,N,threshold,direction,print)
if nargin<6; N=10;end
if nargin<7; threshold=NaN;end
if nargin<8; direction='descend';end
if nargin<9; print=1;end
[tmp indexs]=sort(crit,direction);

select=find(not(isnan(tmp)) & not(isinf(tmp)));
tmp=tmp(select);
indexs=indexs(select);
keywords=[];
keywordsMini=[];
Nsave=N;
if N==0
    if print
        fprintf('No signficiant keywords found, printing 10 words with lowest p-values: ')
    end
    N=min(10,length(select));
end
outputVariable=s.par.resultsVariables;
if isempty(outputVariable)
    outputVariable='p';
end
selected=zeros(1,length(indexs));
selected(indexs(1:N))=1;
for i=1:N
    [tmp2 tmp2 res]=resultsVariables(structSelect(data,indexs(i)),outputVariable,data.p(indexs(i)));
    keywords=[keywords sprintf('%s %s  ',dic{indexs(i)},res)];
    keywordsMini=[keywordsMini sprintf('%s ',dic{indexs(i)})];
end
tmp=tmp(1:N);

if print
    fprintf(label);
    fprintf('%s\n',keywords)
end
if Nsave==0
    keywords=' ';
    keywordsMini=' ';
end




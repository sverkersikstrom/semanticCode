function [s, info,resultTabel]=clusterSpace(s,index,N,name,fByIndex)
resetRandomGenator(s);
resultTabel='';
if nargin<3
    N=[];
end
if isempty(N)
    N=s.par.Ncluster;
end
if nargin<4
    name=[];
end
if isempty(name)
    name=s.par.clusterName;
end
if nargin<5
    fByIndex=[];
end
if not(isfield(index,'x'))
    [o s]=getX(s,index);
else
    o=index;
end
y=[];
text='';
info.results='';

%fprintf('Clustering...');
Nw=size(o.x);
info.y=nan(1,Nw(1));
info.indexX=zeros(1,Nw(1));

for i=1:Nw(1)
    o.x(i,:)=o.x(i,:)/sum(o.x(i,:).*o.x(i,:))^.5;
end
dist_type='cosine';%questdlg2('Choice distance measure','','sqEuclidean','cosine','sqEuclidean');
if o.N<=1
    text=[text sprintf('Error: You need at least two words to cluster\n')];
    return
end
N=min([N Nw]);
warning off
if s.par.clusterQuality
    Nall=1:N+1;
else
    Nall=N;
end
optimalDunn=1e+9;
DB=NaN;Dunn=NaN;
U=s.par.clusterFuzzyKMeansUOverlapParmeter;
for i=1:length(Nall) %Loop over number of cluster!
    fprintf('%d',i);
    for j=1:max(1,s.par.clusterNRepetions) %Try several times. Take the best clustering!
        try
            Ntmp=size(o.x);
            T{i,j}.y=NaN(1,o.N);T{i,j}.x=NaN(N,Ntmp(2));
            if s.par.clusterFuzzyKMeans
                %Make sure that to set
                %s.par.clusterFuzzyKMeansUOverlapParmeter correctly!!! 1.01
                %works ok
                %1.02 500 1e-6 1], default 2 100 1e-5 1]
                %1.005: kantig kontinerlig minskning
                %1.01: mindre kantig, kontinerlig minskning
                %1.02: mindre kantig, N=12
                %1.04: mindre kantig, N=7
                %1.08: kantig fr?n N=10, h?gt hela tiden
                %1.16: h?gt hela tiden, mest noll kluster
                %1.32: tv? ej noll kluster
                %TAKE CARE OF NAN
                indexOk=find(not(isnan(o.x(:,1))));
                Ndim=size(o.x);
                T{i,j}.yFuzzy=nan(Nall(i),Ndim(1));
                [T{i,j}.x,T{i,j}.yFuzzy(:,indexOk),iterations] = fcm(o.x(indexOk,:),Nall(i),[U 500 1e-6 0]);
                if isnan(iterations(end)) & i>1
                    fprintf('Fuzzy k-means algorithm did not converge with U=%.4f, setting U-parameter to 1.1\n',U)
                    U=1.1;
                    [T{i,j}.x,T{i,j}.yFuzzy(:,indexOk),iterations] = fcm(o.x(indexOk,:),Nall(i),[U 500 1e-6 0]);
                    if isnan(iterations(end))
                        fprintf('Fuzzy k-means algorithm did not converge with U-parameter to 1.1\n')
                    end
                end
                [tmp1 T{i,j}.y]=max(T{i,j}.yFuzzy);
                T{i,j}.y(isnan(tmp1))=NaN;
                T{i,j}.y=T{i,j}.y';
            else
                if o.N<Nall(i) %More clusters than data
                    [T{i,j}.y T{i,j}.x]=kmeans(o.x,o.N-1,'Maxiter',5000,'distance',dist_type);
                    T{i,j}.x(o.N:Nall(i),:)=NaN;%Adding missing 
                else
                    [T{i,j}.y T{i,j}.x]=kmeans(o.x,Nall(i),'Maxiter',5000,'distance',dist_type);
                end
            end
            fprintf('.');
            [DB(j), Dunn(j)]=clusterQuality(T{i,j}.y,T{i,j}.x,o.x,Nall(i));
        catch
            text=[text sprintf('Error in clustering, check if the number words are larger than the number of clusters.\n')];
        end
        
    end
    [~,j]=min(DB);
    [~,j]=max(Dunn);
    info.DB(i)=DB(j);info.Dunn(i)=Dunn(j);
    if length(Nall)<=1 
        y=T{i,j}.y;x=T{i,j}.x;
    elseif i==1
        y=T{i,j}.y;x=T{i,j}.x;
        N=i;
    elseif (i>1 & optimalDunn>info.Dunn(i)/info.Dunn(i-1))
        optimalDunn=info.Dunn(i)/info.Dunn(i-1);
        y=T{i-1,j}.y;x=T{i-1,j}.x;
        N=i-1;
    end
end

%Fixing NaN. Matches NaNs words to best fitting words with 
indexNaN=find(isnan(y));
if not(isempty(indexNaN)) & not(isempty(fByIndex))
    for k=1:length(indexNaN)
        indexC=fByIndex.fByIndex(:,index(indexNaN(k)));
        tmp1=fByIndex.fByIndex(indexC(indexC>0),:);
        if not(isempty(tmp1))
            class=zeros(1,length(index));
            for i=1:length(index)
                if tmp1(index(i))>0 & not(isnan(y(i)))
                    class(y(i))=class(y(i))+1;
                end
            end
            [tmp best]=max(class);
            y(indexNaN(k))=best;
        end
    end
end

fprintf('.done\n');

xInSpace=x(:,find(o.xInspace));
warning on
if isempty(xInSpace)
    clear xInSpace
    for i=1:N
        xInSpace(i,:)=average_vector(s, s.x(index(find(y==i)),:));
    end
end

%Seldom used. Categories according to words-classes. Consider removing.
if s.par.clusterDominantWordclass
    wc=zeros(N,length(s.classlabel)+1);
    for i=1:length(index)
        [infoI s]=getWordClassCash(s,index(i),[],1);
        indexOk=infoI.wordclass(infoI.wordclass>0);
        wordclass(i)=0;
        if not(isnan(y(i)))
            wordclass(i)=indexOk(1);
            wc(y(i),indexOk)= wc(y(i),indexOk)+1;
        end
    end
    ysave=y;
    for i=1:N
        wc2=sum(wc(not(i==1:N),:));
        for j=1:length(wc2)
            w1=nansum(wc2(not(j==1:N)));
            w2=nansum( wc(i,not(j==1:N)));
            [p(i,j) q(i,j)]=chi2test([wc2(j), wc(i,j);w1,w2]);
            class(i,j)=wc2(j)/w1<wc(i,j)/w2;
        end
        p(not(class))=1;
        q(not(class))=-Inf;
        q(find(isnan(q)))=-Inf;
        [qsort(i,:) indexQ]=sort(q(i,:),'descend');
        
        dominantWC(i)=indexQ(1);
        dominantWCstring{i}='';
        j=1;
        while p(i,indexQ(j))<.05 & j<=N
            dominantWCstring{i}=[dominantWCstring{i} sprintf('%s\t%d\t%.4f\t',s.classlabel{indexQ(j)},wc(i,indexQ(j)),p(i,indexQ(j)))];
            j=j+1;
        end
        dominantN(i)=wc(i,indexQ(1));
    end
    text=[text sprintf('Cluster\tN\tDominantWordClass\tNdominant\n')];
    for i=1:N
        text=[text sprintf('%d\t%d\t%s\n',i,length(find(y==i)),dominantWCstring{i})];
    end
end


%Printouts
if s.par.clusterFuzzyKMeans
    text=[text sprintf('Algorithm: Fuzzy k-means, using U=%.5f\n',U)];
else
    text=[text sprintf('Algorithm: k-means\n')];
end
labels=cell2string(o.label);
text=[text 'Dimensions: ' labels(1:min(end,2500))];
text=[text sprintf('Semantic    similarity: Words ordered by decreasing semantic similarity to the cluster centroid. Good to use if the data covers different topics.\n')];
text=[text sprintf('Semantic   differences: For cluster 1, we first aggregate the cluster centroid of all other clusters (i.e. 2-N) and subtract this vector from the centroid of cluster 1. We then calculate the semantic similarity (i.e., the cosines of the angle between) between all words and the resulting vector. The ten words with the highest semantic similarity are printed in the table, and they are ordered by decreasing similarity. This procedure is repeated for all clusters. At each step the length of the vectors are normalized to one.')];
%text=[text sprintf('Semantic   differences: Words ordered by decreasing semantic similarity to the difference between cluster centroid and the mean of all other cluster centroids. Good to use if the data has two natural endpoints (e.g., based on difference between between two vectors)\n')];
text=[text sprintf('Semantic dissimilarity: Words ordered by largest semantic dissimilarity to the cluster mean. Good to use if the data otherwise is too simiilar.\n')];



text=[text sprintf('\nCluster\tN\t')];
text=[text sprintf('Semantic similarity\t')];
text=[text sprintf('Semantic difference-similarity\t')];
text=[text sprintf('Semantic dissimilarity\n')];

fprintf('Calculating keywords...');
for i=1:N
    [~, ~ ,textI, out]=print_nearest_associations_s(s,'noprint',xInSpace(i,:),'descend');
    info.index{i}=out.indexClose;
    info.d{i}=out.dClose;
    text=[text sprintf('%d\t%d\t%s\t',i,length(find(y==i)), textI)];
    %kword{i}=s.fwords{info.index{i}(1)};
    
    tmp1=xInSpace(i,:);tmp1=tmp1./sum(tmp1.*tmp1)^.5;
    if N==2
        tmp2=xInSpace(not(1:N==i),:);
    else
        tmp2=nansum(xInSpace(not(1:N==i),:))-xInSpace(i,:);
    end
    tmp2=tmp2./sum(tmp2.*tmp2)^.5;
    dx(i,:)=tmp1-tmp2;
    [~,~, textDiff out]=print_nearest_associations_s(s,'noprint',dx(i,:),'descend');
    text=[text sprintf('%s\t', textDiff)];
    if isempty(out.indexClose)
        kword{i}='';
    else
        kword{i}=s.fwords{out.indexClose(1)};
    end
    
    [~,~, textDiff]=print_nearest_associations_s(s,'noprint',xInSpace(i,:),'ascend');
    text=[text sprintf('%s\n', textDiff)];
end
fprintf('done\n');

%Printing texts in clusters
Nmax=100;
for i=1:N
    select=find(y==i);
    [d indexS]=semanticSearch(x(i,:),o.x(select,:));
    info.indexX(select(indexS))=1:length(indexS);
    text=[text sprintf('Texts in cluster %d: ',i)];
    text=[text index2SmallContext(s,o.index(select(indexS)),Nmax)];
    if length(select)>Nmax
        text=[text sprintf('... And % more words',length(select)-Nmax)];
    end
    text=[text sprintf('\n')];
end

%Printing Dunn-index
[~,Nbest]=max(info.DB(2:end)./info.DB(1:end-1));
DB='';Dunn='';
for i=1:length(Nall)
    DB=[DB sprintf('%d\t%.4f\t',i,info.DB(i))];
    Dunn =[Dunn sprintf('%d\t%.1f\t',i,full(info.Dunn(i)))];
end
text=[text sprintf('\nDavies Bouldin index of cluster quality (N=%d): %s\n',Nbest,DB)];
[~,Nbest]=min(info.Dunn(2:end)./info.Dunn(1:end-1));
text=[text sprintf('Dunn           index of cluster quality (N=%d): %s\n',Nbest,Dunn)];
if s.par.clusterQuality
    figure(1);hold off
    if 1 %Plot Dunn index
        plot(info.Dunn);
        ylabel('Dunn index')
    else %Plot Dunn an DB index
        plot(info.Dunn/nansum(info.Dunn));hold on
        plot(info.DB/nansum(info.DB))
        legend({'Dunn index','Davies Bouldin index'})
        ylabel('Normalized index (percentage)')
    end
    title('Cluster quality')
    xlabel('Number of clusters')
    set(gcf,'color',[1 1 1])
    if s.par.plotAutoSaveFigure
        warning off;mkdir('figure');warning on;
        file=['figure/cluster' num2str(s.par.Ncluster) '-' s.par.variableToCreateSemanticRepresentationFrom];
        title(regexprep(file,'_',''));
        saveas(1,file, 'fig');
        hgx(1,'',[file '.png']);
    end
end


if length(name)>0 %Only do if the an identifier for the clustering is used as input
    catname=fixpropertyname(name);
    text=[text sprintf('Saveing cluster number in property: %s\n',catname)];
    infow.specialword=3;
    
    s.par.fastAdd2Space=1;
    for i=1:N %Add new identifiers for cluster centroids
        [s, ~ ,clusterName{i}]= addX2space(s,['_' name num2str(i)],xInSpace(i,:),infow,1,['Cluster centroid ' num2str(i) ' for ' catname ' : ' cell2string(s.fwords(info.index{i})) ]);
    end
    for i=1:N %Add new identifiers for cluster difference centroids
        s=addX2space(s,['_d' name num2str(i)],dx(i,:),infow,1,['Difference between cluster centroid ' num2str(i) ' and the other ' num2str(N-1) ' clusters for ' catname]);
    end
    s.par.fastAdd2Space=2;
    s=addX2space(s);
    
    %Add identifier for classifier to categories...
    infow.comment=['Classifies a text into 1 of ' num2str(N) ' categories'];
    infow.cluster=clusterName;
    s=addX2space(s,catname,average_vector(s, xInSpace),infow,0,['Categories text into cluster number for ' catname]);
    
    s=setInfo(s,o.fwords,catname,y);%Stores the cluster categories into clustered text
    
end


%Heirical cluster...
if 0
	xOk=o.x;
    xOk(find((isnan(nanmean(o.x')))),:)=nanmean(o.x);%Set NaN to mean
    Y=pdist(xOk,'cosine');%Pairwise cosinus distance between semantic vectors
    squareform(Y);%D as squared form. Easier to look at, but not used.
    Z = linkage(Y);%Links object. First two cloumns identiferas of objects. Last columns is the distance measure.
    figure(2);
    dendrogram(Z);%Plots in dendogram tree
    T = cluster(Z,'cutoff',1.2)
    T = cluster(Z,'maxclust',2)
    find(T==1)
end
if s.par.clusterPlot
    %Divides into a binary tree
    fprintf('Binary heriarical clustering:\n')
    [s,tmp,binarCluster]=binary_cluster(s,o,o.x,o.fwords,0);%s=getSpace('s');
    
    if 0
        s=binary_cluster(s,o,xInSpace,kword,0);%s=getSpace('s');
        fprintf('Hiearical clustering:\n')
        for i=1:N
            xInSpace(i,:)=xInSpace(i,:)/sum(xInSpace(i,:).^2)^.5;
        end
        fprintf('Similiarity matrix between clusters\n');
        for i=1:N
            fprintf('Cluster %d: ',i)
            for j=1:N
                fprintf('%.2f ',sum(xInSpace(i,:).*xInSpace(j,:)));
            end
            fprintf('\n')
        end
        Y = pdist(xInSpace,'cosine');
        squareform(Y);
        Z = linkage(Y);
        [N1 tmp]=size(Z);
        for i=1:N
            lista{i}=i;
        end
        for i=1:N1
            lista{i+N}=[lista{Z(i,1)} lista{Z(i,2)}];
            s=addX2space(s,['_hiearicalcluster' num2str(i+N)],average_vector(s,o.x(lista{i+N},:)),[],1,['Hiearical cluster centroid ' num2str(i) ' for ' catname]);
            kword{i+N}=[kword{Z(i,1)} '+' kword{Z(i,2)}];
            fprintf('cluster %d (%s) [row1 row],groups with cluster %d (%s) creating supercluster %d d=%.2f\n',Z(i,1),kword{Z(i,1)},Z(i,2),kword{Z(i,2)},i+N,Z(i,3));
        end
        figure;
        [H,T]=dendrogram(Z);
    end
end

%function test_cluster_words
if 0
    correct=textread('correct.txt');
    correct=correct(ok_index);
    for i=1:N
        select=find(y==i);
        fprintf('Category=%d N=%d Mean=%.2f ',i,length(select),nanmean(correct(select)));
        select0=find(shiftdim(y,1)==i & correct==0);
        select1=find(shiftdim(y,1)==i & correct==1);
        [x0 x1]=ttest_space(x,select0,select1);
        print_nearest_associations_s(s,'',x1-x0,'descend',num2str(i) );
    end
end

%Used for continous data, and the statistics is based on t-tests.
properties=string2cell(s.par.clusterProperties);
if length(properties)>0
    text2='';
    for k=1:length(properties);
        fprintf('%s ',properties{k});
        [y0,~,s]=getProperty(s,properties{k},o.index);

        [p(k) table]=anova1(y0,y,'off');
        Ntable=size(table);
        text2=[text2 sprintf('%s\n',properties{k})];
        for i=1:Ntable(1)
            for j=1:Ntable(2)
                text2=[text2 cell2string(table(i,j)) char(9)];
            end
            text2=[text2 char(13)];
        end
        text2=[text2 char(13)];
        try
            text2=[text2 sprintf('Eta2 (SS(between)/SS(tot) = %.3f\n',table{2,2}/table{4,2})];
        end
        

        text2=[text2 sprintf('Cluster(row)*Cluster(column) table.\n')];
        text2=[text2 sprintf('Cells represents p-values (*=Bonferroni corrected for multiple-comparisons) from t-tests on variable %s:. +/- indicates direction of significant p-values\n\t',properties{k})];
        text2=[text2 sprintf('m\tsd\td''\t')];
        text2=[text2 sprintf('All others\t')];
        for i=1:N
            text2=[text2 sprintf('%d\t',i)];
        end
        text2=[text2 sprintf('\n')];
        summaryLow{k}='';
        summaryHigh{k}='';
         for i=1:N
            y1=y0(find(y==i));
            
            y1all=y0(find(not(y==i)));
            [tmp z cohensD]=getP(y1,y1all,N);
            if tmp(1)=='-'; summaryLow{k} =[summaryLow{k}  ' ' kword{i}];end
            if tmp(1)=='+'; summaryHigh{k}=[summaryHigh{k} ' ' kword{i}];end
            text2=[text2 sprintf('%d\t%.3f\t%.3f\t%.3f\t%s\t',i,nanmean(y1),nanstd(y1),cohensD,tmp)];
            for j=1:i-1
                y2=y0(find(y==j));
                text2=[text2 getP(y1,y2,N*(N-1)/2)];
            end
            text2=[text2 sprintf('\n')];
        end
    end
    text=[text sprintf('\nSummary table\nvarlable\tp\tunder-presented\tover-represented\n')];
    [~,indexSort]=sort(p,'ascend');
    for i=1:length(properties);
        k=indexSort(i);
        if p(k)<.05/length(p) sig='**'; elseif p(k)<.05 sig='*';else sig='';end
        text=[text sprintf('%s\t%.4f%s\t%s\t%s\n',properties{k},p(k),sig,summaryLow{k},summaryHigh{k})];
    end
    text=[text sprintf('\nNote: Over- and under-represented clusters have significantly higher, respectively lower, mean value in the clusters compared to a baseline of the mean value for all other clusters\n\n')];
    text=[text text2];
end

%Used for categorical data and Chi-2 tests:
propertiesCategorical=string2cell(s.par.clusterPropertiesCategorical);
if length(propertiesCategorical)>0
    text2='';
    text2=[text2 sprintf('Cells represent p-values for Chi-2 tests, testing whether the frequency in a category & clusters differs from other categories and clusters.\n')];
    text2=[text2 sprintf('+=over-represented frequency, -=under represented frequency, NS=not significant, frequency, and the chi2 test (X2 (degress of freedom, N = sample size) = chi-square).\n')];
    text2=[text2 sprintf('Significant values are corrected for multi-comparisions in respect to the number of clusters and categories\n')];
    clear pTot;clear qTot;clear dfTot;
    for k=1:length(propertiesCategorical);
        fprintf('%s ',propertiesCategorical{k});
        [y0,~,s]=getProperty(s,propertiesCategorical{k},o.index);
        yUnique=unique(y0);
        for i=1:N
            for j=1:length(yUnique)
                Nchi2(i,j)=sum(y'==i & y0==yUnique(j));
            end
        end
        [pTot(k),qTot(k),dfTot(k)]=chi2test(Nchi2);
        text2=[text2 sprintf('\n%s (categorical), p=%.4f,q=%.4f, df=%d\n',propertiesCategorical{k},pTot(k),qTot(k),dfTot(k))];
                
        text2=[text2 sprintf('Cluster\t')];
        for i=1:length(yUnique)
            text2=[text2 sprintf('%.2f\t',yUnique(i))];
        end
        text2=[text2 sprintf('\n')];
        for i=1:N
            text2=[text2 sprintf('%d %s\t',i,kword{i})];
            %highCat{k}='';lowCat{k}='';
            for j=1:length(yUnique)
                Nc(1,1)=sum(Nchi2(i,j)); 
                Nc(1,2)=sum(Nchi2(find(not(i==1:N)),j));
                Nc(2,1)=sum(Nchi2(i,find(not(j==1:length(yUnique)))));
                Nc(2,2)=sum(sum(Nchi2(find(not(i==1:N)),find(not(j==1:length(yUnique))))));
                [p q df]=chi2test(Nc);
                %p=myBinomTest(Nchi2(i,j),sum(Nchi2(:,j)),1/N,'two');
                if p<.05/(N*length(yUnique))
                    if Nc(1,1)/Nc(1,2)>Nc(2,1)/Nc(2,2) 
                        sign='+';%highCat{k}=[highCat{k} ' ' num2str(j)];  
                    else
                        sign='-';%lowCat{k}=[lowCat{k} ' ' num2str(j)];
                    end
                    text2=[text2 sprintf('%s %.4f %d, X2 (%d, %d) = %.2f \t',sign,p,Nchi2(i,j),df,sum(sum(Nc)),q)];
                    %X2 (degress of freedom, N = sample size) = chi-square 
                else
                    text2=[text2 sprintf('NS %d\t',Nchi2(i,j))];
                end
            end
            text2=[text2 sprintf('\n')];
        end
    end
    
    text=[text sprintf('\nSummary statistics\nvariable\tp\tQ\tdf\n')];
    [~,indexSort]=sort(qTot,'descend');
    for i=1:length(propertiesCategorical);
        k=indexSort(i);
        text=[text sprintf('%s\t%.4f\t%.2f\t%d\n',propertiesCategorical{k},pTot(k),qTot(k),dfTot(k))];
    end
    text=[text sprintf('\n') text2];
end

info.results=text;
info.text=text;
info.y=y;

if nargout==3
    %Print result tabel
    resultTabel=sprintf('text\tclusterId\t');
    for i=1:N
        resultTabel=[resultTabel sprintf('SemanticSimilarityCluster%d-%s\t',i,s.par.variableToCreateSemanticRepresentationFrom)];
    end
    resultTabel=[resultTabel sprintf('\n')];
    for j=1:length(index)
        tmp=index2word(s,index(j));
        resultTabel=[resultTabel sprintf('%s\t', tmp{1})];
        resultTabel=[resultTabel regexprep(sprintf('%d\t', y(j)),'NaN','')];
        for i=1:N
            resultTabel=[resultTabel regexprep(sprintf('%.3f\t', sum(o.x(j,:).*x(i,:))),'NaN','')];
        end
        resultTabel=[resultTabel sprintf('\n')];
    end
end


function [text, z,cohensD]=getP(y1,y2,N)
try
    [h p]=ttest2(y1,y2);
    p1=length(y1)/(length(y1)+length(y2));
    cohensD=(nanmean(y1)-nanmean(y2))/(nanvar(y1)*p1+nanvar(y2)*(1-p1))^.5;
    z=(nanmean(y1)-nanmean(y2))/(nanvar(y1)/length(y1)+nanvar(y2)/length(y2))^.5;
catch
    p=NaN;
    cohensD=NaN;
    z=NaN;
end
text='';
if p>.05
    text=[text sprintf('ns\t')];
else
    if z>0 sign='+ '; else sign='- ';end
    if p<.05/N star='*';else star=' ';end
    text=[text sprintf('%s%.4f%s\t',sign,p,star)];
end


function text=index2SmallContext(s,index,Nmax)
text='';
Nchar=100;
index=index(index<=s.N);
for j=1:min(Nmax,length(index))
    %if isfield(s.info{index(j)},'context')
    %    context=s.info{index(j)}.context;
    %    if length(context)>Nchar
    %        context=[context(1:Nchar) '... omitting ' num2str(length(context)-Nchar) ' characters\n'];
    %    end
    %else
    %    context=s.fwords{index(j)};
    %end
    %if isnan(context)
    %    context='';
    %end
    context=getText(s,index(j));
    text=[text '[' context(1:min(length(context),100)) ']'];
end

function [DB, Dunn]=clusterQuality(y,c,x,N)
for i=1:N
    index=find(y==i);
    cintra(i,:)=nanmean(nanmean(x(index,:)'.*repmat(x(i,:),length(index),1)'));
    c(i,:)=c(i,:)/sum(c(i,:).*c(i,:))^.5;
    for j=1:N
        cinter(i,j)=sum(c(i,:).*c(j,:));
    end
end
[DB, Dunn] = valid_DbDunn(cintra, cinter, N);

function [DB, Dunn] = valid_DbDunn(cintra, cinter, k)
% Davies-Bouldin index
R = zeros(k);
dbs=zeros(1,k);
for i = 1:k
    for j = i+1:k
        if cinter(i,j) == 0
            R(i,j) = 0;
        else
            R(i,j) = (cintra(i) + cintra(j))/cinter(i,j);
        end
    end
    dbs(i) = max(R(i,:));
end
DB = nanmean(dbs(1:k-1));

% Dunn index
dbs = max(cintra);
R = cinter/dbs;
for i = 1:k-1
    S = R(i,i+1:k);
    dbs(i) = min(S);
end
Dunn = min(dbs);






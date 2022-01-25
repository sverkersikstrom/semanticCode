function [out ,s]=statisticOnGroupsOfIdentifers(s,index1,index2,out,corrProperty,indexF);
if nargin<4;out=[];end
if nargin<5;corrProperty=[];end
if nargin<6;indexF=[];end
data=[];

parcategory=s.par.category;

for i=1:s.par.Ncluster
    parcategory{end}=[parcategory{end} ' ' '_semanticCluster' num2str(i) ];
end

%Compare the two datasets based on getProperty function:

%First dataset
[category1,s,indexLIWC]=getData(s,parcategory,index1);

%Second dataset
[category2,s,indexLIWC]=getData(s,parcategory,index2);


LIWC='';
for i=1:length(parcategory)
    if isfield(s.par,'categoryLabel') & length(s.par.categoryLabel)>=i
        data{i}.categoryLabel=s.par.categoryLabel{i};
    else
        data{i}.categoryLabel='identifiers';
    end
    
    LIWC=[LIWC sprintf('\nCategory of identifier: %s\n',data{i}.categoryLabel)];
    LIWC=[LIWC sprintf('label                     ')];
    if not(isempty(corrProperty))
        LIWC=[LIWC sprintf('\tmean\tp(corr)\t\tr(corr)')];
    else
        LIWC=[LIWC sprintf('\tp\tvalue1\t\tvalue2')];
    end
    if length(s.par.LIWCcorr)>0
        [indexLIWCcorr label]=text2index(s,s.par.LIWCcorr);
        for i=1:length(indexLIWCcorr)
            LIWC=[LIWC sprintf('\t%s',label{i})];
        end
    end
    LIWC=[LIWC sprintf('\n*=significant (uncorrected), **=significant Bonferroni corrected\n')];
    clear LIWCtext
    for j=1:length(indexLIWC{i})
        LIWCr='';
        data{i}.category1(j)=nanmean(category1{i}(:,j));
        data{i}.category2(j)=nanmean(category2{i}(:,j));
        if data{i}.category1(j)>data{i}.category2(j)
            sign='>';
            data{i}.categorySign(j)=1;
        else
            sign='<';
            data{i}.categorySign(j)=0;
        end
        if length(category2{i}(:,j))==0
            data{i}.category_p(j)=NaN;
        else
            [tmp data{i}.category_p(j) tmp stats]=ttest2(category1{i}(:,j),category2{i}(:,j));
            data{i}.tstat(j)=stats.tstat;
        end
        data{i}.categoryIdentifiers{j}=s.fwords{indexLIWC{i}(j)};
        
        if data{i}.category_p(j)<10^-6
            sig='***';
        elseif data{i}.category_p(j)<0.05/length(indexLIWC{i})
            sig=' **';
        elseif data{i}.category_p(j)<0.05
            sig=' *';
        else
            sig='';
            sign='=';
        end
        
        LIWCr=[LIWCr sprintf('%s\t', fixStringLength([data{i}.categoryIdentifiers{j} sig],26))];
        if isempty(corrProperty)
            LIWCr=[LIWCr sprintf('%.4f\t%.4f\t%s\t%.4f\t',data{i}.category_p(j),data{i}.category1(j),sign,data{i}.category2(j))];
        else
            notNanIndex=not(isnan(category1{i}(:,j)+corrProperty'));
            try
                [data{i}.rLIWC(j) data{i}.pRLIWC(j)]=nancorr(category1{i}(notNanIndex,j),corrProperty(notNanIndex)');
                if data{i}.pRLIWC(j)<10^-6
                    sig='***';
                elseif data{i}.pRLIWC(j)<0.05/length(indexLIWC{i})
                    sig=' **';
                elseif data{i}.pRLIWC(j)<0.05
                    sig=' *';
                else
                    sig='  ';
                end
            catch
                fprintf('Error during calculation of Correlation\n');
                data{i}.rLIWC(j)=NaN;data{i}.pRLIWC(j)=NaN;sig='';
            end
            LIWCr=[LIWCr sprintf('%.4f\t%.4f\t%s\t%.4f\t',nanmean(category1{i}(notNanIndex,j)), data{i}.pRLIWC(j),sig,data{i}.rLIWC(j))];
        end
        if length(s.par.LIWCcorr)>0
            for i=1:length(indexLIWCcorr)
                [LIWCcorr,~,s]=getProperty(s,indexLIWCcorr(i),index1);
                notNan=not(isnan(LIWCcorr+category1(:,j)));
                [r(i) p1(i)]=nancorr(category1{i}(notNan,j)',LIWCcorr(notNan,j)');
            end
            for i=1:length(indexLIWCcorr)
                LIWCr=[LIWCr sprintf('%.4f\t',p1(i))];
            end
            for i=1:length(indexLIWCcorr)
                LIWCr=[LIWCr sprintf('%.4f\t',r(i))];
            end
        end
        LIWCtext{j}=[LIWCr sprintf('\n')];
    end
    if length(indexLIWC{i})>0
        if isempty(corrProperty)
            [tmp indexTmp]=sort(data{i}.tstat);%data{i}.category_p);
        else
            [tmp indexTmp]=sort(data{i}.rLIWC);
        end
        for j=1:length(indexTmp)
            LIWC=[LIWC LIWCtext{indexTmp(j)}];
        end
    end
end

for i=1:length(data);
    if isempty(indexF)
        f1=[];
        for i1=1:length(index1)
            [s,f1 , f2WC]=mkfreq(s,index1(i1),f1);
        end
        for i1=1:length(index2)
            [s,f1, f2WC]=mkfreq(s,index2(i1),f1);
        end
        indexF2=find(f1);
        [tmp indexSort]=sort(f1(indexF2),'descend');
        indexF=indexF2(indexSort);
    end
    
    if isfield(data{i},'category_p')
        out.comment9='Categories of identifiers';
        out.categoryIdentifiers{i}=data{i}.categoryIdentifiers;
        out.category_p{i}=data{i}.category_p;
        out.categorySign{i}=data{i}.categorySign;
        if not(isfield(data{i},'class')) | length(data{i}.class)<max(indexF)
            data{i}.class(max(indexF))=0;
        end
        out.categoryClass{i}=data{i}.class(indexF);
        out.categoryLabel{i}=data{i}.categoryLabel;
    end
    out.plotwordCountCorrelation=s.par.plotwordCountCorrelation;
    if isfield(data{i},'rLIWC')
        out.rLIWC{i}=data{i}.rLIWC;
        out.pRLIWC{i}=data{i}.pRLIWC;
    end
end
%out.LIWC=LIWC;
out.comment7='Category of identifiers';
if not(isfield(out,'results'))
    out.results='';
end
out.results=[out.results LIWC];


function [category1,s,indexLIWC]=getData(s,parcategory,index1)
for i=1:length(parcategory)
    [indexLIWC{i} words]=text2index(s,parcategory{i});
    indexLIWC{i}=indexLIWC{i}(find(indexLIWC{i}>0));
    category1{i}=nan(length(index1),length(indexLIWC{i}));
end

getPropertyShow=s.par.getPropertyShow;
if s.par.parfor
    t=toc;
    handles=s.handles;
    s.handles=[];
    for j=1:length(parcategory)
        progress(s,'keywords',['Data 1:' num2str(j) ' ']);
        if isfield(s.par,'CategoryGetPropertyShow') && length(s.par.CategoryGetPropertyShow)>=j
            s.par.getPropertyShow=s.par.CategoryGetPropertyShow{j};
        else
            s.par.getPropertyShow=getPropertyShow;
        end
        parfor i=1:length(indexLIWC{j})
            [tmp{i},~]=getProperty(s,indexLIWC{j}(i),index1);
        end
        for i=1:length(indexLIWC{j})
            category1{j}(:,i)=tmp{i};
        end
    end
    s.handles=handles;
    fprintf('Time=%.2f\n',toc-t)
else
    t=toc;
    for j=1:length(parcategory)
        progress(s,'keywords',['Data 1:' num2str(j) ' ']);
        if isfield(s.par,'CategoryGetPropertyShow') && length(s.par.CategoryGetPropertyShow)>=j
            s.par.getPropertyShow=s.par.CategoryGetPropertyShow{j};
        else
            s.par.getPropertyShow=getPropertyShow;
        end
        if 1
            [category1{j},~,s]=getProperty(s,indexLIWC{j},index1);
            category1{j}=category1{j}';
        else %A bit slower...
            for i=1:length(indexLIWC{j})
                [category1{j}(:,i),~,s]=getProperty(s,indexLIWC{j}(i),index1);
            end
        end
    end
    fprintf('Time=%.2f\n',toc-t)
end
s.par.getPropertyShow=getPropertyShow;


function d=getProperty2fileResults(s,d,file);
%load('English-ab-sumdata.mat')
%s=getNewSpace(d.languagefile)

[~,categories,indexC]=getIndexCategory(5,s);
d.liwcLabels=index2word(s,indexC);
d.results='';
d.results=[d.results sprintf('variable\tLIWC\tkeyword\tf(M)\tm\tstd\tstde\tz\tN\tLIWC\n')];
d.resultsM='';
d.resultsN='';
d.resultsSE='';
d.header='';
for p=1:length(d.properties)
    l=0;
    for k=0:length(indexC)
        if k>0
            fprintf('%d\t%d\t%s\n',p,k,s.fwords{indexC(k)});
            [text textIndex]=getText(s,indexC(k));
            textIndex=textIndex(textIndex>0);
            d.liwcIndex{k}=textIndex;
        end
        d.results=[d.results sprintf('\n')];
        for i=1:length(d.keywords)
            indexTmp=d.data{i}.indexContext;
            inan=find(isnan(d.resAll(p,:)));
            if k>0
                LIWC=s.fwords{indexC(k)};
                indexIsNan=find(mean((isnan(indexTmp')))==1);
                for k1=1:size(indexTmp,1)
                    ok=0;
                    for k2=1:size(indexTmp,2)
                        if find(indexTmp(k1,k2)==textIndex)
                            ok=ok+1;
                        end
                    end
                    
                    if ok==0
                        indexTmp(k1,:)=NaN;
                    end
                    resLIWC(k1)=ok;
                end
                resLIWC(indexIsNan)=NaN;
            else
                LIWC='';resLIWC=NaN;
            end
            indexTmp(find(isnan(indexTmp)))=inan(1);
            res=[];
            for j=1:size(indexTmp,2);
                res(:,j)=d.resAll(p,indexTmp(:,j));
            end
            res2=nanmean(res');
            m(i)=nanmean(res2);
            N=length(find(not(isnan(res2))));
            l=l+1;
            d.tabel(1,l)=nanmean(res2);
            d.tabel(2,l)=nanstd(res2)/N^.5;
            d.tabel(3,l)=N;
            d.resultsM=[d.resultsM sprintf('%.3f\t',nanmean(res2))];
            d.resultsN=[d.resultsN sprintf('%d\t',N)];
            d.resultsSE=[d.resultsSE sprintf('%.3f\t',nanstd(res2)/N^.5)];
            if iscell(d.keywords{i})
                d.headerS{l}=sprintf('%s[%s]\t',d.keywords{i}{1},LIWC);                
            else
                d.headerS{l}=sprintf('%s[%s]\t',d.keywords{i},LIWC);
            end
            d.header=[d.header d.headerS{l}];
            text=sprintf('%s\t%s\t%s\t%.1f\t%.4f\t%.4f\t%.4f\t%.4f\t%d\t%.4f\n',d.properties{p},LIWC,d.headerS{l},sum(d.data{i}.f)/10^6,nanmean(res2),nanstd(res2),nanstd(res2)/N^.5,(nanmean(res2)-m(1))/(nanstd(res2)/N^.5),N,nanmean(resLIWC));
            d.results=[d.results sprintf('%s',text)];
            if k>0;
                d.m2(i,k)=m(i);
                d.LIWC(i,k)=nanmean(resLIWC);
                d.text2{i,k}=text;
            end
        end
    end
    d.header=sprintf('file\t%s%s%s\n',d.header,d.header,d.header);
    d.results2=sprintf('%s\t%s%s%s\n',d.language,d.resultsM,d.resultsSE,d.resultsN);
    fprintf('%s%s',d.header,d.results2);
    fprintf('%s',d.results)
    d.m(p,:)=m;
    figure(p);plot(d.m(p,:));
    d.languagefile=regexprep(s.languagefile,'\.mat','');
    title(regexprep(d.languagefile,'\.mat',''))
    set(gca,'XTickLabel',d.headerS);
    set(gca,'XTick',1:length(indexC));
    saveas(1,[d.languagefile ' Valence of keywords scores'])
end


if 1 %Make plots
    languagefile=regexprep(s.languagefile,'\.mat','');
    m3=mean(d.m2);
    [~,indexSort]=sort(m3);
    m3=d.m2;
    figure(11);plot(m3(:,indexSort)');
    set(gca,'XTickLabel',regexprep(s.fwords(indexC(indexSort)),'_',''));
    set(gca,'XTick',1:length(indexC));
    set(gca,'XTickLabelRotation',90);
    title([languagefile ' Valence of LIWC scores'])
    legend(d.headerS,'location','northwest')
    saveas(11,[languagefile ' Valence of LIWC scores'])
    
    
    m3=d.m2(1,:)-d.m2(2,:);
    [~,indexSort]=sort(m3);
    figure(12);plot(m3(indexSort));
    set(gca,'XTickLabel',regexprep(s.fwords(indexC(indexSort)),'_',''));
    set(gca,'XTick',1:length(indexC));
    set(gca,'XTickLabelRotation',90);
    title([languagefile ' Valence of he - she'])
    saveas(12,[languagefile ' Valence of he - she'])
    
end

if 0 %Compare two or more languages
    
    %Add de files
    for l=1:length(dlang)
        dn{l}=[];
        for i=1:length(dlang{l}.file);
            %d.file={'aa','ae'};
            if isfield(dlang{l},'corpus')
                file=[dlang{l}.path '/' dlang{l}.language '-' dlang{l}.file{i} '-sumdata.mat' ];
            else
                file=[dlang{l}.path '/' dlang{l}.file{i} 'data.mat' ];
            end
            if exist(file)
                fprintf('Loading %s\n',file)
                load(file);
                if isempty(dn{l})
                    dn{l}=d;
                else
                    for j=1:length(dn{1}.keywords)
                        dn{l}.data{j}.indexContext=[dn{1}.data{j}.indexContext; d.data{j}.indexContext];
                    end
                end
            end
        end
    end
    
    
    %         d.file={'5gm-0003','5gm-0004'};
    %         load([d.file{1} 'data']);dn{1}=d;
    %
    %         d.file={'5gm-0003','5gm-0004'};
    %         load([d.file{2} 'data']);dn{2}=d;
    p=1;
    for n=1:length(dn)
        fprintf('\n%s',dn{n}.language);
        for i=1:length(dn{n}.keywords)
            indexContext=dn{n}.data{i}.indexContext;
            indexContext(find(isnan(indexContext)))=1;
            dn{n}.resAll(1)=NaN;
            dn{n}.m(i)=nanmean(nanmean(dn{n}.resAll(p,indexContext)'));
            
            res=[];
            for j=1:size(indexContext,2)
                res(:,j)=dn{n}.resAll(p,indexContext(:,j)');
            end
            res=nanmean(res');
            for j=1:length(dn{n}.liwcIndex)
                indexLiwc=0*indexContext;
                for k=1:length(dn{n}.liwcIndex{j})
                    indexLiwc(find(indexContext==dn{n}.liwcIndex{j}(k)))=1;
                end
                include=[];
                include(sum(indexLiwc')>0)=1;
                dn{n}.m2(i,j)=nanmean(res(find(include)));
            end
            fprintf('.');
            
            dn{n}.z(i)=nanstd(nanmean(dn{n}.resAll(p,indexContext)'));
            dn{n}.Nkeywords(i)=length(find(not(isnan((dn{n}.data{i}.indexContext(:,1))))));
        end
    end
    save('dn','dn')
    
    figure(20);%keywords
    hold off;
    z=[];leg=[];
    for n=1:length(dn)
        z(n,:)=(dn{n}.m-nanmean(dn{n}.m))/nanstd(dn{n}.m);
        x(n,:)=1:length(dn{n}.m);
        std1(n,:)=(dn{n}.z./dn{n}.Nkeywords.^.5) /nanstd(dn{n}.m);
        leg{n}=dn{n}.languagefile;
    end
    errorbar(x',z',std1')
    set(gca,'XTickLabel',dn{1}.keywords);
    set(gca,'XTick',1:length(dn{1}.keywords));
    legend(leg);
    fprintf('Keywords r=%.2f\n',nancorr(dn{1}.m',dn{2}.m'))
    saveas(20,[dn{1}.languagefile '-' dn{2}.languagefile])
    
    type={'LIWC','he-she'};
    for k=0:1
        figure(21+k);%keywords
        if k==0
            m1=mean(dn{1}.m2);
        else
            m1=dn{1}.m2(1,:)-dn{1}.m2(2,:);
        end
        [~,indexSort]=sort(m1);
        m1=(m1-nanmean(m1))/nanstd(m1);
        hold off;plot(m1(:,indexSort)');
        
        for n=2:length(dn)
            indexCmp=zeros(1,length(dn{1}.liwcLabels));
            for i=1:length(dn{1}.liwcLabels)
                j=find(strcmpi(dn{1}.liwcLabels{i},dn{n}.liwcLabels));
                if not(isempty(j))
                    indexCmp(i)=j;
                end
            end
            indexCmp(indexCmp==0)=1;
            if k==0
                m2=mean(dn{n}.m2);
            else
                m2=dn{n}.m2(1,:)-dn{n}.m2(2,:);
            end
            
            m2(1)=NaN;
            m2=m2(indexCmp);
            m2=(m2-nanmean(m2))/nanstd(m2);
            hold on;plot(m2(indexSort)','r');
        end
        
        set(gca,'XTickLabel',regexprep(dn{1}.liwcLabels(indexSort),'_',''));
        set(gca,'XTick',1:length(dn{1}.liwcLabels));
        set(gca,'XTickLabelRotation',90);
        title([type{k+1} ' ' dn{1}.languagefile dn{2}.languagefile])
        legend(leg)
        saveas(21+k,[type{k+1} ' ' dn{1}.languagefile dn{2}.languagefile])
        
        fprintf('%s\tr=%.2f\n',type{k+1},nancorr(m1',m2'))
    end
    
end


function fileSum=summarizeGoogleFile(file);
fileSum=[file '-sum'];
if not(exist(fileSum)) | 0
    fprintf('Making sum file of %s\n',file);
    d.f=fopen(file,'r','native','UTF-8');
    d.fsum=fopen(fileSum,'w','native','UTF-8');
    N=0;
    a=fgets(d.f);
    ltmp=textscan(a,'%s','delimiter',char(9));
    i=0;
    while not(feof(d.f))
        a=fgets(d.f);
        tmp=textscan(a,'%s','delimiter',char(9));%1=text,2=year,3=count1,4=count2
        if not(strcmpi(tmp{1}{1},ltmp{1}{1})) %A different string => save
            
            %Remove _XXX from: word_XXX
            i1=findstr(ltmp{1}{1},'_');
            if isempty(i1)
                tmp2=ltmp{1}{1};
            else
                i2=findstr([' ' ltmp{1}{1} ' '],' ');
                j=1;
                tmp2='';
                for i=1:min(length(i1),length(i2))
                    tmp2=[tmp2 ' ' ltmp{1}{1}(i2(i):i1(i)-1) ];
                end
            end
            fprintf(d.fsum,'%s\t%d\n',tmp2,N);
            i=i+1;if even(1,100); fprintf('.');end
            ltmp=tmp;
            try
                N=tmp{1}{3};
            catch
                fprintf('Error missing N\n')
                N=0;
            end
        else
            N=tmp{1}{3}+N(1);
        end
    end
    delete(file);
    fclose(d.f);
    fclose(d.fsum);
end

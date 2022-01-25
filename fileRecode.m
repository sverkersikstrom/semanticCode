function [words,data,all_labels]=fileRecode(varargin);
% file,fileOut,d,postFix
if nargin<1
    file='results-one_day3-small.xlsx';
else
    file=varargin{1};
end
if nargin<2 %| length(fileOut)==0
    fileOut=['merged' regexprep(file,'xlsx','txt')];
else
    fileOut=varargin{2};
end
if nargin<3
    d{1}={'sum','DA3apetite	DA4sleeping	DA5move	DA6tired	DA7worthless	DA8concentration	DA9suicidal	DcontrolNo	D10problematic	D11episodes	D12episodes	DOtherCause1	DOtherCause2	DOtherCause3','SADS'};
    d{2}={'sum','DA3apetite2	DA4sleeping2	DA5move2	DA6tired2	DA7worthless2	DA8concentration2	DA9suicidal2	DcontrolNo2	D10problematic2	D11episodes2	D12episodes2	DOtherCause12	DOtherCause22	DOtherCause32','SADS2'};
    d{3}={'delete','interviewtime'};
    d{4}={'text2number','Q4',{'Completely unfair','Somewhat unfair','Neither fair nor unfair','Somewhat fair','Completely fair'}};
else
    d=varargin{3};
end
if nargin<4
    postFix='';
else
    postFix=varargin{3};
end

[words, data, maxcol, all_labels]=textread2(file,0);
for i=1:length(d)
    type=d{i}{1};%sum,delete,concat,concatLabel
    if strcmp(type,'match')
        [wordsM, dataM, maxcolM, all_labelsM]=textread2(d{i}{3}{1},0);
        j=find(strcmp(all_labels,d{i}{2}));
        jM=find(strcmp(all_labelsM,d{i}{3}{2}));
        jMmatch=find(strcmp(all_labelsM,d{i}{3}{3}));
        for k=1:size(wordsM,1)
            ok=find(strcmp(words(:,j),wordsM{k,jM}));
            if ok>0 
                for l=1:length(ok)
                    wordsNew{ok(l)}=wordsM{k,jMmatch};
                end
            end
        end
        all_labels=[all_labels ; all_labelsM{jMmatch}];
        words=[words wordsNew'];
        data=[data cell2num(wordsNew)'];
        1;
    elseif strcmp(type,'deleteRows')
        rows=true(1,size(words,1));
        rows(d{i}{2})=0;
        words=words(rows,:);
        data=data(rows,:);
    elseif not(strcmp(type,'keep'))
        index=zeros(1,length(all_labels));
        
        col=strread(d{i}{2},'%s');%column labels
        if length(postFix)>0
            for j=1:length(col)
                col{j}=[col{j} postFix];
            end
        end
        
        if length(d{i})>2
            newCol={[d{i}{3} postFix]};%labels of new column
        else
            newCol=[all_labels(min(find(index))) postFix];%Default values is first labels of new column
        end
        
        for j=1:length(col)
            index(find(strcmp(col{j},all_labels)))=1;
        end
        a=sum(data(:,find(index))');
        
        
        if strcmp(type,'plotHist') |  strcmp(type,'plot')
            
            figure(i);hold off
            
            edges=5;
            for j=1:length(col)
                x=getData(data,col{j},all_labels,d{i});
                if strcmp(type,'plot')
                    xSort=sort(x);
                    plot(1:length(x),xSort,'-o','linewidth',2)
                else
                    [N,edges1] = histcounts(x,edges);
                    if j==1;
                        edges=edges1;
                        for k=1:length(edges)-1
                            edgesIntervall{k}=sprintf('%.1f-%.1f',edges(k),edges(k+1));
                        end
                        %set(gca,'Xtick',edges(2:end))%[1:length(N)],edges(2:end)
                        set(gca,'XtickLabel',edgesIntervall)%[1:length(N)],edges(2:end)
                        set(gca,'XTickLabelRotation',90)
                    end
                    plot(edges(2:end),N,'-o','linewidth',2)
                end
                hold on
            end
            j=find(strcmpi(d{i},'XTickLabel'));
            if j>0; set(gca,'XTickLabel',d{i}{j+1},'fontsize',12); end
            
            j=find(strcmpi(d{i},'legend'));
            if j>0; legend(d{i}{j+1}); end
            
            j=find(strcmpi(d{i},'title'));
            if j>0;
                title(d{i}{j+1})
                saveas(gcf,d{i}{j+1});
            end
            
            set(gcf,'Color',[1 1 1])
            
            j=find(strcmpi(d{i},'ylabel'));
            if j>0;
                ylabelS=d{i}{j+1};
            else
                ylabelS='N';
            end
            ylabel(ylabelS,'fontsize',20);
            
        elseif strcmp(type,'correlation')
            medianVar=strread(d{i}{3},'%s');%median split variables
            for j=find(index)
                for l=1:length(medianVar)
                    index2=find(strcmpi(medianVar{l},all_labels));
                    if find(strcmp(d{i},'ranksum'))>0
                        [~,index1]=sort(data(:,j));
                        [~,index2b]=sort(data(:,index2));
                        [r,p]=nancorr(index1,index2b);
                        type='ranksum';
                    else
                        [r,p]=nancorr(data(:,j),data(:,index2));
                        type='pearson';
                    end
                    fprintf('%s * %s\tr = %.2f, p = %.4f, %s\n',all_labels{j},all_labels{index2},r,p,type)
                end
            end
        elseif strcmp(type,'statsMedianSplit')
            medianVar=strread(d{i}{3},'%s');%median split variables
            for j=find(index)
                for l=1:length(medianVar)
                    indexMedian=find(strcmpi(medianVar{l},all_labels));
                    med=nanmedian(data(:,indexMedian));
                    select1=data(:,indexMedian)> med;N1=abs(length(find(select1))-size(data,1)/2);
                    select2=data(:,indexMedian)>=med;N2=abs(length(find(select2))-size(data,1)/2);
                    if N1<N2 select=select1;else select=select2;end
                    [h,p,CL,stats]=ttest2(data(select,j),data(not(select),j));
                    fprintf('%s: m(%s<median) = %.2f\tm(%s>=median) = %.2f\t,p = %.4f\n',all_labels{j},all_labels{indexMedian},nanmean(data(not(select),j)),all_labels{indexMedian},nanmean(data(select,j)),p)
                end
            end
        elseif strcmp(type,'ttest')
            fprintf('variables\ttext\ttype\tN\tp\td''\tCL\tm1\tm2\n')
            for j=1:2:length(col) %length(find(index))
                x1=getData(data,col{j},all_labels,d{i});
                x2=getData(data,col{j+1},all_labels,d{i});
                
                %indexOk(1)=find(strcmp(col{j},all_labels));
                %indexOk(2)=find(strcmp(col{j+1},all_labels));
                if length(d{i})<3 d{i}{3}='independent';end
                if strcmpi(d{i}{3},'ranksum')
                    [p,h,stats]=ranksum(x1,x2);
                    %[h,p,stats]=ranksum(data(:,indexOk(1)),data(:,indexOk(1)));
                    stats.sd=NaN;
                    stats.df=length(x1)+length(x2)-2;
                    %stats.df=size(data,1)-2;
                elseif strcmpi(d{i}{3},'paired')
                    [h,p,CL,stats]=ttest(x1-x2);
                    %[h,p,CL,stats]=ttest(data(:,indexOk(1))-data(:,indexOk(2)));
                else
                    [h,p,CL,stats]=ttest2(x1,x2,0.05,'both');
                    %[h,p,CL,stats]=ttest2(data(:,indexOk(1)),data(:,indexOk(2)),0.05,'both');
                end
                m1=nanmean(x1);m2=nanmean(x2);
                %m1=nanmean(data(:,indexOk(1)));m2=nanmean(data(:,indexOk(2)));
                dprime=(m1-m2)/stats.sd;
                fprintf('%s-%s:\t',col{j},col{j+1})
                %fprintf('%s-%s:\t',all_labels{indexOk(1)},all_labels{indexOk(2)})
                if p<.0001
                    pString='< .0001';
                else
                    pString=sprintf('= %.4f',p);
                end
                fprintf('%s, t(%d) %s, d'' = %.2f, CL = [%.2f %.2f], m1=%.2f, m2=%.2f\t',d{i}{3},stats.df,pString,dprime,CL(1),CL(2),m1,m2)
                fprintf('%s\t%d\t%.4f\t%.2f\t[%.2f %.2f]\t%.2f\t%.2f\t',d{i}{3},stats.df,p,dprime,CL(1),CL(2),m1,m2)
                fprintf('\n');
            end
        elseif strcmp(type,'stats')
            indexOk=find(index);
            fprintf('\tm\ts\tmin\tmax\tmedian\tN\tnan\tSE\thist\n')
            for j=1:length(indexOk)
                x=data(:,indexOk(j));
                fprintf('%s:\t',all_labels{indexOk(j)})
                if length(find(not(isnan(x))))==0
                    u=unique(words(:,indexOk(j)));
                    for k=1:length(u)
                        j=find(strcmpi(d{i},'skipN'));
                        if not(isempty(j))
                            fprintf('''%s'', ',u{k})
                        else
                            fprintf('%s (N=%d)\t',u{k},length(find(strcmpi(u{k},words(:,indexOk(j))))))
                        end
                    end
                    fprintf('\n')
                else
                    NnotNaN=length(find(not(isnan(x))));
                    if length(unique(x))<=10 | 1
                        [N,edges] = histcounts(x,5);
                        hist=num2str(N);
                    else
                        hist='';
                    end
                    fprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.d\t%.d\t%.2f\t%s\n',nanmean(x),nanstd(x),nanmin(x),nanmax(x),nanmedian(x),NnotNaN,length(find(isnan(x))),nanstd(x)/NnotNaN^.5,hist)
                end
            end
        elseif strcmp(type,'text2number') | strcmp(type,'regexprep')
            labels=d{i}{3};
            words(:,find(index));
            indexOk=find(index);
            for l=1:length(indexOk)
                if strcmpi(d{i}{3}{1},'alphabetical')
                    labels= unique(words(:,indexOk(l)));
                end
                for j=1:size(data,1)
                    for k=1:length(labels)
                        if strcmp(type,'regexprep')
                            %ok=not(isempty(strfind(upper(words{j,indexOk(l)}),upper(labels{k}))));
                            if length(d{i})>=4
                                words{j,indexOk(l)}=regexprep(words{j,indexOk(l)},labels{k},d{i}{4}(k));
                            else
                                ok=strfind(upper(words{j,indexOk(l)}),upper(labels{k}))>0;
                                if ok
                                    words{j,indexOk(l)}=num2str(k);
                                end
                            end
                        else
                            %ok=strcmpi(labels{k},words{j,indexOk(l)});
                            if strcmpi(labels{k},words{j,indexOk(l)});
                                if length(d{i})>=4
                                    k2=d{i}{4}(k);
                                else
                                    k2=k;
                                end
                                if isnumeric(k2)
                                    words{j,indexOk(l)}=num2str(k2);
                                    data(j,indexOk(l))=k2;
                                else
                                    words{j,indexOk(l)}=k2{1};
                                    data(j,indexOk(l))=NaN;
                                end
                            end
                        end  
                    end
                end
            end
        else
            if strcmp(type,'concat') | strcmp(type,'concatLabel')
                for j=1:length(a)
                    aS{j}='';
                    index2=find(index);
                    for k=1:length(index2)
                        if strcmp(type,'concatLabel')
                            if length(words{j,index2(k)})>0
                                tmp=all_labels{index2(k)};
                                i1=findstr(tmp,'[');
                                i2=findstr(tmp,']');
                                if i1>0 & i2>0 tmp=tmp(i1+1:i2-1);end
                                aS{j}=[aS{j} ' ' tmp];
                            end
                        else
                            aS{j}=[aS{j} ' ' words{j,index2(k)}];
                        end
                    end
                end
            elseif strcmp(type,'sum')
                for j=1:length(a)
                    aS{j}=num2str(a(j));
                end
                aS=regexprep(aS,'NaN','');
            elseif strcmp(type,'delete')
            else
                'Parameters should be either concat,delete,or sum'
                stop
            end
            
            %Remove col
            words=words(:,find(not(index)));
            data=data(:,find(not(index)));
            all_labels=all_labels(find(not(index)));
            
            if not(strcmp(type,'delete'))
                %Add col
                addCol=min(find(index));
                
                
                words=[words(:,1:addCol-1) aS' words(:,addCol:size(words,2))];
                data=[data(:,1:addCol-1) a' data(:,addCol:size(data,2))];
                all_labels=[all_labels(1:addCol-1); newCol; all_labels(addCol:size(all_labels,1))];
            end
        end
    end
end

cell2file(words,fileOut,all_labels)

function [x col]=getData(d,col,all_labels,varargin)
if nargin<4
    varargin{1}=[];
end
i1=findstr(col,'[');
i2=findstr(col,']');
if i1>0 & i2>0
    condition=col(i1+1:i2-1);
    [~,tmp]=text2index(initSpace(),condition);
    for i=1:length(tmp)
        i=find(strcmp(all_labels,tmp{i}));
        if not(isempty(i))
            condition=regexprep(condition,tmp{i},['d(:,' num2str(i) ')']);
        end
    end
    col=col(1:i1-1);
    selection=eval(condition);
else
    selection=true(1,size(d,1));
end
i=find(strcmp(col,all_labels));
x=d(selection,i);
%if nargin>3
cov=find(strcmpi(varargin{1},'covariates'));
%else
%    cov=0;
%end
if cov>=3
    covariatesNames=strread(varargin{1}{cov+1},'%s');
    c=[];
    for i=1:length(covariatesNames)
        c=[c , getData(d,covariatesNames{i},all_labels)];
    end
    x=covariates([],x,[],[],c);
end

j=find(strcmpi(varargin{1},'<'));
if j>0
    fprintf('p(<%.2f)=%.3f\n',varargin{1}{j+1},mean(x(not(isnan(x)))<varargin{1}{j+1}))
end
j=find(strcmpi(varargin{1},'>'));
if j>0
    fprintf('p(>%.2f)=%.3f\n',varargin{1}{j+1},mean(x(not(isnan(x)))>varargin{1}{j+1}))
end

if find(strcmpi(varargin{1},'log+1'));
    x=log(x+1);
elseif find(strcmpi(varargin{1},'log10+1'));
    x=log10(x+1);
end
if find(strcmpi(varargin{1},'outliers'));
    z=(x-nanmean(x))/nanstd(x);
    index=find(abs(z)>4);
    x(index)=NaN;
end


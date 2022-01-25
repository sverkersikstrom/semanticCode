function h=diagnos(s,index,models)

if 0 %Debug data
    [wordset s]=getWord(s,'_t1andt2*');
    models={'_predgadtotalt2', '_predphqtotalt2','_preddiffgadphq'};
    modelsName={'Anxiety', 'Depression','Depression - Anxiety'};
end

if nargin<1
    s=getSpace;
end
if nargin<2
    [wordset s]=getWordFromUser(s,'Choice identifier to diagnos');
    if wordset.N==0 return;end
    if length(findstr(wordset.input,'_'))==0
        [s index]=addText2space(s,wordset.input,'_diagnos');
    else
        index=wordset.index;
    end
end
if nargin<3
    [modelsInput s]=getWordFromUser(s,'Choice models');
    if modelsInput.N==0 return;end
    models=modelsInput.fwords;
end
if ischar(models)
    models={models};
end

if strcmpi(models{1},'_predgadtotalt2')
    modelsName={'Anxiety', 'Depression','Depression - Anxiety'};
else
    modelsName=models;
end
modelsColor={'r','k','b'};
indexModel=word2index(s,models);

pCrit=[.8 .95 .99];
pCritLabel={'Mild','Moderate','Severe'};

res=[];
print=0;
par=s.par;
getPropertyShow=s.par.getPropertyShow;
for k=1:min(10,length(index));
    try;close(k);end
    figure(k)
    h(k)=k;
    for model=1:length(models)
        indexModel=word2index(s,models{model});
        if isnan(indexModel)
            fprintf('Error in Diagnosis,model: %s, does not exist.\n', models{model})
            return
        elseif isfield(s.info{indexModel},'predDataStat')
            m=s.info{indexModel}.predDataStat(1);
            Std=s.info{indexModel}.predDataStat(2);
        elseif isfield(s.info{indexModel},'data')
            m=nanmean(s.info{indexModel}.data);
            Std=nanstd(s.info{indexModel}.data);
        else
            fprintf('Warning: %s is not a trained model, setting std=1, m=0.\n', models{model})
            s.par.getPropertyShow='pred2z';
            m=0;Std=1;
        end
        subplot(length(models)+2,1,model)
        x=-3*Std+m:Std/5:3*Std+m;
        plot(x,pdf('norm',x,m,Std),'color',modelsColor{min(length(modelsColor),model)})
        axis off
        title(regexprep(modelsName{model},'_',' '))
        s.par.getPropertyShow='';
        [predOverall,~,s]=getProperty(s, models{model},index(k));
        s.par.getPropertyShow=getPropertyShow;%'pred2zStored';
        %Print predicted value
        text(predOverall,.35/Std,sprintf('%.0f',predOverall),'HorizontalAlignment','center')
        line([predOverall, predOverall],[0 .3/Std],'linewidth',10,'color',modelsColor{model});
        %Print criteria
        for i=1:length(pCrit)
            crit=Std*norminv(pCrit(i))+m;
            text(crit,-.05/Std,sprintf('%s',pCritLabel{i}),'HorizontalAlignment','center')
            line([crit, crit],[0 .05/Std],'linewidth',1,'color','k');
        end
        
        
        res{1,2*(model-1)+1}= sprintf('%s',modelsName{model});
        res{1,2*(model-1)+2}= sprintf('%.2f',predOverall);;
        
        [statment indexWord]=getText(s,index(k));

        %Print words that users has written orded by predicted value
        [x N Ntot words indexWord s]=text2space(s,statment);
        [pred,~,s]=getProperty(s, models{model},words);
        [~,indexSort]=sort(pred,'descend');
        for j=1:length(words)
            i=indexSort(j);
            res{2+j,2*(model-1)+1}= sprintf('%s',words{i});
            res{2+j,2*(model-1)+2}= sprintf('%.2f',pred(i));
            text(pred(i),(length(words)-j)/length(words)/2.5/Std,words{i})
        end

        
        %Get concepts to ask for
        if isfield(s.info{indexModel},'zIndex')
            for j=1:2
                zIndex=s.info{indexModel}.zIndex;
                z=s.info{indexModel}.z;
                Nselected=min(20,length(z));
                Nprinted=min(5,length(z));
                if j==1
                    [tmp zIndexTMP]=sort(z,'descend');
                else
                    [tmp zIndexTMP]=sort(z,'ascend');
                end
                zIndex=zIndex(zIndexTMP(1:Nselected));
                z=z(zIndexTMP(1:Nselected));
                Nwords=length(indexWord);
                indexWord2=indexWord(indexWord>0);
                for l=1:Nprinted
                    d=[];
                    for i=1:length(zIndex)
                        d(i)=nanmean(similarity(s.x(zIndex(i),:),s.x(indexWord2,:)));
                    end
                    %[tmp,indexSortD2]=sort(d);
                    [tmp,indexSortD(l)]=min(d);
                    indexWord2=[indexWord2 zIndex(indexSortD(l))];
                end
                [tmp,indexSortZ]=sort(-abs(z));
                [tmp,indexSortZD]=sort((-abs(z)+nanmean(abs(z)))/std(z)+(d-nanmean(d))/std(d));
                fprintf('Statement         :%s\n'   ,statment);
                askAboutWords=cell2string(s.fwords(zIndex(indexSortD(1:Nprinted))));
                %res{1,2*(model-1)+4+length(words)}= askAboutWords;
                res{4+Nwords+j,2*(model-1)+1}= askAboutWords;
                subplot(length(models)+2,1,length(models)+1)
                %text(x(fix(length(x)*.75)),.2-j/30,askAboutWords)
                text((1-.5)/length(models),.95,'Ask more about...')
                text((model-.5)/length(models),.80,modelsName{model})
                if j==1 direction='high'; else direction='low ';end
                text(.05                      ,(3-j)/3-.15,direction)
                text((model-.5)/length(models),(3-j)/3-.15,askAboutWords)
                axis off
                
                fprintf('Sort by   distance: %s\n'  ,askAboutWords)
                fprintf('Sort by importance: %s\n'  ,cell2string(s.fwords(zIndex(indexSortZ(1:Nprinted)))))
                fprintf('Sort by  combinded: %s\n\n',cell2string(s.fwords(zIndex(indexSortZD(1:Nprinted)))))
                
                1;
            end
        end
        if 0 %Old AskAboutWords
            x=NaN(length(zIndex),s.Ndim);
            d1=getX(s,indexWord );
            x1=average_vector(s,d1.x);
            for i=1:length(zIndex)
                d2=getX(s,[s.info{indexModel}.zIndex(i)]);
                x(i,:)=average_vector(s,x1+d2.x);
            end
            [r rMultinomial]=predictReg(s.info{indexModel}.model,x,s.info{indexModel}.par);
            [~,indexSort]=sort(r);
            for i=1:3
                tmp=index2word(s,zIndex(indexSort(i)));
                fprintf('%s\t',tmp{1});
            end
            for i=1:3
                tmp=index2word(s,zIndex(indexSort(end-i+1)));
                fprintf('%s\t',tmp{1});
            end
            %unhelpful	crying	bummed	dread	finance	dependent
        end
        
    end
    
    %Print wordcloud
    subplot(length(models)+2,1,length(models)+2)
    plot(x,pdf('norm',x,m,Std),'color','w');axis off;
    s.par.plotNumber=k;
    s.par.plotScale=1;
    s.par.plotPosition=get(gcf,'position');
    [out,hTmp,s]=plotWordCloud(s,index(k));
    
    %Print output to tabel
    N=size(res);
    r='';
    for row=1:N(1)
        for c=1:N(2)
            r=[r sprintf('%s\t',res{row,c})];
        end
        r=[r sprintf('\n')];
    end
    fprintf('%s\n',r)
    participant=index2word(s,index(k));participant=participant{1};
    showOutput({r},['Diagnosis ' participant])
    if print
        saveas(1,participant)
    end
    p=get(k,'Position');
    p(3)=825;
    p(4)=682;
    set(k,'Position',p);
    
end

s.par=par;



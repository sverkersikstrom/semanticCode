function d=scriptMARGRET2(s,d)
%scp -r /Users/sverkersikstrom\ 1/Dropbox/Dropbox/semantic/semanticCode/scriptMARGRET2.m sverker@aurora.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/themes/results3.mat /Users/sverkersikstrom\ 1/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/nonustwitter
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/nonustweets/resultsParTot.mat /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/nonustwitter
%scp -r /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/nonustwitter/Culture-scores\ Results.xlsx sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/erika
%ssh sverker@aurora.lunarc.lu.se
%2018-09-26 Sverker  RKReGcvgr7uX
%cd /lunarc/nobackup/users/sverker/Margret/themes
%sbatch job1.scr
%bordersm('russia','facecolor',[.5 .5 1])
%d.mkResults=1;d=scriptMARGRET2([],d);

%read space
if nargin<1
    s=[];
end
if isempty(s)
    spaceName='spaceEnglish';
    if not(ismac)
        s=getNewSpace(['/lunarc/nobackup/users/sverker/Margret/' spaceName]);
    else
        s=getNewSpace(spaceName);
    end
end
fStart=1;
if nargin>=2
    if ischar(d)
        file=d;
        clear d;
        d.file=file;
    end
    if isfield(d,'sum')
        d=getD(s,d);
        iLoop=max(1000,fix(length(d.inFile)/d.parN+1));
        for i=1:10 %iLoop
            file=['resultsPar' num2str(i) '.mat'];
            if exist(file)
                fprintf('Summing %s\n',file);
                load(file);
                if not(exist('dTot'))
                    dTot=d;
                else
                    for j=1:length(d.data)
                        try
                            [d,dTot]=recode(dTot,d,j,2);
                            [d,dTot]=recode(dTot,d,j,3);
                            [d,dTot]=recode(dTot,d,j,4);
                            
                            dTot.data{j}.d=[dTot.data{j}.d; d.data{j}.d(not(isnan(d.data{j}.d(:,1))),:)];
                            dTot.data{j}.N=dTot.data{j}.N+d.data{j}.N;
                            dTot.done(find(d.done>0))=1;
                        catch
                            fprintf('Missing data %s\n',file);
                        end
                    end
                end
                d=dTot;
                save('resultsParTot','d');
            end
        end
        d=mkResults(s,d);
        return
    end
    mkResults1= isfield(d,'mkResults');
    if isfield(d,'file')
        fprintf('Loading %s\n',d.file)
        load(d.file);
        fStart=d.fId+1;
        fprintf('Starting at %d\n',fStart);
        d.tsave=now;
    end
    if mkResults1
        d=mkResults(s,d);
        return
    end
else
    d=[];
end
d=getD(s,d);

if not(isfield(d,'par')) d.par=0;end
if d.par<0
    d.par=1;
    while exist(['resultsPar' num2str(d.par) '.mat']) & d.par<length(d.inFile)/d.parN+1
        d.par=d.par+1;
    end
    save(['resultsPar' num2str(d.par)],'d');
    fprintf('Starting par at %d\n',d.par);
end
if d.par>0
    fStart=d.par*d.parN+1;
    fStop=min(length(d.inFile),(d.par+1)*d.parN);
else
    fStop=length(d.inFile);
end

%Read file, extract context, print to outfile
for fId=fStart:fStop
    d.fId=fId;
    d.row=0;d.Nchar=0;
    d.outFile{fId}=[regexprep(d.inFile{fId}, '.sift' ,'') '-Index.txt'];
    %fout=fopen(d.outFile{fId},'w','native','UTF-8');
    f   =fopen(d.inFile{fId} ,'r','native','UTF-8');
    d.fileInfo=dir(d.inFile{fId});
    
    while not(feof(f))
        try
            Text=fgets(f);
            d.row=d.row+1;
            d.Nchar=d.Nchar+length(Text);
            textCol=textscan(Text,'%s','delimiter',char(9));
            textCol=textCol{1};
            
            Text=textCol(d.textColumn);Text=Text{1};
            Text=regexprep(Text,'<\w+>','');
            words=textscan(Text,'%s');words=words{1};
            
            
            %Extract contexts
            for i=1:length(d.keywords) %This can be made faster!
                
                for l=1:length(d.keywordsTheme{i}) %This can be made faster!
                    k=find(strcmpi(d.keywordsTheme{i}{l},words));
                    if not(isempty(k))
                        indexTmp=word2index(s,words);
                        indexTmp=[indexTmp(max(1,k-d.contextSize):min(end,k-1))  indexTmp(min(end+1,k+1):min(end,k+d.contextSize))];
                        indexTmpNaN=[indexTmp nan(1,2*d.contextSize- length(indexTmp))];
                        indexTmp=indexTmp(not(isnan(indexTmp)));
                        
                        %Set data
                        d.data{i}.N=d.data{i}.N+1;
                        N=d.data{i}.N;
                        for j=1:length(d.properties)
                            res=nanmean(d.resAll(j,indexTmp));
                            %fprintf(fout,'%s\t%.4f\t', d.keywords{i},res);
                            %for l=[2 3 4 9]
                            %    fprintf(fout,'%s\t', textCol{l});
                            %end
                            %fprintf(fout,'\n');
                            
                            %save data
                            d.data{i}.d(N,j)=res;
                        end
                        j=j+1;d=setD(d,i,j,textCol{3});%Gender
                        j=j+1;d=setD(d,i,j,textCol{9});%Language
                        j=j+1;d=setD(d,i,j,textCol{4});%Country
                        position=str2num(textCol{7});
                        j=j+1;d.data{i}.d(N,j)=position(1);%Latitude
                        j=j+1;d.data{i}.d(N,j)=position(2);%Longitude
                        j=j+1;d.data{i}.d(N,j)=str2num(textCol{2}(6:7));%Month
                        j=j+1;d=setD(d,i,j,datestr(datenum(textCol{2}(1:10)),'dddd'));%Weekday
                        j=j+1;d.data{i}.d(N,j)=str2num(textCol{2}(12:13));%Hour
                        j=j+1;d.data{i}.d(N,j:j+length(indexTmpNaN)-1)=indexTmpNaN;%Index
                        j=j+length(indexTmpNaN)-1;
                        for m=1:length(d.keywordsFullText)
                            tmp=find(strcmpi(d.keywordsFullText{m},words));
                            j=j+1;d.data{i}.d(N,j)=length(tmp);%Full text keywords
                        end
                        try
                            %d.variables=[d.properties 'gender' 'language' 'country' 'latitude' 'longitude' 'month' 'weekdays' 'hour','date'];
                            %j=j+1;d.data{i}.d(N,j)=datenum(regexprep(regexprep(textCol{2},'T',' '),'Z',' '));
                        catch
                            fprintf('Failed date conversion for %s\n',textCol{2});
                        end
                        %Memory allocation for speed
                        if size(d.data{i}.d,1)<=d.data{i}.N
                            d.data{i}.d=[d.data{i}.d ; nan(400,size(d.data{i}.d,2))];
                        end
                        d.jMax=max(max(d.varWord, j));
                    end
                end
            end
        catch
            mkError('Read error');
        end
        d.done(fId)=1;
        %Print progress
        if abs(now-d.now)*24*60>1 | feof(f)
            d.percentageCompleted=d.Nchar/d.fileInfo.bytes;
            d.estimatedDaysToCompletion=24*d.fileInfo.bytes*(now-d.tstart)/d.Nchar;
            d.now=now;
            fprintf('%d of %d\t%s\t%d\t%s\t%.6f\t%.2f\n',fId,length(d.inFile),d.inFile{fId},d.row,datestr(now),d.percentageCompleted,d.estimatedDaysToCompletion);
        end
        
    end
    d.rowTot=d.rowTot+d.row;d.NcharTot=d.NcharTot+d.Nchar;
    
    if fId==length(d.inFile) | abs(now-d.tsave)*24*60>d.tMinBetweenSaves
        d.tMinBetweenSaves=d.tMinBetweenSaves*1.5+30;
        fprintf('Saving.\n')
        d.tsave=now;
        if d.par
            save(['resultsPar' num2str(d.par)],'d')
        else
            save(['results' num2str(fix(log(1+(now-d.tstart)*24)))],'d')
            d=mkResults(s,d);
        end
        
    end
    %fclose(fout);
    fclose(f);
end

function d=getD(s,d);
%set parameters
if ismac
    d.path='/Users/sverkersikstrom 1/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/nonustwitter/';
else
    d.path='/lunarc/nobackup/users/sverker/Margret/nonustweets/';
end
d.keywordsFullText=[];
if not(isempty(findstr(pwd,'erika')))
    d.keywords=strread('Islam Islamic Islamist Muslim Christianity Christian Judaism Jewish Jew Buddhism Buddhist Hinduism Hindu Religion Religious Secular Secularism Secularization Secularist Atheism atheist','%s');
elseif not(isempty(findstr(pwd,'joel')))
    d.keywords=strread('Blessing Devotion Faith Prayer Salvation Security Safety Care Sensitivity Separation Loneliness Abandonment','%s');
elseif not(isempty(findstr(pwd,'themes')))
    [d.keywordsTheme,d.keywords]=THEMED_WORDS;
    d.keywordsFullText={'he','she'};
    d.variables(16:17)= d.keywordsFullText;
else
    d.path='';
    d.keywords={'he','she','I','you','we','they'};
end
if not(isfield(d,'keywordsTheme'))
    for i=1:length(d.keywords)
        d.keywordsTheme{i}{1}=d.keywords{i};
    end
end

%d.inFile=strread(ls([d.path '*.sift']),'%s');
tmp=textscan(ls([d.path '*.sift']),'%s','Delimiter',char(13));
d.inFile=tmp{1};
d.done(length(d.inFile))=0;

d.properties={'_predvalence'};
d.spaceName='spaceEnglish';
d.textColumn=1;
d.contextSize=3;
for i=1:length(d.keywords)
    d.data{i}.N=0;
end
d.variables=[d.properties 'gender' 'language' 'country' 'latitude' 'longitude' 'month' 'weekdays' 'hour'];
d.varWord=10:15;
d.labels{length(d.variables)}='';
for i=-18:18
    d.labels{5}{i+19}=num2str(i*10);
    d.labels{6}{i+19}=num2str(i*10);
end
for i=1:12
    d.labels{7}{i}=num2str(i);
end
d.labels{8}={ 'Monday'    'Tuesday'    'Wednesday'  'Thursday'   'Friday'    'Saturday'    'Sunday'};
for i=1:24
    d.labels{9}{i}=num2str(i);
end


%make/load optimize file
d.optimizeFile=regexprep([s.languagefile cell2string(d.properties)],'\.mat','');
if exist([d.optimizeFile '.mat'])
    fprintf('Loading saved %s data\n',d.optimizeFile)
    load(d.optimizeFile)
    d.resAll=resAll;
else
    index2=1:s.N;
    if iscell(s.par.getPropertyShow)
        getPropertyShow=s.par.getPropertyShow;
        d.resAll=[];
        for i=1:length(getPropertyShow)
            fprintf('%s\n',d.properties{i});
            s.par.getPropertyShow=getPropertyShow{i};
            [tmp,~,s]=getProperty(s,d.properties{i},index2);
            d.resAll=[d.resAll; tmp];
        end
    else
        tic;[d.resAll,~,s]=getProperty(s,d.properties,index2);toc
    end
    resAll=d.resAll;
    save(d.optimizeFile,'resAll','-V7.3');
end
d.rowTot=0;d.NcharTot=0;
d.now=now;
d.tstart=now;
d.tsave=now;
d.tMinBetweenSaves=5;
d.fId=1;
d.parN=10;


function d=mkResults(s,d);
for i=1:length(d.data)
    if not(isfield(d.data{i},'d'))
        d.data{i}.d(1,1:d.jMax)=NaN;
    end
end

if 0 %Load data
    load('resultsParTot2')
end
if 0 %Get LIWC data
    [~,categories,indexC]=getIndexCategory(5,s);
    for i=1:length(d.keywords)
        d.data{i}.liwc=sparse(size(d.data{i}.d,1),length(indexC));
        for j=1:length(indexC);
            for k=1:length(s.info{indexC(1)}.index)
                for l=1:10:10+d.contextSize*2-1
                    tmp=find(d.data{i}.d(:,l)==s.info{indexC(1)}.index(k));
                    if not(isempty(tmp))
                        i
                        d.data{i}.liwc(tmp,j)=d.data{i}.liwc(tmp,j)+1;
                    end
                end
            end
        end
    end
end

property=1;%Property on y-axes
d.property=property;

if 1 %Print Borders word maps
    try
        propertyLoop=property;
        pLoop=length(d.data)+2;
        for property=propertyLoop
            r='';rAll='';
            for jTmp=pLoop %Loop dataset (e.g., pronouns)
                if jTmp>=length(d.data)+1
                    if jTmp==length(d.data)+1
                        j1=1;j2=2;
                    elseif jTmp==length(d.data)+2
                        j1=5;j2=6;
                    end
                    d.keywords{jTmp}=[d.keywords{j1} '-' d.keywords{j2}];
                    m=nanmean(d.data{j1}.d(:,property)) - nanmean(d.data{j2}.d(:,property));
                else
                    j1=jTmp;
                    m=nanmean(d.data{j1}.d(:,property));
                    tmp=[];
                    for k=1:length(d.data)
                        if not(k==j1)
                            tmp=[tmp d.data{k}.d(:,property)'];
                        end
                        m=(nanmean(d.data{j1}.d(:,property))- nanmean(tmp));
                    end
                end
                try;close(jTmp);end
                figure(jTmp);
                bordersm;
                Sd=nanstd(d.data{j1}.d(:,property));
                col=colormap('jet');
                wordL='';wordH='';
                
                for i=1:length(d.labels{4}) %Loop countries
                    idCountryData=d.data{j1}.d(:,4)==i;
                    z(i)=NaN;
                    if length(find(idCountryData))>0
                        if length(find(idCountryData))>1
                            if jTmp==length(d.data)+1
                                idCountryDataK=d.data{j2}.d(:,4)==i;
                                
                                baselineCountry=nanmean(d.data{j2}.d(idCountryDataK,property));
                                baselineNotCountry=nanmean(d.data{j2}.d(not(idCountryDataK),property));
                                %baseline=  y(j2,i);
                                %baseline2=y2(j2,i);
                                %baseline=0;baseline2=0;
                                [h,p(i),ci,stats]=ttest2(d.data{j1}.d(idCountryData,property)-baselineCountry,d.data{j1}.d(not(idCountryData),property)-baselineNotCountry);
                                z(i)=(nanmean(d.data{j1}.d(idCountryData,property))-baselineCountry-m)/Sd;
                                
                                
                                %                         [x1 f1]=index2x(s,d.data{j1}.d(idCountryData,d.varWord));
                                %                         [x2 f2]=index2x(s,d.data{j2}.d(idCountryDataK,d.varWord));
                                %                         [p1 q qRev]=chi2testArray(f1,f2);
                                %
                                %                         [~,indexH]=sort(qRev,'descend');
                                %                         indexH=indexH(1:length(find(p1<.05/length(find((f1+f2)>0)) & qRev>0)));
                                %                         wordH='';
                                %                         for k=1:min(10,length(indexH));wordH=[wordH sprintf('%s\t',s.fwords{indexH(k)})];end;
                                %
                                %                         [~,indexL]=sort(qRev,'ascend');
                                %                         indexL=indexL(1:length(find(p1<.05/length(find((f1+f2)>0)) & qRev<0)));
                                %                         wordL='';
                                %                         for k=1:min(10,length(indexL));wordL=[wordL sprintf('%s\t',s.fwords{indexL(k)})];end;
                                
                            else
                                tmp=[];tmp2=[];
                                for k=1:length(d.data)
                                    if not(k==j1)
                                        idCountryDataK=d.data{k}.d(:,4)==i;
                                        tmp =[tmp  d.data{k}.d(    idCountryDataK ,property)' ];
                                        tmp2=[tmp2 d.data{k}.d(not(idCountryDataK),property)'];
                                    end
                                end
                                baseline=nanmean(tmp);
                                baseline2=nanmean(tmp2);
                                [h,p(i),ci,stats]=ttest2(d.data{j1}.d(idCountryData,property)-baseline,d.data{j1}.d(not(idCountryData),property)-baseline2);
                                z(i)=(nanmean(d.data{j1}.d(idCountryData,property))-baseline-m)/Sd;
                            end
                            c=col(fix(min(64,max(1,32+100*z(i)))),:);
                            %y(j1,i) =nanmean(d.data{j1}.d(    idCountryData,property));%-baseline
                            %y2(j1,i)=nanmean(d.data{j1}.d(not(idCountryData),property));%-baseline2
                            %[h,p,ci,stats]=ttest2(tmp,tmp2);
                            
                            ass=printAssociates(s,d.data{j1}.d(idCountryData,d.varWord),d.data{j1}.d(not(idCountryData),d.varWord),d.resAll);
                            rTmp=sprintf('%s\t%s\t%.4f\t%.2f\t%d\t%s\t%s\t%s\t%s\t%s\t%s\n',d.keywords{jTmp}, d.labels{4}{i},p(i),z(i),length(find(idCountryData)),ass.WordH,ass.WordL,ass.WordHighPositive,ass.WordHighNegative,ass.WordLowPositive,ass.WordLowhNegative);
                            rAll=[rAll rTmp];
                            if p(i)>.05
                                c=[.5 .5 .5];%Grey for no-significance
                            else
                                r=[r rTmp];
                            end
                        else
                            c=[.5 .5 .5];%Grey for one or less data point
                        end
                        try
                            country=d.labels{4}{i};
                            country=regexprep(country,'Iran','Iran Islamic Republic of');
                            country=regexprep(country,'Laos','Lao People''s Democratic Republic');
                            country=regexprep(country,'Vietnam','Viet Nam');
                            country=regexprep(country,'South Georgia and the South Sandwich Islands','South Georgia South Sandwich Islands');
                            country=regexprep(country,'Syria','Syrian Arab Republic');
                            country=regexprep(country,'Republic of the Congo','Democratic Republic of the Congo');
                            bordersm(country,'facecolor',c)
                        catch
                            fprintf('Error in Borders for %s\n',d.labels{4}{i})
                        end
                    end
                end
                title(d.keywords{jTmp})
                colorbar('Ticks',[0,.5,1],'TickLabels',{'z=-.01','z=0.00','z=+.01'})
                h=gcf;
                %saveas(h.Number,['Figure WorldPlot ' d.keywords{jTmp}])
                hgx(h.Number,'',['Figure WorldPlot ' d.variables{property} '-' d.keywords{jTmp} '.png']);
            end
            f=fopen(sprintf('resultsCountries %s.txt',d.variables{property}),'w');
            fprintf('%s',r);
            fprintf('keyword\tcountry\tp\tz\toverrepresented\tunderpresented\toverepresented+Positive\toverepresented+Negative\tunderpresented+Positive\toverepresented+Negative\n');
            fprintf(f,'keyword\tcountry\tp\tz\toverrepresented\tunderpresented\toverepresented+Positive\toverepresented+Negative\tunderpresented+Positive\toverepresented+Negative\n');
            fprintf(f,'%s',r);
            fprintf(f,'\nAll countries\n%s',rAll);
            fclose(f);
        end
    catch
        mkError('Error WorldPlots\n')
    end
end

try %Create clusters and plot old world map (these are the old and ugly word maps)
    fprintf('Create clusters')
    xy=[];
    for i=1:length(d.data)
        if size(xy,1)<100000
            xy=[xy ; d.data{i}.d(:,5:6)];
        end
        %size(xy)
    end
    if size(xy,1)>100000
        xy=xy(1:100000,:);
    end
    xy=xy(not(isnan(xy(:,1))),:);
    [cluster centroid]=kmeans(xy,min(300,fix(size(xy,1)/5)));
    fprintf('..done\n')
    
    for j=1:length(d.keywords)
        d.data{j}.cluster=NaN(1,size(d.data{j}.d,1));
        for i=1:size(d.data{j}.d,1)
            [a d.data{j}.cluster(i)]=min((centroid(:,1)-d.data{j}.d(i,5)).^2+(centroid(:,2)-d.data{j}.d(i,6)).^2);
        end
    end
    %try;close(12);end
    figure(12)
    set(gca,'Xlim',[-180 180])
    set(gca,'Ylim',[-90 90])
    axis off
    j1=1;j2=2;
    %r12=nanmean([d.data{j1}.d(:,property) nanmean(d.data{j2}.d(:,property))]);
    %rSDE12=nanstd(d.data{j1}.d(:,property))/((d.data{j1}.N+d.data{j2}.N)/centroid(i,2))^.5;
    for i=1:size(centroid,1)
        index1=find(i==d.data{j1}.cluster);
        r1=nanmean(d.data{j1}.d(index1,property));
        index2=find(i==d.data{j2}.cluster);
        r2=nanmean(d.data{j2}.d(index2,property));
        sr12=(nanvar(d.data{j1}.d(index1,property))/d.data{j1}.N+nanvar(d.data{j2}.d(index2,property)/d.data{j2}.N))^.5;
        fontSize=2*max(2,fix(12*((length(index1)+length(index2))*size(centroid,1)/(d.data{j1}.N+d.data{j2}.N))^.5));
        if not(isinf(fontSize))
            col=colormap('jet');
            iCol=max(1,min(size(col,1),fix((r1-r2)/sr12+size(col,1)/2)));
            text(centroid(i,2),centroid(i,1),'x','fontsize',fontSize,'col',col(iCol,:))
        end
    end
    for i=1:length(d.labels{4})
        index1=find(i==d.data{1}.d(:,4));
        if length(index1)>250
            text(nanmean(d.data{1}.d(index1,6)),nanmean(d.data{1}.d(index1,5)),d.labels{4}{i});
        end
    end
    mapFile=['Figure Map ' d.keywords{j1} '-' d.keywords{j2}];
    saveas(12,mapFile);
    hgx(12,'',[mapFile '.png']);
catch
    mkError('\nError in making maps\n')
end

try %Close figures
    for i=1:30
        try;close(i);end
    end
end

if 0 %Add predictions from powerNorm.xlsx
    norms=textread2('powerNorms.xlsx');
    for i=(1:size(norms,1))
        v=i+18-1; 
        for p=1:length(d.keywords)
            d.variables{v}=norms{i,1};%NormName
            x=text2space(s,norms{i,2});%Norm-x
            fprintf('Adding norm: %s %s\n',d.keywords{p},norms{i,1})
            %Calculate semantic similiarty to norms and save in data.d(i,v)
            index=d.data{p}.d(:,d.varWord);
            index(isnan(index))=word2index(s,'_nan');
            for j=1:size(index,1)
                x2=nansum(s.x(index(j,:),:));x2=x2/sum(x2.*x2)^.5;
                d.data{p}.d(j,v)=nansum(x.*x2);
            end
        end
    end
end

if 0 %Create PWP from _powerdomains and _importantthings in life
    d.variables{26}='PWP';
    for p=1:length(d.keywords)
        d.data{p}.d(:,26)=d.data{p}.d(:,22).*d.data{p}.d(:,25);
    end
end
    

if 0 %try %Add predictions from x-representation
    newVar=[16 17];
    for v=newVar
        for p=1:length(d.keywords)
            if v==16
                d.variables{v}=[d.keywords{1} ' - ' d.keywords{2}];%he-she
                x=d.data{1}.x-d.data{2}.x;
                x=x/sum(x.*x)^.5;
            elseif v==17
                d.variables{v}='User(he-she)';
                x1=index2x(s,d.data{p}.d(d.data{p}.d(:,2)==1,d.varWord));
                x2=index2x(s,d.data{p}.d(d.data{p}.d(:,2)==2,d.varWord));
                x=x1-x2;
                x=x/sum(x.*x)^.5;
            end
            index=d.data{p}.d(:,d.varWord);
            index(isnan(index))=word2index(s,'_nan');
            for i=1:size(index,1)
                x2=nansum(s.x(index(i,:),:));x2=x2/sum(x2.*x2)^.5;
                d.data{p}.d(i,v)=nansum(x.*x2);
            end
        end
    end
end

try %Make frequency vector and plot wordClouds
    for p=1:6
        [x1 f1]=index2x(s,d.data{p}.d(:,d.varWord));
        d.data{p}.x=x1;
        d.data{p}.f=f1;
        index=[];
        for i=1:6
            if not(p==i)
                index=[index; d.data{i}.d(:,d.varWord)];
            end
        end
        [x2 f2]=index2x(s,index);
        [p1 q]=chi2testArray(f1,f2);
        reverse=f1/sum(f1)<f2/sum(f2);
        q(reverse)=-q(reverse);
        q(isnan(q))=0;
        
        [~,indexH]=sort(q,'descend');
        indexH=indexH(1:length(find(p1<.05/length(find((f1+f2)>0)) & q>0)));
        for i=1:min(10,length(indexH));fprintf('%s\t',s.fwords{indexH(i)});end;fprintf('\n')
        try;close(20+p);end;figure(20+p);
        wordCloud(s,[],s.fwords(indexH),p1(indexH),q(indexH));
        title(d.keywords{p},'fontsize',30)
        saveas(20+p,['Figure wordcloud ' d.keywords{p}])
        hgx(20+p,'',['Figure wordcloud ' d.keywords{p} '.png']);
        %saveas(20+p,['Figure wordcloud ' d.keywords{p}],'jpg')
    end
catch
    mkError('Error plot wordclouds\n')
end

try %Read external world gender variabeles for countries and make correlations
    propertyLoop=property;
    idCountry=NaN(1,500);
    label=d.keywords;
    clear rVall;clear rVall2;clear rVall3;clear label2;clear label3;
    for k=1:length(propertyLoop)
        property=propertyLoop(k);
        fprintf('External variabels on %s\n',d.variables{property});
        dataFile={'Culture-scores.xlsx','master.xlsx','GIWPS.xlsx'};
        fId=3;
        r=sprintf('%s\t%s\t%s\tChars=%d\tRows=%d\n',dataFile{fId},d.optimizeFile,datestr(d.tstart),d.NcharTot,d.rowTot);
        %[dataCultureNum,dataCultureString]= xlsread(dataFile);
        %dataCultureLabels=dataCultureString(1,2:end);
        %dataCultureCountries=dataCultureString(2:end,1);
        [dataCultureString,dataCultureNum,~,dataCultureLabels]= textread2(dataFile{fId});
        %dataCultureCountries=dataCultureString(2:end,1);
        dataCultureCountries=dataCultureString(:,1);
        
        r=[r sprintf('\tN\t')];
        for i=1:length(label)
            r=[r sprintf('%s\t',label{i})];
        end
        r=[r sprintf('\n')];

        
        %Map countries and calculates y
        clear y;
        clear Nother;
        pLoop=1:length(d.data)+3;
        for printF=[0 1]
            r=[r sprintf('Frequency=%d\n',printF)];
            for i=1:length(dataCultureCountries)
                Nother(i)=0;
                for j=1:length(d.data)
                    Nother(i)=Nother(i)+length(find(d.data{j}.d(:,4)==idCountry(i)));
                end
                r=[r sprintf('%s\t%d\t',dataCultureCountries{i},Nother(i))];
                for p=pLoop
                    tmp1=find(strcmpi(dataCultureCountries{i},d.labels{4}));
                    if p==length(d.data)+3
                        label{p}=[label{5} '+' label{6} ' - ' label{1} '+' label{2}];'we+they - he+she';
                        y(i,p)=y(i,5)+y(i,6) - (y(i,1)+y(i,2));
                        pN(i,p)=pN(i,5)+pN(i,6) - (pN(i,1)+pN(i,2));
                    elseif not(isempty(tmp1))
                        idCountry(i)=tmp1;
                        if p<=length(d.data)
                            pronomen=p;
                            label{p}=d.keywords{p};
                            pronomen2=0;
                        elseif p==length(d.data)+1
                            pronomen =1;
                            pronomen2=2;
                            label{p}=[label{pronomen} '-' label{pronomen2}];% 'he-she';
                        elseif p==length(d.data)+2
                            pronomen =5;
                            pronomen2=6;
                            label{p}=[label{pronomen} '-' label{pronomen2}];%'we-they';
                        end
                        
                        
                        idCountryData=find(d.data{pronomen}.d(:,4)==idCountry(i));
                        pN(i,p)=length(idCountryData)/Nother(i);
                        y(i,p)=nanmean(d.data{pronomen}.d(idCountryData,property));
                        if pronomen2>0
                            idCountryData=find(d.data{pronomen2}.d(:,4)==idCountry(i));
                            y(i,p)=y(i,p)-nanmean(d.data{pronomen2}.d(idCountryData,property));
                            pN(i,p)=pN(i)-length(find(d.data{pronomen2}.d(:,4)==idCountry(i)))/Nother(i);
                        end
                    else
                        y(i,p)=NaN;
                        pN(i,p)=NaN;
                    end
                    if printF
                        r=[r sprintf('%.4f\t',pN(i,p))];
                    else
                        r=[r sprintf('%.4f\t',y(i,p))];
                    end
                end
                r=[r sprintf('\n')];
            end
            
            
            r=[r sprintf('N\t')];
            for i=1:length(d.data)
                r=[r sprintf('%d\t',length(d.data{i}.d(not(isnan(d.data{i}.d(:,1))),1)))];
            end
            r=[r sprintf('\n')];
            
            
            %Calculate and print correlatons
            r=[r sprintf('\nCountry\t')];
            for i=1:length(label)
                r=[r sprintf('r(%s-%s)\tp(%s-%s)\t',label{i},d.variables{property},label{i},d.variables{property})];
                %fprintf('r(%s-F)\tp(%s-F)\t',label{i},label{i});
            end
            r=[r sprintf('\n')];
            selected=Nother>nanmedian(Nother) | 0;
            r=[r sprintf('Selecting countries with N larger than median = %d\n',nanmedian(Nother))];
            for i=2:length(dataCultureLabels)
                r=[r sprintf('%s\t',dataCultureLabels{i})];
                for p=pLoop
                    if printF==2
                        if p<=6 baseline=nanmean(y(selected,not(p==[1:6]))')';else baseline=0;end
                        [rV,pV] =nancorr( y(selected,p)-baseline,dataCultureNum(selected,i));
                    elseif printF
                        [rV,pV]=nancorr(pN(selected,p),dataCultureNum(selected,i));
                    else
                        [rV,pV] =nancorr( y(selected,p),dataCultureNum(selected,i));
                    end
                    if printF==0
                        rVall(i,p)=rV;
                        pVall(i,p)=pV;
                    end
                    if pV<.05/length(dataCultureLabels);sigV='**'; elseif pV<.01 sigV='*';else sigV='';end
                    r=[r sprintf('%.2f\t%s%.4f\t',rV,sigV,pV)];
                end
                r=[r sprintf('\n')];
            end
            r=[r sprintf('P(<.01)=%.4f\n',nanmean(nanmean(pVall<.01)))];
        end
        [pAnova,table] = anova1(y(selected,1:2),[],'off');
        r=[r sprintf('\nANOVA by on r by country for : he versus she\n') cell2string(table,9) char(13)];
        for i=1:length(d.keywords)
            [pAnova,table] = anova1(d.data{i}.d(:,property),d.data{i}.d(:,4),'off');
            r=[r sprintf('\nANOVA on raw data by country for: %s\n',d.keywords{i}) cell2string(table,9) char(13)];
        end
        file=sprintf('results %s %s',d.variables{property},regexprep(dataFile{fId},'.xlsx',''));
        save(file,'rVall');
        
        rVall2(:,k*2-2 +[1:2])=rVall(:,1:2);
        label2{k*2-1}=[label{1} '-' d.variables{property}];
        label2{k*2}  =[label{2} '-' d.variables{property}];
        
        rVall3(:,k)=rVall(:,7);
        label3{k}  =[label{7} '-' d.variables{property}];

        plotCorr(rVall,label,dataCultureLabels,file);
        
        r=regexprep(r,'NaN','');
        fprintf('%s',r);
        fout=fopen([file '.txt'],'w');
        fprintf(fout,'%s',r);
        fclose(fout);
    end
    plotCorr(rVall2,label2,dataCultureLabels,['he + she powers - ' regexprep(dataFile{fId},'.xlsx','')]);
    plotCorr(rVall3,label3,dataCultureLabels,['he - she powers - ' regexprep(dataFile{fId},'.xlsx','')]);
catch
    mkError('Error plot datatabel\n')
end

try %Plot: Didvid the data variabels into category, ignore if var==property
    for var=1:9; 
        clear x;clear y;clear ySE;
        for i=1:length(d.keywords)
            for j=1:max(1,length(d.labels{var}));
                if var==property %Plot all data
                    ok=1:length(d.data{i}.d(:,var));
                elseif var==5 | var==6 %Plot categories
                    ok=fix(d.data{i}.d(:,var)/10)==j-18;
                else %Plot categories
                    ok=d.data{i}.d(:,var)==j;
                end
                x(j,i)=i;
                y(j,i)=nanmean(d.data{i}.d(ok,property));
                N(j,i)=sum(not(isnan(d.data{i}.d(ok,property))));
                ySE(j,i)=nanstd(d.data{i}.d(ok,property))/N(j,i)^.5;
            end
        end
        figure(var)
        errorbar(x',y',ySE')
        set(gca,'XTick',1:length(x));
        set(gca,'XTickLabel',d.keywords);
        set(gca,'XTickLabelRotation',90)
        
        ylabel(regexprep(d.properties{property},'_pred',''))
        legend(d.labels{var})
        title(d.variables{var})
        saveas(var,['Figure' d.variables{property} '-' d.variables{var}])
        hgx(var,'',['Figure' d.variables{property} '-' d.variables{var} '.png']);
        %saveas(var,['Figure' d.variables{property} '-' d.variables{var}],'pdf')
    end
catch
    mkError('Error plot category\n')
end

try %Plot property across date
    
    j=find(strcmpi(d.variables,'date'));
    if not(isempty(j))
        try;close(1);end
        figure(1);
        hold on;
        for i=1:length(d.data);
            if 1
                clear t
                for k=1:size(d.data{i}.d,1)
                    try
                        t(k)=datenum(['2018-' num2str(d.data{i}.d(k,7)) '-' num2str(d.data{i}.d(k,8))]);
                    catch
                        t(k)=NaN;
                    end
                end
            else
                t=d.data{i}.d(1:10,j);
            end
            y=d.data{i}.d(:,property);
            y=y(not(isnan(t)));
            t=t(not(isnan(t)));
            [~,index]=sort(t);
            
            plot(t(index),y(index))
            
        end
        legend(d.keywords);
        datetick
        xlabel('date')
        ylabel(regexprep(d.variables{property},'_',''))
        
        file=['Figure time-' d.variables{property}];
        saveas(var,[file])
        hgx(var,'',[file '.png']);
    end
catch
    mkError('Error plot date\n')
end


function d=setD(d,i,j,data)
N=d.data{i}.N;
if isempty(data)
    data='missing';
end
index=find(strcmpi(d.labels{j},data));
if isempty(index)
    d.labels{j}=[d.labels{j} {data}];
    index=find(strcmpi(d.labels{j},data));
end
d.data{i}.d(N,j)=index;

function [x f]=index2x(s,index);
index=reshape(index,1,size(index,1)*size(index,2));
index=index(not(isnan(index)));
f=zeros(1,s.N);
for i=1:length(index)
    f(index(i))=f(index(i))+1;
end
x=zeros(1,size(s.x,2));ok=not(isnan(sum(s.x')));
for i=1:length(f)
    if f(i)>0 & ok(i); x=x+s.x(i,:)*f(i);end
end
x=x/sum(x.*x)^.5;

function mkError(eString)
if nargin<1
    eString='General error';
end
fprintf('\n%s\n',eString);
eTmp=lasterror
for i=1:size(eTmp.stack)
    eTmp.stack(i)
end

function [d,dTot]=recode(dTot,d,j,l)
dRecode=d.data{j}.d(:,l);
dNew=dRecode*NaN;
for k=1:length(d.labels{l})
    index=find(strcmpi(d.labels{l}{k},dTot.labels{l}));
    if not(isempty(index))
        dNew(dRecode==k)=index;
    else
        N=length(dTot.labels{l})+1;
        dTot.labels{l}{N}=d.labels{l}{k};
        dNew(dRecode==k)=N;
    end
end
d.data{j}.d(:,l)=dNew;


function [keywords, labels]=THEMED_WORDS; 

THEMED_WORDS = {...
    'Appearance-Adj',   [{'alluring', 'voluptuous', 'blushing', 'homely', 'plump','sensual', 'gorgeous', 'slim', 'bald', 'fashionable','stout', 'ugly', 'handsome', 'attractive', 'fat', 'thin','pretty', 'beautiful', 'chubby', 'nasty'}],...
    'Intellect-Adj',    [{'precocious', 'resourceful', 'inquisitive', 'sagacious','inventive','astute', 'adaptable', 'reflective', 'discerning', 'intuitive','inquiring','judicious', 'analytical', 'luminous', 'venerable','imaginative', 'shrewd','thoughtful', 'sage', 'smart', 'ingenious', 'clever','brilliant', 'logical','intelligent', 'apt', 'genius', 'wise', 'mastermind', 'learned'}],...
    'Politics-Theme',   [{'democrat', 'republican', 'senate', 'government', 'politics','minister', 'presidency', 'vote', 'president', 'democrats','republicans', 'parliament', 'votes', 'election', 'ministry','elected', 'elect', 'legislator', 'campaign', 'congress','politician'}],...
    'Childcare-Theme',  [{'child', 'children', 'parent', 'parents', 'baby', 'babies','nanny', 'babysitter', 'babysit', 'daycare', 'preschool'}],...
    'Illness-Theme',    [{'autism', 'flu', 'disease', 'death', 'illness', 'cancer','diabetes', 'depression', 'suicide', 'aids', 'sick', 'sickness','measles', 'ebola', 'outbreak', 'epidemic', 'suicidal', 'tired','depressed', 'autistic'}],...
    'Communal-Theme',   [{'community', 'society', 'societies', 'communities', 'humanity','welfare', 'care', 'caring'}],...
    'Success-Theme',    [{'success', 'champion', 'successful', 'win', 'achieve','achievement','contribute', 'contribution', 'greatness', 'courageous','gutsy', 'commendable','respected', 'impressive', 'independent', 'champion', 'champ','champions'}],...
    'Victim-Theme',     [{'abuse', 'abused', 'abuses', 'victim', 'victims', 'survive','survivor', 'survivors', 'harm', 'exploited', 'violence','pain', 'scared', 'threatened', 'endangered', 'vulnerable','broken'}],...
    'Workforce-Theme',  [{'sale', 'sold', 'market', 'job', 'jobs', 'salary', 'pay','wage', 'career', 'boss', 'secretary', 'office', 'department','hire', 'workday'}],...
    'Persistence-Theme',[{'dedicated', 'devout', 'perfected', 'persistent', 'devoted','consistent'}],...
    'Threat-Theme',     [{'scary', 'toxic', 'twisted', 'suspicious', 'threat','dangerous', 'frightening', 'horrifying', 'awful'}],...
    'Excellent-Theme',  [{'phenomenal', 'amazing', 'incredible', 'fantastic','outstanding', 'awesome','magnificent', 'wonderful', 'excellent', 'impressive','brilliant', 'fabulous','magical', 'remarkable', 'stunning', 'adore', 'admire'}],...
    'Prayer-Theme',     [{'bless', 'blessed', 'soul', 'souls', 'pray', 'prayer'}],...
    'Stem-Student-Theme',[{'alum', 'alumna', 'alums', 'student', 'students', 'math','science', 'computer', 'scientist', 'scientists'}],...
    'Unintelligent-Theme',[{'gullible', 'uninformed', 'stupid', 'idiot', 'incapable','ignorant','delusional', 'clueless', 'dumb', 'moron', 'misinformed'}],...
    'Rebel-Theme',      [{'rebel', 'rebellious', 'radical', 'revolution','revolutionary', 'movement','rogue', 'resistance', 'activist', 'feminist', 'liberation'}],...
    'Criminal-Theme',   [{'criminal', 'jail', 'crime', 'corrupt', 'crooked', 'prison'}]};

labels=THEMED_WORDS(1:2:34);
keywords=THEMED_WORDS(2:2:34);

function summarizeThemeData
load('results3')

countryName=d.labels{4};
file={'mean','std','N'};
keywordsTheme=17;
for k=1:length(file)
    t='';
    for i=1:length(countryName)
        t=[t sprintf('%s\t',countryName{i})];
        for j=1:length(d.data)
            if keywordsTheme>0
                index=find(d.data{j}.d(:,4)==i & d.data{j}.d(:,keywordsTheme)==1);
            else
                index=find(d.data{j}.d(:,4)==i);
            end
            
            valence=nanmean(d.data{j}.d(index,1));
            stdValence=nanstd(d.data{j}.d(index,1));
            N=length(index);
            if k==1
                t=[t sprintf('%.3f\t',valence)];
            elseif k==2
                if N==1; stdValence=NaN;end
                t=[t sprintf('%.3f\t',stdValence/N^.5)];
            else
                t=[t sprintf('%d\t',N)];
            end
        end
        t=[t sprintf('\n')];
    end
    if keywordsTheme>0
        file{k}=[file{k} '-' d.keywordsFullText{keywordsTheme-15}];
    end
    f=fopen(sprintf('valence-%s.txt', file{k}),'w');
    t=regexprep(t,'NaN','');
    t=[sprintf('country\t') cell2string(d.keywords,char(9)) sprintf('country\n') t];
    fprintf(f,'%s',t);
    fprintf('%s',t);
    fclose(f);
end

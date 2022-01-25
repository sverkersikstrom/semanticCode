function scriptMARGRET2(s)

%set parameters
d.inFile=strread(ls('*.sift'),'%s');

if not(isempty(findstr(pwd,'erika')))
    d.keywords=strread('Islam Islamic Islamist Muslim Christianity and Christian Judaism Jewish Jew Buddhism Buddhist Hinduism Hindu Religion Religious Secular Secularism Secularization Secularist Atheism atheist','%s');
else
    d.keywords={'he','she','I','you','we','they'};
end

d.properties={'_predvalence'};
d.spaceName='spaceEnglish';
d.textColumn=1;
d.contextSize=3;
for i=1:length(d.keywords)
    d.data{i}.N=0;
end
d.variables=[d.properties 'gender' 'language' 'country' 'latitude' 'longitude' 'month' 'weekdays' 'hour'];
d.labels{length(d.variables)}='';
for i=1:36
    d.labels{5}{i}=num2str(i*10);
    d.labels{6}{i}=num2str(i*10);
end
for i=1:12
    d.labels{7}{i}=num2str(i);
end
d.labels{8}={ 'Monday'    'Tuesday'    'Wednesday'  'Thursday'   'Friday'    'Saturday'    'Sunday'};
for i=1:24
    d.labels{9}{i}=num2str(i);
end

%read space
if nargin<1
    if not(ismac)
        s=getNewSpace(['/lunarc/nobackup/users/sverker/Margret/' d.spaceName]);
    else        
        s=getNewSpace(d.spaceName);
    end
end

%make/load optimize file
optimizeFile=regexprep([s.languagefile cell2string(d.properties)],'\.mat','');
if exist([optimizeFile '.mat'])
    fprintf('Loading saved %s data\n',optimizeFile)
    load(optimizeFile)
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
    save(optimizeFile,'resAll','-V7.3');
end

%Read file, extract context %, print to outfile
d.rowTot=0;d.NcharTot=0;
for fId=1:length(d.inFile)
    d.fId=fId;
    d.row=0;d.Nchar=0;
    %d.outFile{fId}=[regexprep(d.inFile{fId}, '.sift' ,'') '-Index.txt'];
    %fout=fopen(d.outFile{fId},'w','native','UTF-8');
    f   =fopen(d.inFile{fId} ,'r','native','UTF-8');
    d.fileInfo=dir(d.inFile{fId});
    d.now=now;
    d.tstart=now;
    d.tsave=now;

    while not(feof(f))
        text=fgets(f);
        d.row=d.row+1;
        d.Nchar=d.Nchar+length(text);
        textCol=textscan(text,'%s','delimiter',char(9));textCol=textCol{1};
        
        text=textCol(d.textColumn);text=text{1};
        text=regexprep(text,'<\w+>','');
        words=textscan(text,'%s');words=words{1};
        
        
        %Extract contexts
        for i=1:length(d.keywords) %This can be made faster!
            
            k=find(strcmpi(d.keywords{i},words));
            if not(isempty(k))
                indexTmp=word2index(s,words);
                indexTmp=[indexTmp(max(1,k-d.contextSize):min(end,k-1))  indexTmp(min(end+1,k+1):min(end,k+d.contextSize))];
                indexTmpNaN=[indexTmp nan(1,2*d.contextSize- length(indexTmp))];
                indexTmp=indexTmp(not(isnan(indexTmp)));
                
                %Set data
                d.data{i}.N=d.data{i}.N+1;
                N=d.data{i}.N;
                for j=1:length(d.properties)
                    res=nanmean(resAll(j,indexTmp));
                    %                     fprintf(fout,'%s\t%.4f\t', d.keywords{i},res);
                    %                     for l=[2 3 4 9]
                    %                         fprintf(fout,'%s\t', textCol{l});
                    %                     end
                    %                     fprintf(fout,'\n');
                    
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
                
                %Memory allocation for speed
                if size(d.data{i}.d,1)<=d.data{i}.N
                    d.data{i}.d=[d.data{i}.d ; nan(100,size(d.data{i}.d,2))];
                end
            end
        end
        
        %Print progress
        if abs(now-d.now)*24*60>1 | feof(f)
            d.percentageCompleted=d.Nchar/d.fileInfo.bytes;
            d.estimatedDaysToCompletion=24*d.fileInfo.bytes*(now-d.tstart)/d.Nchar;
            d.now=now;
            fprintf('%d\t%s\t%d\t%s\t%.6f\t%.2f\n',fId,d.inFile{fId},d.row,datestr(now),d.percentageCompleted,d.estimatedDaysToCompletion);
        end
        
    end
    d.rowTot=d.rowTot+d.row;d.NcharTot=d.NcharTot+d.Nchar;

    if fId==length(d.inFile) | abs(now-d.tsave)*24*60>5
        fprintf('Saving.\n')
        save(['results' num2str(fix(log(1+(now-d.tstart)*24)))],'d')   
        
        if 0
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
        for var=1:9; %Didvid the data into this, ignore if var==property
            clear x;clear y;clear ySE;
            for i=1:length(d.keywords)
                for j=1:max(1,length(d.labels{var}));
                    if var==property %Plot all data
                        ok=1:length(d.data{i}.d(:,var));
                    elseif var==5 | var==6 %Plot categories
                        ok=fix(d.data{i}.d(:,var)/10)==j;
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
            ylabel(regexprep(d.properties{property},'_pred',''))
            legend(d.labels{var})
            title(d.variables{var})
            saveas(var,['Figure' d.variables{property} '-' d.variables{var}])
            saveas(var,['Figure' d.variables{property} '-' d.variables{var}],'pdf')
        end
    end
    
    %fclose(fout);
    fclose(f);
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


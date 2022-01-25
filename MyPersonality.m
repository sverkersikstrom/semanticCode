function [data, hash]=MyPersonality(command)
if nargin<=0
    command='summarizeUser';
end
%ssh sverker@alarik.lunarc.lu.se
%projinfo
%luncarc: masoh9ieyiCh
%ls /lunarctmp/nobackup/users/sverker/
%scp -r /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/MyPersonality sverker@alarik.lunarc.lu.se:/alarik/nobackup/q_z/sverker/mypersonality
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/ sverker@alarik.lunarc.lu.se:/home/sverker/semantic/semanticCode
%sbatch job1.scr
%scancel 7101

f=[];

try
    if strcmpi(command,'matchFileData')
        %file='big5.csv';
        file='swl.csv';
        matchFileData(file);
    elseif strcmpi(command,'trainData')
        trainData('user_space.mat','swl')
    elseif strcmpi(command,'summarizeUser')
        if 0
            summarizeUser('user_status.csv',1); %('user_status_big5.csv',0);
        else
            summarizeUser('big5.csv',0); %('user_status_big5.csv',0);
        end
    elseif strcmpi(command,'file2space')
        file2space;
    elseif strcmpi(command,'createSpace')
        d.inputType='likes';
        d.debug=1;
        d.debugN=100000;
        d.contextSize=100;
        %d.NSVD=200;
        %s=createSpace('user_like_anonymous.csv',[],[],d);
        d.debug=0;
        d.restart=1;
        s=createSpace('user_like_anonymous.csv',[],[],d);
        beep2(1);
        1;
    elseif strcmpi(command,'printfile')
        f=fopen('user_like_anonymous.csv','r');
        for i=1:10
            fprintf('%s',fgets(f));
        end
    elseif strcmpi(command,'trainLasso')
        step=8000*2*8;
        while step<2000000
            trainLasso(step);
            step=step*2;
        end
    elseif strcmpi(command,'train')
        databaseName='mypersonality';
        %tableName={'big5','demog'};
        tableName={'big5'};
        N=2000;
        for j=1:10 %while N<128000
            for i=1:length(tableName)
                if 1 %Train words...
                    fprintf('Training words\n')
                    databaseName=train(databaseName,tableName{i},[],N);
                else %Train likes
                    fprintf('Training likes\n')
                    databaseName=train(databaseName,tableName{i},[],N,'spaceuser_like_anonymous','likes');
                end
            end
            N=N*2;
        end
        beep2(1);
        1;
    elseif strcmpi(command,'database')
        file='demog';
        file='big5';
        file='swl';
        file='user_status';
        con=file2db(file)
        %[data header big5]=readtable2('big5.csv');
        %struct2Db(con,'demog',big5,'userid');
        %con=file2db('demog')
        1;
        %results = fetch(d,['show slave status']);
        %results = fetch(d,['mysqlimport  mypersonality demog.csv']);
        
        %results = fetch(d,['SELECT `' row '` FROM  `data` WHERE  `unikt_nr` =' col '']);
        
        
    elseif strcmpi(command,'Marie')
        
        %words={'you','it','him','her','them','my','his','her','your','their','its','hers','yours','theirs','myself','himself','herself','yourself','yourselfs','ourselfs','themselves','itself','I','he','she','we','they','me','mine','our','ours','us'};
        
        words={'i','He','She','You','You','We','They','it'  ,'Me','him','Her','you','you','us','them','it',    'my','his','her','your','your','our','their','its',    'mine','his','hers','yours','yours','ours','theirs','its',    'myself','himself','herself','yourself','yourselves','ourselves','themselves','itself'};
        if 0
            [N,con]=countWords(words{1});
            for i=1:length(words)
                fprintf('%s\t%d\n',words{i},countWords(words{i},con))
            end
            mkResults(lower(words),property);
            
            for i=1:length(words)
                d=getData('swl','user_status',['`' words{i} '`=1']);
            end
        end
        words={'January','February','Mars','April','May','June','July','August','September','October','November','December',...
            'Past','Fell','Went','Grew','Spoke','Was','Wrote','Ate','Drove','Did','Chose','Fallen','Gone','Grown',...
            'Spoken','Been','Written','Eaten','Driven','Done','Chosen','Will','Shall',...
            '2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'};
        
        
        s=[];
        property='_predvalence';
        tables={'demog','big5'};%,'swl'
        for i=1:length(words)
            fprintf('%s:\n',words{i});
            %        selectWord(words{i});
            fprintf('\nAddproperty:');
            %       s=addDbProperty(words{i},property,s);
            fprintf('\nGetdata:');
            for k=1:length(tables)
                d=getData(tables{k},'user_status',['`' words{i} '`=1']);
            end
            fprintf('\n');
        end
        mkResults(lower(words));
        
        1;
        if 0
        elseif 0
            for i=1:length(words)
                file=[words{i} '_user_status_properties'];
                fprintf('\n%s: ',file);
                %con=file2db(file);
                mergeDb('demog',file);
                1;
                %[fileMerged,d]=merge(file,{'demog.csv', 'big5.csv'},[],[],-1,d);
            end
        end
        
        %mkResults(words);
        %     elseif 0 %Marie
        %     words={'I','he','she','we','they','me','mine','our','ours','us'};
        %     for i=1:length(words)
        %         file=[words{i} '_user_status_properties.csv'];
        %         [fileMerged]=merge(file,{'demog.csv', 'big5.csv'},[],s,Nmax);
        %     end
    elseif 0
        
        
        words={'I','he','she','we','they','me','mine','our','ours','us'};
        words={'happy','harmony','satisfied'};
        
        if not(exist([words{1} '_' 'user_status.csv']))
            extractContexts('user_status.csv',words);
        end
        
        Nmax=70000;
        restart=0;
        for i=1:length(words)
            file=[words{i} '_user_status.csv'];
            spaceFile=regexprep(file,'.csv','.mat');
            if not(exist(spaceFile)) | restart
                s=getSpace('noSave',[],'/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat');
                s=addfile2space(file,Nmax);
                [fileMerged]=merge(file,[],{'_predvalence'},s,Nmax);
            elseif 1
            else
                s=getSpace('noSave',[],spaceFile);
            end
        end
        beep2
        
        fprintf('Word\tMean\tStd\tN\n')
        for i=1:length(words)
            file=[words{i} '_user_status_properties.csv'];
            warning off;data=readtable(file);warning on;
            N=size(data);
            clear res;
            res=nan(1,N(1));
            for i=1:N(1)
                tmp=data{i,4};
                a=str2num(tmp{1});
                res(i)=a;
            end
            fprintf('%s\t%.4f\t%.4f\t%d\n',file,nanmean(res),nanstd(res)/length(res)^.5,length(res))
        end
        
        properties=getAllproperties;%{'_predvalence','well'};
        properties=[properties pronomen];
        
        file1='user_status.csv';
        file2={'big5.csv','demog.csv'};
        [fileMerged]=merge(file1,file2,properties);
        
    elseif 0
        files=dir('*.csv');
        for i=1:length(files)
            copy(files(i).name);
        end
    elseif 0 %Oscar
        words={'happy','harmony','satisfied,random'};
        extractContexts('user_status.csv',words);%OScars data
    elseif 0
        %Karl Drejing...
        words={'January','February','Mars','April','May','June','July','August','September','October','November','December',...
            'Past','Fell','Went','Grew','Spoke','Was','Wrote','Ate','Drove','Did','Chose','Fallen','Gone','Grown',...
            'Spoken','Been','Written','Eaten','Driven','Done','Chosen','Will','Shall',...
            '2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'};
        
        extractContexts('user_status.csv',words);
    elseif strcmpi(command,'countLikes')
        f=fopen('user_like_anonymous.csv','r');
        header=fgets(f);
        h=java.util.Hashtable;
        N=0;
        row=0;
        tic;
        Ne=fix(30295512/100);
        while not(feof(f))
            a=fgets(f);
            row=row+1;
            i=findstr(a,',');
            userid=a(1:i-1);
            like_id=a(i+1:end);
            
            i=h.get(like_id);
            if isempty(i)
                if N>200000
                    [tmp index]=sort(count,'descend');
                    N=150000;
                    index=index(1:N);
                    like_id_save=like_id_save(index);
                    count=count(index);
                    fprintf('%d',row);
                    h=java.util.Hashtable;
                    for j=1:length(count);
                        h.put(like_id_save{j},j);
                    end
                end
                N=N+1;
                h.put(like_id,N);
                like_id_save{N}=like_id;
                i=h.get(like_id);
                count(N)=0;
            end
            if even(row,Ne)
                fprintf('.');
            end
            count(i)=count(i)+1;
        end
        toc
        fclose(f);
        fout=fopen('user_like_count.csv','w');
        fprintf(fout,'"","lid","n"\n');
        for i=1:length(count)
            fprintf(fout,'"%d","%s","%d"\n',i,like_id_save{i},count(i));
        end
        fclose(fout);
        beep2;
        
    end
    
catch
    m=lasterror
    m.message
    m.stack
    for i=1:length(m.stack)
    end
end


function trainData(datafile,variabel)
if exist('spaceenglish.mat')
    file='spaceenglish.mat';
else
    file='/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat';
end
s=getSpace('noSave',[],file);
if nargin<1
    %datafile='user_spaceSMALL.mat';
    datafile='user_space.mat';
end
load(datafile)
fprintf('trainData %s\n',datafile);
d.par=getPar;
d.handles=getHandles;
d.par.NleaveOuts=2;
d.par.trainOnWordFrequency=0;
d.par.trainSavePrediction=0;

debug=0;

if debug
    'DEUBG MODE'
    d.par.model='';
    d.x=d.x(4000:4100,:);
    d.y=d.y(4000:4100,:);
elseif 0
    d.par.model='logistic';
elseif 1
    d.par.model='lasso';
else
    d.par.selectBestDimensions=1;
end
%i=find(strcmpi(d.variabel,'ope'));
N=size(d.y);
d.par.maxPrintedCharacters=500;
s.par=d.par;
if nargin<2
    index=1:N(2)
else
    index=find(strcmpi(d.variabel,variabel));
end
for i=index
    fprintf('Training %d %s\n',i,d.variabel{i})
    
    propertySave=['_' d.variabel{i} 'fb' ];
    %[s info xnorm]=train(s,d.y(:,i),propertySave,1:length(d.fwords));%,data(index,:));
    [s info xnorm]=train(s,d.y(:,i),propertySave,[],[],d.x);
    %[s info xnorm]=train(s,d.y(:,i),propertySave,1:length(d.fwords));%,data(index,:));
    if isfield(info,'results')
        info
        f=fopen('results.txt','a');
        fprintf(f,'%s\n',info.results);
        fclose(f);
        index=word2index(s,propertySave);
        s.info{index}.persistent=1;
        getSpace('set',s);
        saveSpace(s,s.filename,1);
    end
end

function data=matchDbData(userid,variabel)
for i=1:length(userid)
    useridSort{i}=regexprep(userid{i},'_userid','');
end
data=nan(length(userid),length(variabel));
id=0;
done=0;step=500000;
while not(done)
    [d databaseName]=db2struct('mypersonality','demog',['`id`>=' num2str(id) ' order by `id` limit 0,' num2str(step)],{variable{:},'userid','id'});%['`id`<10']
    id=id+step;
    done=isempty(d.id);
    fprintf('.')
    d.fwords=d.userid;
    d=mkHash(d,1);
    for i=1:length(userid)
        j=word2index(d,useridSort{i});
        if not(isnan(j))
            for k=1:length(variabel)
                data(i,k)=eval(['d.' variabel{k} '(j);']);
            end
        end
    end
end

function d=matchFileData(file,datafile,variabel)
if nargin<1
    %file='summary_big5SMALL.csv';
    file='big5.csv';
end
if nargin<2
    %datafile='user_spaceSMALL.mat';
    datafile='user_space.mat';
end
load(datafile)
fprintf('\nMatchFileData %s %s\n',datafile,file);
%for i=1:length(d.fwords)
%    useridSort{i}=regexprep(d.fwords{i},'_userid','');
%end

f=fopen(file,'r');
labels=fgets(f);
labels=textscan(labels,'%q','delimiter',',');labels=labels{1};
if nargin<3
    if not(isfield(d,'variabel')) d.variabel=[];end
    d.variabel=[ d.variabel ; labels];
end

for i=1:length(labels)
    icolumns(i)=i;%find(strcmpi(labels{i},d.variabel));
    tmp=find(strcmpi(labels{i},d.variabel));
    ycolumns(i)=tmp(1);
end
j=find(strcmpi(labels,'userid'));
d=mkHash(d);
row=0;
if isfield(d,'y')
    N=size(d.y);
    if N(2)<length(d.variabel)
        d.y(1:length(d.fwords),N(2)+1:length(d.variabel))=NaN;%nan(length(d.fwords),length(d.variabel));
    end
else
    d.y=nan(length(d.fwords),length(d.variabel));
end
fprintf('Matching');

while not(feof(f))
    k=NaN;
    while isnan(k) & not(feof(f))
        t=fgets(f);
        row=row+1;
        data=textscan(t,'%q','delimiter',',');
        data=data{1};
        if even(row,10000)
            fprintf('.');
        end
        k=word2index(d,data{j});
    end
    if not(feof(f)) & strcmpi(data{j},d.fwords{k})
        for i=1:length(icolumns)
            tmp=str2num(data{icolumns(i)});
            if not(isempty(tmp))
                d.y(k,ycolumns(i))=tmp;
            end
        end
    end
end
fclose(f);
fprintf('\n')
for i=1:length(d.variabel)
    fprintf('%s\tNmatch=%d of Ntotal=%d\n',d.variabel{i},length(find(not(isnan(d.y(:,i)')))),length(d.y))
end
save([datafile],'d')
1;


function [N,con]=countWords(word,con)
if nargin<2 con=[];end
if isempty(con)
    con = database('mypersonality','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/DB_INSTANCE']);
end
databaseName='mypersonality';
file='user_status';
Nstart=fetch(con,['SELECT COUNT(*) FROM `' databaseName '`.`' file '` where `id`<100000 AND `status_update` REGEXP '' ' word ' '' ORDER BY `id` ASC']);
N=Nstart{1};
%SELECT * FROM `user_status` WHERE `id` < 100 AND `status_update` REGEXP ' she ' ORDER BY `id` ASC


function mkResults(words,property);
if nargin<2
    property='predvalence';
end
warning off
mkdir results
warning on
fid=fopen('results/results.txt','w');
for j=1:length(words)
    file=words{j};
    d=getData('demog','user_status',['`' words{j} '`=1']);
    data=eval(['d.' property]);
    print='';
    print=[print sprintf('%s\t%s\t%.3f\n',file,property,nanmean(data))];
    f=fields(d);
    print=[print sprintf('variable\tr\tp\tN\tN(nan)\tLower\tUpper\tmean\n')];
    for i=1:length(f);
        d2=eval(['d.' f{i}]);
        N=size(d2);
        if N(1)<N(2)
            d2=d2';
        end
        try
            if min(d2)==max(d2)
                d2(isnan(d2))=0;
            end
            [r p]=nancorr(data,d2);
            NnotNan=length(find(not(isnan(d2))));
            m=nanmedian(d2);
            if length(find(d2<m))==0
                index=d2<=m;
            else
                index=d2<m;
            end
            m0=nanmean(d2);
            m12=nanmean(data);
            resAll(j)=m12;
            resAllStd(j)=nanstd(data)/length(data)^.5;
            m1=nanmean(data(find(index)));
            m2=nanmean(data(find(not(index))));
            N1=length(find(index));
            N2=length(find(not(index)));
            std1=nanstd(data(find(index)))/N1^.5;
            std2=nanstd(data(find(not(index))))/N2^.5;
        catch
            r=NaN;p=NaN;NnotNan=NaN;
            m1=NaN;m2=NaN;m0=NaN;m12=NaN;
            std1=NaN;std2=NaN;
        end
        if p<.01;print=[print sprintf('*')];end
        res(1,j,i)=m1;
        res(2,j,i)=m2;
        resStd(1,j,i)=std1;
        resStd(2,j,i)=std2;
        print=[print sprintf('%s\t%.3f\t%.3f\t%d\t%d\t%.3f\t%.3f\t%.3f\n',f{i},r,p,length(data),NnotNan,m1,m2,m0)];
    end
    fprintf('%s',print);
    fprintf(fid,'%s',print);
    1;
end
fclose(fid);

%Plot all
i=2;
try;close(i);end
h=figure(i);
step=8;
for j=1:5
    index=min((j-1)*step+1:j*step,length(words));
    plot(resAll(index));
    hold on;
end
legend({'Subjective form',	'Objective form',	'Possessive determiner','Possessive pronouns','Reflexive'})
for j=1:5 %Plot standard deviations
    index=min((j-1)*step+1:j*step,length(words));
    for k=1:length(index)
        plot([k k],[resAll(index(k))-resAllStd(index(k)) resAll(index(k))+resAllStd(index(k)) ],'g','Linewidth',4)
    end
end
title(property)%Finalize..
set(gca,'Xtick',1:length(words(index)))
set(gca,'Xticklabel',words(index))
ylabel(property);
set(gcf,'Position', [218 135 1006 665]);
saveas(h,['results/PlotAll']);
saveas(h,['results/PlotAll.jpg']);


%Plot high/low median split
for i=1:length(f)
    try;close(i);end
    h=figure(i);
    for j=1:5
        step=8;
        index=(j-1)*step+1:j*step;
        index=min(index,length(words));
        subplot(5,1,j);
        plot(res(1,index,i),'b');
        hold on;
        plot(res(2,index,i),'r');
        legend({'low','high'})
        for k=1:length(index)
            plot([k k],[res(1,index(k),i)-resStd(1,index(k),i) res(1,index(k),i)+resStd(1,index(k),i) ],'Linewidth',4)
            plot([k k],[res(2,index(k),i)-resStd(2,index(k),i) res(2,index(k),i)+resStd(2,index(k),i) ],'Linewidth',4)
        end
        title(f{i})
        set(gca,'Xtick',1:length(words(index)))
        set(gca,'Xticklabel',words(index))
        ylabel(property);
    end
    set(gcf,'Position', [218 135 1006 665]);
    saveas(h,['results/Plot-' f{i}]);
    saveas(h,['results/Plot-' f{i} '.jpg']);
end



function trainLasso(Nmax,step);
step=500;
if nargin<1
    Nmax=10000;
end
spaceLangName='spaceuser_like_anonymous';
s=getSpace('',[],spaceLangName);
if length(s.filename)==0 | isempty(findstr(s.filename,spaceLangName))
    s=getSpace('noSave',[],spaceLangName);
end

f=[];
[likes,userid,f]=getLikes(f);
if exist('likesUser.mat')
    k=3;
    load('likesUser','d2')
    if Nmax>d2.i
        fprintf('\nStarting');
        for i=1:d2.i
            [likes,userid,f]=getLikes(f);
        end
    end
    d2.i=d2.i+1;
else
    d2.i=1;
    d2.x=sparse(1,1);
end

if 0
    Nmax=d2.i-1+step;
end

if Nmax>d2.i & not(feof(f))
    fprintf('\nGetting data');
    for i=d2.i:Nmax %d2.i-1+step
        if not(feof(f))
            [likes,userid,f]=getLikes(f);
            if not(feof(f))
                d2.userid{i}=userid;
                d2.status_update{i}=likes;
                l=textscan(likes,'%s');l=l{1};
                index=word2index(s,l);
                index=index(not(isnan(index)));
                d2.x(i,index)=1/length(index);
                if even(i,200) fprintf('.'); end
            end
            
            if even(i,1000) | i==Nmax | feof(i)
                where=mkWhere(d2.userid(d2.i:end)');
                useridSort=sort(d2.userid);
                where2=[' `userid`>=''' useridSort{1} ''' AND `userid`<=''' useridSort{end} ''' AND ('  where ')'];
                databaseName='mypersonality';
                tableName='big5';
                tic;
                [d databaseName]=db2struct(databaseName,tableName,where2);
                toc
                variables=fields(d);
                d2.variables=variables;
                for i=d2.i:length(d2.userid)
                    j=find(strcmpi(d2.userid{i},d.userid));
                    for k=1:length(variables);
                        d2.y(i,k)=NaN;
                        if not(isempty(j))
                            a=eval(['d.' variables{k} '(j)' ]);
                            if isnumeric(a)
                                d2.y(i,k)=a;
                            end
                        end
                    end
                    d2.N(i)= length(find(d2.x(i,:)>0));
                end
                toc
                d2.i=length(d2.userid);
                d2.feof=feof(f);
                save('likesUser','d2')
            end
        end
    end
    fprintf('\nDone.\n');
end

% d2.Nx=size(d2.x);
% d2.N=nan(1,d2.Nx(1));
% for i=1:d2.Nx(1)
%    d2.N(i)= length(find(d2.x(i,:)>0));
% end

fprintf('\nLasso\n');
f=fopen('Results-Lasso.txt','a');
res='';
for k=3:3%length(d2.variables);
    index=find(not(isnan(d2.y(:,k))) & d2.N'>=20);
    
    %NlikesStep=800*4*4*4;
    for NlikesStep=[100 500 2500 10000 40000 160000 640000]
        for j=1:1;
            index2=find(sum(d2.x)>0);
            
            %index2=find(sum(d2.x)>1);%REMOVE
            index2=index2(1+(j-1)*NlikesStep:min(j*NlikesStep,length(index2)));%REMOVE
            
            Ncv=min(10,length(index));
            x=d2.x(index,index2);
            x=full(x);
            N=d2.N(index);
            Ntemp=size(x);
            for i=1:Ntemp(1)
                x(i,:)=x(i,:)/max(x(i,:));
            end
            y=d2.y(index,k);
            par.model='lasso';
            %Lambda=[.08 .04 .02 .01 .005 .0025 .00125];
            Lambda=[.02 .01 .005 .0025];
            %Lambda=.005;
            par.maxNleaveoutTesting=1;
            for i=1:length(Lambda)
                par.Lambda=Lambda(i);
                Ngroup=2;
                group=fix(Ngroup*(1:length(y))/(length(y)+1));
                [tmp indexY]=sort(rand(1,length(y)));
                group=group(indexY);
                if not(isempty(x))
                    tic;
                    [model{k} pred0]=regression(x,y,par,'oneleaveout',group);
                    [tmp tmp r2 ]=nancorr(pred0,y,N);
                    
                    pred(j,:)=pred0;
                    tmp=full(nansum(nansum(x)));
                    r=sprintf('%s\t%.3f\t%.4f\t%d\t%.4f\t%d\t%.2f\t%.2f\t%s\n',d2.variables{k},model{k}.r,model{k}.p,length(index),par.Lambda,j*NlikesStep,tmp,toc,r2);
                    res=[res r];
                    fprintf('%s',r);
                    fprintf(f,'%s',r);
                end
            end
        end
    end
    1;
    %[B FitInfo] = lasso(x,y,'CV',Ncv);
end
fclose(f);
1;

function [databaseName,s]=train(databaseName,tableName,variable,Nmax,spaceLangName,inputType);
if nargin<1
    databaseName='mypersonality';
end
if nargin<2
    tableName='swl';
end
if nargin<3
    variable=[];
end
if nargin<4
    Nmax=16000;
end
if nargin<5
    spaceLangName='/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat';
end
if nargin<6
    inputType='';%database
end


spaceName=['space_' tableName inputType];
if exist([spaceName '.mat'])
    s=getSpace('noSave',[],spaceName);
else
    s=getSpace('noSave',[],spaceLangName);
    s.extraData.N=0;
end
d2=[];
d.userid{1}=1;
Nmax0=Nmax;
Nmax=max(Nmax,s.extraData.N+200000);
step=min(Nmax-s.extraData.N,11000);

if Nmax0==0 %Do not load more data...
elseif not(strcmpi(inputType,''))
    [likes,userid,f]=getLikes([]);
    for i=1:s.extraData.N
        [likes,userid,f]=getLikes(f);
    end
    for i=1:step
        [likes,userid,f]=getLikes(f);
        d2.userid{i}=userid;
        d2.status_update{i}=likes;
    end
    s.extraData.N=s.extraData.N+step;
    where=mkWhere(d2.userid');
    useridSort=sort(d2.userid);
    where2=[' `userid`>=''' useridSort{1} ''' AND `userid`<=''' useridSort{end} ''' AND ('  where ')'];
    [d databaseName]=db2struct(databaseName,tableName,where2);
else
    while s.extraData.N<Nmax & length(d.userid)>0
        [d databaseName]=db2struct(databaseName,tableName,[' `userid`>''' s.extraData.lastUserid ''' ORDER BY `userid` LIMIT 0,' num2str(step)]);
        s.extraData.lastUserid=d.userid{end};
        %[d databaseName]=db2struct(databaseName,tableName,[' 1 ORDER BY `userid` LIMIT ' num2str(s.extraData.N) ',' num2str(step)]);
        s.extraData.N=s.extraData.N+step;
        where=mkWhere(d.userid(1:end));
        useridSort=sort(d.userid);
        where2=[' `userid`>=''' useridSort{1} ''' AND `userid`<=''' useridSort{end} ''' AND ('  where ')'];
        d2=structAppend(d2,db2struct(databaseName,'user_status',where2,{'userid','status_update'}));
        fprintf('.');
    end
end

if not(isempty(d2))
    if isempty(variable)
        variable=fields(d);
        s.extraData.variable=fields(d);
    end
    
    m=0;
    data=[];userid=[];N=[];status_update=[];type=[];
    for i=1:length(d.userid)
        j=find(strcmpi(d.userid{i},d2.userid));
        if not(isempty(j))
            m=m+1;
            status_update{m}='';
            for k=1:length(j);
                status_update{m}=[status_update{m} ' xxxnewlinexxx ' d2.status_update{j(k)}];
            end
            N(m)=length(j);
            userid{m}=['_userid' d.userid{i} ];
            for k=1:length(variable)
                r=eval(['d.' variable{k} '(i);']);
                if isnumeric(r)
                    data(k,m)=nanmean(r);
                else
                    data(k,m)=NaN;
                end
                typeNum{k}{m}=['_' variable{k}];
            end
            type{m}='_text';
        end
    end
    
    %Store in s
    [s newword index]=setProperty(s,userid,type,status_update);
    for k=1:length(variable)
        s=setProperty(s,userid,typeNum{k},num2cell(data(k,:)));
    end
end

%Save
saveSpace(s,spaceName);
return


%Retrieve from s
[set s]=getWord(s,['_userid*']);
for k=1:length(s.extraData.variable)
    propertySave=['_' s.extraData.variable{k}];
    data2=getProperty(s,propertySave,set.index);
    nwords=getProperty(s,'_nwords',set.index);
    index=find(nwords>20);
    %Predict
    [s info]=train(s,data2(index),propertySave,set.index(index));
    [~,~,res]=nancorr2(info.pred',info.data',nwords(index));
    if isfield(info,'results')
        f=fopen([s.extraData.variable{k} inputType '.txt'],'a');
        fprintf(f,'%s\n',info.results);
        fprintf(f,'%s\n',res);
        fclose(f);
    end
end

%Save
saveSpace(s,spaceName);
1;



function s=addDbProperty(word,property,s)
if nargin<3
    s=[];
end
if isempty(s)
    s=getSpace('noSave',[],'/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat');
end
databaseName='mypersonality';
tableName='user_status';
d.id=1;
id=0;
while not(isempty(d.id))
    try
        WHERE=[' `' word '` = 1 AND `' property(2:end) '` IS NULL AND `id`>' num2str(id) ' ORDER  BY `id` limit 0,1000'];
        [d databaseName]=db2struct(databaseName,tableName,WHERE,{'id','status_update',property(2:end)});
    catch
        fprintf('ERROR\n');
        WHERE=[' `' word '` = 1 AND `id`>' num2str(id) ' ORDER BY `id` limit 0,1000'];
        [d databaseName]=db2struct(databaseName,tableName,WHERE,{'id','status_update'});
    end
    if not(isempty(d.id))
        id=max(d.id);
        for i=1:length(d.status_update)
            d.status_update{i}=regexprep(d.status_update{i},[' ' word ' '],'   ','ignorecase');
        end
        p=getProperty(s,property,d.status_update');
        eval(['d.' property(2:end) '=p;']);
        d=rmfield(d,'status_update');
        struct2Db(databaseName,tableName,d,'id');
        fprintf('.');
    end
end


function d=getData(dbFrom,dbTo,where,step)
if nargin<4
    step=20000;
end
%file=['demog' '_' dbTo where];%dbFrom
file=['data/' where(2:end-3)];%dbFrom
property='_predvalence';
con = database('mypersonality','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/DB_INSTANCE']);
columns=fetch(con,['SHOW COLUMNS FROM  `' dbFrom]);
dAdd='';
if exist([file '.mat'])
    load(file)
    if not(eval(['isfield(d,''' columns{end,1} ''')']))
        dAdd=d;
    elseif length(d.userid)==step | 1
        return
    end
end
if nargin<3
    where='1';
end
select_struct=[];
%maxId=fetch(con,['SELECT `id` FROM `' dbTo '` ORDER BY `' dbTo '`.`id` DESC limit 0,1']);
fprintf('Merge %s and %s: ',dbFrom,dbTo);
%dToId.userid=1;

k=0;
where2=[ where ' ORDER BY `userid` LIMIT ' num2str(k) ',' num2str(step) ];
dToId=db2struct(con,dbTo,where2,{'userid',property(2:end)});
m1=sort(unique(dToId.userid));

%if 1
smallStep=5000;
d=[];
N=min(length(m1),[1 smallStep]);
while N(1)<length(m1)
    fprintf('*')
    where2=mkWhere(m1(N(1):N(2)));
    where3=['''' m1{N(1)} '''<=`userid` AND ''' m1{N(2)} '''>=`userid` AND ('  where2 ')'];
    where4=[ where3 ' ORDER BY `userid` LIMIT ' num2str(k) ',' num2str(smallStep) ];
    d=structAppend(d,db2struct(con,dbFrom,where4,select_struct));
    N=min(length(m1),N+smallStep);
end
%else
%    where2=mkWhere(unique(dToId.userid));
%    where3=['''' m1{1} '''<=`userid` AND ''' m1{end} '''>=`userid` AND ('  where2 ')'];
%    where4=[ where3 ' ORDER BY `userid` LIMIT ' num2str(k) ',' num2str(step) ];
%    d=db2struct(con,dbFrom,where4,select_struct);
%end

if not(isempty(dAdd))
    %d=structMerge(d,dAdd);
    f=fields(dAdd);
    for i=1:length(f);
        eval(['dToId.' f{i} '=dAdd.' f{i} ';']);
    end
end

f=fields(d);
for k=1:length(f)
    if not(strcmpi(f{k},'userid'))
        if not(iscell(eval(['d.' f{k} '(1)'])))
            eval(['dToId.' f{k} ' = NaN(1,length(dToId.userid));']);
        else
            for i=1:length(dToId.userid)
                eval(['dToId.' f{k} '{i} ='''';']);
            end
        end
    end
end
ok=NaN(1,length(dToId.userid));
for i=1:length(d.userid)
    j=find(strcmpi(d.userid{i},dToId.userid));
    ok(j)=1;
    for k=1:length(f)
        eval(['dToId.' f{k} '(j) = d.' f{k} ' (i);']);
    end
end
if not(nanmean(ok)==1)
    stop
end
fprintf('.');
d=dToId;
save(file,'d');

function s1=structAppend(s1,s2)
if isempty(s1);
    s1=s2;return
end
f=fields(s1);
if length(eval(['s2.' f{1}]))==0
    return
end
for i=1:length(f)
    N=size(eval(['s1.' f{i}]));
    if N(1)>N(2) r=';'; else r=' ';end
    eval(['s1.' f{i} '=[s1.' f{i} r ' s2.' f{i} '];']);
end


function mergeDb(dbFrom,dbTo,where)
if nargin<3
    where='1';
end
select_struct=[];
step=1000;
con = database('mypersonality','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/DB_INSTANCE']);

%        columns=fetch(con,['SHOW columns from `' con.Instance '`.`' dbFrom '`']);

k=0;
maxId=fetch(con,['SELECT `id` FROM `' dbTo '` ORDER BY `' dbTo '`.`id` DESC limit 0,1']);
fprintf('Merge %s and %s: ',dbFrom,dbTo);
dToId.userid=1;
while k+step<maxId{1} & not(isempty(dToId.userid))
    
    where=[ where ' ORDER BY `userid` LIMIT ' num2str(k) ',' num2str(step) ];
    
    dToId=db2struct(con,dbTo,where,{'userid'});
    
    where2=mkWhere(dToId.userid);
    m1=sort(dToId.userid);
    where2=['''' m1{1} '''<=`userid` AND ''' m1{end} '''>=`userid` AND ('  where2 ')'];
    d=db2struct(con,dbFrom,where2,select_struct);
    struct2Db(con,dbTo,d,'userid');
    fprintf('.');
    k=k+step;
end


function where=mkWhere(userid)
N=size(userid);
where=' ';
where(N(1)*50)=' ';
j=1;
for i=1:N(1)
    a=['`userid`=''' userid{i,1} ''' OR '];
    where(j:j+length(a)-1)=a;
    j=j+length(a);
end
where=where(1:j-4);

function t=struct2file(d,file)
fi=fields(d);
t='';
for i=1:length(fi)
    t=[t sprintf('%s\t',fi{i})];
    try;
        type(i)=eval(['ischar(d.' fi{i} '{1})']);
    catch
        type(i)=0;
    end
end
t=[t sprintf('\n')];
k=length(t);
for j=1:length(eval(['d.' fi{i}]))
    t2='';
    for i=1:length(fi)
        if type(i)
            t2=[t2 sprintf('%s\t',eval(['d.' fi{i} '{j}']))];
        else
            t2=[t2 sprintf('%.3f\t',eval(['d.' fi{i} '(j)']))];
        end
    end
    t2=[t2 sprintf('\n')];
    if length(t)<k+length(t2)
        t(length(t)*2+10)=' ';
    end
    t(k+1:k+length(t2))=t2;
    k=k+length(t2);
end
t=t(1:k);
f=fopen(file,'w');
fprintf(f,'%s',t);
fclose(f);



function con=file2db(file,par)
if nargin<2
    par=[];
end
databaseName='mypersonality';
con = database(databaseName,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/DB_INSTANCE']);
d=NaN;
step=50000;
par.Nmax=[1 step];
if isfield(par,'restart') & par.restart
    exec(con,['DROP TABLE `' file '`;']);
else
    try
        Nstart=fetch(con,['SELECT COUNT(*) FROM `' databaseName '`.`' file '`']);
        par.Nmax=par.Nmax + Nstart{1};
    catch
        fprintf('Creating database %s\n',databaseName);
    end
end
feof=0;
while not(feof)
    fprintf('*');
    [~, ~, d,feof]=readtable2([file '.csv'],par);
    struct2Db(con,file,d);%,'userid'
    par.Nmax=par.Nmax+step;
end

function d=file2space(s,file)
d=[];
if nargin<1
    spacefile='/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat';
    if not(exist(spacefile))
        spacefile='spaceenglish.mat';
    end
    s=getSpace('noSave',[],spacefile);
end
if nargin<2
    file='summary_user_status.csv';
end
outfile='user_space';
fprintf('file2space %s\n',file)
f=fopen(file,'r');
labels=fgets(f);
if exist(outfile) & 0
    load(outfile)
    type='a';
    if not(isfield(d,'row'))
        d.row=length(d.fwords);
    end
    fprintf('Skipping %d rows\n',d.row);
    for i=1:d.row
        fgets(f);
    end
else
    type='w';
end
fout=fopen(['space_' file],type);
foutIndex=fopen(['index_' file],type);
fprintf(fout,'"userid","space"\n');
fprintf(foutIndex,'"userid","index"\n');
i=0;
d.row=0;
while not(feof(f)) % & i<5000
    t=fgetsCSV(f);
    d.row=d.row+1;
    a=textscan(t,'%q','delimiter',',');
    if length(a{1})<2
        fprintf('Error %d\n',i')
    else
        i=i+1;
        text=a{1}{2};
        [x1 N Ntot t index s]=text2space(s,text);
        fprintf(fout,'"%s","%s"\n',a{1}{1},num2str(x1));
        fprintf(foutIndex,'"%s","%s"\n',a{1}{1},num2str(index));
        d.x(i,:)=x1;
        d.fwords{i}=a{1}{1};
    end
    
    if even(i,1000) | feof(f)
        fprintf('.');
        d.x=d.x(1:i-1,:);
        d.fwords=d.fwords(1:i-1);
        save(outfile,'d');
        if not(feof(f))
            d.x(i:i+1000,:)=NaN;
            d.fwords{i+1000}='';
        end
    end
end
fclose(f);
1;

function summarizeUser(file,summarize);
if nargin<1
    file='user_status.csv';
end
if nargin<2
    summarize=1;
end
warning off

fprintf('Summarize: %s\n',file);

folder=['temp' regexprep(file,'.csv','')];
f=fopen(file,'r');
labels=fgets(f);
ok=0;
if ok
    mkdir(folder)
    delete([ folder '/*'])
    i=0;
    while not(feof(f)) % & i<5000
        i=i+1;
        t=fgetsCSV(f);
        index=findstr(t,',');
        a=textscan(t,'%q','delimiter',',');
        
        if strcmpi(a{1}{1},'29289b3f5a8cb2df6c265069c1112fb6')
            1;
        end
        %if length(index)>2
        t(index(find(not(t(index-1)=='"'))))=' ';
        t=regexprep(t,'/",','/" ');
        t=regexprep(t,'%',' ');
        %end
        file2=[folder '/' a{1}{1} '.csv'];
        addLabel= not(exist(file2));
        fout=fopen([folder '/' a{1}{1} '.csv'],'a');
        if addLabel
            fprintf(fout,labels);
        end
        fprintf(fout,t);
        fclose(fout);
        if rand<.0001
            fprintf('.')
        end
    end
end
fclose(f);

fout=fopen(['summary_' file],'w');
if summarize
    fprintf(fout,'"userid","status_update"\n');
else
    fprintf(fout,'%s',labels);
end
files=dir([folder '/*']);
for i=3:length(files)
    try
        data=readtable2([folder '/' files(i).name]);
        N=size(data);
        if summarize
            for k=1:N(1)
                t='';
                for j=1:N(1)
                    t=[t data{j,3}{1}];
                    if j<N(1)
                        if t(end)=='"'
                            t(end)=' ';
                        end
                        t=[t ' .. '];
                    end
                end
            end
            t=regexprep(t,char(13),' ');
            t=regexprep(t,char(10),' ');
            fprintf(fout,'"%s","%s"\n',data{1,1}{1},t);
        else
            for k=1:N(1)
                for j=1:N(2)
                    fprintf(fout,'"%s"',data{k,j}{1});
                    if j<N(2)
                        fprintf(fout,',');
                    end
                end
                fprintf(fout,'\n');
            end
        end
    catch
        m=lasterror
        m.message
        fprintf('%d %s\n',i,[folder '/' files(i).name]);
    end
end
fclose(fout);
%delete([ folder '/*'])
warning on

1;

function extractContexts(file,words);
f=fopen(file,'r');
t=fgets(f);
for i=1:length(words)
    fout(i)=fopen([words{i} '_' file],'w');
    fprintf(fout(i),'%s',t);
end
while not(feof(f))
    t=fgetsCSV(f);
    %    if not(t(end))==10 | not(t(1)=='"')
    %        1;
    %    end
    t2=t(40:end);%Remove years
    for i=1:length(words)
        if strcmpi('random',words{i})
            if rand<.002
                fprintf(fout(i),'%s',t);
            end
        elseif not(isempty(findstr(lower(t2),lower([' ' words{i} ' ']))))
            fprintf(fout(i),'%s',t);
        end
    end
end
fclose(f);
for i=1:length(words)
    fclose(fout(i));
end
1;

function t=fgetsCSV(f)
t=fgets(f);
while not(strcmpi(t(end-1:end),['"' char(10)])) & not(feof(f))
    t=[t fgets(f)];
    if not(strcmpi(t(end-1:end),['"' char(10)]))
        t=regexprep(t,char(10),' ');
    end
end

function test
f=fopen(file,'r');
fout=fopen(['ok' file],'w');
%for i=1:18
%    t=fgets(f);
%end

while not(feof(f)) %for i=1:18
    t=fgetsCSV(f);
    t=regexprep(t,',',' ');
    fprintf(fout,'%s',t);
end
data2=readtable(['ok' file]);

function [d,header,struct,feof1]=readtable2(file,par)
feof1=0;
if nargin<2
    par.Nmax=[];
end

f=fopen(file,'r');
header=fgets(f);

header=textscan(header,'%q','delimiter',',');
if length(header{1})==3
    fix=strcmpi(header{1}{3},'status_update');
else
    fix=0;
end

row=0;
if length(par.Nmax)>0
    skip=0;
    while not(feof(f)) & skip+1<par.Nmax(1)
        t=fgetsCSV(f);
        skip=skip+1;
    end
end

clear d;
while not(feof(f)) & (isempty(par.Nmax) | row<par.Nmax(2)-par.Nmax(1)+1)
    row=row+1;
    t=fgetsCSV(f);
    a=textscan(t,'%q','delimiter',',');
    if length(a{1})>3  & fix
        for i=4:length(a{1})
            a{1}{3}=[a{1}{3} ' ' a{1}{i}];
        end
        a{1}=a{1}(1:3);
    end
    for i=1:length(a{1})
        d{row,i}=a{1}(i);
        
    end
    N=size(d);
    if row>=N(1)
        d{round(row*1.5+1),1}=[];
    end
end
feof1=feof(f);
fclose(f);
if row==0
    return
end
d=d(1:row,:);

if nargout>=3
    N=size(d);
    for i=1:N(2)
        j=1;
        while isempty(d{j,i}{1}) & j<N(1);
            j=j+1;
        end
        string=isempty(str2num(d{j,i}{1})) & not(isempty(d{j,i}{1}));
        if strcmpi(header{1}{i},'date') string=1;end
        if header{1}{i}(1)=='_'; header{1}{i}=header{1}{i}(2:end);end
        for j=1:N(1)
            if string
                eval(['struct.' header{1}{i} '{j}=d{j,i}{1};']);
            elseif isempty(d{j,i}{1})
                eval(['struct.' header{1}{i} '(j)=NaN;'])
            else
                eval(['struct.' header{1}{i} '(j)=str2num(d{j,i}{1});'])
            end
        end
    end
end

function s=addfile2space(file,Nmax)
s=getSpace;
data=readtable2(file);
row=1;
N=size(data);
if nargin>=2
    N(1)=min(N(1),Nmax);
end
Nstep=100;
while row<N(1)
    i=0;
    for j=row:min(N(1),row+Nstep-1)
        i=i+1;
        id{i}=['_row' num2str(j) 'user' data{j,1}{1}];
        text{i}='_text';
        d{i}=data{j,3}{1};
    end
    [s newword index]=setProperty(s,id,text,d);
    row=row+Nstep;
end
saveSpace(s,regexprep(file,'.csv',''));


function [fileMerged,d]=merge(file1,file2,properties,s,Nmax,d)
if nargin<3
    properties=[];
end
addProperties= not(isempty(properties));
if not(isempty(properties)) & nargin<4
    s=getSpace;
end
if nargin<5
    Nmax=-1;
end

parrarell=0;
Npar=10000;

%Read file2 to data
file2string='';
debug=0;

for k=1:length(file2)
    fprintf('%s\n',file2{k})
    tic;
    file=[regexprep(file2{k},'.csv','') '.mat'];
    if exist(file) & 0
        load(file)
        d.data{k}=data1;d.header{k}=header1;
    elseif isfield(d,'data') & length(d.data)>=k
        %Already calculated...
    else
        [d.data{k} d.header{k}]=readtable2(file2{k});
        %save([regexprep(file2{k},'.csv','')],'data1','header1','-V7.3');
    end
    toc
    Ndata{k}=size(d.data{k});
    debug= Ndata{k}(1)<10;
    file2string=[file2string '_' file2{k}];
end
fprintf('done reading files.\n')
if debug Npar=5; end

f=fopen(file1,'r');
fileMerged=[regexprep(file1,'.csv','') file2string];
fileMerged=[regexprep(fileMerged,'.csv','') '_properties.csv'];

%Parrell computation...
if parrarell
    fileMergedOrg=fileMerged;
    fileMerged=[fileMergedOrg '1'];
    i=1;
    while exist(fileMerged) & not(feof(f))
        i=i+1;
        fileMerged=[fileMergedOrg num2str(i)];
        for j=1:Npar
            if not(feof(f)) fgets(f); end
        end
    end
    parrarellDone=feof(f);
end


%Make hash for file2
for k=1:length(file2)
    fileHash=[file2{k} '_Hash.mat'];
    if exist(fileHash)
        load(fileHash)
    else
        fprintf('Making hash..')
        h=java.util.Hashtable;
        tic;
        for i=1:Ndata{k}(1)
            h.put(d.data{k}{i,1}{1},i);
        end
        fprintf('done\n');toc
        save(fileHash,'h','-V7.3');
    end
    d.hash{k}=h;
end

%Adding labels from file1
fout=fopen(fileMerged,'w');
clear h;
he=fgets(f);
fprintf(fout,'%s,',he(1:end-1));

%Add labels from file2
for k=1:length(file2)
    for j=2:Ndata{k}(2)
        fprintf(fout,'"%s",',d.header{k}{1}{j});%data{k}.Properties.VariableNames{j});
    end
end

%Add labels from properties
if addProperties
    for j=1:length(properties)
        fprintf(fout,'"%s",',properties{j});
    end
    s.par.reverseOrder=1;
    liwcStart=find(strcmpi('_liwcfunctionwords',properties));
    for i=1:liwcStart-1
        s.par.getPropertyShow{i}='';
    end
    for i=liwcStart:length(properties)
        s.par.getPropertyShow{i}='liwc';
    end
end

fprintf(fout,'"empty"\n');

%Debugging
if debug;
    fprintf('DEBUG!!!!\n');
else
    fprintf('Starting...\n');
end

%Loop over all data
row=0;
tic;
while not(feof(f)) & not(parrarell & row>=Npar) & (Nmax<=0 | row<Nmax)
    row=row+1;
    
    %Write file1 data
    t=fgetsCSV(f);
    %a=textscan(t,'%q%q%q','delimiter',',');
    t=regexprep(t,'/"',' ');
    a=textscan(t,'%q','delimiter',',');
    if length(a{1})<=2
        fprintf('Problem on row %d\n',row)
    else
        a{1}{3}=regexprep(a{1}{3},',','. ');%Exchange , to . , makes it easer to read csv files!
        for j=1:length(a{1})
            fprintf(fout,'"%s",',a{1}{j});
        end
        
        %Write file2 data
        if not(isempty(file2))
            %i=find(strcmpi(a{1}{1},d));
            
            for k=1:length(file2)
                if debug
                    i=1;
                else
                    i=d.hash{k}.get(a{1}{1});
                end
                
                for j=2:Ndata{k}(2)
                    if isempty(i)
                        w=[];
                    else
                        w=d.data{k}{i,j}{1};
                    end
                    fprintf(fout,'"%s",',w);
                end
            end
        end
        
        %Write properties
        if addProperties
            if 1
                id=['_row' num2str(row) 'user' a{1}{1}];
                res=getProperty(s,id,properties);
            else
                res=getProperty(s,a{1}{3},properties);
            end
            for j=1:length(res)
                fprintf(fout,'"%.4f",',res(j));
            end
        end
        
        fprintf(fout,'" "\n');
    end
end
toc
fclose(f);
fclose(fout);

%Parrell computation...
if parrarell
    fileMerged=[fileMergedOrg '1'];
    i=1;
    fout=fopen(fileMergedOrg,'w');
    while exist(fileMerged)
        f=fopen(fileMerged,'r');
        if i>1; fgets(f);end %Skip labels
        while not(feof(f))
            a=fgets(f);
            fprintf(fout,'%s',a);
        end
        fclose(f);
        i=i+1;
        fileMerged=[fileMergedOrg num2str(i)];
    end
    fclose(fout);
    if not(parrarellDone)
        [fileMerged]=merge(file1,file2,properties);
    end
    fileMerged=fileMergedOrg;
end


function properties=getAllproperties
s=getSpace;
indexUse=[4 6 12 8 2 5];
properties=[];
propertiesString=[];
for i=1:length(indexUse)
    [ ~,categories,indexCat]=getIndexCategory(indexUse(i),s);
    if indexUse(i)==2
        [a b]=getProperty(s,1,indexCat);
        for j=1:length(b)
            a(j)=isempty(b{j});
        end
        indexCat=indexCat(find(a));
    elseif indexUse(i)==6 %Semantic dimensions
        indexCat=indexCat(1:20);
    end
    propertiesString=[propertiesString cell2string(s.fwords(indexCat))];
    properties=[properties s.fwords(indexCat)];
end


function [d,lUseridOut,f]=getLikes(f)
persistent textSum;
persistent lUserid;
if isempty(f)
    f=fopen('user_like_anonymous.csv','r');
    d=fgets(f);
    textSum='';
    lUserid='';
end
userid=lUserid;
while not(feof(f)) & (strcmpi(userid,lUserid))
    text=fgets(f);
    c.feof=feof(f);
    i=findstr(text,',');
    userid=text(1:i-1);
    if strcmpi(userid,lUserid)
        textSum=[textSum ' ' text(i+1:end-1)];
    else
        d=textSum;
        textSum=text(i+1:end-1);
    end
end
lUseridOut=lUserid;
lUserid=userid;
%textSum='';

function copy(file)
f=fopen(file,'r');
fout=fopen(['small/' file],'w');
for i=1:10
    t=fgets(f);
    fprintf(fout,t,'%s');
end
fclose(f);
fclose(fout);

function [out in par]=ngram(varargin)
dbstop if error 
%Program window baserat terminal: "thinlinc Client"
%F8 change between windows
%kurs15 qua7IeLahvez
%configCluster %Run once, per user
%projinfo %Type in 'terminal', to get 'username'

%ClusterInfo.setProjectName('snic2015-2-1')
%ClusterInfo.setWallTime('01:00:00')
%ClusterInfo.state
% p=parpool(10)%10=Number of workers...
%parfor
%parfeval Execute function on worker in parallel pool
%spmd Single Program Multiple Data 
%datastore huge data set!
%mapreduce web(fullfile(docrot,'matlab/mapreduce.html'))

%Google ngram:
%http://storage.googleapis.com/books/ngrams/books/datasetsv2.html
%Login to alarik:
%documentation: http://www.lunarc.lu.se/
%snicquota
%ssh sverker@alarik.lunarc.lu.se masoh9ieyiCh
%du -skh * %List size of directories

%cd /alarik/nobackup/q_z/sverker/
%File transfer to alarik
%scp stoplistswe sverker@alarik.lunarc.lu.se:/home/sverker
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/* sverker@alarik.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r /Volumes/LaCie/ngramdata/transfer sverker@alarik.lunarc.lu.se:/lunarc/nobackup/users/sverker/english/download
%scp -r /temp sverker@alarik.lunarc.lu.se:/lunarc/nobackup/users/sverker/swedishFile
%scp /Users/sverkersikstrom/Dropbox/semantic/semanticCode/ngram.m sverker@alarik.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r sverker@alarik.lunarc.lu.se:/lunarc/nobackup/users/sverker/danish/spaceDanishDone.mat /Users/Dropbox/ngram/
%scp -r /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/MyPersonality/swl.csv sverker@alarik.lunarc.lu.se:/alarik/nobackup/q_z/sverker/mypersonality/MyPersonality
%scp sverker@alarik.lunarc.lu.se:/home/sverker/semantic/semanticCode/ngram.m /Users/sverkersikstrom/Dropbox/semantic/semanticCode 
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/* sverker@alarik.lunarc.lu.se:/home/sverker/semantic/semanticCode

%scp /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/english/ngram/countEnglishTimeSUM.mat sverker@alarik.lunarc.lu.se:/lunarc/nobackup/users/sverker/english/download/

%https://docs.google.com/document/d/1KFWF7-mLMOzDtO-XkDrCjsXLhGBD-yiEZiAICdSqTnA/edit?authkey=CKa_hfYB#heading=h.eiu9sjdaomjb
%https://docs.google.com/document/d/1KFWF7-mLMOzDtO-XkDrCjsXLhGBD-yiEZiAICdSqTnA/edit?authkey=CKa_hfYB&pli=1
%module add matlab
%matlab
%ls /lunarc/nobackup/users/sverker/english/download
%sbatch job1.scr
%scancel 7101
%squeue
%NOT USED ON ALARIK qsub job1.scr


if length(varargin)>=1 & isnumeric(varargin{1})
    %Old syntax (ngram(0,par)), do not use
    d.user=varargin{1};
    d=varargin{2};
elseif length(varargin)>=1
    %New syntax, use: ngram(par)
    d=varargin{1};
end
if isfield(d,'language') & strcmpi(d.language,'swedish') %Make a space from Google n-grams:
    d.func='createSpace';
    d.ngramfile=1;
    d.language='Swedish';
    d.Ncol=50000;
    d.user=0;
end
d=getPar(d);
d=getParNgram(d);

if strcmpi(d.func,'mkFrequency')
    s=getFrequency(d);%From Ngram...
elseif strcmpi(d.func,'ocurrenceFromNgram')
    ocurrenceFromNgram;
elseif strcmpi(d.func,'createSpace1T') %mkSwedish
    %d.language='dutch';
    d.path='';
    [s new]=getFrequencyNgram1T(d);
    if new
        fprintf('Done making new vocabulary space\n')
        return
    end
    fprintf('Allocating %d space\n',d.memorySize)
    fprintf('Done allocation space\n')
    if d.split>0
        c.feof=0;
        i=0;
        while c.feof==0
            d.fileExt{d.split}=num2str(d.split);
            d.fileExtOne=d.fileExt{d.split};
            file{d.split}=[d.path 'count' d.language d.fileExtOne ''];
            c=ocurrenceFromNgram(d,s,1,['cooccurence' num2str(d.split)]);
            d.split=d.split+1;
        end
    else
        for k=1:length(d.fileExt)
            d.fileExtOne=d.fileExt{k};
            if strcmpi(d.language,'finnish')
                file{k}=[d.path  'fragFinnish' d.fileExtOne '.txt'];
            else
                file{k}=[d.path num2str(d.ngram) 'gm-00' d.fileExtOne ''];
            end
            c=ocurrenceFromNgram(d,s,1,file{k});
        end
    end
    ctot.count=spalloc(s.N,d.Ncol,d.memorySize);
    for k=1:length(d.fileExt)
      d.fileExtOne=d.fileExt{k};
        c=ocurrenceFromNgram(d,s,1,file{k});
        if not(isempty(c))
            if isfield(c,'count')
                ctot.count=ctot.count+c.count;
            else
                fprintf('Failed finding field c.count in %s\n',file{k})
            end
        end
        clear c;
    end
    s.filename=[s.filename 'Done'];
    s=createSpaceSCD(ctot,s,d);
    s
    fprintf('Saving %s ', s.filename)
    save(s.filename,'s','-V7.3');
    save('counts','ctot','-V7.3');
    s=getNewSpace(s.filename);
    [a b]=getProperty(s,'_associates','london');fprintf('%s\n',b{1})
elseif 1 | strcmpi(d.func,'createSpace')
    %Init
    fprintf('Createspace Nrow=%d, Ncol=%d\n',d.Nrow,d.Ncol);
    if not(isfield(d,'path')) d.path=''; end
    if not(isfield(d,'file')) d.file='nowac.txt';end
    file=regexprep(d.file,'.txt','');
    file=regexprep(file,'.csv','');
    spacefile=[d.path 'lang' file '.mat'];
    countfile=[d.path 'count' file '.mat'];
    
    %Make dictionary...
    if not(exist(spacefile)) | d.restart==1
        %Here there should be...
        if d.ngramfile
            s=getFrequency(d);
            m=0;
            fprintf('Checking if file exist\n')
            while not(exist([d.path d.lexicon '.mat'])) & m<60*24*7
                m=m+1;
                pause(60);
                fprintf('.')
            end
            fprintf('Done\n')
        else
            s=file2dictionary(d,d.file);
            if isempty(s); return; end
        end
    else
        fprintf('Load %s\n',spacefile)
        load(spacefile);
        s.filename=spacefile;
    end
    s.par=getPar;
    
    %Make co-occurence
    if d.ngramfile
        d.func='mkOcurrence';
        s=mkFunc(d,s);
        %Create space
        d.name=['count' d.corpus];
        d.func='mkSpace';
        s=mkFunc(d,s);
    else
        c=file2coOrruence(d,d.file,s);
        %Create space
        s=createSpaceSCD(c,s,d);
        fprintf('Saving %s ', s.filename)
        save(s.filename,'s','-V7.3');
    end
    out=s;
end
end

function s=file2dictionary(d,file);
if nargin<2
    file='nowact.txt';
end
D=dir([d.path file]);
%f=fopen(file,'r');%,'n', 'UTF-8'
f=fopen([d.path file],'r','n', 'UTF-8');
if f==-1
    fprintf('Missing file: %s\n',[d.path file]);
    s=[];
    return
end
s=initSpace;
s.N=0;
Nlarge=d.Nrow*6;%480000;
s.f=zeros(1,Nlarge);
s.row=0;
s.nchar=0;
s.nWords=0;
s.filename=[d.path 'lang ' regexprep(file,'.txt','')];
s.filename=regexprep(s.filename,'.csv','');
s.fwords=[];
s.data=0;
s=mkHash(s,1);

if exist([s.filename '.mat'])==2 & 0
    load(s.filename)
    for i=1:s.row
        data=textscan(f,'%s %d %d %d',1,'delimiter',char(9));        %text,year, count,books
        end1;
        fprintf('Done loading.')
    end
    %s.minf=min(s.f);
end
cont=1;
while cont
    cont=not(feof(f)) & (not(d.debug==1 & s.row>d.debugN));
    data=lower(fgets(f));
    if strcmpi(d.inputType,'likes') %Select identifier after the comma (,)...
        data=data(strfind(data,',')+1:end);
    end
    s.nchar=s.nchar+length(data);
    if cont
         [~,data]=text2index(s,data);
         %         for j=1:length(d.seperationCharacters)
         %             data=regexprep(data,['\' d.seperationCharacters(j)],' ');
         %         end
         %         if d.LSAaddColumnNames | d.LSAaddRowNames
         %             data=regexprep(data,'_',' ');
         %         end
         %
         %         data=textscan(data,'%s');data=data{1};
        s.row=s.row+1;

        s.nWords=s.nWords+length(data);
        for i=1:length(data)
            j=s.hash.get(lower(data{i}));
            if isempty(j)
                if s.N<Nlarge
                    s.N=s.N+1;
                    s.hash.put(lower(data{i}),s.N);
                    insert=s.N;
                else
                    [tmp insert]=min(s.f);
                end
                s.f(insert)=1;
                s.fwords{insert}=data{i};
                try;
                    s.upper(insert)=upper(s.fwords{insert}(1))==s.fwords{insert}(1);
                end
                %s.minf=min(s.f);
            else
                s.f(j)=s.f(j)+1;
            end
        end
    end
    if even(s.row,50000)
        t=toc;
        fprintf('Making dictionary %.4f s=%.1f h=%.1f\n',s.nchar/D.bytes,t,D.bytes/s.nchar*t/3600)
        1;
        %fprintf('%.4f\n',s.nchar/D.bytes)
    end
    if even(s.row,200000) | not(cont)
        fprintf('.')
        save(s.filename,'s');
    end
end
s=cleanDictionary(s,d);
%beep2(1);
end


function c=file2coOrruence(d,file,s); 
fprintf('Make CoOcurences from File\n')
if nargin<3
    s=getSpace;
end

%c.count=sparse(s.N,d.Ncol);
c.count=spalloc(s.N,d.Ncol,d.memorySize);

c.d=d;
c.nchar=0;
c.i=0;
D=dir([d.path file]);
try
    c.filebytes=D.bytes;
catch
    c.filebytes=3.8062e+09;
end
c.file=[d.path 'count' regexprep(file,'.txt','')];
c.file=regexprep(c.file,'.csv','');
fprintf('Starting count on %s. ', datestr(now))

if isfield(d,'multi')
    c.multi=d.multi;
else
    c.multi=0;
end
c.fwords=s.fwords;
if c.multi==0
    f=fopen([d.path file],'r','n','UTF-8');
    if exist([c.file '.mat']) & not(d.restart)
        load(c.file)
        if not(c.feof)
            for i=1:c.i
                text=fgets(f,10000);
            end
        else
            fprintf('Count file exist, skipping counting: %s\n',c.file) 
            return
        end
    end
    if strcmpi(d.inputType,'likes')
        textSum='';
        lUserid='';
        while not(feof(f)) & (not(d.debug==1 & c.i>d.debugN))
            text=fgets(f,10000);
            c.feof=feof(f);
            i=findstr(text,',');
            userid=text(1:i-1);
            if strcmpi(userid,lUserid)
                textSum=[textSum ' ' text(i+1:end-1)];
            else
                c=text2coOcurrence(c,s,textSum,d);
                textSum=text(i+1:end);
                lUserid=userid;
            end
        end
    else
        while not(feof(f)) & (d.debug==0 | c.i<d.debugN)
            text=fgets(f,10000);
            c.feof=feof(f);
            if s.par.LSAtabSeperator | s.par.LSAaddColumnNames | s.par.LSAaddRowNames
                if s.par.LSAaddRowNames | s.par.LSAaddColumnNames
                    text=[regexprep(text,'_','') ' '];
                end
                text=textscan(text,'%s','delimiter',char(9));text=text{1};
                if s.par.LSAaddRowNames & length(text)>0
                    row=[text{1} ' '];
                else
                    row='';
                end
                for i=1:length(text)
                    if s.par.LSAaddColumnNames
                        if c.i==0
                            text=regexprep(text,'_',' ');
                            columns=text;
                        end
                        c=text2coOcurrence(c,s,[row columns{i} ' ' text{i}],d);
                    else
                        c=text2coOcurrence(c,s, [row text{i}],d);
                    end
                end
            else
                c=text2coOcurrence(c,s,text,d);
            end
        end
    end
else
    cfile=c.file;
    for i=1:c.multi
        c.count=zeros(s.N,d.Ncol);
        c.d=d;
        c.nchar=0;
        c.i=0;
        c.file=[cfile num2str(i) '.mat'];
        f=fopen([d.path file],'r','n','UTF-8');
        ok=not(exist(c.file));
        blockfile=['block' num2str(i)];
        if exist(blockfile)
            ok=0;
        end
        
        if ok
            fblock=fopen(blockfile,'w');fprintf(fblock,'h');fclose(fblock);
            fprintf('Making count file %s\n',c.file)
            c.feof=feof(f);
            while not(c.feof)
                text=fgets(f,10000);
                c.feof=feof(f);
                if even(c.i+i,c.multi) | c.multi==0
                    c=text2coOcurrence(c,s,text);
                else
                    c.i=c.i+1;
                end
            end
            c.count=sparse(c.count);
            save(c.file,'c','-V7.3');
            delete(blockfile);
        else
            fprintf('Skipping count file %s\n',c.file)
        end
        fclose(f);
    end
    for i=1:c.multi
        c.file=[d.path cfile num2str(i) '.mat'];
        done=1;
        if exist(c.file)
            fprintf('Adding count file %s ',c.file)
            load(c.file);
            fprintf('sum= %d, feof=%d\n',sum(sum(full(c.count(1:1000,:)))),c.feof)
            if not(c.feof) done=0;end
            if exist('ctot')
                ctot.count=ctot.count+c.count;
                ctot.nchar=ctot.nchar+c.nchar;
                ctot.nchari(i)=c.nchar;
                ctot.feofi(i)=c.feof;
            else
                ctot=c;
            end
        else
            done=0;
        end
    end
    c=ctot;
    c.file=[d.path cfile];
    if not(done)
        return
    end
end

t=toc;
if s.par.LSAsaveExtraFiles
    fprintf('Saving %d %s. ', datestr(now))
    save(c.file,'c','-V7.3');
end
fprintf('Done\n')
end



function lda(d)
Path=regexprep(d.path,[lower(d.language) '/'],'');
addpath([Path 'topictoolbox']);
addpath('/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/topictoolbox');
exampleAT1;
end

function getAllFiles
d=getPar;
for i=1:length(d.gram1)
    filename=[d.path d.corpus1 '1gram' d.corpus3 d.gram1{i}  '.txt'];
    www=['http://storage.googleapis.com/books/ngrams/books/' d.corpus1 '1gram' d.corpus3 d.gram1{i} '.gz'];
    getFile(www,filename,1);
end
end

function alarik
% #!/bin/sh
% #PBS -l nodes=1
% #PBS -l walltime=167:00:00
%module add matlab
%matlab
end

function twitter
% Example:
% google_search = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=matlab';
% matlab_results = parse_json(urlread(google_search));
% disp(matlab_results{1}.responseData.results{1}.titleNoFormatting)
% disp(matlab_results{1}.responseData.results{1}.visibleUrl)

%https://dev.twitter.com/docs/api/1.1/get/statuses/sample
twitter_search = 'https://stream.twitter.com/1.1/statuses/sample.json';
matlab_results = parse_json(urlread(twitter_search));
% disp(matlab_results{1}.responseData.results{1}.titleNoFormatting)
% disp(matlab_results{1}.responseData.results{1}.visibleUrl)
end

function copyWordClass
load('space_anders_small.mat');
sFrom=s;
file='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/swedish/spaceSwedish.mat';
load(file)
s.classlabel=sFrom.classlabel;
s.classlabel{end+1}='Unknown';
s.wordclass=ones(1,s.N)*length(s.classlabel);
for i=1:s.N
    index=sFrom.hash.get(lower(s.fwords{i}));
    if not(isempty(index))
        s.wordclass(i)=sFrom.wordclass(index);
    end
end
cell2string(sFrom.fwords(sFrom.wordclass==6))
cell2string(s.fwords(s.wordclass==6))
save(file,'s','-V7.3')
end

function getWordClass
fprintf('Getwordclasses\n')
global rootPath
rootPath=pwd;
load('englishFiles/space_eng_anders_20110119.mat');
filename='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/Corpus/Reuters/korpus/reuters_not9707.txt';
f=fopen(filename,'r','n', 'UTF-8');
outFile='wordclassEnglish.mat';
if exist(outFile)
    load(outFile)
    for i=1:wc.i
        fgets(f);
    end
else
    wc.i=0;
    wc.fwords=s.fwords;
    wc.wordclass=zeros(s.N,17);
    wc.error=0;
end
while not(feof(f))
    wc.i=wc.i+1;
    if even(wc.i,100)
        [tmp s.wordclass]=max(wc.wordclass');
        s.wordclass(find(tmp==0))=0;
        wc.wc=s.wordclass;
        for i=1:length(s.classlabel)
            fprintf('%s %d %s\n',s.classlabel{i},length(find(s.wordclass==i)),cell2string(s.fwords(find(s.wordclass==i))))
        end
        wc.N=sum(sum(wc.wordclass));
        fprintf('\n%s %d found=%.3f\n',datestr(now),wc.N,length(find(sum(wc.wordclass')>0))/s.N);
        save(outFile,'wc','-V7.3')
    end
    texts='';
    for i=1:20
        if not(feof(f))
            t=fgets(f);
        end
        if length(t)>30
            texts=[texts t];
        end
    end
    if length(texts)>30
        if 0
            texts=regexprep(texts,char(160),' ');
            remove=',''!?;&?()"*/\-<>';
            texts=regexprep(texts,'\.',' . ');
            for i=1:length(remove)
                texts=regexprep(texts,remove(i),[' ' remove(i) ' ']);
            end
        end
        %t=strread(texts,'%s');
        t=textscan(texts,'%s');t=t{1};
        
        try
            localStat=getWordclass2(s,t);
            index=word2index(s,lower(t));
            indexNotNan=find(not(isnan(index)));
            s.classlabel=localStat.classlabel;
            wc.classlabel=localStat.classlabel;
            for j=1:length(indexNotNan)
                wc.wordclass(index(indexNotNan(j)),localStat.wordClass(indexNotNan(j)))=wc.wordclass(index(indexNotNan(j)),localStat.wordClass(indexNotNan(j)))+1;
            end
        catch
            wc.error=wc.error+1;
        end
    end
end


s.classlabel=localStat.classlabel;
end



function getFile(www,filename,ver);
if nargin<3
    ver=0;
end
fprintf('File %s\n',filename);
try
    if not(exist(filename))
        fprintf('Downloading %s\n',datestr(now));
        urlwrite(www,[filename '.gz']);
    end
    if not(exist([filename])) & exist([filename '.gz'])==2 & ver==0
        fprintf('Gunzip %s (waiting 10 seconds)\n',datestr(now));
        pause(10);
        gunzip([filename '.gz']);
        %movefile([filename '.gz'],filename)
        delete([filename '.gz']);
    end
catch
    ok=0;wait=10;
    while not(ok)
        wait=min(7200,wait*(rand/10+1.3));
        fprintf('Retrying after %.1fs following error in: File %s\n',wait,filename);
        pause(wait);
        try
            fprintf('Downloading\n');
            urlwrite(www,[filename '.gz']);
            pause(wait);
            fprintf('Gunzip\n');
            gunzip([filename '.gz']);
            delete([filename '.gz']);
            ok=1;
        end
    end
end

end

function [s new]=getFrequencyNgram1T(d)
path='';
if nargin<1
    d=getPar;
    d.language='Swedish';
    path='/swedishUnzip/';
end

% gunzip([d.path 'SWEDISH/5gms/5gm-0000.bz2'],[d.path 'SWEDISH/5gms/5gm-0000']);

f=fopen([d.path path 'vocab'],'r','n', 'UTF-8');
s.N=0;
Nlarge=480000;
s.f=zeros(1,Nlarge);
s.row=0;
s.filename=[d.path path 'space' d.language ];
if exist([s.filename '.mat'])==2
    load(s.filename)
    fprintf('Done loading.')
    new=0;
    return
    for i=1:s.row
        data=textscan(f,'%s %d %d %d',1,'delimiter',char(9));        %text,year, count,books
    end
end
new=1;
s.minf=min(s.f);
while not(feof(f))
    data=textscan(f,'%s %d %d %d',1,'delimiter',char(9));        %text,year, count,books
    if not(feof(f))
        s.row=s.row+1;
        text=data{1}{1};
        freq=data{2};
        if d.delimiter==32
            [text freq]=strread(text,'%s %d');text=text{1};
        end
        if freq>s.minf
            if s.N<Nlarge
                s.N=s.N+1;
                insert=s.N;
            else
                [tmp insert]=min(s.f);
            end
            s.f(insert)=freq;
            s.fwords{insert}=text;
            try;
                s.upper(insert)=upper(s.fwords{insert}(1))==s.fwords{insert}(1);
            end
            s.minf=min(s.f);
        end
    end
    if even(s.row,100000) | feof(f)
        fprintf('.')
        save(s.filename,'s');
    end
end
s=cleanDictionary(s,d);
beep2(1);
end



function s=getFrequency(d);
%Make frequency file from Google-Ngram
if nargin<1; d=getPar;end
N=d.Nrow;
Nlarge=N*4;
s.filename=[d.path 'space' d.language ];
if exist([s.filename '.mat'] )
    fprintf('Loading frequency file: %s\n',s.filename)
    load(s.filename )
    return
end

for i=1:length(d.gram1)
    text='';
    data{3}=0;
    data{4}=0;
    data{5}=0;
    error=0;
    busyFile=[s.filename 'Busy' num2str(i) '.mat'];
    workingFile=[s.filename 'Working' num2str(i) '.mat'];
    doIt=exist(busyFile)==0 & exist([s.filename 'Done' num2str(i) '.mat'])==0;
    if doIt
        save(busyFile,'i','-V7.3')
        if exist(workingFile)
            load(workingFile)
            startRow=s.meta.row;
        else
            startRow=0;
            s.N=0;
            s.minf=0;
            s.meta.d=d;
            s.meta.row=0;
            s.meta.i=1;
            s.meta.error=0;
            s.f=zeros(1,Nlarge);
            s.fTime=zeros(Nlarge,d.tMax);
            s.upper=zeros(1,Nlarge);
        end
        fprintf('Making frequency file: %d, %s\n',i,datestr(now))
        s.meta.i=i;
        filename=[d.path d.corpus1 '1gram' d.corpus3 d.gram1{i}  '.txt'];
        %http://storage.googleapis.com/books/ngrams/books/googlebooks-eng-all-1gram-20120701-a.gz
        www=['http://storage.googleapis.com/books/ngrams/books/' d.corpus1 '1gram' d.corpus3 d.gram1{i} '.gz'];
        getFile(www,filename);
        f=fopen(filename,'r','n', 'UTF-8');
        if startRow>0
            fprintf('Starting at row %d feof %d\n',s.meta.row,feof(f))
            for j=1:startRow
                textscan(f,'%s %d %d %d %d',1,'delimiter',char(9));        %text,year, count,books
            end
            starRow=0;
        end
        
        while not(feof(f))
            try
                j=0;
                ok=1;
                sumData=zeros(1,3);
                fTime=zeros(1,d.tMax);
                while ok
                    s.meta.row=s.meta.row+1;
                    j=j+1;
                    if isempty(data{2})
                        fprintf('Empty data on row %d\n',s.meta.row)
                    else
                        tIndex=data{2}-d.tStart;
                        if tIndex>0 & tIndex<d.tMax
                            fTime(tIndex)=data{3};
                        end
                        sumData(1)=sumData(1)+data{3};
                        sumData(2)=sumData(2)+data{4};
                        %sumData(3)=sumData(3)+data{5};
                    end
                    
                    data=textscan(f,'%s %d %d %d',1,'delimiter',char(9));        %text,year, count,books
                    try
                        ok=(strcmpi(text,data{1}{1}) && not(feof(f)));
                    catch
                        ok=0;
                    end
                end
                if not(isempty(data{1}))
                    if (s.N<N | sumData(1)>s.minf) & length(text)>0
                        if s.N<Nlarge
                            s.N=s.N+1;
                            insert=s.N;
                        else
                            [tmp insert]=min(s.f);
                        end
                        s.f(insert)=sumData(1);
                        s.fTime(insert,:)=fTime;
                        s.fwords{insert}=text;
                        try;
                            s.upper(insert)=upper(s.fwords{insert}(1))==s.fwords{insert}(1);
                        end
                        s.minf=min(s.f);
                    end
                    text=data{1}{1};
                end
                if even(s.meta.row,100000) | feof(f);
                    s.timeSaved{i}=datestr(now);
                    fprintf('Saveing: i=%d,N=%d,row=%d %s\n',i,s.N,s.meta.row,datestr(now));
                    save([s.filename 'WorkingTemp' num2str(i)],'s','-V7.3')
                    movefile([s.filename 'WorkingTemp' num2str(i) '.mat'],workingFile)
                end
            catch
                err=lasterror;
                try
                    fprintf('Error in row %d in file feof %d %s line=%d\n',s.meta.row,feof(f),err.message,err.stack.line)
                    error=error+1;
                    if error>20
                        return;
                    end
                    s.meta.error=error;
                catch
                    fprintf('Error in prinout\n')
                end
                %return
            end
        end
        fprintf('Completed file\n')
        s.meta.row=0;
        fclose(f);
        movefile(workingFile,[s.filename 'Done' num2str(i) '.mat'])
        delete(busyFile);
        delete(filename);
    end
end

fprintf('Summarizing now!\n')
s.meta.fCompleted=zeros(1,length(d.gram1));
for i=1:length(d.gram1)
    filename=[s.filename 'Done' num2str(i) '.mat'];
    if exist(filename)==2
        load(filename);
        if exist('stot')==0
            stot=s;
        else
            [fsort insert]=sort(stot.f,'ascend');
            k=1;
            %[minf insert]=min(stot.f);
            index=find(s.f>fsort(k));
            minf=max(s.f);
            fprintf('Summarizing %s, N=%d\n',filename,length(index))
            for j=1:length(index);
                if fsort(k)<s.f(index(j))
                    stot.f(insert(k))=s.f(index(j));
                    stot.fTime(insert(k),:)=s.fTime(index(j));
                    stot.fwords{insert(k)}=s.fwords{index(j)};
                    k=k+1;
                    minf=min([minf s.f(index(j))]);
                    if minf<fsort(k) & k>200
                        [fsort insert]=sort(stot.f,'ascend');
                        k=1;
                        minf=max(s.f);
                    end
                    %[minf insert(k)]=min(stot.f);
                end
            end
        end
        stot.meta.fCompleted(i)=1;
        stot.meta.fSum(i)=sum(s.f);
    end
end
s=stot;
if not(mean(s.meta.fCompleted)==1)
    s.filename=[s.filename 'Incomplete'];
end
save([s.filename 'Org'],'s','-V7.3')



s=cleanDictionary(s,d);

end


function d=getParNgram(d2);
%global user
d.language='English';
d.user=0;
if nargin>0
    d=mergeStruct(d,d2);
end

if d.user==1
    %d.path=['/alarik/nobackup/q_z/sverker/' lower(d.language) '/download/'];
    d.path=['/lunarc/nobackup/users/sverker/' lower(d.language) '/download/'];
elseif d.user==2
    d.path='/Volumes/LaCie/ngramdata/';
else
    d.path=[pwd '/'];%['/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/' lower(d.language) '/'];
end



d.name=['count' d.language ];
d.lexicon=['space' d.language];
d.ngram=5;
if strcmpi(d.language,'French')
    %    http://storage.googleapis.com/books/ngrams/books/googlebooks-fre-all-1gram-20120701-a.gz
    d.corpus='googlebooks-fre-all-5gram-20120701-';
    d.corpus1='googlebooks-fre-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cq cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fw fx fy g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lq lr ls lt lu lv lw lx ly m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py q_ qa qb qc qd qe qg qi ql qn qo qp qs qu qv qw qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rq rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vr vs vt vu vv vw vx vy w_ wa wb wc wd we wf wh wi wj wl wm wn wo wp wr ws wt wu wv ww wx wy x_ xa xc xd xe xf xg xh xi xj xk xl xm xn xo xp xq xr xs xt xu xv xw xx xy xz y_ ya yb yd ye yg yh yi yl ym yn yo yp yq yr ys yt yu yv yx yz z_ za zb zd ze zg zh zi zk zl zm zn zo zp zr zs zu zv zw zx zy zz';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'German')
    %http://storage.googleapis.com/books/ngrams/books/googlebooks-ger-all-1gram-20120701-a.gz
    %    http://storage.googleapis.com/books/ngrams/books/googlebooks-fre-all-1gram-20120701-a.gz
    d.corpus='googlebooks-ger-all-5gram-20120701-';
    d.corpus1='googlebooks-ger-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fr fs ft fu fv fw fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kq kr ks kt ku kv kw kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv pw px py pz q_ qa qf qi qk qm qn qo qr qu qw qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uz v_ va vb vc vd ve vf vg vh vi vk vl vm vn vo vp vr vs vt vu vv vw vx vy vz w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wp wr ws wt wu wv ww wx wy wz x_ xa xc xe xh xi xj xl xm xn xp xs xt xu xv xw xx xy xz y_ ya yb yc yd ye yi ym yn yo yp ys yt yu yv yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zr zs zt zu zv zw zx zy zz';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Swedish')
    %d.path=[d.path d.language '/'];
    d.pathResults=d.path;
    %d.corpus='swedishUnzip/vocab';
    d.corpus='5gm-00';%08
    d.corpus1='';
    d.corpus3='';
    d.fileExt='00 01 02 03 04 05 06 07 09 10';
    d.gram1='vocab';
elseif strcmpi(d.language,'SwedishFile')
    %d.path=[d.path d.language '/'];
    d.pathResults=d.path;
    d.corpus='';%08
    d.corpus1='';
    d.corpus3='';
    d.fileExt='';
    d.gram1='';
    if d.user==1
        d.path=['/lunarc/nobackup/users/sverker/swedishFile/'];
    end
elseif strcmpi(d.language,'English')
    d.language='English';
    d.corpus='googlebooks-eng-all-5gram-20120701-';
    d.corpus1='googlebooks-eng-all-';
    d.corpus3='-20120701-';
    d.name='countEnglish';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cq cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fq fr fs ft fu fv fw fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gq gr gs gt gu gv gw gx gy gz h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jq jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kq kr ks kt ku kv kw kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lq lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nq nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py pz q_ qa qb qc qd qe qf qg qh qi qj ql qm qn qo qp qq qr qs qt qu qv qw qx qy qz r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rq rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vq vr vs vt vu vv vw vx vy vz w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wp wq wr ws wt wu wv ww wx wy wz x_ xa xb xc xd xe xf xg xh xi xj xk xl xm xn xo xp xq xr xs xt xu xv xw xx xy xz y_ ya yb yc yd ye yf yg yh yi yj yk yl ym yn yo yp yq yr ys yt yu yv yw yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zq zr zs zt zu zv zw zx zy zz';
    d.lexicon='spaceEnglish';
    d.synonymFile2=[d.path 'qualitysandberg.txt'];
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Spanish')
    d.corpus='googlebooks-spa-all-5gram-20120701-';
    d.corpus1='googlebooks-spa-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bl bm bn bo bp br bs bt bu bv bw by c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fv g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hw hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy k_ ka kb kc kd ke kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mw mx my n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nq nr ns nt nu nv nw ny o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv pw px py pz q_ qa qd qe qh qm qn qo qq qr qu r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uy uz v_ va vc vd ve vf vg vh vi vl vm vn vo vp vr vs vt vu vv vw vy w_ wa wb wc wd we wf wg wh wi wj wl wm wn wo wp wr ws wt wu wv ww wy x_ xa xc xd xe xh xi xk xl xm xn xo xp xr xt xu xv xx xy y_ ya yb yc yd ye yg yh yi yl ym yn yo yp yr ys yt yu yv yx yz z_ za zb zc zd ze zh zi zl zn zo zs zu zv zw zy';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Italian')
    d.corpus='googlebooks-ita-all-5gram-20120701-';
    d.corpus1='googlebooks-ita-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy e_ ea eb ec ed ee ef eg eh ei ej el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fv fw fx g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gq gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hw hx hy i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jq jr js jt ju jv jw jx k_ ka kb kc kd ke kf kg kh ki kj kl km kn ko kp kr kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj ll lm ln lo lp lr ls lt lu lv lx ly m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my n_ na nb nc nd ne nf ng nh ni nj nl nm nn no np nq nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py pz q_ qa qd qi ql qn qo qs qt qu qv qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uk ul um un uo up uq ur us ut uu uv uw ux uz v_ va vb vc vd ve vg vh vi vj vk vl vm vn vo vp vq vr vs vt vu vv vx vy w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wr ws wt wu wv ww wx wy x_ xa xc xe xh xi xl xm xn xo xr xt xu xv xx y_ ya yd ye yh yi ym yn yo yp yr ys yt yu yv yx z_ za zd ze zh zi zl zn zo zr zs zu zw zx zy';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Russian')
    d.corpus='googlebooks-rus-all-5gram-20120701-';
    d.corpus1='googlebooks-rus-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp br bs bt bu bv bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fr fs ft fu fv fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gy gz h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv px py pz q_ qu r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up ur us ut uu uv ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vr vs vt vu vv vx vy vz w_ wa we wh wi wo wr ws wu ww x_ xa xc xd xe xg xh xi xl xm xn xo xp xr xs xu xv xx xy y_ ya yc yd ye yg yh yi yj yk yl ym yn yo yp yr ys yt yu yv yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zr zs zt zu zv zw zx zy zz';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Hebrew')
    d.corpus='googlebooks-heb-all-5gram-20120701-';
    d.corpus1='googlebooks-heb-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ ab ad af al am an ar as at b_ ba bb bd be bg bh bk bl bm bn bo bp bq br bs bt bu bv bw by bz ca co d_ da db dd de dg dh di dk dl dm dn do dp dq dr ds dt du dv dw dy dz e_ ed em et fi fo fr g_ ga gb gd gg gh gi gk gl gm gn gp gq gr gs gt gv gw gy gz h_ ha hb hd he hg hh hi hk hl hm hn hp hq hr hs ht hv hw hy hz i_ if ii in is it iv j_ je jo k_ ka kb kc kd kg kh kk kl km kn kp kq kr ks kt kv kw ky kz l_ la lb lc ld le lg lh li lk ll lm ln lp lq lr ls lt lv lw ly lz m_ ma mb mc md mg mh mk ml mm mn mo mp mq mr ms mt mw my mz n_ na nb nd ne ng nh nk nl nm nn no np nq nr ns nt nu nv nw ny nz of on or ot other ou ov p_ pa pb pc pd pg ph pk pl pm pn po pp pq pr ps pt pu punctuation pv pw py pz q_ qb qd qg qh qk ql qm qn qp qq qr qs qt qw qy qz r_ ra rb rd rg rh rk rl rm rn rp rq rr rs rt rv rw ry rz s_ sa sb sc sd se sg sh si sk sl sm sn so sp sq sr ss st su sv sw sy sz t_ ta tb td tg th ti tk tl tm tn to tp tq tr ts tt tv tw ty tz un up us v_ va ve vi vn w_ wa wb wc wd we wg wh wi wk wl wm wn wo wp wq wr ws wt ww wy wz x_ xi y_ ya yb yd ye yg yh yk yl ym yn yp yq yr ys yt yw yy yz z_ za zb zc zd zg zh zk zl zm zn zp zq zr zs zt zv zw zy zz';
    d.gram1='a b c d e f g h i j k l m n o p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'Chinese')
    d.corpus='googlebooks-chi-sim-all-5gram-20120701-';
    d.corpus1='googlebooks-chi-sim-all-';
    d.corpus3='-20120701-';
    d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay b_ ba bb bc bd be bf bi bj bl bm bn bo bp br bs bt bu bx by c_ ca cb cc cd ce cf ch ci cj ck cl cm cn co cp cr cs ct cu cx cy d_ da db dc dd de df dg dh di dj dl dm dn do dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej el em en eo ep eq er es et eu ev ew ex ey f_ fa fc fd fe ff fi fj fl fn fo fp fr fs ft fu fy g_ ga gb gc gd ge gg gh gi gl gm gn go gp gr gs gu gy h_ ha hb hc he hf hg hh hi hj hk hl hn ho hp hr hs ht hu hw hy i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv ix iz j_ ja jb jc je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju k_ ka kb ke kg kh ki kl km kn ko kr ku kw ky l_ la lc ld le lf lg lh li lj ll lm ln lo lp lr ls lt lu ly m_ ma mb mc md me mg mi mj ml mm mn mo mp mr ms mt mu mw mx my n_ na nb nc nd ne nf ng ni nj nl nm nn no nr ns nt nu nv nw ny o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy p_ pa pb pc pd pe pf ph pi pj pl pm pn po pp pr ps pt pu punctuation pv py q_ qa qc qi ql qn qo qq qu r_ ra rb rc rd re rf rg rh ri rj rl rm rn ro rp rr rs rt ru ry s_ sa sb sc sd se sf sh si sj sk sl sm sn so sp sq sr ss st su sv sw sy sz t_ ta tb tc te tf tg th ti tj tl tm tn to tp tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf uh ui uk ul um un uo up ur us ut uu uv uy v_ va vc vd ve vf vi vl vn vo vs vu vv w_ wa we wh wi wl wm wn wo wr ws wt wu ww x_ xe xi xm xn xp xu xv xx y_ ya yb ye yi yl yn yo yu z_ za ze zh zi zl zn zo zr zu zw';
    d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
elseif strcmpi(d.language,'dutch')
    d.fileExt='00 01 02 03';
    d.gram1='';
    d.ngram=4;
elseif strcmpi(d.language,'czech')
    d.fileExt='00 01 02 03 04 05 06 07 08 09 10';
    d.gram1='';
    d.ngram=5;
elseif strcmpi(d.language,'polish')
    d.fileExt='00 01 02 03 04 05 06 07 08 09 10 11';
    d.gram1='';
    d.ngram=5;
elseif strcmpi(d.language,'portuguese')
    d.fileExt='00 01 02 03 04 05 06 07 08 09 10 11 12 13';
    d.gram1='';
    d.ngram=5;
elseif strcmpi(d.language,'finnish')
    d.fileExt='01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48';
    d.gram1='';
    d.ngram=5;
elseif strcmpi(d.language,'romanian')
    d.fileExt='00 01 02 03 04 05';
    d.gram1='';
    d.ngram=4;
elseif strcmpi(d.language,'norweigan') | strcmpi(d.language,'danish')
    d.split=1;
    d.fileExt='';
    d.gram1='';
elseif strcmpi(d.language,'persian')
    d.fileExt='';
    d.gram1='';  
    d.corpus='';
    d.file='persian';
    d.ngramfile=1;
else
    stopHere
end

d.fileExtOne='';
d.fileExt=strread(d.fileExt,'%s');

d.pathResults=d.path;
d.synonymFile=[d.path 'synonyms' d.language '.txt'];

d.gram1=strread(d.gram1,'%s');

d.date=datestr(now);
d.saveByYear=0;
d.k2=length(d.fileExt);
d.Ncol=10000;
d.Nrow=120000;
d.tMax=250;
d.tStart=1800;
d.mkspace=0;
d.id=rand;
d.NSVD=2000;
d.restart=0;
d.debug=0;
d.func='';
d.weightContext=0;
d.contextSize=15;
d.pause=0;
d.mkSpaceSUM=0;
d.contextWords=[];
d.ocurrenceFromNgram=1;
d.kIndex=1:length(d.fileExt);
d.ngramfile=0;
d.debugN=1000;
%d.memorySize=10000000000;
d.memorySize=100000000;
d.delimiter=0;

if not(isfield(d,'inputType')) d.inputType='';end

if nargin>0
    d=mergeStruct(d,d2);
end
if d.debug
    d.NSVD=100;
end

if d.user==1
    fprintf('ALARIK!!! ')
end
fprintf('Runing %s on computer=%d\n',d.func,d.user)
if d.weightContext
    d.weightName='Weight';
else
    d.weightName='';
end
if d.pause>0
    t=d.pause*rand;
    fprintf('Pause %.1f\n',t);
    pause(t);
end
end

function test
a='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/web3/matlab_code_latest/branches/Anders/v.0.5.1.0/ngram/googlebooks-eng-all-0gram-20120701-z'
f=fopen(a,'r','n', 'UTF-8');
for i=1:10
    fgets(f)
end

end

function d=mergeStruct(d,d2)
if isstruct(d2)
    f=fields(d2);
    for i=1:length(f)
        eval(['d.' f{i} '=d2.' f{i} ';']);
    end
end
end

function s=mkFunc(d,s);

spaceName=[d.path d.lexicon];
ok=1;

if strcmpi(d.func,'mkSpaceAll') | strcmpi(d.func,'mkSpace')| strcmpi(d.func,'mkSpaceSUM')
    %load(spaceName);
    spaceName=[spaceName d.weightName];
    if strcmpi(d.func,'mkSpaceSUM')
        file=[d.pathResults d.name 'SUM.mat'];
        load(file);
    else
        %ctot.count= sparse(s.N,d.Ncol);
        %ctot.count=spalloc(s.N,d.Ncol,d.memorySize);
        for k=d.kIndex
            file=[d.pathResults d.name d.fileExt{k} d.weightName '.mat'];
            if exist(file)==2
                fprintf('Making space file, %s, %s \n',datestr(now),file);
                load(file);
                if strcmpi(d.func,'mkSpace') | (d.restart==0 &  (isfield(s,'qSVDHistory') && length(s.qSVDHistory)>=k && not(isempty(s.qSVDHistory{k}))))
                    ctot.loaded(k)=1;
                    if k==d.kIndex(1)
                        ctot.count=c.count;
                    else
                        ctot.count=ctot.count+c.count;
                    end
                    try;ctot.snew{k}=c.snew;end
                    ctot.d{k}=c.d;
                else
                    [s sSUM qSVD qSUM qSVDVer2 qSUMVer2]=createSpaceSCD(c,s,d);
                    s.qSVDHistoryOne{k}=qSVD;
                    s.qVer2HistoryOne{k}=qSVDVer2;
                    sSUM.qSUMHistoryOne{k}=qSUM;
                    sSUM.qVer2HistoryOne{k}=qSUMVer2;
                    
                    hist.qSVDHistoryOne{k}=qSVD;
                    hist.qSVDVer2HistoryOne{k}=qSVDVer2;
                    hist.qSUMHistoryOne{k}=qSUM;
                    hist.qSUMVer2HistoryOne{k}=qSUMVer2;
                    
                    if k==d.kIndex(1)
                        ctot.count=c.count;
                    else
                        ctot.count=ctot.count+c.count;
                    end
                    %ctot.count=ctot.count+c.count;
                    clear c;
                    [s sSUM qSVD qSUM qSVDVer2 qSUMVer2]=createSpaceSCD(ctot,s,d);
                    
                    s.qSVDHistory{k}=qSVD;
                    s.qVer2History{k}=qSVDVer2;
                    sSUM.qSUMHistory{k}=qSUM;
                    sSUM.qVer2History{k}=qSUMVer2;
                    
                    hist.qSVDHistory{k}=qSVD;
                    hist.qSVDVer2History{k}=qSVDVer2;
                    hist.qSUMHistory{k}=qSUM;
                    hist.qSUMVer2History{k}=qSUMVer2;
                    
                    save([d.path d.lexicon 'Temp.mat'],'s','-V7.3');
                    movefile([d.path d.lexicon 'Temp.mat'],[spaceName 'One.mat']);
                    
                    save([d.path d.lexicon 'SUMTemp.mat'],'sSUM','-V7.3');
                    movefile([d.path d.lexicon 'SUMTemp.mat'],[spaceName 'OneSUM.mat']);
                    
                    save([d.path d.lexicon 'History.mat'],'hist','-V7.3');
                    
                end
                clear c;
                if d.user==0
                    fprintf('Not saveing SUM file\n')
                else
                    save([d.pathResults d.name d.weightName 'SUM.mat'],'ctot','-V7.3');
                end
            end
        end
    end
    if  strcmpi(d.func,'mkSpace') | strcmpi(d.func,'mkSpaceSUM')
        [s sSUM q]=createSpaceSCD(ctot,s,d);
        fprintf('Saving %s\n',spaceName)
        save([spaceName 'Done'],'s','-V7.3');
        if not(isempty(sSUM))
            save([spaceName 'SUM'],'sSUM','-V7.3');
        end
    end
elseif strcmpi(d.func,'mkOcurrence') | strcmpi(d.func,'mkOcurrenceTime')
    %load(spaceName);
    spaceName=[spaceName d.weightName];
    if  strcmpi(d.func,'mkOcurrenceTime')
        d.saveByYear=1;
    else
        d.saveByYear=0;
    end
    for k=d.kIndex
        fprintf('Making ocurrence files... %s\n',datestr(now));
        d.fileExtOne=d.fileExt{k};
        c=[];
        if d.ngramfile
            seperationCharacters=s.par.seperationCharacters;
            s.par.seperationCharacters='';
            file=[d.corpus d.fileExtOne];
            countFile=['count' file '.mat'];
            %a=dir(countFile);
            %redo=length(a)>0 & abs(datenum(a.date)-now)>.25;
            if not(exist(countFile)) | d.restart 
                c=file2coOrruence(d,file,s);
            end
            s.par.seperationCharacters=seperationCharacters;
        else
            d=ngramSumYear(d,s,k);
        end
    end
    
    s.filename=['space' d.language 'Done'];
else
    ok=0;
end
end




function s=cleanDictionary(s,d)
for i=1:length(s.fwords)
    s.fwords{i}=regexprep(s.fwords{i},'??','?');
    s.fwords{i}=regexprep(s.fwords{i},'??','?');
    s.fwords{i}=regexprep(s.fwords{i},'??','?');
    s.fwords{i}=regexprep(s.fwords{i},'??','?');
end

[tmp index]=sort(s.f,'descend');
s.N=length(s.f(find(s.f>0)));
s.f=s.f(index(1:s.N));
s.upper=s.upper(index(1:s.N));
s.fwords=s.fwords(index(1:s.N));
try
    s.fTime=s.fTime(index(1:s.N),:);
end


fprintf('Getting wordclasses\n')
s.wordOrg=s.fwords;
s.classlabel{1}='unknown';
s.wordclass=nan(1,length(s.wordOrg));
for i=1:length(s.wordOrg)
    sep=findstr(s.wordOrg{i},'_');
    if isempty(sep)
        s.wordclass(i)=1;
    else
        s.fwords{i}=s.wordOrg{i}(1:sep(end)-1);
        L=length(s.wordOrg{i});
        if sep(end)<L
            wordClass=s.wordOrg{i}(sep(end)+1:length(s.wordOrg{i}));
            class=find(strcmpi(s.classlabel,wordClass));
            if isempty(class)
                if i<5000
                    s.classlabel{length(s.classlabel)+1}=wordClass;
                    class=length(s.classlabel);
                else
                    class=L;
                end
            end
            s.wordclass(i)=class;
        else
            s.wordclass(i)=1;
        end
    end
end
fprintf('Removing duplicates\n')
keep=ones(1,s.N);
len=nan(1,s.N);

if 0
    fprintf('Creating hash table...');
    hash1=java.util.Hashtable;
    hash2=java.util.Hashtable;
    for i=1:length(s.fwords)
        s.fwords{i}=lower(s.fwords{i});
        if length(s.fwords{i})==0
            keep(i)=0; 
        elseif not(s.par.allowNumbers) & (not(isempty(strfind([33:'A'-1 'Z'+1:'a'-1 '{':'~'],s.fwords{i}(1)))))
            keep(i)=0;
        end
        s.fwords{i}=lower(s.fwords{i});
        if length(s.fwords{i})>0
            hash1.put(s.fwords{i},i);
        end
        k=length(s.fwords)-i+1;
        if length(s.fwords{k})>0
            hash2.put(s.fwords{k},k);
        end
    end
end

fprintf('Creating hash table...');
hash=java.util.Hashtable;
for i=1:length(s.fwords)
    s.fwords{i}=lower(s.fwords{i});
    %for j=1:length(d.seperationCharacters)
    %    s.fwords{i}=regexprep(s.fwords{i},['\' d.seperationCharacters(j)],'');
    %end
    %s.fwords{i}=regexprep(s.fwords{i},'\.','');
    if length(s.fwords{i})==0
        keep(i)=0;
    elseif not(d.allowNumbers) & not(strcmpi(d.inputType,'likes')) & not(isempty(strfind([33:'A'-1 'Z'+1:'a'-1 '{':'~'],s.fwords{i}(1))))
        keep(i)=0;
    end
    if length(s.fwords{i})>0
        k=hash.get(lower(s.fwords{i}));
        if isempty(k)
            indexRep{i}=i;
        else
            indexRep{i}=[indexRep{k} i];
        end
        hash.put(lower(s.fwords{i}),i);
    end
end


for i=1:length(s.fwords)
    if keep(i)>0
        index=indexRep{hash.get(lower(s.fwords{i}))};
        indexW=zeros(1,s.N);
        indexW(index)=1;
        index2=find(indexW & s.wordclass>1);
        if not(isempty(index2))
            keep(index)=0;
            keep(index2(1))=1;
        else
            if length(index)>1
                keep(index(2:end))=0;
            end
        end
    end
end


s.f=s.f(find(keep));
s.fwords=s.fwords(find(keep));
s.wordOrg=s.wordOrg(find(keep));
s.wordclass=s.wordclass(find(keep));
try
    s.fTime=s.fTime(find(keep),:);
end
s.upper=s.upper(find(keep));
s.N=length(s.f);
s=mkHash(s,1);
%try
%    save([s.filename 'Large'],'s','-V7.3')
%end

N=d.Nrow;
s.N=min(N,length(s.f(find(s.f>0))));
s.f=s.f(1:s.N);
s.fwords=s.fwords(1:s.N);
s.upper=s.upper(1:s.N);
s.wordclass=s.wordclass(1:s.N);
s.wordOrg=s.wordOrg(1:s.N);
try;
    s.fTime=s.fTime(1:s.N,:);
end
s=mkHash(s,1);
save(s.filename,'s','-V7.3')

%delete([s.filename 'Working.mat'])
fprintf('\nDone: %s\n',s.filename)
end



function c=ocurrenceFromNgram(d,s,k,filename);
fprintf('Use function ocurrenceFromNgram2 instead!!!\n')
if d.weightContext
    weight(4)=1;
    weight(3)=1/2;
    weight(2)=1/3;
    weight(1)=1/4;
else
    weight(1:4)=1;
end

doneFile=[d.pathResults d.name d.fileExtOne d.weightName '.mat'];
resultFile=[d.pathResults d.name d.fileExtOne 'Working'];
c.feof=0;
if (exist(doneFile)==2 | exist([resultFile '.mat'])==2) & d.debug==0 & d.restart==0
    fprintf('Loading %s\n', doneFile)
    try
        load(doneFile);
    catch
        fprintf('Failed loading %s\n', doneFile)
    end
    if not(isfield(c,'feof')) c.feof=0; end
    return
end

snew.row=0;
snew.Nwords=0;
snew.feof=0;
%c.count=sparse(s.N,d.Ncol);
c.count=spalloc(s.N,d.Ncol,d.memorySize);

fprintf('Saving resultfile: %s\n',resultFile);
save([resultFile '.mat'],'c','-V7.3');

%Create Ocurrency files from Google Ngram
fprintf('k=%d p(0>)=%.3f\n',k,full(mean(mean(c.count>0))))
snew.k=k;

if d.debug
    snew.maxRow=10;
else
    snew.maxRow=1000000;
end

snew.split=d.split;
fprintf('Making ocurrencefile from: %s\n',filename);
if d.split>0
    file=fopen(['ngram.txt' ],'r','n', 'UTF-8' );
    for i=1:d.split-1
        for j=1:snew.maxRow
            if not(feof(file))
                tmp=fgets(file);
            end
        end
    end
else    
    file=fopen([filename ],'r','n', 'UTF-8' );
end

rowsaved=snew.row;
tic;
sec=toc;
while not(feof(file)) & (d.split==0 | snew.row<snew.maxRow)
    a=lower(fgets(file));
    snew.row=snew.row+1;
    words=textscan(a,'%s');words=words{1};
    ok=0;
    if length(words)>=d.ngram+1
        N=str2num(words{d.ngram+1});
    else
        N=0;
        fprintf('Possible error in input, row=%d\n',snew.row);
    end
    if N>0
        ok=1;
        index=zeros(1,d.ngram);
        for i=1:d.ngram
            j=s.hash.get(lower(words{i}));
            if not(isempty(j))
                index(i)=j;
            end
        end
        for i=1:d.ngram
            if index(i)>0
                j=find(not(i==(1:d.ngram)) & index>0 & index<d.Ncol);
                if not(isempty(j))
                    c.count(index(i),index(j))=c.count(index(i),index(j))+N*weight(abs(i-j));
                    snew.Nwords=snew.Nwords+N;
                end
            end
        end
    end
    if feof(file) | even(snew.row,100000)
        snew.feof=feof(file);
        fprintf('saving at row=%d,s=%.1f, %s ...',snew.row,toc-sec,datestr(now));
        tic;
        sec=toc;
        if feof(file)
            snew.k=snew.k+1;
            snew.row=0;
        end
        c.snew=snew;
        c.d=d;
        save([resultFile 'Tmp.mat'],'c','-V7.3');
        pause(1);
        movefile([resultFile 'Tmp.mat'],[resultFile '.mat']);
        fprintf('done. ');
        print_mem;
    end
end
c.feof=feof(file);
fclose(file);
movefile([resultFile '.mat'],doneFile);
end

function out=keyWordsNgram(word1,word2)
%input
if nargin<1
    word1='harmony';
    word2='happiness';
end
%define
load('countEnglish');
load('englishFiles/space_eng_anders_20110119.mat');
out=keyWordsWC(s,s.fwords,count,word1,word2);
end

function out=keyWordsWC(s,fwords,count,i1,i2,word1,word2,print)
if ischar(i1)
    i1=word2index(s,i1);
    i2=word2index(s,i2);
end
if nargin<6 | isempty(word1)
    word1=s.fwords{i1};
    word2=s.fwords{i2};
end
if nargin<8
    print=1;
end

out=keyWords(s,fwords,count,i1,i2,word1,word2,print);
for i=1:length(s.classlabel)
    index=find(s.wordclass==i & (1:length(s.wordclass))<=10000);%THIS CONSTANT MAY CHANGE!
    out.wc{i}=keyWords(s,fwords(index),count(:,index),i1,i2,[word1 ' (' s.classlabel{i} ')'],[word2 ' (' s.classlabel{i} ')'],print);
end
end

function out=keyWords(s,fwords,count,i1,i2,word1,word2,print)
%calculation
if ischar(i1)
    i1=word2index(s,i1);
    i2=word2index(s,i2);
end
if nargin<6 | isempty(word1)
    word1=s.fwords{i1};
    word2=s.fwords{i2};
end
if nargin<8
    print=1;
end

N=sum(sum(count));
N1=sum(sum(count(i1,:)));
N2=sum(sum(count(i2,:)));
p=count/N;
Nwords=size(p);

clear count;
crit=norminv(.05/length(p(1,:)));
pAll=sum(p);
vAll=pAll.*(1-pAll)/N;

pAll1=sum(p(i1,:)');
pAll2=sum(p(i2,:)');

p1=p(i1,:)/pAll1;
p2=p(i2,:)/pAll2;
v1=p1.*(1-p1)/N1;
v2=p2.*(1-p2)/N2;
z=(p1-p2)./(v1+v2).^.5;
z(isnan(z))=0;

zR1=(p1-pAll)./(v1+vAll).^.5;
zR1(isnan(zR1))=0;
[tmp1 indexSortR1]=sort(zR1,'descend');
indexR1=find(zR1(indexSortR1)>-crit);
out.keyWord1=cell2string(fwords(indexSortR1(indexR1)));
out.z1=zR1(indexSortR1(indexR1));
out.p1=normcdf(out.z1);
out.result1=sprintf('%s (N=%d, N(p<.05)=%d): %s\n',word1,full(N1),length(indexR1),out.keyWord1);

zR2=(p2-pAll)./(v2+vAll).^.5;
zR2(isnan(zR2))=0;

[tmp1 indexSortR2]=sort(zR2,'descend');
indexR2=find(zR2(indexSortR2)>-crit);
out.keyWord2=cell2string(fwords(indexSortR2(indexR2)));
out.z2=zR2(indexSortR2(indexR2));
out.p2=normcdf(out.z2);
out.result2=sprintf('%s (N=%d, N(p<.05)=%d): %s\n',word2,full(N2),length(indexR2),out.keyWord2);


[tmp1 indexSort1]=sort(z,'descend');
index1=find(z(indexSort1)>-crit);
out.keyWord12=cell2string(fwords(indexSort1(index1)));
out.result12=sprintf('%s - %s (N(p<.05)=%d): %s\n',word1,word2,length(index1),out.keyWord12);

[tmp2 indexSort2]=sort(z,'ascend');
index2=find(z(indexSort2)<crit);
out.keyWord21=cell2string(fwords(indexSort2(index2)));
out.result21=sprintf('%s - %s (N(p<.05)=%d): %s\n',word2,word1,length(index2),out.keyWord21);

out.N1=full(N1);
out.N2=full(N2);
out.word1=word1;
out.word2=word2;

if print>0
    %if print==1;i1=1;i2=4;else i1=3;i2=4;end
    if length(out.keyWord1)>0;fprintf('%s',out.result1);end
    if length(out.keyWord2)>0;fprintf('%s',out.result2);end
    if not(print==1)
        if length(out.keyWord12)>0;fprintf('%s',out.result12);end
        if length(out.keyWord21)>0;fprintf('%s',out.result21);end
    end
    %for i=i1:i2
    %    fprintf('%s',result{i})
    %end
    fprintf('\n')
end
end

function keyWord=keyWords2(zR1,crit,s,word1,N1)
end


function db2file(d)
%mkdir temp
%cd temp
%ls
%d.path='';
c=database('TheWebbotArchives','root','root','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' '3306' '/TheWebbotArchives']);
q=['SELECT MAX(autoId)  FROM  `archive_latin1` '];
maxId = fetch(c,q);maxId=maxId{1};
idStep=1000;
j=0;k=1;id=0;
f=fopen([d.path 'Webbot' num2str(k) '.txt'],'w');
while id<maxId
    q=['SELECT `header`,`preamble`,`body`,`published`  FROM  `archive_latin1` WHERE  `published`>0 AND  `autoId` >' num2str(id) ' AND `autoId` <=' num2str(id + idStep) ];
    id=id+idStep;
    text = fetch(c,q);
    N=size(text);
    j=j+1;
    fprintf('.')
    if j>100
        j=0;
        k=k+1;
        fclose(f);
        fprintf('%d\n',k)
        f=fopen([d.path 'Webbot' num2str(k) '.txt'],'w');
    end
    for i=1:N(1) %Loop articles
        article=([text{i,1} ' ' text{i,2} ' ' text{i,3} ]);
        fprintf(f,'%s %s\n',text{i,4},article);
    end
end
end


function c=text2coOcurrence(c,s,text,d)
persistent lastNow
try
    if nargin<4
        d.inputType='';
        d.ngramfile=0;
    end
    if isempty(lastNow)
        lastNow=now;
    end
    quick=1;
    
    if quick & not(isfield(c,'tmpCount'))
        c.Nsave=0;
        c.tmpCount=spalloc(size(c.count,1),size(c.count,2),d.memorySize);
    end
    
    c.i=c.i+1;
    c.nchar=c.nchar+length(text);
    [index words]=text2index(s,lower(text));
    if d.ngramfile
        index=index(1:d.ngram);
        add=str2double(words(end));
    elseif strcmpi(d.inputType,'likes') | c.d.normalizeContextSize>0
        NnotNan=length(index(find(not(isnan(index)) & index<=s.N)))-1;
        if c.d.normalizeContextSize==1
            add=1/NnotNan;
        else
            add=1/NnotNan^2;
        end
    else
        add=1;
    end
    
    nr=1:length(index);
    for j=1:length(index); %Loop words
        if not(isnan(index(j))) & index(j)<=s.N
            %Context
            index2=find(not(nr==j) & not(isnan(index)) & index<c.d.Ncol & ((j>=nr-c.d.contextSize & j<=nr+c.d.contextSize) | c.d.contextSize<=0));
            if isempty(index2)
            elseif quick
                c.tmpCount(index(j),index(index2))=c.tmpCount(index(j),index(index2))+add;
            else
                c.count(index(j),index(index2))=c.count(index(j),index(index2))+add;
            end
        end
    end
    if even(c.i-1,10000) | c.feof | abs(lastNow-now)*24*60>1
        fprintf('.')
        t=toc;
        c.count=sparse(c.count);
        c.Nsave=c.Nsave+1;
        if quick
            c.count=c.count+c.tmpCount;
            c.tmpCount=spalloc(size(c.count,1),size(c.count,2),d.memorySize);
        end
        if s.par.LSAsaveExtraFiles & (c.feof | even(c.Nsave-1,5))
            fprintf('Saving cooccurence file %s %s %.4f s=%.1f h=%.1f\n',c.file,datestr(now),c.nchar/c.filebytes,t,c.filebytes/c.nchar*t/3600)
            save(c.file,'c','-V7.3');
        end
        lastNow=now;
    end
catch
    fprintf('Error in processing: %s\n',text)
end
end

function ocurrenceFromFile(d);
%Use  mkCoOrruenceFromFile instead
fprintf('DO NOT USE THIS! Ocurences from File\n')
load([d.path 'spaceSwedishFile']);
tic;
for k=1:22
    %c.count=sparse(s.N,d.Ncol);
    c.count=spalloc(s.N,d.Ncol,d.memorySize);
    
    c.d=d;
    resultFile=[d.path 'count' num2str(k)];
    if exist([resultFile '.mat'])==0 | d.debug
        fprintf('Starting count on %d %s.\n',k, datestr(now))
        save(resultFile,'c','-V7.3');
        f=fopen([d.path 'Webbot' num2str(k) '.txt'],'r','n', 'UTF-8');
        i=0;
        while not(feof(f))
            article=fgets(f,10000);
            i=i+1;
            c.i=i;
            if even(i,1000)
                t=toc;
                fprintf('.');
                save(resultFile,'c','-V7.3');
            end
            article=regexprep(article,'\.',' ');
            article=regexprep(article,'\?',' ');
            %w=strread(article,'%s');
            w=textscan(article,'%s');w=w{1};
            
            index=word2index(s,lower(w));
            nr=1:length(index);
            for j=1:length(w); %Loop words
                if not(isnan(index(j))) & index(j)<=s.N
                    %Context
                    index2=find(not(nr==j) & not(isnan(index)) & index<d.Ncol & j>=nr-d.contextSize & j<=nr+d.contextSize);
                    c.count(index(j),index(index2))=c.count(index(j),index(index2))+1;
                end
            end
        end
        t=toc;
        fprintf('Saving %d %s. ',k, datestr(now))
        save(resultFile,'c','-V7.3');
        fprintf('Done\n')
    end
end
end


function ocurrenceFromDb(d)
fprintf('Ocurences from dB\n')
load('space_anders_small');

if exist('snewDb.mat')==2
    load('snewDb');
    load('countOk.mat')
    id=snew.id;
else
    snew.contextSize=4;
    snew.Ncol=10000;
    %count=sparse(s.N,snew.Ncol);
    count=spalloc(s.N,snew.Ncol,d.memorySize);
    
    id=0;
end
fprintf('id=%d\n',id)
idStep=1000;

c=database('TheWebbotArchives','root','root','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' '3306' '/TheWebbotArchives']);
q=['SELECT MAX(autoId)  FROM  `archive_latin1` '];
maxId = fetch(c,q);maxId=maxId{1};

k=0;
while id<maxId
    q=['SELECT `header`,`preamble`,`body`  FROM  `archive_latin1` WHERE  `autoId` >' num2str(id) ' AND `autoId` <=' num2str(id + idStep) ];
    text = fetch(c,q);
    N=size(text);
    i=1;j=1;
    
    for i=1:N(1) %Loop articles
        article=lower([text{i,1} ' ' text{i,2} ' ' text{i,3} ]);
        article=regexprep(article,'\.',' ');
        article=regexprep(article,'\?',' ');
        %w=strread(article,'%s');
        w=textscan(article,'%s');w=w{1};
        
        index=word2index(s,w);
        nr=1:length(index);
        
        for j=1:length(w); %Loop words
            if not(isnan(index(j))) & index(j)<=s.N
                %Context
                index2=find(not(nr==j) & not(isnan(index)) & index<snew.Ncol & j>=nr-snew.contextSize & j<=nr+snew.contextSize);
                count(index(j),index(index2))=count(index(j),index(index2))+1;
            end
        end
    end
    id=id+idStep;
    fprintf('.')
    if even(id,idStep*1) | not(id<maxId)
        snew.id=id;
        fprintf('Saving %.4f %s',id/maxId, datestr(now))
        save('count','count','-V7.3');
        fprintf('done\n')
        save('snewDb','snew','-V7.3');
        movefile('count.mat','countOk.mat');
        
        try
            s.synonymFile='swedishFiles/synonymerSwedish1k.txt';
            s.filename='spaceImproved-Swedish-2013-01-13';
            k=k+1;
            if d.mkspace
                [s sSUM snew.q{k}]=createSpaceSCD(count,s);
            end
        end
    end
end

end


function d=ngramSumYear(d,s,k)
c=[];
d.fileExtOne=d.fileExt{k};
%workingFileMeta=[d.path d.name 'WorkingMeta' d.fileExtOne '.mat'];
busyFile=[d.path d.name 'Busy' d.fileExtOne '.mat'];

fileNameSum=[d.path d.corpus d.fileExtOne 'SUM.txt'];
doneFile=regexprep(fileNameSum,'SUM','SUMDONE');
resultFile=[d.pathResults d.name d.fileExtOne '.mat'];
resultFileWeigth=[d.pathResults d.name d.fileExtOne 'Weight.mat'];

skip= exist(busyFile)==2 | exist(doneFile)==2 | exist(resultFile) | exist(resultFileWeigth)  ;

if skip & d.debug==0 & d.restart==0
    fprintf('File exist, or busy %s\n',doneFile);
    return
else
    fprintf('Making coOcucrence file %s\n',doneFile);
end
i=1;
save(busyFile,'i','-V7.3');

for l=1:length(d.contextWords)
    fcontext(l)=fopen([d.path d.contextWords{l} '.txt'],'a');
end


filename=[d.path d.corpus d.fileExtOne '.txt'];
www=['http://storage.googleapis.com/books/ngrams/books/' d.corpus d.fileExtOne '.gz'];%,[filename '.gz'];
getFile(www,filename);

if length(d.contextWords)>0
    tempfile=['temp' d.fileExtOne];
    f=fopen([tempfile '2'],'w');fprintf(f,'');fclose(f);
    for i=1:length(d.contextWords)
        fprintf('Extracting: %s %s\n',d.contextWords{i},datestr(now))
        a=['grep ' d.contextWords{i} ' ' filename ' > ' tempfile];
        system(a);
        system(['cat ' tempfile '2 ' tempfile ' > ' tempfile '3']);
        movefile([tempfile '3'],[tempfile '2'])
    end
    movefile([tempfile '2'],filename)
    delete(tempfile);
    fprintf('Done extracting %s\n',datestr(now))
end

fprintf('Summarize %s\n',datestr(now));
ok=1;
if ok;
    Nrows=getFileRows(filename);
else
    Nrows=NaN;
end
f=fopen(filename,'r','n', 'UTF-8');

fout=fopen(fileNameSum,'w','n', 'UTF-8');
data{3}=0;
data{4}=0;
data{5}=0;
data{1}={'_a _a _a _a _a'};
maxYear=100;
%if 0 %Empty yeardiff files!
%    for i=1:maxYear
%        fyear=fopen(['ngram/yeardiff' num2str(i-maxYear/2)],'w');
%        fprintf(fyear,'\n');
%        fclose(fyear);
%    end
%end

if d.saveByYear==1
    fprintf('Creating by year files.\n')
    %c.count=sparse(s.N,d.Ncol*d.tMax);
    c.count=spalloc(s.N,d.Ncol*d.tMax,d.memorySize);
    
end
i=0;
if 0 % & exist(workingFile)==2;
    load(workingFile);
    %load(workingFileMeta);
    d=c.d;
    fprintf('Start at row=%d, %s ...',d.i,datestr(now));
    for i=d.i
        textscan(f,'%s %d %d %d %d',1,'delimiter',char(9));
    end
end
sec=toc;
iSave=100000;
tic;
while not(feof(f))
    sum=zeros(1,3);
    i=i+1;
    if even(i,100000); fprintf('.',i); end
    j=0;
    ok=1;
    if d.saveByYear==1
        year=zeros(1,400);
        countYear=zeros(1,400);
    end
    while ok
        j=j+1;
        text=data{1};
        if d.saveByYear==1
            year(j) =data{2};
            countYear(j)=data{3};
        end
        sum(1)=sum(1)+data{3};%count
        sum(2)=sum(2)+data{4};%pages
        sum(3)=sum(3)+data{5};%books
        data=textscan(f,'%s %d %d %d %d',1,'delimiter',char(9));
        try
            ok=(strcmpi(text,data{1}) && not(feof(f))); %|| sum(1)==0;
        catch
            ok=0;
        end
    end
    try
        if even(i,iSave) | feof(f)
            sec=toc;
            d.i=i;
            c.d=d;
            if d.saveByYear==1
                workingFile=[d.path d.name 'Time' d.fileExtOne num2str(fix(i/iSave)) '.mat'];
                fprintf('saving at row=%d (estimated=%.2f),sec=%.1f, %s, %s ',i,23.*i/Nrows,toc-sec,datestr(now),workingFile);
                tic;
                save(workingFile,'c','-V7.3');
                save(busyFile,'i','-V7.3');
                %if even(i,iSave)
                fprintf('Clearing workingfile!\n')
                %c.count= sparse(s.N,d.Ncol*d.tMax);
                c.count=spalloc(s.N,d.Ncol*d.tMax,d.memorySize);
                
                %end
            end
            %save(workingFileMeta,'d','-V7.3');
            fprintf('%d done. ',i);
            print_mem;
        end
        
        N=length(text{1});
        if text{1}(N)==32; text{1}=text{1}(1:N-1);end
        fprintf(fout,'%s\t%d\t%d\t%d\n',text{1},sum(1),sum(2),sum(3));
        for l=1:length(d.contextWords)
            %textSt=strread(text{1},'%s');
            textSt=textscan(text{1},'%s');textSt=textSt{1};
            
            index=find(strcmpi(textSt,d.contextWords{l}));
            if not(isempty(index))
                fprintf(fcontext(l),'%s\t%d\t%d\t%d\n',text{1},sum(1),sum(2),sum(3));
            end
        end
        
        if d.saveByYear==1
            c=getIndex(s,c,text,year,countYear,d);
        end
    catch
        1;
    end
end
fclose(f);
fclose(fout);
movefile(fileNameSum,doneFile);
for l=1:length(d.contextWords)
    fclose(fcontext(l));
end
%if d.saveByYear==1
%    movefile(workingFile,[d.path d.name 'Time' d.fileExtOne '.mat']);
%end

clear c;
delete(filename);

if d.ocurrenceFromNgram
    c=ocurrenceFromNgram(d,s,k,doneFile);
end
delete(doneFile);
%delete(workingFileMeta)
delete(busyFile);


fprintf('\nSummary %s done %s\n',d.fileExtOne ,datestr(now));

end

function N=getFileRows(filename);
fprintf('Count rows in file: %s ...\n',filename);
f=fopen(filename,'r','n', 'UTF-8');
N=0;
while not(feof(f))
    fgets(f);
    N=N+1;
end
fprintf('Rows=%d\n',N);
end

function c=getIndex(s,c,data,year,countYear,d)

words=textscan(data{1},'%s %s %s %s %s',1,'delimiter',' ');
index=zeros(1,5);
for i=1:5
    j=s.hash.get(lower(words{i}{1}));
    if not(isempty(j))
        index(i)=j;
    end
end
indexYear=find(year>d.tStart & year<d.tStart+d.tMax);
for i=1:5
    if index(i)>0
        index2=find(not(i==(1:5)) & index>0 & index<d.Ncol);
        if not(isempty(index2))
            for k=1:length(index2)
                %indexWnY=index(index2(k))*250+year(indexYear)-1800;
                indexWnY=index(index2(k))+(year(indexYear)-d.tStart-1)*d.Ncol;
                c.count(index(i),indexWnY)=c.count(index(i),indexWnY)+countYear(indexYear);
            end
        end
    end
end
end


function ngramSubstitution

%input
word='I';
Npre=200;
Nsub=1000;

%1 Find index of search word
query=['select id,frequency from google_english_unigrams where word=''' word ''' '];
data=fetch2('ngrams',query);
index=data{1};
f=data{2};

%2 find preceeding words..
query=['select word1_id,frequency from google_english_bigrams where word2_id=' num2str(index) '  order by frequency desc limit 0,' num2str(Npre)];
data=fetch2('ngrams',query);
index1=cell2mat(data(:,1));
f1=cell2mat(data(:,2));

%find pre-substituion words..
string=' 0 ';
for i=1:length(index1)
    string=[string ' or word1_id=' num2str(index1(i))];
end
query=['select word2_id,frequency from google_english_bigrams where ' string ' order by frequency desc limit 0,' num2str(Nsub)];
data=fetch2('ngrams',query);
iTemp=cell2mat(data(:,1));
fTemp=cell2mat(data(:,2));


%3 find post-ceeding words..
query=['select word1_id,frequency from google_english_bigrams where word2_id=' num2str(index) '  order by frequency desc limit 0,' num2str(Npre)];
data=fetch2('ngrams',query);
index2=cell2mat(data(:,1));
f2=cell2mat(data(:,2));

%find post-substituion words..
string=' 0 ';
for i=1:length(index1)
    string=[string ' or word2_id=' num2str(index2(i))];
end
query=['select word1_id,frequency from google_english_bigrams where ' string ' order by frequency desc limit 0,' num2str(Nsub)];
data=fetch2('ngrams',query);
iTemp=[iTemp ; cell2mat(data(:,1))];
fTemp=[fTemp ; cell2mat(data(:,2))];

%Merge words from 2 and 3
[indexSub u]=unique(iTemp);
fpairSub=zeros(1,length(indexSub));
for i=1:length(indexSub)
    fpairSub(i)=sum(fTemp(find(indexSub(i)==iTemp)));
    %fpairSub(i)=sum(log(fTemp(find(indexSub(i)==iTemp))));
end

%find chacters f?r substition words
string=' 0 ';
for i=1:length(indexSub)
    string=[string ' or id=' num2str(indexSub(i))];
end
query=['select word,frequency from google_english_unigrams where ' string ' order by frequency desc  limit 0,' num2str(Nsub)];
data=fetch2('ngrams',query);

wordSub=data(:,1);
fSub=cell2mat(data(:,2))';

ratio=fpairSub./fSub;
[ratioSort indexSort]=sort(ratio,'descend');
wordSub(indexSort(1:30))
end









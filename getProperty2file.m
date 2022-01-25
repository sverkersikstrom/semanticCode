function d=getProperty2file(s,index,file,d)
%This script maps calculates index (e.g. properties) scores for texts in 'file' (e.g. flashback.txt) and prints this
%to  ['Output' file] (e.g. Outputflashback.txt).
%To run a part of the a file, use
%d.runOnce=1;d.done=0;while not(d.done);d=getProperty2file(s,index,file,d);end
dbstop if error
%Open space
if nargin<1
    s=getSpace;
end

if nargin<2 %Properties to calculate
    [tmp s]=getWordFromUser(s,'Choice properties to calculate','');
    index=tmp.index;
    if length(index)==0;return; end
    d.properties=tmp.fwords;
else
    if isnumeric(index)
        d.properties=index2word(s,index);
    else
        d.properties=index;
    end
end
%d.properties=d.properties;

if nargin<3 %Input file
    [file path]=uigetfile('*.txt','Choise file to process (text is in column 1)');
    if file==0;return;end
    file=[path file];
end

if nargin<4
    d=s.par;
end

if isfield(d,'parallelFiles') & d.parallelFiles %not tested/completed
    d=getProperty2fileParalell(s,index,file,d);
    return
end

if isfield(d,'iFile')
    file={d.file{d.iFile}};
elseif ischar(file)
    file={file};
    d.iFile=1;
    d.saveFile{1}=[regexprep(file{1},'\.','') 'data' ];
end

for f=1:length(file)
    fileInfo=dir(file{f});
    i=findstr(file{f},'.');
    if not(isfield(d,'outfile'))
        d.outfile=[file{f}(1:i-1) 'Results' file{f}(i:end)];
    end
    
    %Parameters
    if not(isfield(d,'textColumn')) d.textColumn=1;end%Column where the text is in
    if not(isfield(d,'notSaveText')) d.notSaveText=0;end%Do not save text data in outputfile
    if not(isfield(d,'restart')) d.restart=1;end%Starts from the beginging of the file (otherwise continue when interupted
    if not(isfield(d,'keepText')) d.keepText=0;end %Keep text in output file
    if not(isfield(d,'hasTitle')) d.hasTitle=0;end%Inputfile has a title row that is skipped
    if not(isfield(d,'runOnce')) d.runOnce=0;end %Run Nstep texts, and then exit
    if not(isfield(d,'Nstep')) d.Nstep=20;end %Calculates N rows at a time
    if not(isfield(d,'keywords')) d.keywords='';end%Limit text to that includes these keywords, e.g. {'han',hon'}
    if not(isfield(d,'save')) d.save=0;end%Save d.strucutre every few minuts
    if not(isfield(d,'optimize')) d.optimize=0;end%Calculates getProperty one time only
    if not(isfield(d,'sumTime')) d.sumTime=0;end%For Google Ngram data only, summarize year data on the second column
    
    
    if d.keepText %Save text in output file
        textColumn=d.textColumn;
    else
        textColumn=d.textColumn-1;
    end
    
    Nstep=d.Nstep;
    
    %Open files
    d.i=0;d.N=0;d.Nchar=0;
    if not(isfield(d,'f'))
        if d.sumTime
            file{f}=summarizeGoogleFile(file{f});
            fileInfo=dir(file{f});
        end
        
        d.f=fopen(file{f},'r','native','UTF-8');
        
        if d.hasTitle fgets(d.f);end
        if not(d.restart) & exist(d.outfile) %Do if you interput the code and want to restart
            d.fout=fopen(d.outfile,'r','native','UTF-8');
            fgets(d.fout);%Skip titles
            while not(feof(d.fout))
                fgets(d.fout);t=fgets(d.f);d.i=d.i+1;
                d.Nchar=d.Nchar+length(t);
            end
            fprintf('Restarting at row %d\n',d.i)
            fclose(d.fout);
            warning off;d.fout=fopen(d.outfile,'a','native','UTF-16');warning off;
        else
            warning off;d.fout=fopen(d.outfile,'w','native','UTF-16');warning on;
            %Print headers
            out=sprintf('i\t');
           
            for j=1:textColumn-d.notSaveText
                out=[out sprintf('%s\t',['text' num2str(j)])];
            end
            
            for j=1:length(d.properties)
                out=[out sprintf('%s\t',d.properties{j})];
            end
            fprintf('%s\n',out);
            fprintf(d.fout,'%s\n',out);
            if isfield(d,'startRow')
                for i=1:d.startRow
                    fgets(d.f);
                end
                d.i=i;
                fprintf('Starting at row %d\n',d.i);
            end
        end
    end
        
    tstart=now;
    d.done=0;
    d.index=index;
    d.now=now;
    for i=1:length(d.keywords)
        d.data{i}.r=zeros(1,length(d.properties));
        d.data{i}.N=zeros(1,length(d.properties));
        d.data{i}.x=zeros(1,s.Ndim);
        d.data{i}.f=zeros(1,s.N);
        d.data{i}.indexContext=[];
        d.data{i}.i=1;
    end
    if d.optimize>0
        optimizeFile=regexprep([s.languagefile cell2string(d.properties)],'\.mat','');
        if exist([optimizeFile '.mat']);
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
    end
    indexContext=[];
    indexKeywords=word2index(s,d.keywords);
    if length(d.keywords)==0
        while not(feof(d.f)) & not(d.done)
            try
                data=fgets(d.f);
                d.Nchar=d.Nchar+length(data);
                d.N=d.N+1;
                data=textscan(data,'%s','delimiter',char(9));data=data{1};
                if d.notSaveText
                    indexSave=find(not(1:length(data)==d.textColumn));
                else
                    indexSave=1:length(data);
                end
                t=data(d.textColumn);
                [indexTmp t2 s]=text2index(s,t{1});
                indexTmp=indexTmp(not(isnan(indexTmp)));
                if d.optimize
                    for j=1:length(d.properties) %
                        res(j)=nanmean(d.resAll(j,indexTmp));
                    end
                else
                    [res,~,s]=getProperty(s,data3(:,d.textColumn)',d.properties);
                end
                for i=indexSave;
                    fprintf(d.fout,'%s\t',data{i});
                end
                for i=1:length(res);
                    fprintf(d.fout,'%.4f\t',res(i));
                end
                fprintf(d.fout,'\n');
                if abs(now-d.now)*24*60>1 | feof(d.f) %even(d.i+k,Nstep)
                    d.percentageCompleted=d.Nchar/fileInfo.bytes;
                    d.estimatedDaysToCompletion=fileInfo.bytes*(now-tstart)/d.Nchar;
                    d.now=now;
                    fprintf('%s\t%d\t%s\t%.6f\t%.1f\n',file{f},d.N,datestr(now),d.percentageCompleted,d.estimatedDaysToCompletion);
                end
            catch
                fprintf('Error on row %d\n',d.N);
            end
        end
    else
        while not(feof(d.f)) & not(d.done)
            if d.runOnce
                d.done=1;
            end
            d.N=d.N+1;
            data3={};j=1;
            keywords=zeros(Nstep,length(d.keywords));
            while size(data3,1)<Nstep & not(feof(d.f))
                d.i=d.i+1;
                t{j}=fgets(d.f);
                d.Nchar=d.Nchar+length(t{j});
                textCol=textscan(t{j},'%s','delimiter',char(9));textCol=textCol{1};
                if isfield(d,'removeBrackets')
                    textCol=regexprep(textCol,'<\w+>','');
                end
                try
                    if length(d.keywords)>0
                        text=textCol(d.textColumn);text=text{1};
                        words=textscan(text,'%s');words=words{1};
                        for i=1:length(d.keywords) %This can be made faster!
                            if iscell(d.keywords{i})
                                k=[];
                                for l=1:length(d.keywords{i})
                                    k=[k find(strcmpi(d.keywords{i}{l},words))];
                                end
                            else
                                k=find(strcmpi(d.keywords{i},words));
                            end
                            if not(isempty(k))
                                indexTmp=word2index(s,words);
                                if isfield(d,'contextSize') & d.contextSize>0
                                    indexTmp=[indexTmp(max(1,k-d.contextSize):min(end,k-1))  indexTmp(min(end+1,k+1):min(end,k+d.contextSize))];
                                    if length(indexTmp)<d.contextSize*2
                                        indexTmp=[indexTmp NaN(1,d.contextSize*2-length(indexTmp)) ];
                                    end
                                    keywords(j,i)=1;
                                else
                                    indexTmp=indexTmp(not(indexKeywords(i)==indexTmp));
                                    if length(indexTmp)<size(indexContext,2)
                                        indexTmp=[indexTmp nan(1,size(indexContext,2)-length(indexTmp))];
                                    end
                                    keywords(j,i)=str2num(textCol{2});
                                end
                                indexContext(j,:)=indexTmp;
                                indexTmp=indexTmp(not(isnan(indexTmp)) & not(indexKeywords(i)==indexTmp));
                                if length(indexTmp)>0
                                    d.data{i}.x=nansum([d.data{i}.x; s.x(indexTmp,:)]);
                                end
                                data3(j,1:length(textCol))=regexprep(textCol,d.keywords{i},'');
                                d.data{i}.f(indexTmp)=d.data{i}.f(indexTmp)+keywords(j,i);
                                j=j+1;
                            end
                        end
                    else
                        data3(j,1:length(textCol))=textCol;
                        j=j+1;
                    end
                catch
                    fprintf('Error at row %d\n',d.i)
                    N=size(data3);
                    try
                        data3(j,1:N(2))=textCol(1:N(2));
                    catch
                        textCol
                    end
                end
            end
            
            try
                s.par.reverseOrder=1;
                if not(d.optimize)
                    [res,~,s]=getProperty(s,data3(:,d.textColumn)',d.properties);
                end
                for i=1:length(d.keywords) %keywords
                    for j=1:length(d.properties) %properties
                        include=zeros(1,size(data3,1));
                        for k=1:size(data3,1) %texts
                            if d.optimize
                                indexTmp=indexContext(k,:);
                                indexTmp=indexTmp(not(isnan(indexTmp)));
                                res(k,j)=nanmean(d.resAll(j,indexTmp));
                            end
                            if keywords(k,i)>0 & not(isnan(res(k,j)))
                                include(k)=1;
                                d.data{i}.r(j)=d.data{i}.r(j)+res(k,j)*keywords(k,i);
                                d.data{i}.N(j)=d.data{i}.N(j)+keywords(k,i);
                            end
                        end
                        Nadd=length(find(include));
                        if Nadd>0
                            d.data{i}.indexContext(d.data{i}.i:d.data{i}.i+Nadd-1,:)=indexContext(find(include),:);
                            d.data{i}.i=d.data{i}.i+Nadd;
                            if size(d.data{i}.indexContext,1)<d.data{i}.i+Nstep*2
                                d.data{i}.indexContext=[d.data{i}.indexContext; nan(2000,size(d.data{i}.indexContext,2))];
                            end
                        end
                    end
                    if even(d.N-1,300) | feof(d.f)
                        if i==1;fprintf('\n');end
                        fprintf('%s\t%d\t',d.keywords{i},d.data{i}.N(1))
                        for j=1:length(d.properties)
                            fprintf('%.4f\t',d.data{i}.r(j)/d.data{i}.N(j))
                        end
                        fprintf('\n')
                    end
                end
                for k=1:size(data3,1)
                    out=sprintf('%d\t',d.i+k-Nstep);
                    for j=1:textColumn
                        out=[out sprintf('%s\t',data3{k,j})];
                    end
                    for j=1:length(d.properties)
                        out=[out sprintf('%.4f\t',res(k,j))];
                    end
                    if d.i-Nstep<10
                        fprintf('%s\n',out);
                    end
                    d.percentageCompleted=d.Nchar/fileInfo.bytes;
                    d.estimatedDaysToCompletion=fileInfo.bytes*(now-tstart)/d.Nchar;
                    if abs(now-d.now)*24*60>1 | feof(d.f) %even(d.i+k,Nstep)
                        d.now=now;
                        fprintf('%s\t%d\t%s\t%.6f\t%.1f\n',file{f},d.i,datestr(now),d.percentageCompleted,d.estimatedDaysToCompletion);
                        if d.save
                            save(d.fileSave{d.iFile},'d','-V7.3');
                        end
                    end
                    fprintf(d.fout,'%s\n',out);
                    if isfield(d,'endRow') & d.i-Nstep+k>=d.endRow
                        fprintf('Ending at row %d\n',d.i-Nstep+k);
                        fclose(d.f);d=rmfield(d,'f');
                        return
                    end
                end
            catch
                fprintf('Error storing at row %d\n',d.i)
                eTmp=lasterror
                eTmp.stack
            end
        end
    end
    
    d.done=feof(d.f);
    if not(d.runOnce)
        fclose(d.f);
        fclose(d.fout);
    end
end

if length(d.keywords)>0 %Calculates results
    d=getProperty2fileResults(s,d,file);
end

if d.save
    save(d.fileSave{d.iFile},'d','-V7.3');
    %save([regexprep(file{end},'\.','') 'data' ],'d','-V7.3');
end


function d=getProperty2fileParalell(s,index,file,d)
d.restart=1;
d=rmfield(d,'parallelFiles');
%Count rows
f=fopen(file,'r','native','UTF-8');
rows=0;
if rows==0
    while not(feof(f));fgets(f);rows=rows+1;end
end
fprintf('Rows %d\n',rows);

p=gcp;
Nprocesses=max(1,p.NumWorkers-1);%Make three paraell processes
Nstep=fix(rows)/Nprocesses+1;
d.done=0;
i=0;
handles=s.handles;
s.handles=[];
tic;
dTmp=d;
for i=1:Nprocesses
    d=dTmp;
    d.startRow=1+(i-1)*Nstep;
    d.endRow=i*Nstep;
    j=findstr(file,'.');
    d.outfile=[file(1:j-1) num2str(i) file(j:end) 'TMP'];
    d=getProperty2file(s,index,file,d);
    movefile(d.outfile,d.outfile(1:end-3));
    d.outfile=d.outfile(1:end-3);
    resultfile{i}=d.outfile;
end
toc
s.handles=handles;
%Summarize all files
i=findstr(file,'.');
warning off;
fout=fopen([file(1:i-1) 'Results' file(i:end)],'w');%,'native','UTF-8');
for i=1:Nprocesses
    f=fopen(resultfile{i},'r','native','UTF-8');
    if i>1;fgets(f);end
    while not(feof(f))
        t=fgets(f);
        fprintf(fout,'%s',t);
    end
    fclose(f);
end
warning on;
fclose(fout);


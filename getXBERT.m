function [s, xnorm,BERTData]=getXBERT(s,index,BERTData);
if nargin<3
    BERTData=[];
end
save2file=1;
mem=1;
if s.par.parfor
    maxN=min(10000,length(index));
else
    maxN=500;
end

fprintf('BERT: %d %d\n',length(index),maxN)
if not(isfield(s,'extraData')) s.extraData='';end
if s.par.parfor bak='.bakp'; else bak='.bak';end
if save2file
    file=[s.datafile '-BERT.mat'];
    if file(1)=='-'; file=file(2:length(file));end
    if isempty('BERTData') | not(isfield(BERTData,'file')) | not(strcmp(BERTData.file,file))
        BERTData.file=file;
        if exist(file)
            file2=regexprep(file,'.mat',bak);
            a1=dir(file);
            a2=dir(file2);
            if exist(file2) & a2.bytes>a1.bytes
                movefile(file2,file);
            end
            load(file)
        else
            if isfield(s.extraData,'hash')
                BERTData.hash=s.extraData.hash;
                s.extraData=rmfield(s.extraData,'hash');
            end
            BERTData.file=file;
        end
        if mem & not(isfield(BERTData,'hash2'))
            BERTData.hash2=java.util.Hashtable;
            BERTData.x=[];
            if isfield(BERTData,'hash')
                BERTData=rmfield(BERTData,'hash');
            end
        elseif not(isfield(s.extraData,'hash'))
            s.extraData.hash=java.util.Hashtable;
        end
    end
end
if length(index)>maxN
    xnorm=[];
    for i=1:maxN:length(index)
        [s, x,BERTData]=getXBERT(s,index(i:min(length(index),i+maxN-1)),BERTData);
        xnorm=[xnorm; x];
    end
end

%Get texts
text=getText(s,index,[],0);
if ischar(text) text={text};end
%Find cashed BERT data
set2NaN=zeros(1,length(index));
missing=[];
xnorm=[];
for i=1:length(index)
    if save2file
        if mem
            j=BERTData.hash2.get(num2str(keyGenerator([s.par.BERT ':' text{i}])));
            if not(isempty(j))
                x=BERTData.x(str2double(j),:);
            else
                x=[];
            end
        else
            x=BERTData.hash.get([s.par.BERT ':' text{i}]);
        end
    else
        x=s.extraData.hash.get([s.par.BERT ':' text{i}]);
    end
    missing(i)=isempty(x);
    if length(text{i})==0 | strcmp(text{i},'NA') 
        set2NaN(i)=1;missing(i)=0;
    elseif not(missing(i))
        if mem
            xnum=x;
        else
            xnum=str2double(x);
        end
        xnorm(i,1:length(xnum))=xnum;
    end
end
t=now;

%Get missing data

rootPath=s.par.rootPath;
if length(rootPath)==0 rootPath=pwd;end

if not(isempty(find(missing)))
    %Save text to file
    if s.par.parfor
        index2=find(missing);
        Ngroup=23;%min(23,fix(length(index2)/1000));
        group=fix((1:length(index2))/(length(index2)+1)*Ngroup)+1;
        fprintf('Ngroup=%d\n',Ngroup)
        iLoop=unique(group);
        BERT=s.par.BERT;
        parfor i=iLoop
            xcell{i}=text2bert(text(index2(find(group==i))),BERT,rootPath);
        end
        for i=iLoop
            x(find(group==i),:)=xcell{i};
        end
    else
        x=text2bert(text(find(missing)),s.par.BERT,rootPath);
    end
    
    %Store BERT results
    xnorm(find(missing),:)=x;
    x2=[];
    for i=find(missing)
        xnorm(i,:)=xnorm(i,:)/sum(xnorm(i,:).*xnorm(i,:))^.5;
        if save2file
            if mem
                x2=[x2; xnorm(i,:)];
                BERTData.hash2.put(num2str(keyGenerator([s.par.BERT ':' text{i}])),num2str(size(BERTData.x,1)+size(x2,1)));
            else
                BERTData.hash.put([s.par.BERT ':' text{i}],num2str(xnorm(i,:)));
            end
        else
            s.extraData.hash.put([s.par.BERT ':' text{i}],num2str(xnorm(i,:)));
        end
    end
    if mem & save2file
        BERTData.x=[BERTData.x; x2];
    end
end
xnorm(find(set2NaN),:)=NaN;

if save2file & not(isempty(find(missing))) %(now-t)*24*60>.5
    if exist(BERTData.file)
        a=dir(BERTData.file);
        if a.bytes>1000
            movefile(BERTData.file,regexprep(BERTData.file,'.mat',bak))
        else
            stop
        end
    end
    save(BERTData.file,'BERTData')
    fprintf('%d\t%d\t%s\n',i,length(index),BERTData.file)
end

function x=text2bert(text,BERT,rootPath);
new=1;
if new
    nr=regexprep(num2str(rand),'\.','');
    file=[rootPath '/file2BERT-' nr '.csv'];
else
    file=[rootPath '/file2BERT.csv'];
end
fprintf('\nfile2BERT: %s\n',file);
f=fopen(file,'w','n','UTF-8');
fprintf(f,'"text"\n');
for i=1:length(text)
    fprintf(f,'"%s"\n',regexprep(regexprep(regexprep(regexprep(regexprep(text{i},'__',' '),char(13),' '),char(10),' '),char(9),' '),'"',' '));
end
fclose(f);
%Run BERT
if new %New can be parallised
    if isempty(findstr(getenv('PATH'),':/usr/local/bin'))
        setenv('PATH',[getenv('PATH') ':/usr/local/bin'])
    end
    path=[rootPath '/'];%'/Users/sverkersikstrom/Dropbox/semantic/';
    file=['BERT-' nr '.csv'];
    RFile=[rootPath '/semanticCode/matlab2R' nr '.R'];
    f=fopen(RFile,'w');
    fprintf(f,'matlab2R%s <- function (model = "%s",file="%s",path="%s")\n{\n',nr,BERT,file,path);
    fprintf(f,'source("%s/semanticCode/file2BERT2.R")\n',rootPath);
    fprintf(f,'t <- file2BERT2(model,file,path) \n}\nt2<-matlab2R%s()\n',nr);
    fclose(f);
    a=system(['module load GCC/9.3.0 OpenMPI/4.0.3 R/4.0.0' char(13) char(10) 'R -f ' RFile]);
    fprintf('\nBERT: %s',[rootPath '/' file]);
    [words, data, dim, labels,labelsFixed,dataType]=textread2([rootPath '/' file],0);
    fprintf('.\n');
    
    delete(RFile);
    delete([rootPath '/' file]);
    delete([rootPath '/file2' file]);
else %Old not parallesed
    if strcmpi(s.par.BERT,'bert_base_uncased')
        model='file2BERT.R';
    else
        model='file2BERTML.R';
    end
    a=system(['R -f ' rootPath '/semanticCode/' model]);
    
    %Read BERT data
    [words, data, dim, labels,labelsFixed,dataType]=textread2([rootPath '/BERT.csv'],0);
end
x=data(:,7:size(data,2));

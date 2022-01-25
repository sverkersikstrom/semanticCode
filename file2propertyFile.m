function d=file2propertyFile(s,file,properties,par)
if nargin<1
    s=getSpace;
end
if nargin<3
    properties={'_predvalencestenberg'};
end
if nargin<4
    par=[];
end

if not(isfield(par,'print')) par.print=0;end
if not(isfield(par,'rows')) par.rows=200;end
if not(isfield(par,'column')) par.column=4;end
if not(isfield(par,'targetWord')) par.targetWord='';end
if not(isfield(par,'para')) par.para=-1;end
if not(isfield(par,'paraN')) par.paraN=0;end
if not(isfield(par,'load')) par.load=0;end
if not(isfield(par,'recursive')) par.recursive=1;end

if par.para==0 | par.para==-2
    d.eof=0; 
    d2.x=[];d2.dataOut=[];d2.dataNum=[];
    paraN=0;
    while d.eof==0 & (par.paraN==0 | paraN<par.paraN)
        par.para=par.para+1;
        fprintf('Paralell %d\n',par.para);
        dFile=[regexprep(file,'\.txt','') num2str(par.para) '.mat'];
        paraN=paraN+1;
        if exist(dFile)
            load(dFile)
        elseif par.load
            d.eof=1;d.done=0;
        else
            clear d;
            d.eof=0;
            d.done=0;
            d.tStart=now;
            save(dFile,'d','-V7.3')
            d=file2propertyFile(s,file,properties,par);
            d.done=1;
            save(dFile,'d','-V7.3')
        end
        done(par.para)=d.done;
        if d.done
            d2.x=[d2.x; d.x];
            d2.dataOut=[d2.dataOut; d.dataOut];
            d2.dataNum=[d2.dataNum; d.dataNum];
        end
    end
    d2.done=mean(done)==1;
    d=d2;
    while not(d.done) & par.recursive & par.load==0
        fprintf('Pause 5 minuts\n')
        pause(60*5)
        par.para=0;
        par.recursive=0;
        d=file2propertyFile(s,file,properties,par);
        par.recursive=1;
    end
    return
end

f=fopen(file,'r','n', 'UTF-8');
if par.para>0
    if not(isfield(par,'paraNrows')) par.paraNrows=2000;end
    for i=1:par.paraNrows*(par.para-1) 
        text=fgets(f);
    end
    par.rows=par.paraNrows;
end

if par.para>1
    type='a';
else
    type='w';
end

fout=fopen(['property' file],type,'n', 'UTF-8');
D=dir(file);
rows=0;
bytes=0;
result=[];
bytesProcent=0;
tic;
dataOutSave=[];
lrow=0;
while not(feof(f)) & (par.rows==0 | rows<par.rows)
    text=fgets(f);
    try
        rows=rows+1;
        if length(par.targetWord)>0
            while not(feof(f)) & isempty(strfind(text,par.targetWord))
                text=fgets(f);
                bytes=bytes+length(text);
            end
        end
        bytes=bytes+length(text);
        data= string2cell(text,char(9));
        if rows==1
            for i=1:length(data)
                d.label{i}=['column' num2str(i)];
                fprintf(fout,'column%d\t',i);
            end
            for i=1:length(properties)
                d.label{length(data)+i}=properties{i};
                fprintf(fout,'%s\t',properties{i});
            end
            fprintf(fout,'\n');
        end
        
        if not(isempty(s))
            [tmp , result, s]=getProperty(s,data(par.column),properties);
            if nargout>=3 | 1
                x(rows,:)=s.x(word2index(s,'_tempa1'),:);
                N=size(x);
                if N(1)==rows
                    x(rows+1000,:)=NaN;
                end
            end
            text=regexprep(text,char(10),' ');
            for i=1:length(result)
                text=[text result{i} char(9)];
            end
        end
        if nargout>=1 | 1
            dataOut(rows-lrow,:)=[data ; result']';
        end
        fprintf(fout,'%s\n',text);
        if bytes/D.bytes>bytesProcent
            bytesProcent=bytesProcent+.001;
            fprintf('.');
            dataOutSave=[dataOutSave; dataOut];
            lrow=rows;
            clear dataOut;
        end
        if par.print
            fprintf('%.5f\t%s\n',bytes/D.bytes,text)
        end
    catch
        [e1 e2]=lasterr;
        rows=rows-1;
        fprintf('Error %s %s in row %d %s\n',e1,e2,rows,text)
    end
    1;
end
if exist('dataOut')
    dataOut=[dataOutSave; dataOut];
else
    dataOut=dataOutSave;
end

fprintf('\nCompleted: %.5f row=%\n',bytes/D.bytes,rows)

if nargout>=2 | 1   
    N=size(dataOut);
    for i=1:N(1)
        for j=1:N(2)
            try
                dataNum(i,j)=str2double(dataOut{i,j});
            catch
                dataNum(i,j)=NaN;
            end
        end
    end
end
if nargout>=3 | 1
    x=x(1:rows,:);
end
d.x=x;d.dataNum=dataNum;d.dataOut=dataOut;d.eof=feof(f);
fclose(f);


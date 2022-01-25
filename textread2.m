function [words, data, dim, labels,labelsFixed,numeric]=textread2(file,questions,maxr,useLabels)
if nargin<2; questions=1; end
if nargin<3
    maxr=0;
end
if nargin<4
    useLabels=0;
end


op=0;
if not(isempty(findstr(file,'.json')))
    file=json2txtfile(file);
end

if not(isempty(findstr(file,'.xls')))
    %fprintf('Excel files MUST be saved in the Excel 5.0/95 format!\nTHIS EXCEL FORMAT ONLY WORKS WITH TEXT SHORTER THAN 255 CHARACTERS!!!\n')
    [NUMERIC,TXT,data1.textdata]= xlsread(file);
    if isfield(data1.textdata,'Sheet1')
        data1.textdata=data1.textdata.Sheet1;
    end
    [r col1]=size(data1.textdata);
    for i=1:r
        for j=1:col1
            d=data1.textdata{i,j};
            if isnan(d)
                d='';
            elseif isnumeric(d) 
                data(i,j)=d;
            elseif islogical(d)
                d=d*1.0;
                data(i,j)=d;                
            else
                d=regexprep(d,char(9),char(32));
                d=regexprep(d,char(13),char(32));
            end
            words{i,j}=d;
        end
    end
    
    labels=words(1,:)';
    
    words=words(2:end,:);
    dim=col1;
    
else
disp('==================');
disp(file);
disp('==================');

    f=fopen(file,'r','n','UTF-8');
    i=0;
    labels=fgets(f);
    
    if strcmpi(file(max(end-3,1):end),'.csv')
        if findstr(labels,';')>0
            delimiter=';';
        else
            delimiter=',';
        end
    else
        delimiter=char(9);
    end


    if nargout>3
        if questions
            useLabels= strcmpi('Yes',questdlg2('Use first rows as labels?','Labels','Yes','No','Yes'));
        else
            useLabels=1;
        end
        if useLabels
            a=textscan(fgets(f),'%s','delimiter',delimiter);%,'bufsize',40000);
            a=a{1};
        else
            labels=file;
        end
        if questions
            labels=inputdlg3('Choose label names',labels,-1);
        end
        labels=regexprep(labels,' ','');
        labels=string2cell(labels,delimiter);
    else
        a=string2cell(labels,delimiter);
        labels=a;
    end
    if useLabels
        startrow=2;
    else
        startrow=1;
    end
    dim=length(a);
    fclose(f);
    
    clear words;
    words{1}=[];
    f=fopen(file,'r','n','UTF-8');i=0;
    %tabDelimiter=0;
    fprintf('Please use Tabs as delimiter in text file!\n')
    if startrow>1
        a=fgets(f);
    end
    op=1;
    zero=' ';zero(1)=0;
    while not(feof(f)) & (i<maxr | maxr<=0)
        if even(i,10000) fprintf('.'); end
        a=fgets(f);
        a=fixchar(a);
        if delimiter==',' & 0
            j=find(a=='"');
                while (length(find(a==','))+1<length(labels) | not(even(length(j),2))) & not(feof(f))
                    a=[a fgets(f)];
                    j=find(a=='"');
                end
                for k=1:2:length(j)
                    a(j(k)+1:j(k+1)-1)=regexprep(a(j(k)+1:j(k+1)-1),',',' ');
                end
                a(j)=' ';
                a(find(a==10))=' ';
        end
        a=regexprep(a,zero,'');
        a=string2cell(a,delimiter);
        if length(a)>0
            i=i+1;
            Nc=length(a);
            [tmp1 tmp2]=size(words);
            if i>tmp1
                %words(fix(i*1.2)+100,1:Nc)=a(1:Nc);
                words(fix(i*1.2)+100,1)={[]};
                data(fix(i*1.2)+100,1:Nc)=NaN;
            end
            if op
                tmp=str2double(a);
                isNaN=find(isnan(tmp));
                words(i,1:length(a))=a;
                %words(i,isNaN)=a(isNaN);
                data(i,1:length(tmp))=tmp;
            else
                words(i,1:Nc)=a(1:Nc);
            end
        end
    end
    fclose(f);
    words=words(1:i,:);
    data=data(1:i,:);
end

if nargout>1 & not(op)
    N=length(words(:,1));
    data=NaN(N,dim);
    %fprintf('MkOutput');
    for i=1:dim
        fprintf('.');
        for j=1:N
            try
                if isnumeric(words{j,i})
                    data(j,i)=words{j,i};
                else
                    data(j,i)=str2double(words{j,i});
                end
            catch
                data(j,i)=NaN;
                fprintf('Error on %s row %d and column %d, skipping this line!\n',words{j,i},i,j);
            end
        end
    end
end
for i=1:length(labels)
    labelsFixed{i}=fixpropertyname(labels{i});
    numeric(i)=isnumeric(words{1,i});
end
fprintf('\n');

function convert(a)
a=regexprep(a,char(65533),char(229));%?




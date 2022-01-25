function scriptHossein
dbstop if error
%targetWords='ALCOA ALLSTATE ABBOTT ALTRIA AMAZON AMGEN APACHE APPLE AVON BAXTER BERKSHIRE BOEING CAREMARK CATERPILLAR CHEVRON CISCO CITIGROUP COCA COLGATE COMCAST CONOCOPHILLIPS COSTCO DELL 3M DEVON';
%targetWords=string2cell(targetWords);
%targetWords={'AT&T','EMC','EMERSON','ENTERGY','EXELON','EXXON','FEDEX','FORD','FREEPORT-MCMOR','GOLDMAN','GOOGLE','HALLIBURTON','HEINZ','HEWLETT-PACKARD', 'HONEYWELL','INTEL','IBM','MORGAN','KRAFT','LOCKHEED','LOWE','MASTERCARD','MCDONALDS','MEDTRONIC','MERCK','METLIFE','MICROSOFT','MONSANTO','MORGAN','NIKE','OILWELL','NORFOLK','OCCIDENTAL','ORACLE','PEPSICO','PFIZER','PHILIP','PROCTER','QUALCOMM','RAYTHEON','SCHLUMBERGER','SPRINT','WARNER','UNITEDHEALTH','VERIZON','VISA','WALGREEN','DISNEY','FARGO','WEYERHAEUSER','WILLIAMS','XEROX'};

if 0
    [NUM,TXT,RAW]=xlsread('Weekly volatility.xlsx');
    targetWords=TXT(2,:);
else
    %stop
    targetWords={'ABBOTT LABORATORIES' 'ABBVIE' 'ACCENTURE' 'ALCOA' 'Allegheny Technologies' 'ALLSTATE ' 'ALTRIA' 'AMAZON' 'American Electric Power' 'AMERICAN EXPRESS' 'AMERICAN INTERNATIONAL' 'AMGEN' 'ANADARKO' 'ANHEUSER' 'APACHE' 'APPLE' 'AT&T' 'AVON' 'BAKER HUGHES' 'BANK OF AMERICA' 'BANK OF NEW YORK MELLON' 'BAXTER INTERNATIONAL' 'BERKSHIRE HATHAWAY' 'BOEING' 'BRISTOL MYERS' 'Burlington Northern' 'CAMPBELL SOUP' 'CAPITAL ONE FINANCIAL' 'CATERPILLAR' 'CHEVRON' 'CISCO' 'CITIGROUP' 'CLEAR CHANNEL' 'COCA COLA' 'COLGATE-PALMOLIVE' 'COMCAST' 'CONOCOPHILLIPS' 'COSTCO' 'CVS' 'DELL' 'Delta' 'DEVON ENERGY' 'DOW CHEMICAL' 'DU PONT' 'KODAK' 'EBAY' 'ELI LILLY' 'EMC' 'EMERSON ELECTRIC' 'ENTERGY' 'EXELON' 'EXXON' 'FEDEX' 'FORD' 'McMoRan' 'GENERAL DYNAMICS' 'GENERAL ELECTRIC' 'GENERAL MOTORS' 'GILEAD SCIENCES' 'GILLETTE' 'GOLDMAN SACHS' 'GOOGLE' 'HALLIBURTON' 'The Hartford' 'HCA' 'HEWLETT' 'HILLSHIRE BRANDS' 'HJ HEINZ' 'HOME DEPOT' 'HONEYWELL' 'INTEL' 'IBM' 'International paper' 'JOHNSON & JOHNSON' 'JP MORGAN' 'LEHMAN BROTHERS' 'LOCKHEED' 'LOWE''S' 'LUCENT' 'MASTERCARD' 'MCDONALDS' 'MEDIMMUNE' 'MEDTRONIC' 'MERCK' 'MERRILL LYNCH' 'METLIFE' 'MICROSOFT' 'MONDELEZ' 'MONSANTO' 'MORGAN STANLEY' 'VARCO' 'NEXTEL' 'NIKE' 'NORFOLK SOUTHERN' 'OCCIDENTAL PETROLEUM' 'OFFICEMAX' 'ORACLE' 'PEPSICO' 'PFIZER' 'PHILIP MORRIS' 'PROCTER' 'QUALCOMM' 'RADIOSHACK' 'RAYTHEON' 'ROCKWELL AUTOMATION' 'SCHLUMBERGER' 'STARBUCKS' 'TEXAS INSTRUMENTS' 'TIME WARNER' 'TOYS R US' 'CENTURY FOX' 'TYCO INTERNATIONAL' 'UNION PACIFIC' 'UNISYS' 'UNITED PARCEL' 'UNITED TECHNOLOGIES' 'UNITEDHEALTH' 'US BANCORP' 'WAL-MART' 'WALGREEN' 'WALT DISNEY' 'WELLS FARGO' 'VERIZON' 'WEYERHAEUSER' 'VIACOM' 'VISA' 'XEROX';};
end

timeFile='Weekly volatility.xlsx';
%[words data col targetWords]=textread2(timeFile);
%save('targetWords','targetWords')
%load('targetWords')

propertyName='_voatility';
path='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/Corpus/journals/';
if not(exist(path));
    path='/lunarc/nobackup/users/sverker/journals/';
    pathRes=[path 'results/'];
else
    path='/Users/sverkersikstrom/Dropbox/ngram/';
    pathRes='results/';
end

try
    addpath('/Users/sverkersikstrom/Dropbox/ngram/');
    addpath('/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/Corpus/journals/');
end
addpath('/lunarc/nobackup/users/sverker/journals/');
if 0
    delete results/spaceALCOA.mat
end
source{1}='nytimes-87-07.csv';
source{2}='nytimes-08-13.csv';
source{3}='wsj.csv';
mkdir(pathRes);
restart=1;
if restart
    istart=1;
else 
    s=getNewSpace([path 'spaceenglish.mat']);
    load('infosave')
    istart=length(infosave)+1;
end

for i=istart:length(targetWords);
    %Getspace
    label=regexprep(targetWords{i},' ','');
    spaceFile=[pathRes 'space' label];
    %s.saved=1;
    %s=getSpace('set',s);
    resultFile=[pathRes  label '.txt'];
    if restart
        getSpace('initNoSave');
        s=getNewSpace(spaceFile);        
    elseif exist(resultFile) 
        fprintf('Done %s\n',resultFile)
    elseif exist([spaceFile '.mat'])
        fprintf('Loading %s\n',spaceFile)
        s=getNewSpace(spaceFile);
    elseif 1
        f=fopen([spaceFile '.mat'],'w');fclose(f);
        s=getNewSpace([path 'spaceenglish.mat']);
        s=addX2space(s,propertyName);
        s=addX2space(s,'_id');
        s=addX2space(s,'_source');
        saveSpace(s,spaceFile);
        
        %Extract contexts
        s=extractContextOne(s,targetWords{i},source);
        saveSpace(s,spaceFile);
    end
    
    %Train
        if not(exist([spaceFile '.mat']))
            fprintf('Missing space file %s\n',label);
        elseif exist(resultFile) & not(restart)
            fprintf('Resultfile exist skipping %s\n',label);
        else
            [o s]=getWord(s,['_' label '*']);
            if o.N==0
                fprintf('No words found %s\n',label);
            else
                s=setPropertyFromTimeFile(s,timeFile,o.index,targetWords{i},propertyName);
                time=getProperty(s,'_time',o.index');
                id=getProperty(s,'_id',o.index');
                [tmp source2]=getProperty(s,'_source',o.index');
                y=getProperty(s,propertyName,o.index')';
                if not(isnan( nanmean(y)))
                    [~, context]=getProperty(s,'_context',o.index');
                    s.par.timeSerie=1;
                    [~, indexTime]=sort(time,'ascend');
                    [s info]=train(s,y(indexTime),['_pred' propertyName(2:end) label],o.index(indexTime),time(indexTime));
                    infosave{i}=info;
                    
                    %Save results
                    f=fopen(resultFile,'w');
                    for j=1:length(y)
                        if not(isnan(time(indexTime(j))))
                            fprintf(f,'%.4f\t%.4f\t%s\t%s\t%s\t%s\t%s\n',y(indexTime(j)),info.pred(indexTime(j)),datestr(time(indexTime(j))),context{indexTime(j)},num2str(s.x(o.index(indexTime(j)),:)),id(indexTime(j)),source2{indexTime(j)});
                        end
                    end
                    fclose(f);
                    f=fopen([pathRes label 'Info.txt'],'w');
                    fprintf(f,'%s',info.results);
                    fclose(f);
                    f=fopen(['results.txt'],'a');
                    fprintf(f,'%s\t%.4f\t%d\t%.4f',label,info.p,info.n,info.r);
                    fprintf(f,'\t%.4f\t%.4f',info.timep,info.timer);
                    fprintf(f,'\t%.4f\t%.4f\n',info.time4p,info.time4r);
                    fclose(f);
                    
                    %Can be removed later....
                    clear('indexR');
                    for j=1:length(s.fwords);
                        indexR(j)=not(isempty(findstr(s.fwords{j},['_' lower(label) ])>0));
                    end
                    s=remove_words_now(s,find(indexR));
                    
                    saveSpace(s,spaceFile);
                    clear s;
                end
            end
        end
    save('infosave','infosave')
end

function s=extractContextOne(s,targetWord,source);
%targetWord='because';
path='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/Corpus/journals/';
if not(exist(path));
    path='/lunarc/nobackup/users/sverker/journals/';
end
j=0;
sum=0;
i=0;
for k=1:length(source)
    D=dir([path source{k}]);
    %path='';
    f=fopen([path source{k}],'r');
    t=fgets(f);
    t=fgets(f);
    while not(feof(f))
        i=i+1;
        [d t f nchar]=getData(f,t);
        d.source=source{k};
        if findstr(lower(d.context),lower(targetWord))>0
            [s j]=extractContext(s,targetWord,d.context,d,j);
        end
        sum=sum+nchar;
        %fprintf('%s %s\n\n',d.publish_start,d.text)
        if even(i+1,2000)
            fprintf('%s %.4f %s\n',source{k},sum/D.bytes,targetWord)
        end
    end
    fclose(f);
end

function [d t f sum]=getData(f,t);
j=0;
sum=0;
for i=1:19
    if i==19
        delimiter=char(10);
    else
        delimiter=',';
    end
    [a{i} t f]=getNext(t,f,delimiter);
    sum=sum+length(a{i});
    j=j+1;
    %fprintf('%d %s\n',j,a{i});
    if length(t)==0
        t=fgets(f);
    end
end
%article_id,"headline","lead","body",language_code,"publish_start","publish_url","authors",link_id,"date_created",deleted,text_revision,headline_hash,lead_hash,body_hash,fulltext_hash,original_id,ext_id,"ext_ref"
%<p>Write to Matt Bradley at matt.bradley@dowjones.com</p>",1804,"2012-01-17 12:00:00","http://online.wsj.com/article/SB10001424052970203735304577165134204402866.html","<h3>By MATT BRADLEY</h3>",NULL,"2012-01-17 14:33:25",0,0,-7856321737443516012,NULL,-7195907774066602933,-6160176850503871469,0,NULL,NULL
%nytimes-87-07.csv
%article_id,"headline","lead","body",language_code,"publish_start","publish_url","authors",link_id,"date_created",deleted,text_revision,headline_hash,lead_hash,body_hash,fulltext_hash,original_id,ext_id,"ext_ref"
%nytimes-08-13.csv
%article_id,"headline","lead","body",language_code,"publish_start","publish_url","authors",link_id,"date_created",deleted,text_revision,headline_hash,lead_hash,body_hash,fulltext_hash,original_id,ext_id,"ext_ref"

d.id=a{1};
headline=removeNull(a{2});
lead=removeNull(a{3});
body=removeNull(a{4});
d.context=[headline ' ' lead ' ' body];

d.languagecode=str2double(a{5});
d.date=a{6};
d.time=datenum(a{6});
publish_url=a{7};
authors=a{8};
link_id=a{9};
date_created=a{10};
deleted=a{11};
text_revision=a{12};
headline_hash=a{13};
lead_hash=a{14};
body_hash=a{15};
fulltext_hash=a{16};
original_id=a{17};
ext_id=a{18};
ext_ref=a{19};
if d.languagecode==1804
elseif d.time<datenum('2014-01-01 16:37:15') & d.time>datenum('1979-01-01 16:37:15') & (not(isempty(strfind(publish_url,'www'))) | not(isempty(strfind(publish_url,'http'))))
else
    stop
end


function t=removeNull(t)
if strcmpi(t,'NULL'); t='';end
t=regexprep(t,'<p>',' ');
t=regexprep(t,'</p>',' ');
t=regexprep(t,'\\"','"');
t=regexprep(t,'&apos;','''');

function [a t f]=getNext(t,f,delimiter)
i=findstr(t,delimiter);
i2=[];
while t(1)=='"' & isempty(i2)
    t=[t fgets(f)];
    i2=findstr(regexprep(t,'\\"','  '),['"' delimiter]);
    if length(i2)>1 & i2(1)==1; i2=i2(2);end
    i=i2+1;
end
comma=isempty(i);
if isempty(i)
    a=t;t='';
else
    a=t(1:i-1);
    t=t(i+1:end);
end

if a(1)=='"';a=a(2:end);end
if length(a)>0 & a(end)=='"';a=a(1:end-1);end

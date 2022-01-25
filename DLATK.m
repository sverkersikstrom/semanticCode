function [s,info,xnorm]=DALTK(s,y,text,labels,dPredict);
if nargin==0
    s=getSpace;
end
if nargin<5
    dPredict=[];
end
if ischar(labels) labels={labels};end

% #Extract a 1gram feature table, vilket skapar: 'feat$1gram$msgs$user_id$16to16?
% par.DLATKparameter1='./dlatkInterface.py -d space2 -t msgs -c user_id --add_ngrams -n 1';%DLATK1    
% 
% #Filter to features mentioned by at least 10% of groups  (vilket skapar:  'feat$1gram$msgs$user_id$16to16$0_05'
% par.DLATKparameter2='./dlatkInterface.py -d space2 -t msgs -c user_id -f 'feat$1gram$msgs$user_id$16to16' --feat_occ_filter --set_p_occ 0.05';%DLATK2
%  
% #Makes a predicion model
% par.DLATKparameter3='./dlatkInterface.py -d space2 -t msgs -c user_id --group_freq_thresh 1 -f 'feat$1gram$msgs$user_id$16to16$0_05' --outcome_table outcomes --outcomes swlstotal hilstotal --combo_test_reg --feat_selection magic_sauce --model ridgehighcv --folds 10 --save_model --picklefile ~/msgs_tsBERThils_swls_OK_TEST14aug_2.pickle';%DLATK3

%par.DLATKparameter1='./dlatkInterface.py -d space2 -t msgs -c user_id --add_ngrams -n 1';%DLATK feature parameters (e.g. ./dlatkInterface.py -d dla_tutorial -t msgs_andy -c user_id --add_ngrams -n 1)
%par.DLATKparameter2='./dlatkInterface.py -d space2 -t msgs -c user_id --group_freq_thresh 1 -f ''feat$1gram$msgs$user_id$16to16'' --outcome_table outcomes --outcomes swlstotal hilstotal --combo_test_reg --feat_selection magic_sauce --model ridgehighcv --folds 10';%DLATK parameters (e.g., ./dlatkInterface.py -d lund_bert -t msgs -c user_id --group_freq_thresh 1 -f ''feat$1gram$msgs$user_id$16to16'' --outcome_table outcomes --outcomes swlstotal hilstotal --combo_test_reg --feat_selection magic_sauce --model ridgehighcv --folds 10)

%Detta kod sparar en model (baserad p? satisfaction ord):
%./dlatkInterface.py -d lund_bert -t msgs_ts -c user_id --group_freq_thresh 1 -f 'feat$BERT_bas_meL8L9L10L11$msgs_ts$user_id$16to16' --outcome_table outcomes --outcomes swlstotal hilstotal --train_reg --feat_selection pca --model ridgehighcv --save_model --picklefile ~/msgs_tsBERThils_swls_OK_TEST14aug_2.pickle

%Och detta anrop applicerar ovan sparad model p? ett nytt feature table (allts? harmoni orden); och det skapas en tabell i Mysql som heter p_ridg$swlstotal_hilstotal 
%                     ./dlatkInterface.py -d space2 -t msgs_th -c user_id --group_freq_thresh 1 -f ''feat$1gram$msgs$user_id$16to16''  --predict_regression_to_outcome_table swlstotal_hilstotal --load --picklefile ~/msgs_tsBERThils_swls_OK_TEST14aug_2.pickle

DLATKparameter=[];
if not(isempty(s.par.DLATKparameter1)) DLATKparameter=[DLATKparameter {s.par.DLATKparameter1}]; end
if not(isempty(s.par.DLATKparameter2)) DLATKparameter=[DLATKparameter {s.par.DLATKparameter2}]; end
if not(isempty(s.par.DLATKparameter3)) DLATKparameter=[DLATKparameter {s.par.DLATKparameter3}]; end

xnorm=NaN;
d.db='space2';
d.msgs='msgs';
d.user_id='user_id';
d.labels=labels;
d.featureTable='';
d.picklefile=['~/pred' labels{1} '.pickle'];
d.results='';
d.r=NaN;
d.p=NaN;
d.pred=NaN;

%if isempty(findstr(DLATKparameter{end},'--picklefile')) DLATKparameter{end}=[DLATKparameter{end} ' --picklefile ' d.picklefile ];end



d=getD(s.par.DLATKparameter1,d);

%Make struct
m.message_id=(1:length(y))';
m.message=text;%getText(s,wordsIndex,[],0)';
m.(d.user_id)=(1:length(y))';

if not(isempty(labels))
    o.user_id=(1:length(y))';
    for i=1:length(labels)
        o.(regexprep(labels{i},'_pred',''))=y(:,i);
    end
    
    if 0 %nargin==0
        %Read csv file to struct
        m=csv2struct(d.msgs);
        o=csv2struct(d.outcomes);
    end
    
    %Copy struct to dB
    struct2db(d.msgs,m,d.db)
    struct2db(d.outcomes,o,d.db)
end

if not(isempty(dPredict))
    fprintf(dPredict.predict)
    system(dPredict.predict);
    fprintf('Reading from incorrect table: %s\n',d.msgs)
    pred=db2struct(getDb,d.msgs);
    info.pred=pred.id;
    return
end

for i=1:length(DLATKparameter)
    d=callDLATK(DLATKparameter{i},d);
end

d.predict=['./dlatkInterface.py -d ' d.db ' -t ' d.msgs ' -c ' d.user_id ' --group_freq_thresh 1 -f ' d.featureTable ' --predict_regression_to_outcome_table ' 'swlstotal_hilstotal' ' --load --picklefile ' d.picklefile ];

info.model='';
info.DLATK=d;
info.specialword=4;
info.results=d.results;
info.r=d.r;
info.p=d.p;
info.pred=d.pred;
[s,~,propertySave]=addX2space(s,labels{1},NaN(1,s.Ndim),info,0, ['DLATK model of ' labels{1}]);

showOutput({info.results},['Train: ' ])


function d=callDLATK(parS,d);
if isempty(parS) return;end
%Map variables
[d parS]=getD(parS,d);

parMod=cell2string(parS');
fprintf('DLATK: %s\n',parMod);

outFile='tmp';
outFile='outfileResults.txt';
system([parMod ' > ' outFile]);

%Find featureTable in outfileFeature.txt
f=fopen(outFile,'r');
d.featureTable='';

while not(feof(f))
    text=fgets(f);
    if not(feof(f))
        d.results=[d.results text];
    end
    i=findstr(text,'''R'':');
    if not(isempty(i));
        %text(i+1:end-1)
        d.r=str2num(text(i+4:end-2));
    end

    %SQL QUERY: ALTER TABLE feat$BERT_bas_meL8L9L10L11$msgs_ts$user_id$16to16 ENABLE KEYS
    i=findstr(text,'SQL QUERY: ALTER TABLE');
    if not(isempty(i));
        i2=findstr(text,'ENABLE KEYS');
        d.featureTable=['''' text(24:i2-2) ''''];
        
        i3=find(strcmp(parS,'-f'));
        if not(isempty(i3));
            fprintf('Found featuretable: %s\n',d.featureTable);
            fprintf('Adding featuretable: %s\n',d.featureTable);
            parS{i+1}=d.featureTable;
        end
        
    end
end
fclose(f);


function struct2db(table,d,db_instance);
if nargin<3
    db_instance = 'DB_INSTANCE';
end
dB=getDb(0,db_instance);

%Drop table
exec(dB,['DROP TABLE ' table],0);

%Upload to dB
struct2Db(dB,table,d)

function d=csv2struct(table)
%read csv
[cell, data, dim, labels]=textread2([table '.csv'],0);

%Cell2struct
d=cell2struct(cell,data,labels);

function d=cell2struct(cell,data,labels)
%Cell 2 struct
d=[];
for i=1:length(labels)
    if not(isnan(data(1,i)))
       eval(['d.' labels{i} '=data(:,' num2str(i) ');']);
    else
       cell(:,i)=regexprep(cell(:,i),'"','');
       eval(['d.' regexprep(labels{i},'"','') '=cell(:,' num2str(i) ');']);        
    end
end


function [d parS]=getD(parS,d);
%   ./dlatkInterface.py -d space2 -t msgs -c user_id 
if isempty(findstr(parS,' -c ')) parS=[' -c ' num2str(d.user_id) ' ' parS ];end
if isempty(findstr(parS,' -t ')) parS=[' -t ' num2str(d.msgs) ' ' parS ];end
if isempty(findstr(parS,' -d ')) parS=[' -d ' num2str(d.db) ' ' parS ];end
if isempty(findstr(parS,'dlatkInterface')) parS=['./dlatkInterface.py ' parS];end
    
parS=textscan(parS,'%s');parS=parS{1};

i=find(strcmp(parS,'-d'));
if not(isempty(i)); d.db=parS{i+1};end

i=find(strcmp(parS,'-t'));
if not(isempty(i)); d.msgs=parS{i+1};end

i=find(strcmp(parS,'-c'));
if not(isempty(i)); d.user_id=parS{i+1};end

i=find(strcmp(parS,'-f'));
if not(isempty(i)); 
    d.featureTable=parS{i+1};
    parS{i+1}=d.featureTable;
end

i=find(strcmp(parS,'--outcome_table'));
if not(isempty(i)); d.outcomes=parS{i+1};else d.outcomes='outcomes';end


function d=dTest
%Create small test dS
N=3;
dS.message_id=1:N;
for i=1:N
    dS.message{i}='A';
end
dS.user_id=1:N;
dS.wh1ws2th3ts4=ones(1,N);
dS.Study=2*ones(1,N);

function OLD_BERT
if 0
    %Do DALTK BERT: --add_sent_tokenized 
    %./dlatkInterface.py -d lund_bert -t msgs_ts --group_freq_thresh 1 --add_sent_tokenized
   %parMod1b=['./dlatkInterface.py -d ' db ' -t ' msgs ' -c user_id --add_ngrams -n 1'];    
    parMod1 =['./dlatkInterface.py -d ' d.db ' -t ' d.msgs ' --group_freq_thresh 1 --add_sent_tokenized'];
    fprintf('DLATK STEP 1: %s\n',parMod1);
    system(parMod1);
    
    %Do DALTK BERT: --add_bert &> outfileFeature.txt 
    %./dlatkInterface.py -d lund_bert -t msgs_ts --group_freq_thresh 1 --add_bert &> outfileFeature.txt    
   %parMod2b=['./dlatkInterface.py -d ' db ' -t ' msgs ' -c user_id -f 'feat$1gram$msgs$user_id$16to16' --feat_occ_filter --set_p_occ 0.05']; 
    parMod2 =['./dlatkInterface.py -d ' d.db ' -t ' d.msgs ' --group_freq_thresh 1 --add_bert '];
    fprintf('DLATK STEP 2: %s\n',parMod2);
    outFile='tmp';
    outFile='outfileFeature.txt';
    system([parMod2 ' &> ' outFile]);
    
end




function scriptMarie
file='flashback.txt';
addpath('/Users/sverkersikstrom/Dropbox/semantic/semanticCode/')
if 0 %Calculates properties
    file=properties2file
end
if 1 %Calculate first usage
    summarize(file)
end
if 1 %Select blogs to use
    selectflashback(file)
end
if 1 %Mk statistics
    StatisticsFlashback(file)
end

function file=properties2file
addpath('/Users/sverkersikstrom/Dropbox/ngram/')
s=getNewSpace('spaceSwedish2');
%liwc='_predvalencestenberg _textbyword _predabstract _liwcfunctionwords _liwckkagency _liwckkcommunion _liwckkinteractive2nd _liwckk2ndsingular _liwckk2nplural _liwckkagency	_liwckkcommunion	_liwckkinteractive2nd	_liwckk2ndsingular	_liwckk2nplural	_liwckkallpronomen	_liwckkneutralpronomen	_liwckkopersonligapronomen	_liwckksadness	_liwckksenses _liwckksee	_liwckkauditory	_liwckktactile	_liwckkolfactory	_liwckksocial	_liwckkcommunication	_liwckkotherreferences	_liwckkfriends	_liwckkfamily	_liwckkhumans _liwckkjob	_liwckkachivements	_liwckk1stsingular	_liwckk1stplural	_liwckktotal2nd	_liwckk3rdsingular	_liwckkaffect	_liwckkposemotion	_liwckkoptimism	_liwckknegemotions	_liwckkanger	_liwckkvisual	_liwcstenbergnegative	_liwcstenbergpositive	_liwcfunctionwords	_liwcpersonalpron	_liwc1stsingular	_liwc1stplural	_liwctotal2nd	_liwc3rdsingular	_liwc3rdplural	_liwcimpersonalpron	_liwcarticles	_liwccommonverbs	_liwcauxiliaryverbs	_liwcpasttense	_liwcpresenttense	_liwcfuturetense	_liwcadverbs	_liwcprepositions	_liwcconjunctions	_liwcnegations	_liwcquantifiers	_liwcnumbers	_liwcswearwords	_liwctotalpron	_liwcsocialprocesses	_liwcfamily	_liwcfriends	_liwchumans	_liwcaffectiveprocesses	_liwcpositiveemotion	_liwcnegativeemotion	_liwckkanxiety	_liwccognitiveprocesses	_liwcinsight	_liwccausation	_liwcdiscrepancy	_liwctentativeness	_liwccertainty	_liwcinhibition	_liwcinclusion	_liwcexclusion	_liwcperceptualprocesses	_liwcseeing	_liwchearing	_liwcfeeling	_liwcbiologicalprocesses	_liwcbody	_liwchealth	_liwcsexual	_liwcingestion	_liwcrelativity	_liwcmotion	_liwcspace	_liwctime	_liwcwork	_liwcachievement	_liwcleisure	_liwchome	_liwcmoney	_liwcreligion	_liwcdeath	_liwcassent	_liwcnon';
%NOT USE _kk1stsi _kk1stpl _3rdplur _insight _causati _swearwo _negativ _certain _kkanger _positive _death
liwc='_nwords _liwckk1stsingular _liwckk1stplural _liwc3rdplural _liwcinsight _liwccausation _liwcswearwords _liwcnegativeemotion _liwccertainty _liwckkanger _liwcpositiveemotion _liwcdeath';
properties=strread(liwc,'%s');
index=word2index(s,properties);
file='flashback.txt';
d.textColumn=4;
d=getProperty2file(s,index,file,d) %Calculate properites and save in file


function summarize(file)
savefile=['summarize' regexprep(file,'.txt','.mat')];
if exist(savefile)
    return
end
f=fopen(['results' file],'r','n','utf-8');
t=fgets(f);
t=t(t>0);
d.hash = java.util.HashMap;
d.user=[];
row=0;
while not(feof(f))
    row=row+1;
    if even(row,1000) fprintf('.'); end
    try
        t=fgets(f);
        t=t(t>0);
        data=textscan(t,'%s','delimiter',char(9));
        data=data{1}';
        i=d.hash.get(lower(data{4}));
        if isempty(i)
            i=length(d.user)+1;
            d.N(i)=0;
            d.tstart(i)=10^20;
            d.hash.put(lower(data{4}),i);
        end
        d.N(i)=d.N(i)+1;
        time=datenum(data{3});
        d.tstart(i)=min(time,d.tstart(i));
        d.user{i}=data{4};
    catch
        try
            fprintf('Failed %d %s\n',row,data{3});
        catch
            fprintf('Failed\n');
        end
    end
end
save(savefile,'d')
1;


function selectflashback(file)
restart=0;
if exist(['Selected' file]) & not(restart)
    return
end
fileSummarize=['summarize' regexprep(file,'.txt','.mat')];
load(fileSummarize)
f=fopen(['results' file],'r');
t=fgets(f);
t=t(t>0);
fout=fopen(['Selected' file],'w');
fprintf(fout,'DayOnFlashback\t%s',t);
row=0;
while not(feof(f))
    try
        row=row+1;
        if even(row,1000) fprintf('.'); end
        t=fgets(f);
        t=t(t>0);
        data=textscan(t,'%s','delimiter',char(9));
        data=data{1}';
        Nwords=str2double(data{5});
        time=datenum(data{3});
        i=d.hash.get(lower(data{4}));
        tnow=time-d.tstart(i);
        if d.N(i)>10 & d.N(i)<500 %& Nwords>10
            fprintf(fout,'%.3f\t%s',tnow,t);
        end
    catch
        fprintf('Failed %d %s\n',row,data{5})
    end
end
fclose(f);fclose(fout);

function StatisticsFlashback(file)
file=['Selected' file];
matFile='dataflashback.mat';
tic
if exist(matFile)
    load(matFile)
else
    [words, data, dim, labels]=textread2(file,0);%,100000);
    fprintf('saving...')
    %save(matFile,'-v7.3')
    fprintf('done\n')
end
toc

fprintf('\nCalculating correlations\n')
user=unique(words(:,5));
r=NaN(length(user),length(labels));
for i=1:length(user)
    index=find(strcmpi(user{i},words(:,5)));
    for j=1:length(labels)
        [r(i,j) p(i,j)]=nancorr(data(index,1),data(index,j));
    end
end
for j=1:length(labels)
    [sig p2(j)]=ttest(r(:,j));
    fprintf('%s\t%.4f\t%.4f\n',labels{j},p2(j),nanmean(r(:,j)))
end
toc
1;


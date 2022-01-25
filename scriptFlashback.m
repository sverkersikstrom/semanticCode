function d=flashbackAnalysis(s,index,file,d)


%This script maps calculates LIWC scores for flashback.txt and prints this
%to flashbackLIWC.txt

%Open space
if nargin<1
    addpath('/Users/sverkersikstrom/Dropbox/ngram/')
    s=getNewSpace('spaceSwedish2');
end

if nargin<2
    liwc='_predvalencestenberg _textbyword _predabstract _liwcfunctionwords _liwckkagency _liwckkcommunion _liwckkinteractive2nd _liwckk2ndsingular _liwckk2nplural _liwckkagency	_liwckkcommunion	_liwckkinteractive2nd	_liwckk2ndsingular	_liwckk2nplural	_liwckkallpronomen	_liwckkneutralpronomen	_liwckkopersonligapronomen	_liwckksadness	_liwckksenses _liwckksee	_liwckkauditory	_liwckktactile	_liwckkolfactory	_liwckksocial	_liwckkcommunication	_liwckkotherreferences	_liwckkfriends	_liwckkfamily	_liwckkhumans _liwckkjob	_liwckkachivements	_liwckk1stsingular	_liwckk1stplural	_liwckktotal2nd	_liwckk3rdsingular	_liwckkaffect	_liwckkposemotion	_liwckkoptimism	_liwckknegemotions	_liwckkanger	_liwckkvisual	_liwcstenbergnegative	_liwcstenbergpositive	_liwcfunctionwords	_liwcpersonalpron	_liwc1stsingular	_liwc1stplural	_liwctotal2nd	_liwc3rdsingular	_liwc3rdplural	_liwcimpersonalpron	_liwcarticles	_liwccommonverbs	_liwcauxiliaryverbs	_liwcpasttense	_liwcpresenttense	_liwcfuturetense	_liwcadverbs	_liwcprepositions	_liwcconjunctions	_liwcnegations	_liwcquantifiers	_liwcnumbers	_liwcswearwords	_liwctotalpron	_liwcsocialprocesses	_liwcfamily	_liwcfriends	_liwchumans	_liwcaffectiveprocesses	_liwcpositiveemotion	_liwcnegativeemotion	_liwckkanxiety	_liwccognitiveprocesses	_liwcinsight	_liwccausation	_liwcdiscrepancy	_liwctentativeness	_liwccertainty	_liwcinhibition	_liwcinclusion	_liwcexclusion	_liwcperceptualprocesses	_liwcseeing	_liwchearing	_liwcfeeling	_liwcbiologicalprocesses	_liwcbody	_liwchealth	_liwcsexual	_liwcingestion	_liwcrelativity	_liwcmotion	_liwcspace	_liwctime	_liwcwork	_liwcachievement	_liwcleisure	_liwchome	_liwcmoney	_liwcreligion	_liwcdeath	_liwcassent	_liwcnon';
    %NOT USE _kk1stsi _kk1stpl _3rdplur _insight _causati _swearwo _negativ _certain _kkanger _positive _death
    %liwc='_liwckk1stsingular _liwckk1stplural _liwc3rdplural _liwcinsight _liwccausation _liwcswearwords _liwcnegativeemotion _liwccertainty _liwckkanger _liwcpositiveemotion _liwcdeath';
    properties=strread(liwc,'%s');
else
    properties=s.fwords(index);
end

if nargin<3
    file='flashback.txt';
end

if nargin<4
    d.feof=0;
end

%Parameters
fileInfo=dir(file);
outfile='flashbackLIWC.txt';

%Open files
if not(isfield(d,'f'))
    d.f=fopen(file,'r','native','UTF-8');
    restart=0;
    i=0;Nchar=0;
    if restart & exist(outfile) %Do if you interput the code and want to restart
        d.fout=fopen(outfile,'r','native','UTF-8');
        while not(feof(d.fout))
            fgets(d.fout);fgets(d.f);i=i+1;
        end
        fclose(d.fout);
        d.fout=fopen(outfile,'a','native','UTF-8');
    else
        d.fout=fopen(outfile,'w','native','UTF-8');
        %Print headers
        out=sprintf('i\tnr\tdate\tid\t%s\t');
        for j=1:length(properties)
            out=[out sprintf('%s\t',properties{j})];
        end
        fprintf('%s\n',out);
        fprintf(d.fout,'%s\n',out);
    end
end



%getText(s,word2index(s,properties{5}));
tstart=now;
Nstep=1000;
while not(feof(d.f)) %& i<10
    for j=1:Nstep
        i=i+1;
        t{j}=fgets(d.f);
        Nchar=Nchar+length(t{j});
        tmp=textscan(t{j},'%s','delimiter',char(9));
        data3(j,:)=tmp{1};
    end
    s.par.reverseOrder=1;
    res=getProperty(s,data3(:,4)',properties);
    for k=1:Nstep
        out=sprintf('%d\t%s\t%s\t%s\t%s\t',i+k-Nstep,data3{k,1},data3{k,2},data3{k,3});
        for j=1:length(properties)
            out=[out sprintf('%.4f\t',res(k,j))];
        end
        if i-Nstep<10
            fprintf('%s\n',out);
        end
        if even(i+k,100)
            fprintf('%.6f\t%.1f\n',Nchar/fileInfo.bytes,fileInfo.bytes*(now-tstart)/Nchar);
        end
        fprintf(d.fout,'%s\n',out);
    end
end
now-tstart
fclose(d.f);
fclose(d.fout);
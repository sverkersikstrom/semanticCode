function s=demoFile(s,db)
%Load new space from harddrive
if nargin<1
    %s=getNewSpace('spaceSwedish2')
    %space='spaceenglish2';
    s=getNewSpace('spaceenglish')
    %s=getNewSpace('space_allmansum3')
end

if nargin<2
    db=0;
end
if isempty(s); s.par=getPar;end

resetRandomGenator(s);
N=2;
[ref,var,text]=mkTestData(s,1,N);
%text={'as?df ad?fad','sd?fa as?dfa'}
[ref2,var2,text2]=mkTestData(s,2,N);

if db 
    %New function for keeping the space in data base (called "space2")
    %The first time you run this, it will put the language space in the
    %databse, which will taka while (up to an hour). Then it will go
    %faster. Ten documents/qustions are keept in internal memory for quick
    %references. Then we also save to a file for quick load. Otherwise we
    %load from the datbase
    document='test';%This is the name of the document/or question. 
    lang=s.filename;%This will be the name of the database where language space is stored. The document is stored in "lang-document-t"
    lang=regexprep(lang,'\.mat','');%Remove .mat extension
    type='update';%Update data. 
    type='clear';%Clear all data, and load them from again from dB. 
    type='';%Default. reads word vectors in the the s-stucture. 
    tic;%For debuggin
    s2=[];
    par=getPar; %Here we set parameters.
    s2=getSfromDB(s2,lang,document,ref,text,type,par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
    s2=getSfromDB(s2,lang,document,ref2,text2);%Does the same for index.
    index=word2index(s2,ref);
    index2=word2index(s2,ref2);
    toc;%For debugging
    tmp2=getX(s2,index);%For debugging
    s=s2;%For debugging
else
    tic;
    [s userId index]=setProperty(s,ref,var,text);
    [s userId2 index2]=setProperty(s,ref2,var2,text2);
    toc
    tmp=getX(s,index);
end


userNames=[ref ref2];userNames{1}='Sverker';


labels=[];
%plotProperty=[];
toc

%plotTestType{1}='Text-Number';
%plotTestType{1}='Text-Evaluation';
%plotCloudType='category';
s.par.plotCloudType='words';
s.par.plotCluster=0;
s.par.plotWordcloud=1;
numbers=[];
index=[index index2];
par=[];
[out2,h2,s]=plotWordcount(s,index,numbers,par,labels,userNames);
1;

numbers{1}=[1:length(index)];%must be length(index) + length(index2)
%3*2*2*4=48
for i=1:3
    plotCloudTypeS={'users','words','category'};
    s.par.plotCloudType=plotCloudTypeS{i};
    for s.par.plotCluster=0:1
        for s.par.plotWordcloud=0:1
            %for j=1:4
            %    plotTestTypeS={'Text-Text','Text-Number','Text-Categories','Text-Evaluation'};
                %plotTestTypeS={'semanticTest','train','frequency','property'};
             %   plotTestType{1}=plotTestTypeS{j};
               % tic;
                fprintf('%s %d %d %s\t',plotCloudType,plotCluster,plotWordcloud,num2str(numbers{1}));
                [out2,h2,s]=plotWordcount(s,index,numbers);
               % toc;
              %  drawnow;
                %input('press enter')
             %   1;
            %end
        end
    end
end
stop

%1- Plot
%2- Theme
%3- Type
%4- Compare

%set default values
s.par.plotCloudType = 'words';
s.par.plotCluster = 0;
s.par.plotWordcloud = 1;
%plotTestType = [];
numbers = [];



% Plot
%1.1 plot->words
[out1,h1,s]=plotWordcount(s,index,numbers);

%1.2 plot->users
s.par.plotCloudType = 'users';%SS Fine - but we need to plot something nice here....
[out2,h2,s]=plotWordcount(s,index,numbers);

%1.3 plot->category
s.par.plotCloudType = 'category';
[out3,h3,s]=plotWordcount(s,index,numbers);


% Themes
%2.1 Theme->off
[out4,h4,s]=plotWordcount(s,index,numbers);

%2.2 Theme->on
s.par.plotCluster = 1;%SS this space does not have LIWC categoreis
[out5,h5,s]=plotWordcount(s,index,numbers);


%Type
%3.1 Type->Wordcloud
[out6,h6,s]=plotWordcount(s,index,numbers);

%3.2 Type->Scale
s.par.plotWordcloud = 0;
[out7,h7,s]=plotWordcount(s,index,numbers);

%Compare
%4.1 Compare->None
%plotTestType=[];
numbers=[];plotProperty=[];labels=[];
[out8,h8,s]=plotWordcount(s,index,numbers);


%Please mention or set parameters if i miss anything for above type. I will put if condition on clicking of each button on above type.
%if have time and write others as well. so i can imlement as per this in excelServer and we will live in next couple of day
stop

function [ref,var,text]=mkTestData(s,k,N);
if nargin<3 N=10;end
for i=1:N
    ref{i}=['_UserReference' num2str(k) 'i' num2str(i)];
    var{i}='_text';
    text{i}='';
    for j=1:3
        text{i}=[text{i} ' ' s.fwords{fix(rand*1000)+1}];
    end
end


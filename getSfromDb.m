function [s,index]=getSfromDB(s,lang,documentName,textId,document,type,par,textIdentifier)
%Creates an s-structure based on the words in document
%space2: Database name
%spaceEnglish: Stores the langagues representation 
%spaceEnglish-DocumentId: Stores th
persistent checkOnce 
persistent d;   
%w='_frequency';sTmp=getSfromDB(initSpace,'sv','test99',{'_ref1'},{w},'update');i=word2index(sTmp,w);sTmp.fwords{i};sTmp.x(i,1:10)
%fetch(getDb,['select `id`,`xdata`,`info`,`f`,`wordclass` from  `space2`.`spaceSwedish2` where   `id` = ''' t{8} ''''  ])
   
if isempty(checkOnce) %Add new function to language files. Only run if a new function is added
    addNewFunctions2dB;
    checkOnce=1;
end

if nargin<1
    s=[];
end
if nargin<2
    lang='en';
end
if length(lang)<=4
    lang=getSpaceName(lang);
end

if nargin<3
    documentName='';
end
if nargin<4
    textId={'_user1text1','_user2text1'};
end
if nargin<5
    document={'a i not','at be'};
end
if nargin<6
    type='';
end
if nargin<7
    if isfield(s,'par')
        par=s.par;
    else
        par=getPar;
    end
end
if nargin<8
    textIdentifier={};
end
if isempty(lang)
    if isempty(s); s=initSpace;end
    s.error='Error: Language is not specified!\n';
    fprintf(s.error);
    index=NaN(1,length(textId));
    return
end
lang=regexprep(lang,'\.mat','');
documentName=regexprep(documentName,'\.mat','');
if isempty(d)
    d=config;
    d.file=[];
end
file=[d.spaceCache lang '-' documentName '.mat'];
indexFile=find(strcmp(file,d.file));
if strcmpi(type,'clear');%Do not think this is used
    try;delete(d.file{indexFile});end %Delete cached file
    d=rmSfromD(d,indexFile); %Delete memory cach
    dbSpace(lang,documentName,'clear',[],[],[],'t');
    indexFile=find(strcmp(file,d.file));
elseif strcmpi(type,'set');%Do not think this is used
    d.s{indexFile}=s;
    return
end
 
useCach=1; 
if not(isempty(s)) & length(s.fwords)>0
elseif useCach & not(isempty(indexFile))
    %s-space is in memory, using it!
    s=d.s{indexFile};
elseif useCach & exist(file)
    %Load saved space file
    load(file)
    s.handles=getHandles;
else %Init-file 
    initfile=[d.spaceCache lang '-initsmallest.mat'];
    if exist(initfile)
        %Load existing init-file
        load(initfile);
    else
        %Create new init-file
        s=initSpace;
        if not(isfield(s,'xmean2'))
            [s2.x,s2.info,s2.f,s2.fwords,s2.wordclass] =dbSpace(lang,'','get',{'_xmean2','_nwords','_nwordsfound','_frequency','_predvalence','_predvalencestenberg'});
            s=mergeSpace(s,s2);
            [s.xmean2] =dbSpace(lang,'','get',{'xmean2'});
        end
        s=rmfield(s,'handles');
        s.Ndim=length(s.xmean2);
        save(initfile,'s');
    end
    s.handles=getHandles;
    s.Ndim=length(s.xmean2);
end

%Set some variables
s.par=par;
s.languagefile=lang;
s.filename=documentName;

%Add identifiers from database if missing
if isempty(textId)
    indexText=[];
else
    indexText=word2index(s,textId);
end
updateWord=[];
nanIndexText=zeros(1,length(indexText));
update=not(isnan(indexText));
addNorm=zeros(1,length(indexText));
if strcmpi(type,'updateAll')
    %Update everything
    nanIndexText=ones(1,length(indexText));
    updateWord=textId;
elseif strcmpi(type,'update')
    %Update missing (NaN) identifier
    nanIndexText(isnan(indexText))=1;
    
    %Add updates to identifier with new texts
    add=zeros(1,length(update));
    for i=find(update)
        add(i) =not(strcmp(document{i},getText(s,textId{i})));
    end
    %Always add cluster, predictions and norms (3,4 and 13)
    w='';
    for i=find(update)
        if isfield(s.info{indexText(i)},'specialword')
            specialword= s.info{indexText(i)}.specialword;
            if specialword==3 | specialword==4 | specialword==7 | specialword==13
                if isfield(s.info{indexText(i)},'date') & strcmp(s.info{indexText(i)}.date,cashIdDate(textId{i}))
                    nanIndexText(i)=0;add(i)=0;%In cash, no reading from database!
                else
                    w =[w ' `id` = ''' regexprep(textId{i},'''','\\''') ''' OR'];
                end
            end
        end
    end
    
    if length(w)>0
        w=[ w(1:max(0,end-2)) ];
        query = ['select `id`,`datestr` from  `space2`.`' lang '-Models` where  ' w ];
        res=[];
        try
            res = fetch(getDb,query);
        catch
            queryCreate=['CREATE TABLE `space2`.`' lang '-Models` ( `id` char(51) NOT NULL, `datestr` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;'];
            exec(getDb,queryCreate,0);
            res = fetch(getDb,query);
        end
        for i=1:size(res,1)
            j=find(strcmpi(textId,res{:,1}));
            if not(isempty(j))
                cashIdDate(textId{j},res{i,2});
                if isfield(s.info{indexText(j)},'date') & strcmp(s.info{indexText(j)}.date,res{i,2})
                    nanIndexText(j)=0;add(j)=0;%Do not update
                else %Different dates, update
                    s.info{indexText(j)}.date=res{i,2};
                    add(j)=1;
                    addNorm(j)=1;
                    updateWord=[updateWord textId(j)];
                end
            end
        end
    end
    nanIndexText=[nanIndexText | add];
end

%If not identifiers in space, add them to space, and save to database
if strcmpi(type,'merge')
    [s2.x,s2.info,s2.f,s2.fwords,s2.wordclass]=dbSpace(lang,'','get',textId);
    if isfield(par,'specialword') %Randomly seleced words = 100
        for i=1:length(s2.info)
            s2.info{i}.specialword=par.specialword;
        end
    end
    s=mergeSpace(s,s2);
elseif not(isempty(find(nanIndexText)))
    %Check if words are in space
    words=[];
    
    
    
    if isempty(textIdentifier) 
        clear textIdentifier;
        textIdentifier(find(nanIndexText))={'_text'};
    end
    for i=find(nanIndexText);
        [indexWord word1 s]=text2index(s,document{i});
        %textIdentifier{i}='_text';
        words=[words word1'];
    end
    words=unique(words);
    index=word2index(s,words);
    updateIndex=zeros(1,length(words));
    for i=1:length(updateWord)
        updateIndex(find(strcmp(updateWord{i},words)))=1;
    end
    nanIndex=find((isnan(index) | updateIndex));%THIS WILL REMOVE NUMBERS, BUT ALSO 'I' : & isnan(str2double(words)));
    info2{length(nanIndexText)}=[];
    %If not word in space, add them from database
    if not(isempty(words)) & not(isempty(nanIndex))
        [x,info,f,id, wordclass] =dbSpace(lang,'','get',words(nanIndex));
        if isfield(s,'Ndim') & size(x,2)==1
            x(1,s.Ndim)=NaN;%If no words are found, then make the length of x correct
        end 
        s.Ndim=size(x,2);
        s.par.fastAdd2Space=1;%Make fast by setting
        for i=1:length(nanIndex)
            if length(words{nanIndex(i)})>0 & not((words{nanIndex(i)}(1)=='_'))
                info{i}.normalword=0;
            else
                info{i}.normalword=1;
            end
            [s index(i)]=addX2space(s,words{nanIndex(i)},x(i,:),info{i},0,'',wordclass(i),1);
        end
        s.sTemp.f=f;
        s.par.fastAdd2Space=2;
        s=addX2space(s);
        specialword=getInfo(s,words,'specialword');
        indexTest=find(not(isnan(specialword)));
        for i=1:length(indexTest)
            tmp=find(strcmpi(document,words{indexTest(i)}));
            for j=1:length(tmp)
                info2{tmp(j)}=info{indexTest(i)};
            end
        end
    end
     
    %Now create documents from words
    
    %Remove norms,train, clusters
    specialword=getInfo(s,document,'specialword');
    addNorm=addNorm | specialword==2 |  specialword==3 | specialword==4 | specialword==7 | specialword==13;
    nanIndexText=nanIndexText & not(addNorm);
disp('++++++');
disp(specialword);
disp('+++++');
    for i=find(isnan(specialword))
        number=str2double(document{i}); 
        if not(isnan(number)) & not(strcmpi(document{i},'i'))
            info2{i}.specialword=12;%Define as numeric data
        else
            info2{i}.specialword=9;%Define as text data
        end
    end
     
    index=word2index(s,textId);
    %Here we set only text data (specialword==9)
    [s, newword, index(nanIndexText)]=setProperty(s,textId(nanIndexText),textIdentifier(nanIndexText),document(nanIndexText),info2(nanIndexText));
    if strcmpi(type,'updateAll') | 0 %Save documents in database
        %I think the ? 1 above can be removed
        %if length(find(addNorm))>0
        %    index(find(addNorm))=word2index(s,textId(find(addNorm)));
        %    index(find(isnan(index)))=word2index(s,document(find(isnan(index))));
        %end
        %index=index(not(isnan(index)));
        if isempty(par.user); par.user=0;end
        try
            if length(find(index==0))>0
                %s.error='Warning: Index includes zeros, should not occur';
                %fprintf('%s\n',s.error);
                index=index(index>0);
            end
            dbSpace(lang,documentName,'save',s.fwords(index),s.x(index,:),s.info(index),'t',zeros(1,length(index)),zeros(1,length(index)),zeros(1,length(index))*par.public,zeros(1,length(index))*par.user);
        catch
            save('MatlabErrorDbSpace')
            fprintf('\nError dbSpace\n');
            %dbSpace(lang,documentName,'save',s.fwords(index),s.x(index,:),s.info(index),'t',zeros(1,length(index)),zeros(1,length(index)),zeros(1,length(index))*par.public,zeros(1,length(index))*par.user);
        end
    %else
        %fprintf('Db saving off');
    end
    
    if s.data & length(documentName)>0
        handels=s.handles;
        s=rmfield(s,'handles');
        if isfield(s,'error')
            s=rmfield(s,'error');
        end
        save(file,'s')
        s.handles=handels;
    end
end

if isempty(indexFile)
    indexFile=length(d.file)+1;
end
s.db=1;
s.rand=rand;
d.file{indexFile}=file;
if isfield(s,'error')
    s=rmfield(s,'error');
end
d.s{indexFile}=s;
d.time(indexFile)=now;

%Keep max 200 Mb in memory, or max 30 spaces!
a=whos('d');
while (length(d.file)>1 & a.bytes>200*10^6) | length(d.file)>30
    [tmp,indexFileRemove]=min(d.time);
    fprintf('\nRemoving spaces %s, current size %0.fMb\n ', d.file{indexFileRemove},a.bytes/10^6)
    d=rmSfromD(d,indexFileRemove);
end

if nargout>1
    if isempty(textId)
        index=[];
    else
        index=word2index(s,textId);
    end
end


function d=rmSfromD(d,indexFileRemove);
%Removes a space from d-structure
indexKeep=1:length(d.file);
if not(isempty(indexKeep))
    indexKeep(indexFileRemove)=0;indexKeep=indexKeep(find(indexKeep));
    d.file=d.file(indexKeep);
    d.s=d.s(indexKeep);
    d.time=d.time(indexKeep);
end

function addNewFunctions2dB
%Add a missing function to language space. Should only be run if there is a
%new function added to system
newfunction{1}='_wildcardexpansion';
for j=1:length(newfunction)
    query=['SELECT `id` FROM `spaceSwedish2` WHERE `id` LIKE ''' newfunction{j} ''''];
    r=fetch(getDb,query);
    if isempty(r)
        [space,~,languageNames]=getSpaceName;
        for i=1:size(languageNames,1)
            query=['SELECT `id` FROM `' languageNames{i,2} '` WHERE `id` LIKE ''' newfunction{j} ''''];
            e=exec(getDb,query);
            if isempty(e.Message)
                fprintf('\nAdding function %s to %s\n',newfunction{j},languageNames{i,2})
                s=initSpace;
                s.languagefile=languageNames{i,2};
                s.par.db2space;
                info=[];
                info.specialword=2;
                info.persistent=1;
                s=addX2space(s,'_wildcardexpansion',[],info,0,'Expandes words including *, i.e. lov* exands to love.');
                i=1;
                dbSpace(s.languagefile,'','save',s.fwords(i),s.x(i,:),s.info(i),'w',s.f(i),s.wordclass(i));
                file=[s.languagefile '-init.mat'];
                delete(file);
            end
        end
    end
end




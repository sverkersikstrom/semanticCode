function s=getNewSpace(filename,version,sLang);
if nargin<1
    s=getSpace;
    return
end
if nargin<2 version='';end

%Remove ending .mat in file name
filename=regexprep(filename,'\.mat','');

if not(exist([filename '.mat']))
    fprintf('\nLocate missing space-file: %s in %s\n',[filename '.mat'],pwd);
    i=findstr(filename,'/');
    if not(isempty(i))
        filename=[filename(i(end)+1:end)];
    end
    if not(exist([filename '.mat']))
        [file,PathName]=uigetfile2(['*'],['Please locate missing space-file:' char(13) filename]);
        filename=[PathName file];
        if file==0 | not(exist(filename))
            fprintf('\nCan not find file: %s, aborting!\n',filename);
            s=initSpace;
            return
        end
        filename=regexprep(filename,'\.mat','');
    end
end

fprintf('Reading %s file:\n',filename);
%if isfield(s
load([filename '.mat']);
if not(exist('s')==1)
    fprintf('Opening report: %s\n',filename);
    s=getReport([filename '.mat']);
    %fprintf('\n%s may not be a space file!\n',filename);
    %s=initSpace;
    return
end

if not(isfield(s,'data'))
    s.data=0;
end

s.filename=filename;

if s.data==1 %Load data-space
    fprintf('(data-space)');
    global spaceIsLoaded
    sLang=getSpace;
    if strcmp(version,'clearOldData') | isempty(sLang) | sLang.N==0 | not(isfield(sLang,'languagefile')) | not(strcmpi(s.languagefile,sLang.languagefile))
        sLang=getLanguageSpace(s);
    end
    %Merge sLang to the s space!
    s=mergeSpace(sLang,s);
    clear('sLang')
    s.datafile=filename;
    global spaceIsLoaded
    spaceIsLoaded=1;
else %Load language-space
    fprintf('(language-space)');
    filename2=which([filename '.mat']);
    if length(filename2)>0 filename=filename2;end
    filename=regexprep(filename,'\','/');
    i=findstr(filename,'/');
    if isempty(i)
        i=0;
        s.languagefilePath=pwd;
    else
        s.languagefilePath=filename(1:i(end));
    end
    s.filename=[ filename(i(end)+1:end)];
    s.languagefile=s.filename;
    s.path=pwd;
    s.datafile='';
    %try;s=rmfield(s,'datafile');end
    s.data=0;
    s.rand=rand;
end

s.par=getPar;
fprintf('done.\n');
[s.N, s.Ndim]=size(s.x);
s.handles=getHandles;
newReport_Callback([],[])

s=checkLanguageFile(s);
s.saved=1;
fprintf('%d words.\n',s.N);
s=getSpace('set',s);


function s=checkLanguageFile(s);

if std(s.x(1:s.N,s.Ndim))==0
    fprintf('Warning higher dimensions appears to have no variability!\n');
end

[s.N s.Ndim]=size(s.x);
if length(s.fwords)<s.N %Fix strange bug in Chinese file
    s.x=s.x(1:s.N,:);
    s.f=s.f(1:s.N);
    [s.N s.Ndim]=size(s.x);
end

if not(isfield(s,'xmean2')) | s.xmean2(1)==0  | isnan(mean(s.xmean2))
    fprintf('Creating s.xmean2\n')
    include=ones(1,s.N);
    s.xmean2=zeros(1,s.Ndim);
    fSum=0;
    for i=1:s.N
        if s.fwords{i}(1)=='_';
            include(i)=0;
        else
            f=s.f(i);
            tmp=s.x(i,:)*f;
            if not(isnan(mean(tmp)))
                fSum=fSum+f;
                s.xmean2=s.xmean2+tmp;
            end
        end
    end
    s.xmean2=s.xmean2/fSum;
    if not(isfield(s,'data')) s.data=1;end
    if s.data==0
        saveSpace(s,[s.languagefilePath s.filename],1);
    end
end

s.f=s.f/nansum(s.f);
if not(isfield(s,'info'))
    s.info{s.N}=[];
end
if not(isfield(s,'wordclass'))
    s.wordclass=zeros(1,s.N);
end


if word2index(s,s.fwords{min(length(s.fwords),s.N)})==s.N
    fprintf('Skipping indexing\n')
else
    s=mkHash(s,1);
end

i=word2index(s,'_liwcnon-fluencies');
if not(isnan(i)) %Fix weired bug in English space
    s.fwords{i}='_liwcnonfluencies';
end

%Add functions identifiers to the languagefile!
update=0;
if isnan(word2index(s,'_spaceInfo'))
    info=[];
    info.specialword=2;
    info.persistent=1;
    s=addX2space(s,'_spaceInfo',[],info,0,'Print information about the space');
end

s=spaceAddModels(s,1);

% update=isnan(word2index(s,'_translate'));
% if update %Move to other functions later
%     info.specialword=2;
%     info.persistent=1;
% end

update=isnan(word2index(s,'_concatenate'));
 
if update & s.data==0
    s=spaceAddModels(s);    
    if not(isfield(s.info{1},'bigram'))
        s=calculate_bigram(s);
    end
    for i=1:s.N
        if not(isempty(s.fwords{i})) & regexp(s.fwords{i},'_liwc')==1
            fprintf('Initiating %s to LIWC type\n',s.fwords{i})
            s.info{i}.specialword=5;
        end
    end
    if s.data==0
        saveSpace(s,[s.languagefilePath s.filename],1);
    end
end


function s=getLanguageSpace(s);
if not(isfield(s,'languagefilePath'))
    i=findstr(s.languagefile,'/');
    if not(isempty(i))
        s.languagefilePath=s.languagefile(1:i(end));
        s.languagefile=s.languagefile(i(end)+1:end);
    else
        s.languagefilePath='';
    end
end
if length(s.languagefilePath)>0
    file=[s.languagefilePath '/' s.languagefile];
else
    file=s.languagefile;
end
fprintf('\nReading language file:\n%s\n...',file);
if not(exist([regexprep(file,'.mat',''),'.mat'])) |  length(s.languagefile)==0
    i=findstr(file,'/');
    s.languagefile=[file(i(end)+1:end) ];
    if exist(s.languagefile)
        file=s.languagefile;
    else
        helptext=['Please locate missing language file: ' char(13) file];
        fprintf('%s\n',helptext);
        [s.languagefile,s.languagefilePath]=uigetfile('space*',helptext,'');
        file=[s.languagefilePath  s.languagefile];
    end
end

languagefile=s.languagefile;
load(file);
s.N=length(s.fwords);
s.languagefilePath=which(file);
i=findstr(s.languagefilePath,'/');
if not(isempty(i)) s.languagefilePath=s.languagefilePath(1:i(end));end
s.languagefile=languagefile;
if not(isfield(s,'hash'))
    s=mkHash(s,1);;
end






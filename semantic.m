function varargout = semantic(varargin)  
 
%mcc -m semantic -N -p C:\Program\MATLAB71\toolbox\stats\private\
% semantic M-file for Semantic.fig
%      Semantic, by itself, creates a new Semantic or raises the existing
%      singleton*.
%
%      H = Semantic returns the handle to a new Semantic or the handle to
%      the existing singleton*.
%
%      Semantic('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Semantic.M with the given input
%      arguments.
%
%      Semantic('Property','Value',...) creates a new Semantic or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Semantic_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are spassed to Semantic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE'savereportas Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Semantic

% Last Modified by GUIDE v2.5 10-Jul-2020 07:07:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1; 
warning('off','MATLAB:dispatcher:InexactMatch');
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @semantic_OpeningFcn, ...
    'gui_OutputFcn',  @semantic_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

warning off
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%warning on
persistent isadded
global rootPath
%global compile

%if 0 & isdeployed %compile
%    try
%        addpath('/Applications/semantic/application/')
%    end
%end
if isempty(isadded) & not(isdeployed)
    isadded=1;
    %javaaddpath('/mysql-connector-java-5.1.34-bin.jar')
    if exist('semantic.m')>0
        addpath([pwd]);
    end
    if exist([pwd '/semanticCode'])>0
        rootPath=pwd;
        addpath([pwd '/matlabjarfiles/jsonlab']);
        addpath([pwd '/semanticCode']);
        if not(exist(['ext_programs'])==7)
            fprintf('Could not find ''ext_programs'' folder, wordclass function may not work!\n')
        end
    end
end

%end
% End initialization code - DO NOT EDIT


% --- Executes just before Semantic is made visible.
function semantic_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Semantic (see VARARGIN)
persistent isLoaded
%global saveGlobalHandels
%global savedHandles2
%savedHandles2=handles;
% Choose default command line output for Semantic
%saveGlobalHandels=hObject;

getHandles(handles);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Update handles structure

% UIWAIT makes Semantic wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if isLoaded==1
    return
end
newReport_Callback(hObject, eventdata, handles);
init_sem(varargin);
isLoaded=1;

function init_sem(varargin) %Should be placed in the output function but does not work whit the complied version
%warning('off','MATLAB:dispatcher:InexactMatch')
warning off all;
dbstop if error

global default
default=0;
rand('state',sum(100*clock));
par=getPar;
if par.excelServer
    return
end

clc

%Load default space English
p=pwd;
a=findstr('/Dropbox/',pwd);
%if a>0
defaultSpace{1}=[p(1:a) 'Dropbox/ngram/spaceenglish.mat'];
defaultSpace{2}='spaceenglish.mat';
defaultSpace{3}='/Applications/SemanticExcel/application/spaceenglish.mat';
defaultSpace{4}='spaceSwedish2.mat';
defaultSpace{5}='/Applications/SemanticExcel/application/spaceSwedish2.mat';
if 1
    s=initSpace;
    fprintf('Loaded empty space: %s\n');
    getSpace('set',s);
else
    ok=0;
    for i=1:length(defaultSpace)
        if exist(defaultSpace{i}) & not(ok)
            ok=1;
            fprintf('Loading default space: %s\n',defaultSpace{i});
            getNewSpace(defaultSpace{i});
        end
    end
end

r=sprintf('Semantic 1.0 2019-09-21 This software can be used for collaborative research, Sverker Sikstrom\n');
r=[r sprintf('Read the document "Semantic Documentation" for getting started\n')];
r=[r pwd sprintf('%s\n',pwd)];
showOutput({r},'Start');


try
    corr(rand(5,1),rand(5,1));
catch
    questdlg2('Most likely you do not have matlabs statistic library installed, some function will therefore not work properly','Ok','Ok');
    %fprintf('Most likely you do not have matlabs statistic library installed, some function will therefore not work properly\n')
end

if not(isempty(varargin))
    if find(strcmpi(varargin{1},'stock'))
        stock;
    elseif find(strcmpi(varargin,'-d'))
        default=1;%Default
        %else
        %default=-1;%Input prompt
    end
    if strcmpi(varargin,'s')
        s=getSpace('s');
    end
end



% --- Outputs from this function are returned to the command line.
function varargout = semantic_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
handles.output = hObject;

function a=a2(a,i1,i2)
a=a(max(1,i1):min(length(a),i2));

function [x,ok,dord1,dmtx1,index]=search_vector_s(s,word1);
%Find a vector from 'word1' based on word1='string'/{'cell1' 'cell2'}/x
%Returns vector and ok=1 if seach successfull!
ok=0;
if isa(word1,'char') %sort by word
    [x ok index]=getXword(s,word1);
elseif isa(word1,'cell') %average word list
    [x, ok]=average_vector_random(s,word1);
else %sort by vector
    ok=1;x=word1;
end

function plot_1d_Callback(hObject, eventdata, handles)
plot_2d_graph_Callback(hObject, eventdata, handles,'d1')

function d3_Callback(hObject, eventdata, handles)
plot_2d_graph_Callback(hObject, eventdata, handles,'d3')

function plot_2d_graph_Callback(hObject, eventdata, handles,ver)
%Plots a dimensional graph of all words!
if nargin<4
    ver='';
end
s=getSpace('s');


odic=getWordMany(s,'Words to plot (*=all)','*');
if length(odic)==0; return; end

[o1 s]=getWordFromUser(s,'Word for the first-dimension','hostage','',1);
if o1.N==0; return; end

if strcmpi(ver,'d1')
    o2=[];
else
    [o2 s]=getWordFromUser(s,'Word for the second-dimension','japan','',1);
    if o2.N==0; return; end
end

if strcmpi(ver,'d3')
    [o3 s]=getWordFromUser(s,'Word for the third-dimension','_price_n2r','',1);
    if o3.N==0; return; end
else
    o3=[];
end
plotSpace(s,odic,o1,o2,o3,strcmpi(get(s.handles.animate2,'checked'),'on'));



function neighbour=read_neighbour(model,handles);
steps=5;
fil=['Neighbour_.mat'];
for k=1:length(model)
    fil_month=['Neighbour_' model{k} '.txt'];
    fil_month4=['Neighbour4_' model{k} '.txt'];
    if exist(fil_month) %& exist(fil_month4)
        neighbour(k,:)=load(fil_month);
    else
        fprintf('\nCalculating neighbours for %s steps %d',model{k},steps);
        s=getNewSpace( model{k});
        s.fwords=s.fwords;x=s.x;
        %skip=savereportas.skip;
        neighbour(k,:)=zeros(1,s.N);
        neighbour4(k,:)=zeros(1,s.N);
        for i=1:s.N
            N=0;
            for j=1:s.N/steps
                j2=j*steps;
                d=sum(x(i,:).*x(j2,:));
                if not(skip(i))  & not(i==j2) %& not(skip(j2))
                    N=N+1;
                    neighbour(k,i)=neighbour(k,i)+d^2;
                    neighbour4(k,i)=neighbour4(k,i)+d^4;
                end
            end
            if N==0
                neighbour(k,i)=-1;
                neighbour4(k,i)=-1;
            else
                neighbour(k,i)=neighbour(k,i)/N;
                neighbour4(k,i)=neighbour4(k,i)/N;
            end
            if i/100==round(i/100)
                fprintf('.');
            end
        end
        neighbour_one=neighbour(k,:);
        save(fil_month,'-ASCII', 'neighbour_one');
        neighbour_one4=neighbour4(k,:);
        save(fil_month4,'-ASCII', 'neighbour_one4');
    end
end

neighbour=fixnan(neighbour);

function s_all=read_cmpmodels(model,cmp,handles);
%Compare two models and stores comparision in a file.
steps=5;%Jumps between comparions. Should be 1, >1 makes it faster!
for k=1:length(model)-1
    if cmp==0 %Compare with following model
        k1=k+1;
    else %Compare with fixed model
        k1=cmp;
    end
    fil=['Diff_' model{k} '_' model{k1} '.txt'];
    if exist(fil)
        s_all(k,:)=load(fil);
    else
        fprintf('\nComparing space %s with %s steps %d ',model{k},model{k1},steps);
        s=getNewSpace( model{k});
        dord1=s.fwords;x1=s.x;
        %skip1=savereportas.skip;
        s=getNewSpace(model{k1});
        dord2=s.fwords;x2=s.x;
        %skip2=savereportas.skip;
        s=zeros(1,length(dord1));
        N=fix(length(dord1)/steps);
        for i1=1:length(dord1)
            for j=1:N
                j1=j*steps;
                if not(isempty(strcmpi(dord2(i1),dord1(i1)))) %Faster
                    i2=i1;j2=j1;
                else
                    i2=find(strcmpi(dord2,dord1(i1)));
                    j2=find(strcmpi(dord2,dord1(j1)));
                end
                %if skip1(i1)==0 & skip1(j1)==0 & skip2(i2)==0 & skip2(j2)==0
                    d1=sum(x1(i1,:).*x1(j1,:));
                    d2=sum(x2(i2,:).*x2(j2,:));
                    s(1,i1)=s(1,i1)+abs(d1-d2)/N;%Possible bug if skip words are different between models...
                %end
            end
            s_all(k,i1)=s(1,i1);
            if i1/100==round(i1/100)
                fprintf('.');
            end
        end
        save (fil ,'-ASCII', 's')
        save(['Diff_' num2str(cmp) '_all.txt'] ,'-ASCII', 's_all');
    end
    %    fprintf('\n%savereportas done!\n',fil);
end


function f=fopen2(file,type)
f=fopen(file,type);
if f<0
    fprintf('Error file: %s, is missing, please locate\n',file);
end

function text=loadtext(fil)
%load a text-file
f=fopen2(fil,'r');
i=0;
while feof(f)==0
    i=i+1;
    text{i}=fgets(f);
end
fclose(f);

function savetext(fil,text)
fid = fopen(fil,'w');
Nj=size(shiftdim(text{1}));
for j = 1:Nj
    Ni=size(shiftdim(text));
    for i = 1:Ni
        a=deblank(text{i}{j});
        fprintf(fid,'%s ',a);
    end
    fprintf(fid,'\n');
end
fclose(fid);

function [dord1, dmtx1, dmtx2_new] =match_attributs(cond1,cond2)
%Machtes attributes in cond1 to cond2
%dbstop if error
s=getNewSpace(cond1);
dord1=s.fwords;dmtx1=s.x;
%skip1=savereportas.skip;
s=getNewSpace(cond2);
dord2=s.fwords;dmtx2=s.x;
%skip2=savereportas.skip;
fil=['attribute_' cond1 '_' cond2 '.mat'];
N=s.Ndim;
if exist(fil) & 1
    load(fil);
else
    d1(1,N)=0;d2(1,N)=0;
    for i=1:length(dord2)
        if isnan(dmtx1(i,1))==0
            d1(i,:)=dmtx1(i,:);
        end
        if isnan(dmtx2(i,1))==0
            d2(i,:)=dmtx2(i,:);
        end
    end
    [c p1]=corr(d1,d2);
    p=p1;
    for i=1:N
        [minp ir]= min(p);
        [min2p ic]=min(minp);
        [v ir2]=min(p(:,ic));
        index(ir2)=ic;
        p(ir2,:)=p(ir2,:)+1;
        p(:,ic)=p(:,ic)+1;
    end
    for j=1:N
        corr(d1(:,j),d2(:,index(j)))
        sig(j)=sign(corr(d1(:,j),d2(:,index(j))));
    end
    save(fil,'index','sig');
end
for j=1:length(dord1)
    if isnan(dmtx2(j,1))==0
        dmtx2_new(j,:)=dmtx2(j,index).*sig;
    end
end

function [s, word]=nearest_associations2_s(s,x,order);
%[savereportas, word,ok,index]=nearest_associations2(x,savereportas.fwords,savereportas.x,order);
%function [savereportas, word,ok,index]=nearest_associations2(x,dord1,dmtx1,order);
if ischar(x)
    [tmp. s]=getWord(s,x);x=tmp.x;
end
s2=shiftdim(s.x*shiftdim(x,1),1);
[s2 index]=sort(s2,order);
word=dord1(index);

function remove_underscore_words_Callback(hObject, eventdata, handles)
swap_check(handles.remove_underscore_words)

function remove_normal_words_Callback(hObject, eventdata, handles)
swap_check(handles.remove_normal_words)

function swap_check(handles)
if strcmpi(get(handles,'checked'),'on');
    set(handles,'checked','off');
else
    set(handles,'checked','on');
end




function important_features(word,fil)
s=getNewSpace(fil);
i=find(strcmpi(s.fwords,word));
if isempty(i)
    fprintf('Cant find %s\n',word);
else
    [value index]=sort(abs(s.x(i,:)),'descend');
end



function mail(header)
try
    setpref('Internet','SMTP_Server','pop.lu.se');
    setpref('Internet','E_mail','sverker.sikstrom@lucs.lu.se');
    sendmail('sverker.sikstrom@lucs.lu.se',header,' ');
catch
    fprintf('Failed sending mail\n');
end

% --- Executes on button press in webcrawler.
function webcrawler_Callback(hObject, eventdata, handles,input)
% hObject    handle to webcrawler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if nargin<4
    input=0;
end
ver=6;

t=clock;lsend=clock;
fil=['large_' '9609'];
subset.only_include='';random=0;subset.url='';%Default
global forcebase
forcebase='';

if ver==0
    random=1;
    outfil='random';
    url{1}='http://www.nyt.com';
    subset.url='';
elseif or(ver==1,ver==2)
    random=0;
    %    url{1}='http://web.archive.org/web/*/http://www.latimes.com';
    %    subset.url='http://web.archive.org/web/20010822044353/http://www.latimes.com/';
    url{1}='http://archive.bibalex.org/web/*/http://latimes.com/index.html';
    subset.url='latimes.com';
    subset.pre='http://archive.bibalex.org/web/';
    
    %http://archive.bibalex.org/
    subset.exclude='class/';
    if ver==1
        outfil='latimes200108-10';
        subset.start=20010800000000;
        subset.end  =20011010000000;
    else
        outfil='latimes20010912144940';
        subset.start=20010912144940;
        subset.end  =20010912151030;
    end
elseif ver==5
    %        url{1}='http://www.fajaf.com/lokalt/HMF/mk/';
    url{1}='http://www.hitler.org/writings/Mein_Kampf/';
    outfil='meinkampfeng';
elseif ver==6
    d='';
    %'http://www.riksdagen.se/webbnav/index.aspx?rm=1990%2F91&nid=100'
    url{1}=inputdlg2('Define start url','Webcrawler',1,{'http://epigraphy.packhum.org/inscriptions/oi?ikey=70&caller=search&bookid=4&region=1&subregion=0'
        },input);
    url=url{1};
    outfil=inputdlg2('Define outputfile','Webcrawler',1,{'greek'},input);outfil=outfil{1};
    forcebase=inputdlg2('Force base to','Webcrawler',1,{'http://epigraphy.packhum.org/inscriptions/'},input);forcebase=forcebase{1};
    
    subset.only_include=inputdlg2('Only include webpages with','Webcrawler',1,{''},input);subset.only_include=subset.only_include{1};
    subset.no_repeat=inputdlg2('Do not allow dubbelets in URL of','Dubblets',1,{'?'},input);subset.no_repeat=subset.no_repeat{1};
    random=inputdlg2('Pick pages to search randomly (1)','Webcrawler',1,{'0'},input);random=str2num(random{1});
    version=inputdlg2('Special: riksdagen/archive','Webcrawler',1,{''},input);
    if strcmpi('riksdagen',version)
        y1=inputdlg2('Start year','Webcrawler',1,{'1999'},input);y1=str2num(y1{1});
        y2=inputdlg2('End year  ','Webcrawler',1,{'1999'},input);y2=str2num(y2{1});
        i=1;
        for year=y1:y2
            for id=1:200
                if year<1999
                    url{i}=['http://www.riksdagen.se/webbnav/index.aspx?nid=101&bet=' num2str(year) '/' num2str(year+1-1900) ':' num2str(id)];
                elseif year==1999
                    url{i}=['http://www.riksdagen.se/webbnav/index.aspx?nid=101&bet=' num2str(year) '/' num2str(2000) ':' num2str(id)];
                else
                    url{i}=['http://www.riksdagen.se/webbnav/index.aspx?nid=101&bet=' num2str(year) '/0' num2str(year+1-2000) ':' num2str(id)];
                end
                i=i+1;
            end
        end
    elseif strcmpi('archive',version)
        url{1}=['http://archive.bibalex.org/web/*/' url{1}{1}];
        subset.url=subset.only_include;
        subset.pre='http://archive.bibalex.org/web/';
        subset.start=inputdlg2('Startdate','Webcrawler',1,{'20010912144940'},input);subset.start=str2num(subset.start{1});
        subset.end  =inputdlg2('Enddate: riksdagen/archive','Webcrawler',1,{'20010912151030'},input);subset.start=str2num(subset.end{1}  );
    end
end
bib='';
fprintf('Crawling the inter-net %s...\nRandomize %1.3f\n ',[fil outfil],rand);
start_time=clock;
j=1;url_links(1)=0;
s=getNewSpace(fil);
dord1=s.fwords;dmtx1=s.x;
%skip1=savereportas.skip;
if exist(['Net_' fil outfil '.mat'])
    load(['Net_' fil outfil '.mat']);
else
    fprintf('Starting new Net - file!\n');
end
m.resample=0;
while m.resample<3
    j0=j-.1;
    while j<=length(url)
        if m.resample>0 %Now looking for failed connections...
            while m.status(j)==1 & j<length(url)
                j=j+1;
            end
            fprintf('\nResampling %d try %d',j,m.resample);
        elseif random
            jtmp=round(rand*(length(url)-j)+j);
            tmp{1}=url{j};url{j}=url{jtmp};url{jtmp}=tmp{1};
            tmp1=url_links(j);url_links(j)=url_links(jtmp);url_links(jtmp)=tmp1;
        end
        tid=clock;
        if tid(4)==12 & etime(clock,lsend)>4000
            lsend=clock;mail(['Alive ' num2str(ver) ' ' num2str(j)]);
        end
        
        fprintf('\nSearch number %d remaning %d random %d pages/h %3.0f time %d:%d\n',j,length(url)-j,random,(j-j0)/(etime(clock,start_time)/3600),tid(4),tid(5));
        fprintf('page %s\n', url{j});
        [words newurl m.durl(j) twb m.status(j)]=read_page(url{j});
        m.time(j,:)=clock;
        
        x=zeros(1,s.Ndim);
        Nd(j)=0;Ntot(j)=0;
        fid=fopen([bib 'page_archive_' outfil '.txt'],'a');
        fprintf(fid,'!number %d durl %s dwb %s date %s time %d:%d status %d\n',j,num2str(m.durl(j)),num2str(twb),date,m.time(j,4),m.time(j,5),m.status(j));
        
        if m.status(j)==1
            fprintf(fid,'page %s\n',url{j});
            fprintf(fid,'<DOC><TEXT>\n');
            for i=1:length(words)
                i1=find(strcmpi(dord1,words(i)));
                if i1>0
                    Nd(j)=Nd(j)+1;
                    x=x+dmtx1(i1,:);
                end
                fprintf(fid,'%s ',words{i});
                Ntot(j)=Ntot(j)+1;
            end
            fprintf(fid,'\n</TEXT></DOC>\n');
        end
        
        fclose(fid);
        
        fprintf('Found %d words of a total of %d words in %s\n',Nd(j),Ntot(j),url{j});
        eng=Nd(j)/(max(1,Ntot(j)));
        if or(random==0,or(eng>.2,Nd(j)>100))
            fprintf('Storing webpage\n');
            len=sum(x.*x);
            if len>0
                x=x/len;
                dmtx(j,:)=x;
            end
            add=0; %Adding new url's to search set!
            for i=1:length(newurl)
                [skip newurl{i}]=skip_url(newurl{i},subset);
                i1=find(strcmpi(url,newurl{i}));
                if skip %Skipping .jpg etc..
                elseif isempty(i1) %Storing new url..
                    url{length(url)+1}=newurl{i};
                    url_links(length(url))=0;
                    m.status(length(url))=0;
                    add=add+1;
                else %Already exists..
                    if not(strcmpi(domain_name(newurl{i}),domain_name(url{i1(1)})))
                        url_links(i1(1))=url_links(i1(1))+1; %Counting number of links from different domains...
                    end
                end
            end
            fprintf('Added %d pages to seach set.',add);
        else
            fprintf('Non-english page page! NOT storing associated vector!\n');
            dmtx(j,:)=x*0;
        end
        if or(j==length(url),round(j/25)==j/25) %Saving results occationally...
            fprintf('Saving results %s ...',[fil outfil]);
            save(['Net_' fil outfil '.mat'],'dmtx','Nd','Ntot','url','j','url_links','m');
            fid=fopen(['Urls_' fil outfil '.txt'],'w');
            for i=1:min(length(m.status),length(url))
                fprintf(fid,'Ok %d %s\n',m.status(i),url{i});
            end
            fclose(fid);
            pack;
            fprintf('done.\n');
        end
        fprintf('. Add time %2.1f\n',etime(clock,m.time(j,:)));
        j=j+1;
    end
    m.resample=m.resample+1;j=1;
end
beep2
if etime(clock,t)>600
    mail(['Completed ' outfil ' ' num2str(j)]);
end

function [skip, a]=skip_url(a,subset)
if length(a)<5
    skip=1;
elseif strcmpi('.gif',a(length(a)-3:length(a))) %Ignore .gif files!
    skip=1;
elseif strcmpi('.jpg',a(length(a)-3:length(a))) %Ignore .jpg files!
    skip=1;
elseif strcmpi('.css',a(length(a)-3:length(a))) %Ignore .css files!
    skip=1;
elseif strcmpi('.js',a(length(a)-2:length(a))) %Ignore .js files!
    skip=1;
elseif length(subset.url)>0 %Choicing url from webarchive with specific page and date range!
    tid=str2num(a(min(length(subset.pre)+1,length(a)):min(length(a),length(subset.pre)+14)));
    prefix=not(isempty(strcmpi(a(1:min(length(subset.pre),length(a))),subset.pre)));
    isurl=not(isempty(findstr(a,subset.url)));
    if length(subset.exclude)>0 & strcmpi([subset.url(42:length(subset.url)) subset.exclude],a(42:min(length(a),length([subset.url subset.exclude]))))
        skip=1;%excluding criteria!
    elseif prefix & isurl & tid>=subset.start & tid<=subset.end
        skip=0;
    else
        skip=1;
    end
    fprintf('Skip %d Url: %s\n',skip,a);
elseif length(subset.only_include)>0 & isempty(findstr(subset.only_include,a)) %Do not include...
    skip=1;
elseif length(subset.no_repeat)>0 & length(findstr(subset.no_repeat,a))>1 %Do not include...
    skip=1;
else
    skip=0;
end

function [a,b]=swap(a,b)
tmp=a;a=b;b=tmp;

function b=domain_name(a)
b=a(8:length(a));
i=findstr(b,'/');
if not(isempty(i))
    b=b(1:i(1)-1);
end

function [words,http,durl,twb,status]=read_page(page)
%Read a webpage, get-https, and get_texts
%dbstop if error
f=fopen('lastpage.txt','w');fprintf(f,'%s',page);fclose(f);%Debugging why the program stops...!
tid=clock;
try
    text=urlread(page);
    status=1;
catch
    fprintf('Could not load page\n');
    durl=1;twb=0;words='';http{1}='';status=0;return
end
fprintf('download time %2.1f\n',etime(clock,tid));tid=clock;
text=lower(text);
durl=get_date(text);
[http,twb]=get_http(text,page);
text=remove(text,'<!--','-->',0);
text=remove(text,'<style','</style>',0);
text3=remove(text,'<script','</script>',0);
[text4 words]=remove(text3,'<','>',1);
fprintf('\nword processing time %2.1f words %d\n',etime(clock,tid),length(words));

function [durl]=get_date(text)
%Finds date in a url!
sday=0;smonth=0;syear=0;
month={'january', 'february','march','april','may','june','july','august','september','october','november','december'};
for i=1:12
    f=findstr(text,month{i});
    if not(isempty(f))
        for j=1:length(f)
            d=str2num(text(f(j)+length(month{i}):f(j)+length(month{i})+2));
            if d<10
                add=1;
            else
                add=2;
            end
            y=str2num(text(f(j)+length(month{i})+add+3:f(j)+length(month{i})+add+6));
            if not(isempty(d)) & not(isempty(y)) & isa(y,'float')  & isa(d,'float')
                if d>0 & d<=31 & y>1990 & y<2030
                    sday=d;smonth=i;syear=y;
                end
            end
        end
    end
end
durl=(syear*10000+smonth*100+sday)*1000000+1;

function [h, twb]=get_http(a,page)
%Finds http-webpages and stores them in 'h'
h{1}='';twb=0;
base1=findstr(a,'<base href="')+12;
wayback=findstr(a,'var swaybackcgi = "http://');
%var sWayBackCGI = "http://web.archive.org/web/20010822044353/";
%http://archive.bibalex.org/web/20010811074955/http://latimes.com/index.html
if not(isempty(wayback)) %Weebarchive add a base to the http....
    t=findstr(a(wayback:length(a)),'"');
    wayb=a(wayback+t(1):wayback+t(2)-2);
    t=findstr(a(wayback:length(a)),'/');
    if length(t)>=5
        twb=str2num(a(t(4):t(5)));
    end
end
if not(isempty(base1)) %Some pages add a base to the http....
    base2=findstr(a(base1(1):length(a)),'"')+base1(1)-2;
    add=a(base1(1):base2(1)-1);
    if not(isempty(findstr(add,'/index.htm')))
        add=add(1:length(add)-10);
    end
    if not(isempty(findstr(add,'/index.html')))
        add=add(1:length(add)-11);
    end
end

%fprintf('REMOVE THIS LINE ADDINGhttp://epigraphy.packhum.org/inscriptions/\n');
global forcebase
if not(isempty(forcebase))
    base1=' ';add=forcebase;
end

b=findstr(a,'href="')+5;
for i=1:length(b)
    j=1;
    while not(a(b(i)+j)=='"') & b(i)+j<length(a)
        j=j+1;
    end
    h{i}=a(b(i)+1:b(i)+j-1);
    if not(isempty(base1)) & isempty(findstr(h{i},'http://'))
        h{i}=[add h{i}];
    end
    if not(isempty(wayback)) & isempty(findstr(h{i},'http://web.archive.org/web'))
        h{i}=[wayb h{i}];
    end
    if isempty(findstr(h{i},'http://'))
        h{i}=[page h{i}];
    end
    if i<=3
        fprintf('%s\n',h{i});
    end
    h{i}=regexprep(h{i},'amp;','');%Causes problems otherwise...
end
fprintf('Found %d non-unique webpages\n',length(b));

function [c, text]=remove(a,r1,r2,pr)
%removes text within 'r1' and 'r2' and special characters...
rem=0;j=0;lj=1;text{1}='';b='';
sp=0;spnr=0;row=0;texton=0;textoff=0;
s='                          ';
b=a;
removes='    -.,:|#?()*!'; %The sign &; is used in Swedish (???) Do not remove / !!!
removes(1)=9;removes(2)=10;removes(3)=13;removes(4)=32;
imax=length(a)-max(length(r2),length(r1));r1l=length(r1);r2l=length(r2);
for i=1:imax
    if strcmpi(a(i:i-1+r1l),r1)
        rem=1;
    elseif rem==1 & strcmpi(a(i:i-1+r2l),r2)
        rem=0;
        texton=j;
        a(i:i+r2l-1)=s(1:r2l);
    elseif not(isempty(findstr(a(i),removes)))
        sp=1;
    elseif rem==0
        if pr==1
            if j==texton
                b(j+1:j+14+11)=['</TEXT></DOC>' char(13) '<DOC><TEXT>'];j=j+14+11;
            end
        end
        j=j+1;
        if sp>0
            sp=0;
            row=row+1;
            if pr==1 & length(b)>0
                text{row}=deblank(b(lj:j-1));
                if row<30
                    fprintf('%s ',text{row});
                    if spnr>10
                        fprintf('\n');
                    end
                end
            end
            lj=j+1;
            
            if spnr>10
                b(j)=char(13);spnr=0;
            else
                b(j)=char(32);
            end
            j=j+1;
            spnr=spnr+1;
        end
        b(j)=a(i);
    end
end
c=b(1:j);

function c=trimeword(a,removes)
%Removes unnessary characters...
j=1;b=a;
for i=1:length(a)
    if isempty(findstr(a(i),removes))
        b(j)=a(i);j=j+1;
    end
end
c=b(1:j);



function test_specific_differences_Callback(hObject, eventdata, handles)
s=getSpace('s');

[data s]=getWordMany(s,'Choice sets of identifiers to compare','*');
%for i=1:length(data);%Make short labels!
%    if length(data{i}.input_clean)>30 data{i}.input_clean='set1';end
%end

if length(data)<1 return; end;
[properties s]=getWordFromUser(s,'Choice properties to compare differences on','_correctr');


squared=1;
if properties.N==0; return; end
r='';
if length(data)==1 & properties.N==1 & squared
    r=[r sprintf('You need at more than one word set to compare, or more than property to compare\n')];
    showOutput({r},'Insufficient input');
    return
end

if length(data)==1 %One text set compared on several properties
    squared=strcmpi('A*A',questdlg2('Results matrix','Matrix','A*A','A*B (input B)','A*A'));
    if not(squared)
        dataC=getWordMany(s,'Choice words to compare','*');
        if length(dataC)<1 return; end;
        [propertiesC s]=getWordFromUser(s,'Choice (B) properties to compare differences on','_correctr');
    end

    N=properties.N;
    for j1=1:N
        labelR{j1}=[data{1}.input_clean '(' s.fwords{properties.index(j1)} ')'];
        dataR{j1}=data{1};
        propertiesR.index(j1)=properties.index(j1);
    end
    if squared
        out=semanticTestPropertyMany(s,dataR,propertiesR.index,labelR);
    else
        N=propertiesC.N;
        for j1=1:N
            labelC{j1}=[dataC{1}.input_clean '(' s.fwords{propertiesC.index(j1)} ')'];
            dataC{j1}=dataC{1};
        end
        out=semanticTestPropertyMany(s,dataR,propertiesR.index,labelR,dataC,propertiesC.index,labelC);
    end
elseif 1 %Several texts compared one property, then loop over each property
    N=properties.N;
    for j1=1:N
        for i=1:length(data)
            label{i}=[data{i}.input_clean '(' s.fwords{properties.index(j1)} ')'];
            data2{i}=data{i};
            properties2.index(i)=properties.index(j1);
        end
        [~,out{j1},s]=semanticTestPropertyMany(s,data2,properties2.index,label);
    end   
    if length(data)==2 & N>1
        fprintf('Summary:\nSet1                                    \tSet2                                     \tp\tm1\tm2\n')
        for j1=1:N
            fprintf('%s\t%s\t%.4f\t%.3f\t%.3f\n',fixStringLength(out{j1}{3}.label1,40),fixStringLength(out{j1}{3}.label2,40),out{j1}{3}.p,out{j1}{3}.m1,out{j1}{3}.m2)
        end
    end
    1;
elseif 0 %Old
    N=max([length(data) properties.N]);
    for j1=1:N
        label{j1}=[data{min(j1,length(data))}.input_clean '(' s.fwords{properties.index(min(j1,length(properties.index)))} ')'];
        data2{j1}=data{min(j1,length(data))};
        properties2.index(j1)=properties.index(min(j1,length(properties.index)));
    end
    
    [out,~,s]=semanticTestPropertyMany(s,data2,properties2.index,label);
end
s=getSpace('set',s);


function semanticTest_Callback(hObject, eventdata, handles)
semanticTestMultiple



function list_attributes_Callback(hObject, eventdata, handles)
s=getSpace('s');
for i=1:s.Ndim
    
    a=sprintf('Dim %d\t',i);b=a;
    vector=zeros(1,s.Ndim);vector(i)=1;
    print_nearest_associations_s(s,'print',vector,'descend',['dim' num2str(i)]);

end

function output_Callback(hObject, eventdata, handles)

function output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function dist_plots_Callback(hObject, eventdata, handles)
% hObject    handle to dist_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s=getSpace('s');
if not(isfield(s,'neighbour'))
    s.neighbour=read_neighbour(s.filename,s.handles);
end

figure;
select=1:length(s.f);
fprintf('Correlation neigbours and log2(frequency)= %.3f\n',corr(shiftdim(s.neighbour(select),1),log2(shiftdim(s.f(select),1))))
plot(log2(s.f(select)),s.neighbour(select),'+')
xlabel('log2(frequency)');ylabel('neigbour');title('Neigbours versus frequency');
for i=1:length(select)
    text(log2(s.f(select(i))),s.neighbour(select(i)),s.fwords{select(i)});
end
%if not(isfield(savereportas,'reg'))
%    savereportas.reg=read_reg(savereportas.models,handles);
%end

i=1;
tmp=find(not(isnan(s.f(i,:))));
[r,p]=corr(shiftdim(s.reg(i,tmp),1),shiftdim(s.f(i,tmp),1));
X=[shiftdim(ones(size(tmp)))  shiftdim(s.f(i,tmp),1)];
a=X\shiftdim(s.reg(i,tmp),1);
fprintf('Correlation valence-frequency: r=%.2f p=%.2f\n',r,p);
fprintf('Regression parameters a0 %.2f a1 %.5f\n',a(1),a(2));
figure;plot(mean(s.x));xlabel('Dimension number');ylabel('mean');title('Mean is not zero for low dimensions');
figure;plot(std(s.x));xlabel('Dimension number');ylabel('standard deviation');title('Standard deviation increases with dimension number');


function [party, surname]=get_politics(s,p,party, surename);
%not used
if findstr([' ' p '</TEXT>'],s)>0
    party=p;
elseif findstr([' ' p ' ',s])>0
    party=p;
end

% --- Executes on button press in split_file.
function split_file_Callback(hObject, eventdata, handles,input)
% hObject    handle to split_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dbstop if error
if nargin<4
    input=0;
end
if input==1
    pagefile{1}='page_archive_riksdagen.txt';
    pagefile=inputdlg2('page file','Splitfile',1,pagefile,input);pagefile=pagefile{1};
else
    pagefile=uigetfile2('page*.txt','Choice page file to split');
end
split={'1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005'};
split=inputdlg2('Split file depening url containing','Splitfile',1,split,input);
split=strread(split{1},'%s');
name{1}='rik_';name=inputdlg2('Choice name','Splitfile name',1,name,input);
random{1}='16';random=inputdlg2('Number of random files','Splitfile name',1,random,input);
yes{1}='no';yes=inputdlg2('Recode page file (yes/no)?','Splitfile name',1,yes,input);
if strcmpi('yes',yes);
    recode_file(pagefile);
    f=fopen(['r_' pagefile]);
else
    f=fopen(pagefile);
end
random=str2num(random{1});
for i=1:random
    outfil=[name{1} 'r_' num2str(i) '.txt'];
    out(i)=fopen(outfil,'a');
end

fil=[name{1} split{1} '.txt'];lfil='';
fw=fopen(fil,'a');
while feof(f)==0
    s=fgets(f);
    s = regexprep(s, '</TEXT><TEXT>', ['</TEXT></DOC>' char(13) char(10) '<DOC><TEXT>']);
    s=regexprep(s,'<DOC><TEXT>',[char(13) char(10) '<DOC><TEXT>']);
    
    if rand<.01
        fprintf('.');
    end
    %    [party surename]=get_politics(savereportas,'v',party, surename);
    if findstr(' v</TEXT>',s)>0
        party='v';
    elseif findstr(' s</TEXT>',s)>0
        party='s';
    elseif findstr(' c</TEXT>',s)>0
        party='c';
    elseif findstr(' fp</TEXT>',s)>0
        party='fp';
    elseif findstr(' m</TEXT>',s)>0
        party='m';
    elseif findstr(' mp</TEXT>',s)>0
        party='mp';
    end
    i=findstr('page http',s);
    if not(isempty(i))
        ok=0;
        for i=1:length(split)
            if findstr(split{i},s)>0
                ok=i;
            end
        end
        if ok>0
            fil=[name{1} split{ok} '.txt'];
        else
            fil=[name{1} '_no_match.txt'];
        end
        if not(strcmpi(fil,lfil))
            lfil=fil;
            fprintf('\nWriting to %s',fil);
            fclose(fw);fw=fopen(fil,'a');
        end
    end
    fprintf(fw,s,'%s');
    fprintf(out(round(random*rand+.5)),s,'%s');
end
fclose(fw);
for i=1:random
    fclose(out(i));
end
return
for i=1:820000
    %for  i=111577-1:111577+1
    infil=['korpus/unzipped/' num2str(i) 'newsML.xml'];
    %    infil=['111577newsML.xml'];
    
    
    %One document
    in=fopen(infil,'r');
    if in>0
        if rand<.002
            infil
        end
        
        outnr=out(round(rand*11.9999999+.5));
        
        fprintf(outnr,'<DOC><TEXT>\n');
        while feof(in)==0
            text=fgets(in);
            
            n=strfind(text,'date="');
            if n>0
                fil=[text(n+8:n+9) text(n+11:n+12)];
                if isempty(strfind(fil,lfil))
                    fclose(monthfil);
                    lfil=fil;
                    monthfil=fopen([bib fil '.txt'],'w');
                end
            end
            
            if strcmpi(text(1:3),'<p>')
                fprintf(outnr,text(4:length(text)-6));
                fprintf(outnr,'\n');
                
                fprintf(monthfil,text(4:length(text)-6));
                fprintf(monthfil,'\n');
            end
        end
        
        fprintf(outnr,'</TEXT></DOC>\n');
        fprintf(monthfil,'</TEXT></DOC>\n');
        fclose(in);
        
        %else
        %fprintf(['nofile' infil]);
        
    end
    
end
for i=1:12
    fclose(out(i));
end
fclose(monthfil);

function open_space_Callback(hObject, eventdata, handles)
[FileName,PathName] =uigetfile2('*.spc','Open spaces','DefaultName');
if not(FileName==0)
    cd(PathName);
    f=fopen([PathName FileName],'r');
    space_time=fgets(f);
    fgets(f);
    fclose(f);
    set(handles.space_time,'string',deblank(space_time));
    getSpace('init');
end

function save_space_Callback(hObject, eventdata, handles)
[FileName,PathName] =uiputfile('*.spc','Save spaces');
if not(isempty(FileName))
    cd(PathName);
    f=fopen([PathName FileName] ,'w');
    fprintf(f,'%s \n ',get(handles.space_time,'string'));
    fclose(f);
end

function spacewalk_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice one word','kvinna');
if not(o.N==0)
    Spacewalk(o.word{1},s);
end

function ass_matrix_ab_Callback(hObject, eventdata, handles)
ass_matrix_Callback(hObject, eventdata, handles,'ab')

function ass_matrix_ab_rank_Callback(hObject, eventdata, handles)
ass_matrix_Callback(hObject, eventdata, handles,'rank')

function corr_matrix_ab_Callback(hObject, eventdata, handles)
ass_matrix_Callback(hObject, eventdata, handles,'corr')

function ass_matrix_Callback(hObject, eventdata, handles,ver)
s=getSpace('s');
[o s]=getWordFromUser(s,'Words for assocation matrix (columns)','');
if o.out.cancel; return; end
if nargin>3
    [or s]=getWordFromUser(s,'Words for assocation matrix (rows)','');
    if or.out.cancel; return; end
else
    or=o;ver='';
end
s=getSpace('s');
var{1,1}='word(s)';
r='';
r=[r sprintf('\nAssociation matrix (%s):\n\t',s.par.getPropertyShow)];
for i=1:length(o.input2)
    r=[r sprintf('%s\t%s',o.input2{i})];
    var{1,i+1}=o.input2{i};
end
pcorr=strcmpi(ver,'corr');
r=[r sprintf('\n')];
for i=1:length(or.input2)
    if not(pcorr) r=[r sprintf('%s\t',or.input2{i})];end
    var{i+1,1}=or.input2{i};
    for j=1:length(o.input2)
        if strcmpi(ver,'rank') & not(isnan(o.x1(j,1)) | isnan(or.x1(i,1) ))
            [di w{i,j}]=getProperty(s,o.index(j),or.index(i));
            dall=getProperty(s,o.index(j),1:length(s.x));
            d(i,j)=mean(di>=dall);
        else
            o.out.noprint=1;
            or.out.noprint=1;
            [o1a s]=getWord(s,o.input2{j},o.out);
            [o2a s]=getWord(s,or.input2{i},or.out);
            res=[];
            for k=1:length(o1a.index)
                [r2, word,s]=getProperty(s,o1a.index(k),o2a.index);
                res(k)=nanmean(r2);
            end
            %if iscell(word); word=word{1}; end
            w{i,j}=word;
            d(i,j)=mean(res);
        end
        if not(pcorr)
            if not(isempty(w{i,j}{1}))
                r=[r sprintf('%s\t',w{i,j}{1})];
                var{i+1,j+1}=w{i,j}{1};
            else
                r=[r sprintf('%.5f\t',d(i,j))];
                var{i+1,j+1}=num2str(d(i,j));
            end
        end;
    end
    if not(pcorr) r=[r sprintf('\n')]; end
end
s=getSpace('set',s);
if pcorr
    r=[r sprintf('\nCorrelation matrix\n\t')];
    for i=1:length(o.input2)
        r=[r sprintf('%s\t',o.input2{i})];
    end
    for i=1:length(o.input2)
        r=[r sprintf('\n%s\t',o.input2{i})];
        for j=1:length(o.input2)
            r=[r sprintf('%.2f\t',corr(d(:,i),d(:,j)))];
        end
    end
    
    r=[r sprintf('\nSignificance values for the correlation maxtrix\n\t')];
    for i=1:length(o.input2)
        r=[r sprintf('%s\t',o.input2{i})];
    end
    for i=1:length(o.input2)
        r=[r sprintf('\n%s\t',o.input2{i})];
        for j=1:length(o.input2)
            [tmp p]=corr(d(:,i),d(:,j));
            r=[r sprintf('%.4f\t',p)];
        end
    end
    
    r=[r sprintf('\n\nN=%d\nMean\t',length(or.input2))];
    for i=1:length(o.input2)
        r=[r sprintf('%.4f\t',mean(d(:,i)))];
    end
    r=[r sprintf('\nStandard deviation\t')];
    for i=1:length(o.input2)
        r=[r sprintf('%.4f\t',std(d(:,i)))];
    end
    r=[r sprintf('\n')];
end
% if strcmpi(get(handles.save_assocation_matrix,'checked'),'on')
%     [FileName,PathName] =uiputfile('*.txt','Save association table');
%     if isnumeric(FileName) && FileName==0
%     else
%         f=fopen([PathName FileName],'w');
%         [Ni Nj]=size(var);
%         for i=1:Ni;
%             for j=1:Nj
%                 if strcmpi(var{i,j},'NaN')
%                     var{i,j}='';
%                 end
%                 fprintf(f,'%s\t',var{i,j});
%             end
%             fprintf(f,'\n');
%         end
%         fclose(f);
%     end
% end
if strcmpi(get(handles.figure_ass_matrix,'checked'),'on')
    figure
    plot(d);
    set(gca,'Xtick',[0:length(or.word)])
    set(gca,'Xticklabel',or.word)
    legend(o.out.labels)
end


showOutput({r},sprintf('\nAssociation matrix (%s):\n\t',s.par.getPropertyShow))

function print_associates_Callback(hObject, eventdata, handles,selectedWords)
if nargin<4; selectedWords=0;end
s=getSpace('s');
[o1 s]=getWordFromUser(s,'Print associates to words','');
if o1.N==0 return; end;
fprintf('Semantic associates:\n');
%o2=getWordFromUser(savereportas,'Contracts words words for word frequency count (opitional)','');
if selectedWords
	[selelected s]=getWordFromUser(s,'From the selected words','*');
    s.par.semanticSelectWords=struct2string(s.fwords(selelected.index));
end

for j=1:length(o1.input2)
    print_nearest_associations_s(s,'print',o1.x1,'descend',o1.input2{j},o1);
end

function print_associates_time_Callback(hObject, eventdata, handles)
s=getSpace('s');
default.time_period=1;
[o s]=getWordFromUser(s,'Print associates across time','_eric*',default);
if o.N==0; return; end
N=str2num(inputdlg3('Divided words into number of time periods','10'));
fprintf('Semantic associates across time for: %s\n',o.input);

for k=1:2
    if k==2; fprintf('\nNow printing difference associates\n'); end
    allwords=average_vector(s,o.x);
    p=(o.time-min(o.time))/(max(o.time)-min(o.time));
    for t=1:N
        select=find(p>=(t-1)/N & p<t/N);
        t1=(t-1)/N*(max(o.time)-min(o.time))+min(o.time);
        t2=t/N*(max(o.time)-min(o.time))+min(o.time);
        d=[datestr(t1) ' to ' datestr(t2) ' N=' num2str(length(select))];
        word=average_vector(s,o.x(select,:));
        if k==2; word=word-allwords; end
        print_nearest_associations_s(s,'closest',word,'descend',d,o,1);
    end
end

function text_associates_selection_Callback(hObject, eventdata, handles)
print_associates_Callback(hObject, eventdata, handles,1)


function text_context_Callback(hObject, eventdata, handles)
nr=0;
s.wordlist=inputdlg2('Words to search for','Search',1,'');%outfil=outfil{1};
nr=inputdlg2('Stop after number of occurrences (0=all)','Search',1,{'20'});nrmax=str2num(nr{1});
printdoc=strcmpi('Yes',questdlg2('Print the whole document?','Documents','Yes','No','No'));
timeperiod=strcmpi('Yes',questdlg2('Print selected time period','Time-period','Yes','No','No'));
if timeperiod
    startdate=datenum(inputdlg3('Select start date','051020'),'yymmdd');
    stopdate=datenum(inputdlg3('Select stop date','051030'),'yymmdd');
else
    startdate=0;stopdate=0;
end

[fil,PathName]=uigetfile2('*.txt','Corpus file','');
fprintf('Searching string in %s...\n',fil);
f=fopen([PathName fil],'r');
fout=fopen('word_contexts.txt','w');
cont=1;article=1;
totalwords=0;doc1='';pr=0;nr=0;date='';datenr=-1;
info='';words='';
while feof(f)==0 & cont==1
    t=fgets(f);
    info=get_info(t,info,'',handles);
    if isfield(info,'time')
        datenr = info.time;%datenum(t(9:18),'yyyy-mm-dd');
        date=datestr(datenr);
    end
    doc1=[doc1 t];
    if strfind(lower(t),'</doc>')>0
        if pr & printdoc
            fprintf('%s\n',doc1);
        end
        article=article+1;
        doc1='';pr=0;date='';
        info='';
    end
    words=strread(t,'%s');
    totalwords=totalwords+length(words);
    if not(timeperiod) | (startdate<=datenr & stopdate>=datenr)
        for i=1:length(s.wordlist)
            a=find(strcmpi(lower(words),lower(s.wordlist{1})));
            if not(isempty(a))
                for j=1:length(a)
                    nr=nr+1;
                    pr=1;
                    if nr>=nrmax & nrmax~=0
                        cont=0;
                    end
                    if isfield(info,'source'); source=info.source;else source='';end
                    fprintf('\n%d(%d) %s, %s: ',nr,article,date,source);
                    fprintf(fout,'\n%d(%d) %s, %s: ',nr,article,date,source);
                    for i=max(1,a(j)-20):min(length(words),a(j)+20)
                        fprintf('%s ',words{i});
                        fprintf(fout,'%s ',words{i});
                    end
                end
            end
        end
    end
end

fprintf('\nFound %d instances in %s\nFrequency per million %.2f.\n',nr,fil,1000000*nr/totalwords);
fclose(fout);
beep2


function limit_hits_Callback(hObject, eventdata, handles)
swap_check(handles.limit_hits)

function help_Callback(hObject, eventdata, handles)
web('semantic.html');

function edit_Callback(hObject, eventdata, handles)
[FileName,PathName] =uigetfile2('*.txt','Open text file for edit','');
if not(FileName==0)
    edit([PathName FileName]);
end

function print_context_number_Callback(hObject, eventdata, handles)
N=inputdlg2('Line/document number','Line number',1);N=str2num(N{1});
Nprint=inputdlg2('Numbers of rows/documents to print','Line/row number',1);Nprint=str2num(Nprint{1});
%savereportas=getSpace('savereportas');
[fil,PathName]=uigetfile2('*.txt','Open file to print','');

f=fopen2([PathName fil],'r');
if strcmpi('Documents',questdlg2('Print documents or lines?','Print','Documents','Lines','Documents'));
    i=1;
    while i<N & not(feof(f))
        if findstr('</doc>',lower(fgets(f)))
            i=i+1;
        end
    end
    for j=1:Nprint
        i=0;
        while i<Nprint & not(feof(f))
            t=fgets(f);
            fprintf('%s',regexprep(t,char(13),''));
            if findstr('</doc>',lower(t))
                i=i+1;
            end
        end
    end
else
    cont=1;article=0;
    for i=1:max(1,N-20)
        t=fgets(f);article=article+1;
    end
    for i=1:Nprint
        t=fgets(f);article=article+1;
        fprintf('%s',regexprep(t,char(13),''));
    end
end
fclose(f);

function print_matches_Callback(hObject, eventdata, handles)
if strcmpi(get(handles.print_matches,'checked'),'off')
    set(handles.print_matches,'checked','on')
else
    set(handles.print_matches,'checked','off')
end

function print_dimension_values_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]=getWordFromUser(s,'Select word(s) to print values for each dimension','');
if o.ok
    fprintf('Values for each dimension:\n\t');
    for j=1:s.Ndim
        fprintf('dim%d\t',j);
    end
    fprintf('\n');
    for i=1:length(o.input2)
        fprintf('%s\t',o.input2{i});
        for j=1:s.Ndim
            fprintf('%.2f\t',o.x1(i,j));
        end
        fprintf('\n');
        if o.N>1
            fprintf('Standard deviations\n');
            fprintf('%s\t',o.input2{i});
            for j=1:s.Ndim
                fprintf('%.2f\t',std(o.x(:,j)));
            end
            fprintf('\n');
        end
    end
end

function use_database_Callback(hObject, eventdata, handles)
p=getdb_parameters();
max=0;

searchString_text=inputdlg3('Input words to extract contexts from (random articles)','');%,searchString_text);
max=str2num(inputdlg3('Maximum number of contexts to retreive (0=all):','0'));
searchStrings=strread(searchString_text,'%s');
phrase=0;
if length(searchStrings)>1
    if strcmpi(questdlg('Treat words as seperate units or a phrase','words','phrase','phrase','phrase'),'phrase')
        phrase=1;
    end
end

if phrase %Allow one string
    mk_contexts(handles,searchString_text,max);
else %Choice multiple words
    %searchStrings=searchString_text;
    for i=1:length(searchStrings)
        mk_contexts(handles,searchStrings{i},max);
    end
end


c=clock;

if 0
    results1 = fetch(p.conn_a,['START SLAVE;']);
    tic;ok=0;
    fprintf('Updating database for 60 seconds...\n');
    while ok==0 & toc<60
        results1 = fetch(p.conn_a,['SHOW SLAVE STATUS;']);
        ok=results1{33}==0;
    end
    fprintf('Updated=%d\n',ok)
    
    
    fprintf('Updated=%d\n',ok)
end


function add_context_words_Callback(hObject, eventdata, handles)
Kluster_Callback(hObject, eventdata, handles,1,0,1)

function add_context_document_Callback(hObject, eventdata, handles)
Kluster_Callback(hObject, eventdata, handles,1,1,0)



function [info, label, text]=get_info(text,info,label,handles)

e='try; info.time = datenum(text(tmp+8:tmp+8+9),''yyyy-mm-dd''); catch fprintf(''Incorrect date format\n''); end';
[text info label]=info_check(text,info,label,'<datum8>','</datum8>',e);
e='try;info.time=datenum(text(tmp+9:tmp+9+15),''yyyy-mm-dd HH:MM'');catch fprintf(''Incorrect date format\n''); end';
[text info label]=info_check(text,info,label,'<datum12>','</datum12>',e);
[text info label]=info_check(text,info,label,'<kalla_namn>','</kalla_namn>','info.source=text(tmp+12:tmp2-1);');
[text info label]=info_check(text,info,label,'<label>','</label>','label=text(tmp+7:tmp2-1);');
[text info label]=info_check(text,info,label,'<text_id>','</text_id>','label=[parameter(handles.word_prefix,''string'') ''_'' text(tmp+9:tmp2-1)];',handles);
[text info label]=info_check(text,info,label,'<data>','</data>','eval([regexprep(text(tmp+6:tmp2-1),''_'',''info.'') '';'']);');


function [text, info, label]=info_check(text,info,label,start,stop,e,handles)
tmp=findstr(text,start);
if not(isempty(tmp))
    tmp2=findstr(text,stop);
    if not(isempty(tmp2))
        command=text(tmp+length(start):tmp2-1);
        eval(e);
        text=[text(1:tmp-1) text(tmp2+length(stop):length(text))];
    else
        fprintf('Missing %s marker\n',stop);
    end
end


function plot_time_serie_Callback(hObject, eventdata, handles)
s=getSpace('s');
persistent h;
persistent ha;
persistent hb;

[o s]=getWordFromUser(s,'Choice words to plot as a function of time','_clinton* _clinton* _clinton* _clinton*');
if o.N==0; return; end

[out s]=getWordFromUser(s,'Choice regressor','_valence ');%_price_dp7
if out.N==0; return; end

Nsmooth=parameter(handles.time_smooth);
plot_articles=strcmpi(get(handles.time_words,'checked'),'on');
randomsubset=strcmpi(get(handles.time_randomsubset,'checked'),'on');
ztransform=strcmpi(get(handles.time_ztransform,'checked'),'on');
h=newfigure(s);
if strcmpi(get(handles.time_new_graf,'checked'),'on')
    try figure(h); catch; h=figure; end
else
    h=figure;
end
hold on;

word=out.word;
c(1)=NaN;clear t
%plot regression
col2=[.9 .9 .9];
input3=strread(o.input,'%s');
for k=1:length(input3)
    if strcmpi(get(handles.time_serie_cluster,'checked'),'on')
        if k==1
            condition_string=inputdlg3('Choise category to divided the graph','_categoryswedbank==1');%o.out.condition_string;
            o.out.condition=1;
        end
        o.out.condition_string=regexprep(condition_string,'1',num2str(k));
        [o s]=getWord(s,input3{k},o.out);
    end
    [o s]=getWord(s,input3{k},o.out);
    if length(o.index)>0
        t=getInfo(s,o.index,'time');
        
        if isnan(min(t));
            fprintf('None of your data points have set the _time properity, can not plot the data as a function of time!\n')
            beep
            return
        end
        
        
        [tmp index]=sort(t);
        t=t(index);
        j=min(k,length(out.word));
        %    for j=1:length(out.word)
        [or s]=getWord(s,word{j},out.out);
        r=getProperty(s,or.index,o.index(index));%Notice that index is the correct time ordering...!
        if strcmpi(get(handles.time_serie_cluster,'checked'),'on') && k==1
            %ftid=zeros(1,length(r));
            o.out.condition=0;
            [odivided s]=getWord(s,input3{k},o.out);
            tall=getInfo(s,odivided.index,'time');
            
            o.out.condition=1;
            baseline=mean(getProperty(s,or.index,odivided.index(index)));%Notice that index is the correct time ordering...!
        end
        N(j)=length(r);
        if ztransform
            r=(r-nanmean(r))/nanstd(r);
        end
        z=(r-nanmean(r))/nanstd(r);
        figure(h)
        [legend_h,object_h,plot_h,text_strings] = legend();
        label=[regexprep(input3{k},'_',' ') ' ' regexprep(word{j},'_',' ')];
        if plot_articles
            plot(t,r,'.','color',col2);
            [legend_h,object_h,plot_h,text_strings] = legend([text_strings label]);
        end
        col2=(rand(1,3)-.5)/10+[.9 .9 .9];
        col='rgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbky';
        clear rsmooth;
        if strcmpi(get(handles.time_average,'checked'),'on')
            for i=1:length(r)
                %rsmooth(i,1)=mean(r(find(abs(t-t(i))<=Nsmooth)));
                tmp=find((t-t(i))<=0 & (t-t(i))>-2*Nsmooth);
                rsmooth(i,1)=mean(r(tmp));
                if strcmpi(get(handles.time_serie_cluster,'checked'),'on')
                    tmp_all=find((tall-t(i))<=0 & (tall-t(i))>-2*Nsmooth);
                    if isempty(tmp_all) tmp_all=1; end
                    rsmooth(i,1)=(rsmooth(i,1)-baseline)*length(tmp)/length(tmp_all)+baseline;
                end
            end
        else
            rsmooth=smooth(r,Nsmooth);
        end
        if ztransform
            rsmooth=(rsmooth-nanmean(rsmooth))/nanstd(rsmooth);
        end
        if not(randomsubset)
            plot(t,rsmooth,col(length(text_strings)+1),'linewidth',2);
            [legend_h,object_h,plot_h,text_strings] = legend([text_strings label]);
        else %Plot random subset
            r1=rand(1,length(r))>.5;
            plot(t(find(r1)),smooth(r(find(r1)),Nsmooth),col(length(text_strings)+1),'linewidth',2);
            [legend_h,object_h,plot_h,text_strings] = legend([text_strings label]);
            plot(t(find(not(r1))),smooth(r(find(not(r1))),Nsmooth),col(length(text_strings)+1),'linewidth',2);
            [legend_h,object_h,plot_h,text_strings] = legend([text_strings label]);
        end
        
        if k==1
            date=min(t):max(t);
        end
        rsmootht(:,k)=get_timeserie(rsmooth,t,date);%Create a number for each date...
        
        if strcmpi(get(handles.plot_bs,'checked'),'on')
            price=getInfo(s,o.index(index),'price');
            pricet(:,k)=get_timeserie(price,t,date);
            
            f=fopen('stockinfo.txt','a');
            for i=1:length(date)
                fprintf(f,'%s %d %.2f %.4f\n',regexprep(regexprep(o.input,'_',' '),'*',''),date(i),pricet(i,k),rsmootht(i,k));
            end
            fclose(f);
            
            rt(1)=NaN;rtp(length(rt))=NaN;
            if k==length(input3) %print predicted buy/sell
                x=rsmootht;p=pricet;
                cont=1;
                while cont
                    ecrit=parameter(handles.buy_criterion,'string');
                    weights=[str2num(parameter(handles.time_serie_buy_weights,'string')) zeros(1,k)];
                    weights=weights(1:k);
                    weights=weights/sum(weights);
                    buy(1)=1;
                    for i=1:length(date)
                        try; eval(['[tmp buy(i,:)]=sort(' ecrit ',''descend'');']); catch; buy(i,1:k)=1:k; end
                        if i==1
                            capital(1,1:k)=1;
                        else %if buy(i-1)
                            tmp=p(i,:)./p(i-1,:);
                            tmp=tmp(buy(i,:)).*weights(1:k);
                            capital(i)=capital(i-1)*sum(tmp);
                            %else
                            %    capital(i)=capital(i-1);
                        end
                    end
                    for k2=1:k
                        ptmp(k2,:)=pricet(:,k2)/pricet(1,k2);
                    end
                    %fprintf('Mean time invested: %.2f\n',nanmean(buy));
                    fprintf('Capital/index ratio at last time step: %.2f\n',capital(length(capital))/mean(ptmp(:,length(ptmp))));
                    Nbuys=sum(not(buy(2:length(buy))==buy(1:length(buy)-1)));
                    fprintf('Number of buys: total=%d, percentage=%.2f\n',Nbuys,Nbuys/length(buy));
                    
                    try figure(hb); catch; hb=figure; end
                    clf
                    hold on
                    [legend_h,object_h,plot_h,text_strings] = legend;
                    plot(date,capital,col(length(text_strings)+1),'linewidth',2);
                    [legend_h,object_h,plot_h,text_strings] = legend([legend ' accumulated capital']);
                    plot(date,mean(ptmp),col(length(text_strings)+1),'linewidth',2);
                    [legend_h,object_h,plot_h,text_strings] = legend([text_strings ' stock price']);
                    %plot(date,buy/(2*length(input3)),col(length(text_strings)+1),'linewidth',2);
                    for i=1:length(date)
                        for k2=1:length(input3)
                            tmp=.5-buy(i,k2)/(2*length(input3));
                            if weights(k2)>0
                                line(date(i):date(i)+1,[tmp tmp],'linewidth',7*weights(k2),'color',col(buy(i,k2)))
                            end
                        end
                    end
                    [legend_h,object_h,plot_h,text_strings] = legend([text_strings ' buy/sell,'],'location','northwest');
                    set(gca,'xticklabel',datestr(get(gca,'xtick'),'yymmdd'))
                    set(gcf,'ResizeFcn','set(gca,''xticklabel'',datestr(get(gca,''xtick''),''yymmdd''))');
                    xlabel(['buy criteria: ' ecrit])
                    
                    try figure(hstock); catch; hstock=figure; end
                    hold on
                    for k2=1:k
                        plot(date,pricet(:,k2)/pricet(1,k2),col(k2),'linewidth',2);
                    end
                    legend(regexprep(input3,'_',' '),'location','northwest');
                    set(gca,'xticklabel',datestr(get(gca,'xtick'),'yymmdd'))
                    plot(date,buy/(2*length(input3)),col(length(text_strings)+1),'linewidth',2);
                    
                    figure(hb)
                    cont=strcmpi('Yes',questdlg2('Replot with new buy criteria','Criteria','Yes','No','No'));
                    if cont
                        parameter(handles.buy_criterion,'set');
                        parameter(handles.time_serie_buy_weights,'set');
                    end
                end
            end
        end
        if strcmpi(get(handles.time_autocorrelation,'checked'),'on')
            if not(exist('ocross'))
                [ocross s]=getWordFromUser(s,'Choice cross-correlation regressor','_price_dp7');
            end
            lr=getProperty(s,ocross.index,o.index(index));%Notice that index is the correct time ordering...!
            lrsmooth=lr;
            lrsmootht=shiftdim(get_timeserie(lr,t,date),1);
            
            c=corr(shiftdim(r,1),shiftdim(lr,1),'rows','complete');
            fprintf('Correlation before smoothing %s %s r=%.3f\n',word{j},'price',c);
            crsmooth=corr(rsmooth,shiftdim(lrsmooth,1),'rows','complete');
            fprintf('Correlation after smoothing %s %s r=%.3f\n',word{j},'price',crsmooth);
            fprintf('Cross-correlation: \n');
            id=200;
            
            for i=-id:id
                if strcmpi(get(handles.time_auto_words,'checked'),'on')
                    c2(k,i+id+1)=corr([nan(-i,1); shiftdim(r(1+max(0,i):length(r)+min(0,i)),1); nan(i,1)],shiftdim(lr,1),'rows','complete');
                elseif 1
                    c2(k,i+id+1)=corr([nan(-i,1); rsmootht(1+max(0,i):length(rsmootht)+min(0,i),k); nan(i,1)],lrsmootht,'rows','complete');
                else
                    c2(k,i+id+1)=corr([nan(-i,1); rsmooth(1+max(0,i):length(rsmooth)+min(0,i)); nan(i,1)],lrsmooth,'rows','complete');
                end
                fprintf('%.3f ',c2(k,i+id+1));
            end
            try figure(ha); catch; ha=figure; end
            hold on;
            plot(-id:id,c2(k,:),col(length(text_strings)+1),'linewidth',2);
            legend(regexprep(input3,'_',' '));
            title('Cross-correlation');
            xlabel('days');ylabel('correlation')
            
            try figure(hauto1); catch; hauto1=figure; end
            plot(-id:id,mean(c2),'linewidth',2);
            title('Mean cross-correlation');
            xlabel('days');ylabel('correlation')
            
            title(['Cross-correlation ' regexprep(ocross.input2{1},'_',' ') ' and ' regexprep(out.input2{1},'_',' ')]);
            fprintf('\n');
            [cmax imax]=max(c2(k,:));
            fprintf('Maximum cross-correlation (%.3f) at %d time steps\n',cmax,imax-id-1);
        end
    end
    if strcmpi(get(s.handles.keywords_frequency,'checked'),'on') %add labels
        N1=length(rsmooth);f=10/length(rsmooth);
        h1 = fir1(N1,f,'low');%The higher value the more linish...
        tmp= conv(h1,rsmooth);
        tmp=tmp(N1/2+1:length(tmp)-N1/2);%Removes padding...
        figure(102);hold off;
        plot(t,rsmooth,'r');
        hold on;
        plot(t,tmp,'linewidth',3);
        
        for i=2:length(tmp)-1
            if not(sign(tmp(i)-tmp(i-1))==sign(tmp(i+1)-tmp(i)))
                indexk=find(abs(t-t(i))<2);
                fprintf('peak at %s N=%d ',datestr(t(i)),length(indexk));
                otmp.index=o.index(indexk);%Mean vector should be correct....
                [d, index,keywords]=print_nearest_associations_s(s,'closest',mean(s.x(indexk,:)),'descend','',otmp);
                line([t(i),t(i)],[rsmooth(i)-.1,rsmooth(i)+.1],'linewidth',3)
                for k2=1:10
                    text(t(i), rsmooth(i)+.55-k2*.05,keywords{k2})
                end
            end
        end
        tmp=tmp;
    end
end


figure(h)
title(regexprep(regexprep(o.input,'_',' '),'*',''),'fontsize',16)
set(gca,'xticklabel',datestr(get(gca,'xtick'),'yymmdd'))
set(gca,'ButtonDownFcn','set(gca,''xticklabel'',datestr(get(gca,''xtick''),''yymmdd''))');
set(gcf,'ButtonDownFcn','set(gca,''xticklabel'',datestr(get(gca,''xtick''),''yymmdd''))');
set(gcf,'ResizeFcn','set(gca,''xticklabel'',datestr(get(gca,''xtick''),''yymmdd''))');
set(gcf,'WindowButtonDownFcn','set(gca,''xticklabel'',datestr(get(gca,''xtick''),''yymmdd''))');

xlabel(['time period from ' datestr(min(t)) ' to ' datestr(max(t)) ' r=' num2str(c(1)) ' N=' num2str(N(1))])
%autosave('timeserie_');

if strcmpi(get(handles.save_assocation_matrix,'checked'),'on')
    [FileName,PathName] =uiputfile('*.txt','Save time graf data');
    if not(FileName(1)==0)
        f=fopen([PathName FileName],'w');
        [Ni Nj]=size(rsmootht);
        for i=1:Ni
            fprintf(f,'%s ',datestr(date(i)));
            for j=1:Nj
                fprintf(f,'%.4f ',rsmootht(i,j));
            end
            fprintf(f,'\n');
        end
        fclose(f);
    end
end

s=[];save('stocks')

function [rt, date]=get_timeserie(r,t,date);
if nargin<3
    date=min(t):max(t);
end
for i=1:length(date)
    select=find(t>=date(i) & t<date(i)+1);
    rt(i)=nanmean(r(select));
    if isnan(rt(i))
        if i==1
            rt(1)=r(1);
        else
            rt(i)=rt(i-1);
        end
    end
end



% --------------------------------------------------------------------
function Cluster_time_plot_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_time_plot_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fil,PathName]=uigetfile2('Cluster*.mat','Open cluster-file','');load([PathName fil]);

%if strcmpi('Yes',questdlg2('Print valence and time','Time','Yes','No','No'));
%reg{1}='_active';reg=inputdlg2('Choice word to make regression on','Regression',1,reg);reg=reg{1};
reg=inputdlg3('Choice word to make regression on','_valence');
[val a]=valence_calc(s,x,reg);
%figure
[tmp index]=sort(doc_date);
%plot_(doc_date(index),val(index));
%xlabel(['Time: ' datestr(doc_date(index(1))) ' - ' datestr(doc_date(index(length(doc_date))))] );ylabel('valence');

figure;hold on
temp1=doc_date(index);temp2=val(index);temp3=countj(:,index);temp4=doc_date(index);
col='mcrgbwkymcrgbwkymcrgbwky';
smoothN{1}='200';smoothN=inputdlg2('Number of data points for smoothing','Smooth',1,smoothN);smoothN=str2num(smoothN{1});
k=0;
for i=1:Nkluster
    select=find(temp3(i,:)>0 & temp4>0);
    if not(isempty(select))
        k=k+1;
        %[tmp select1]=find(doc_date<doc_date(length(doc_date)/2));
        select1=find(temp3(i,:)>0 & temp4>0 & doc_date(index)<doc_date(round(length(doc_date)/2)));
        select2=find(temp3(i,:)>0 & temp4>0 & doc_date(index)>=doc_date(round(length(doc_date)/2)));
        m1(k)=mean(temp2(select1));m2(k)=mean(temp2(select2));
        s1(k)=std(temp2(select))/length(select)^0.5;
        fprintf('%s m(t1)=%.3f m(t2)=%.3f m(t1)-m(t2)=%.3f std=%.3f N1=%d N2=%d\n',clustername{i},m1(k),m2(k),m1(k)-m2(k),s1(k),length(select1),length(select2));
        plot(temp1(select),temp2(select),[col(min(length(col),i)) '.'],'Markersize',2);
        plot(temp1(select),smooth(temp2(select),smoothN),[col(min(length(col),i))]);
        legend_name{k*2-1}=clustername{i};
        legend_name{k*2}=clustername{i};
    end
end
z=((m1(1)-m2(1))-(m1(2)-m2(2)))/(s1(1)^2+s1(2)^2)^.5;
fprintf('Difference of difference t1 - t2 z=%.3f p=%.3f\n',z,cdf('norm',z,0,1));

xlabel(['Time: ' datestr(min(doc_date(doc_date>0))) ' - ' datestr(doc_date(index(length(doc_date))))] );ylabel('valence');
legend(legend_name)
r(1)=NaN;
for i=1:Nkluster
    if exist([clustername{i} '.txt'])
        fid = fopen([clustername{i} '.txt']);
        data = textscan(fid,'%s%f%f%f%f%f%f');
        fclose(fid);
        datenr = datenum(data{1},'yyyy-mm-dd');
        figure;hold on
        
        select=find(temp3(i,:)>0 & temp4>0);
        plot(temp1(select),(temp2(select)-mean(temp2(select)))/std(temp2(select)),'g.','MarkerSize',2);%valence
        diffprice=data{2}(2:length(data{2}))-data{2}(1:length(data{2})-1);
        diffprice=smooth(diffprice,smoothN);
        plot(datenr(2:length(datenr)),(diffprice-mean(diffprice))/std(diffprice),'y');%price change smooth
        plot(datenr,(data{2}-mean(data{2}))/std(data{2}),'b');%price
        clear pred;
        for j=1:length(data{1})
            s=0;w=0;
            for k=1:length(temp1(select))
                %if datenr(j)>=temp1(select(k)) & datenr(j)-60<=temp1(select(k))
                if (datenr(j)-temp1(select(k)))<30 %Select +/- one month
                    w0=pdf('norm',datenr(j)-temp1(select(k)),0,30);%*temp3(i,select(k));
                    s=s+temp2(select(k))*w0;
                    w=w+w0;
                end
            end
            if w>0
                pred(j)=s/w;
            else
                pred(j)=NaN;
            end
        end
        plot(datenr,(pred-nanmean(pred))/nanstd(pred),'r');
        
        select2=find(not(isnan(pred)));
        diffpred=pred(2:length(select2))-pred(1:length(select2)-1);
        diffpred=smooth(diffpred,smoothN);
        plot(datenr(select2(1:length(select2)-1)),(diffpred-nanmean(diffpred))/nanstd(diffpred),'color',[.8 .8 .08]);
        set(gca,'Ylim',[-7 7]);
        
        legend({'valence','smooth change in price ','price','smooth valence'});
        ylabel('z-score');
        xlabel(['Time: ' datestr(min(doc_date(select))) ' - ' datestr(max(doc_date(select)))] );
        saveas(gcf,clustername{i})
        select2=find(not(isnan(pred)));
        [r(i) p]=corr(shiftdim(pred(select2),1),data{2}(select2));
        N=sum(temp3(i,select)>0);
        fprintf('%s: correlation price and smooth valence %.3f p=%.4f N=%d\n',clustername{i},r(i),p,N)
        title([clustername{i} ' r=' num2str(r(i)) ' N=' num2str(N) ]);
    end
end
fprintf('Mean correlation: %.3f \n',mean(r))
%end
%Y = fft(sin(0:.01:2*pi),512);
%Pyy = Y.* conj(Y) / 512;
%plot(Pyy)
%plot(ifft(Pyy(1:length(Pyy)/2)))



function Cluster_print_articles_Callback(hObject, eventdata, handles)
doc1=[];
[fil,PathName]=uigetfile2('Cluster*.mat','Open cluster-file','');load([PathName fil]);

%Prints documents ordered by cluster...
if not(exist('N')==1)
    fprintf('No clustering made\n');
elseif not(exist('doc1')==1)
    fprintf('Articles not saved!\n');
else
    if exist('clustername2')
        for i=1:length(clustername2)
            fprintf('Number: %d Name: %s\n',i,clustername2{i});
        end
    end
    clear print_cluster;print_cluster{1}='';print_cluster=inputdlg2('Cluster to print (deafault all)','Print cluster ',1,print_cluster);print_cluster=str2num(print_cluster{1});
    clear print_N;print_N{1}='';print_N=inputdlg2('Number of documents to print (deafault all)','Print number ',1,print_N);print_N=str2num(print_N{1});
    for k=1:N
        Nprinted=0;
        for i=1:count-1
            if y(i)==k & (find(print_cluster==k) | isempty(print_cluster)) & (Nprinted<print_N | isempty(print_N))
                Nprinted=Nprinted+1;
                fprintf('CLUSTER %d Document %d ',k,i);
                for j=1:30
                    fprintf('%s ',word{k}{j});
                end
                fprintf('\n%s',regexprep(doc1{i},char(13),' '));
            end
        end
    end
end

% --------------------------------------------------------------------
function Cluster_save_space_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_save_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles_tmp=handles;
[fil,PathName]=uigetfile2('Cluster*.mat','Open cluster-file','');load([PathName fil]);
s.handles=handles_tmp;
if exist('N')==1
    file=inputdlg3('Name of documents to add','_doc');
    inclusion=inputdlg3('Only add this word','');
    for j=1:length(x) %Add documents...
        clear info;
        tmp=['_doc' num2str(doc_number(j))];
        for i=1:Nkluster %Add clusters...
            if countj(i,j)>0
                tmp=[tmp '_' clustername{i}];
                info.data{i}=clustername{i};
            end
        end
        if rand<.001
            fprintf('.');
        end
        info.time=doc_date(j);
        info.countj=countj(:,j);
        if not(isempty(findstr(tmp,inclusion))) | length(inclusion)==0
            s=addX2space(s,tmp,x(j,:),info);
        end
    end
    fprintf('\ndone, do not forget to save the new space!\n');
    beep2
elseif 0
    File{1}=['Dic_'];File=inputdlg2('Filename?','Filename',1,File);
    dmtx=s.x;dord=s.fwords;
    %skip=savereportas.skip;
    k=length(dord);
    dmtx(length(dord)+length(x),:)=zeros(1,s.Ndim);
    dord{length(dord)+length(x)}='';
    for j=1:length(x) %Add documents...
        k=k+1;
        dmtx(k,:)=x(j,:);
        tmp=['_doc' num2str(doc_number(j))];
        for i=1:Nkluster %Add clusters...
            if countj(i,j)>0
                tmp=[tmp '_' clustername{i}];
            end
        end
        if rand<.001
            fprintf('.');
        end
        dord{k}=[tmp '_@' clustername2{y(j)}];
        %skip(k)=0;
        doc_time(k)=doc_date(j);
    end
    for j=1:N %Add clusters...
        k=k+1;
        v=mean(x(find(y==j),:));
        dmtx(k,:)=v/(sum(v.^2)^.5);
        dord{k}=['_cluster' num2str(j) '_$' clustername2{j}];
        %skip(k)=0;
    end
    fprintf('\nSaving\n');
    save(File{1},'dmtx','dord','doc_time');
    beep2
else
    fprintf('No clustering made!\n');
end

function [Y, a]=valence_calc(s,x,reg)
vectorfile=['valensvector_' s.active_space '.txt'];
if exist(vectorfile)
    a=load(vectorfile ,'-ASCII', 'a');
elseif nargin>2 %& strcmpi(reg,'_valence')==0
    vectorfile=[reg(2:length(reg)) '_' s.active_space '.rgv'];
    if exist(vectorfile)==2
        a=load(vectorfile ,'-ASCII', 'a');
    else
        a=shiftdim([0 wordstring2vector(s,reg)],1);
    end
end
X = [ones(size(x(:,1))) x];
Y = [X*a];

function plot_distribution_diff_Callback(hObject, eventdata, handles)
s=getSpace('s');

ow=getWordMany(s,'Choice set of words to plot','*a');

[ow1 s]=getWordFromUser(s,'First (of two) set of words to plot on the (x-axis)','*a');
if ow1.N==0; return; end

[ow2 s]=getWordFromUser(s,'Second set of words to plot on the (x-axis)','*b');
if ow2.N==0; return; end


%if 1 %New version, excludes the to-be plotted data point from averaging (no artifacts)
propertyX=fixpropertyname([ow1.input_clean 'm' ow1.input_clean 'x']);
propertyX=fixpropertyname(inputdlg3('Save results to property (cancel=no saving)',propertyX));

if strcmpi('Yes',questdlg2('Add a data-sets on the y-axsis','Text','Yes','No','Yes'))
    [ow3 s]=getWordFromUser(s,'Third set of words to plot (y-axis)','*b');
    if ow3.N==0; return; end
    [ow4 s]=getWordFromUser(s,'Fourth set of words to plot(y-axis)','*b');
    if ow4.N==0; return; end
    propertyY=fixpropertyname([ow3.input_clean 'm' ow4.input_clean 'y']);
    propertyY=fixpropertyname(inputdlg3('Save results to property (cancel=no saving)',propertyY));
    
else
    ow3=[];
    ow4=[];
end
normalDist=strcmpi('Yes',questdlg2('Add normal distributions','Text','Yes','No','Yes'));
addLabels=strcmpi('Yes',questdlg2('Add text labels','Text','Yes','No','Yes'));

plotDifference(s,ow,ow1,ow2,propertyX,ow3,ow4,propertyY,normalDist,addLabels);


function create_random_corpus_files_Callback(hObject, eventdata, handles)
s=getSpace('s');
Np=0;
models=length(strread(get(handles.space_time,'string'),'%s'));
m_max{1}=num2str(models);
m_max=inputdlg2('Number of random corpus files to create','Create random corpus files',1,m_max);m_max=str2num(m_max{1});
tags= strcmpi( 'Yes', questdlg2('Divide corpuses by cluster tags?','Tags','Yes','No','Yes'));

for i=1:m_max
    out(i)=fopen(['b_' num2str(i) '.sum'],'w');
end
for i=1:models
    filnr=fix(rand*m_max+1);
    fprintf('\nOpening corpus %s\n',s.models{i});
    f=fopen(['korpus/' s.models{i} '.sum'],'r');
    if tags
        for j=1:m_max
            fprintf(out(j),'\n_cluster %s\n',s.models{i});
        end
    end
    while not(feof(f))
        a=fgets(f);
        fprintf(out(filnr),'%s',a);
        if not(isempty(strfind(a,'</DOC>')))
            filnr=fix(rand*m_max+1);
        end
        if rand<.0002
            fprintf('.');Np=Np+1;
            if Np>100
                fprintf('\n');Np=0;
            end
        end
    end
    fclose(f);
end

for i=1:m_max
    fclose(out(i));
end
beep2


% --------------------------------------------------------------------
function lsa_Callback(hObject, eventdata, handles)
ver=questdlg2(['Create space from'],'File','File','Context','Report','Report');
if strcmpi(ver,'File')
    s=createSpace;
else
    s=createSpaceFromContext(getSpace,ver);
end
if not(isempty(s))
    s=getNewSpace(s.filename);
end
return

%This is the in Infomap version, which is NOT USED!
%if strcmpi('Matlab',questdlg2(['Create space with'],'Infomap','Infomap','Matlab'))
%end

% hObject    handle to lsa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path{1}=pwd;path=inputdlg2('Infomap directory','Creating LSA space in unix enviroment',1,path);
%file{1}='test';file=inputdlg2('Corpus file','Creating LSA space in unix enviroment',1,file);
[corpus,PathName]=uigetfile2('*.txt','Choice corpus file','');
modelname=inputdlg3('Choice model name',regexprep(corpus,'.txt',''));
fprintf('Use this syntax on the corpus file: <DOC><TEXT>\nINSERT YOUR TEXT HERE\n</TEXT></DOC>\n');

PathName=regexprep(PathName,' ','\\ ');
a{1}=['export INFOMAP_WORKING_DIR=' path{1}];
a{2}=['export INFOMAP_WORKING_PATH=' path{1}];
a{3}=['export INFOMAP_MODEL_PATH=' path{1}];
a{4}=['rm ' path{1} '/' modelname '/*' ];
a{5}='PATH=$PATH\:/sw/bin:/sw/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/X11R6/bin:/dir/path ; export PATH';
a{6}=['infomap-build -s ' PathName corpus ' ' modelname];
a{7}=['cd ' modelname];
a{8}=['associate -c ' modelname ' kvinna'];
a{9}=['echo sudo su'];
a{10}=['echo emacs /usr/local/share/infomap-nlp/default-params'];
a{11}=['echo emacs /usr/local/share/infomap-nlp/valid_chars.en'];
for i=1:length(a)
    fprintf('%s\n',a{i});
end
%a=1;

a2=[];
for i=1:length(a);
    a2=[a2  a{i} ';'];
end
fprintf('\nNow running these statements in the unix enviroment:\n')
for i=1:length(a)
    fprintf('%s\n',a{i});
end

if 0
    %Set parameters...
    i=0;f1=fopen('/usr/local/share/infomap-nlp/default-params','r');
    
    %chmod a+w /usr/local/share/infomap-nlp/stop.list
    
    d=db2struct('stopwords',num2str(par.language));
    if isempty(d)
        stopfile='stop.list';fprintf('No stopword file for language %d\n',par.language);
    else
        d=rmfield(d,'id');
        struct2file(d,['/usr/local/share/infomap-nlp/stop.list']);
    end
    
    while not(feof(f1))
        w=fgets(f1);
        w=replace(w,'SINGVALS=',par.Ndim);
        w=replace(w,'PRE_CONTEXT_SIZE=',par.contextSize);
        w=replace(w,'POST_CONTEXT_SIZE=',par.contextSize);
        fprintf('%s',w);
        i=i+1;word{i}=w;
    end
    fclose(f1);
    f1=fopen('/usr/local/share/infomap-nlp/default-params','w');
    for i=1:length(word)
        fprintf(f1,'%s',word{i});
    end
    fclose(f1);
end

system(a2)

clear a;i=0;
i=i+1;a{i}=['Check these files to sets up parameters: '];
i=i+1;a{i}=['sudo su'];
i=i+1;a{i}=['emacs /usr/local/share/infomap-nlp/default-params'];
i=i+1;a{i}=['emacs /usr/local/share/infomap-nlp/valid_chars.en'];
i=i+1;a{i}=['emacs /usr/local/share/infomap-nlp/stop.list'];

fprintf('\nPaste the code below into the terminal window before continuing\n')
for i=1:length(a)
    fprintf('%s\n',a{i});
end
savedir=pwd;
mkdir(modelname);
cd(modelname);
s=makespacefile(modelname);
cd(savedir);
movefile([modelname '/' s.filename], s.filename)
fprintf('Space %s created!\n',s.filename),
%a{5}=['/infomap-nlp-0-1.8.6-pna-sve-mod/admin/infomap-build -savereportas ' PathName
%'/' par.corpusName '.txt ' modelname];

%fprintf('\nPaste the code above into the terminal window before
%continuing\n')
%pause
%system();



function rename_files
path='korpus\';
fil=dir(path);
for i=1:length(fil.name);
    if not(isempty(findstr(fil(i).name,'.sum')>0))
        system(['rename ' path fil(i).name ' ' path regexprep(fil(i).name,'.sum','.txt')]);
    end
end

function cmp_contexts_Callback(hObject, eventdata, handles)
[fil1,PathName]=uigetfile2('*.mat','Context file 1','DefaultName');
[fil2,PathName]=uigetfile2('*.mat','Context file 2','DefaultName');
[fil3,PathName]=uigetfile2('*.mat','Context file 3','DefaultName');
load(fil1);x1=dmtx;skip1=skip;
load(fil2);x2=dmtx;skip2=skip;
load(fil3);x3=dmtx;skip3=skip;
correct=0;N=0;
for i=1:length(dord);
    if skip1(i)==1 | skip2(i)==1 | skip3(i)==1
        fprintf('%d Missing %d %d  %d\n',i,skip1(i),skip2(i),skip3(i));
    else
        N=N+1;
        d13(N)=sum(x1(i,:).*x3(i,:));d23(N)=sum(x2(i,:).*x3(i,:));
        if d13(N)>d23(N)
            correct=correct+1;
        end
        fprintf('%d 1-3 %.3f 2-3 %.3f\n',i,d13(N),d23(N));
    end
end
fprintf('correct %d N %d\n',correct,N);
[h p]=ttest(d13-d23)
a=1;

function mk_context_Callback(hObject, eventdata, handles)
s=getSpace('s');
[file,PathName]=uigetfile2('*.txt','Make context vectors from text file','DefaultName');
f=fopen(file,'r');
fprintf('File: %s\n',file);
i=0;
found=0;
while not(feof(f))
    i=i+1;
    a=lower(fgets(f));
    c=string2cell(a);
    v=zeros(1,s.Ndim);skip(i)=1;
    fprintf('\nRow %d: ',i);
    for k=1:length(c)
        m=find(strcmpi(s.fwords,c{k}));
        if not(isempty(m))
            m=m(1);
            v=v+s.x(m,:);found=found+1;skip(i)=0;
        end
        fprintf('%s %d ',c{k},not(isempty(m)) & sum(v.^2)^.5>0);
    end
    if sum(v.^2)^.5==0
        skip(i)=1;
        dmtx(i,:)=ones(1,s.Ndim)*NaN;
    else
        skip(i)=0;
        dmtx(i,:)=v/sum(v.*v);
    end
    dord{i}=['doc' num2str(i)];
    context{i}=c;
end
fprintf('\nDocuments found %d\nDone.\n',i);
beep2
name{1}=[regexprep(file,'.txt','')];
name=inputdlg2('File name document space','filenname',1,name);
save (name{1},'dmtx','dord','skip','context');


function PCA_Callback(hObject, eventdata, handles)
[FileName,PathName] =uigetfile2('*.mat','Open spaces for PCA','DefaultName');
load([PathName FileName]);
[pc,score,latent,tsquare] = princomp(s.x,'econ');
figure;plot(latent);
title('Eiqenvalues');xlabel('number of eigenvalue');ylabel('eigenvalue');
if strcmpi('Yes',questdlg2('Save PCA to mat file?','PCA','Yes','No','Yes'));
    [tmp N]=size(score);
    N=inputdlg3('Number of components to keep?',num2str(N));N=str2num(N);
    s.x=score(:,1:N);
    File{1}=['PCA_' FileName];File=inputdlg2('Filename?','Filename',1,File);
    save(File{1},'s');
end


function print_vocabulary_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]=getWordFromUser(s,'Print name of the following words','*');
if o.N==0 return; end
for i=1:length(o.word)
    fprintf('%s\t',o.word{i});
    if round(i/10)-i/10==0
        fprintf('\n');
    end
end
fprintf('\nFound %d words\n',length(o.word));


function clean_greece
f=fopen ('page_archive_greek.txt','r');
i=0;
while not(feof(f)) & i<200
    i=i+1;
    s=fgets(f);
    s = regexprep(s,'& xa0;','');%
    s = regexprep(s,'& xb3;','');%
    s = regexprep(s,'&mdash;','');%
    
    s = regexprep(s,'0','');%
    s = regexprep(s,'1','');%
    s = regexprep(s,'2','');%
    s = regexprep(s,'3','');%
    s = regexprep(s,'4','');%
    s = regexprep(s,'5','');%
    s = regexprep(s,'6','');%
    s = regexprep(s,'7','');%
    s = regexprep(s,'8','');%
    s = regexprep(s,'9','');%
    
    fprintf('%s',s);%disp(s);
end
fclose(f);

function clean_greece_output
e ? ?? 109 189
n ?? 110 189
%savereportas='[??? ???? ??? ????????? ?????????????? ??????]';
%[? ????????? ???????? ???]
s
s = regexprep(s,'??','e');%?
s = regexprep(s,'??','n');%e'
s
a=urlread('http://epigraphy.packhum.org/inscriptions/oi?ikey=70&caller=search&bookid=4&region=1&subregion=0');

f=fopen('test.txt','r');
a2=fgets(f)
a2*1
fclose(f);

[FileName,PathName] =uigetfile2('*.txt','File to do search and replace','DefaultName');
FileName='associations_test_greece.txt'
FileName='gtest.txt'
fi=fopen(FileName,'r');
f=fopen(['Out_' FileName],'w');
%fprintf(f,'%c%c%c%c',255,   254  , 189,     3);
clear s
s(1)=239;s(2)=187;s(3)=191;%s(4)=206;s(5)=189;%s(6)=97;
for i=1:length(s)
    fprintf(f,'%c',s(i)*1);
end
%savereportas=['>[??? ????????????????? ???????????????? ??????]'];%??? ????????? ?????????????? ??????';
%>[??? ????????????????? ???????????????? ??????]
%[? ????????? ???????? ???]
%c=144;
%savereportas = regexprep(savereportas,'?',c);%?
while not(feof(fi))
    s=fgets(fi);
    s = regexprep(s,'?','?');%?
    %savereportas
    for i=1:length(s)
        if 1
        elseif s(i)==26
            s(i)=144;
        elseif s(i)==710
            s(i)=136;
        elseif s(i)==8222
            s(i)=132;
        elseif s(i)==8364
            s(i)=128;
        elseif s(i)==8240
            s(i)=137;
        end
        fprintf(f,'%c',s(i)*1);
        %   fprintf('%d ',savereportas(i)*1);
    end
    %fprintf(f,'\n');
end
fclose(f);fclose(fi);

slCharacterEncoding('UTF-8')
%  f=fopen('dic.txt','r');
% name=fgets(f)

%  name='r?ksm?rg?s'
%  name='[??? ????????????????? ???????????????? ??????]'
name='[??????????????? ????????10????????]'
name=double(name)
name=char(name)
fclose(f)

fid = fopen('test2.txt');
b = fread(fid,'*char')';
fclose(fid);
str = native2unicode(b,'US-ASCII');
title(str)
disp(str);

% --------------------------------------------------------------------
function search_replace_Callback(hObject, eventdata, handles)
[FileName,PathName] =uigetfile2('*.txt','File to do search and replace','DefaultName');
search_={''};search_=inputdlg2('Search?','Search',1,search_);%search=str2num(search{1});
replace={''};replace=inputdlg2('Replace?','Replace',1,replace);%replace=str2num(replace{1});
[tmp1 tmp2 search_]=search(search_{1},'tmp', 1);
[tmp1 tmp2 replace]=search(replace{1},'tmp', 1);
fid = fopen([PathName FileName],'r');
fout = fopen('tmp99.txt','w');
i=0;
for i=1:min(length(search_),length(replace))
    search_(i) = regexprep(search_(i),'_',' ');%
end
while not(feof(fid))
    i=i+1;
    s=fgets(fid);
    for i=1:min(length(search_),length(replace))
        s = regexprep(s,search_(i),replace(i));%
    end
    fprintf(fout,'%s',s);
end
fclose(fid);
fclose(fout);
movefile([PathName FileName],'tmp.txt');
movefile('tmp99.txt',[PathName FileName]);
beep2;


% --------------------------------------------------------------------
function use_defaults_Callback(hObject, eventdata, handles)
% hObject    handle to use_defaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global default
default=not(default);
if default
    set(handles.use_defaults,'Checked','On');
else
    set(handles.use_defaults,'Checked','Off');
end


function [p, f] = ftest(d1, d2)
%FTEST F-test for two samples.
%       FTEST(X1, X2) gives the probability that the F value
%       calculated as the rati of the variances of the two samples is
%       greater than observed, i.e. the significance level.
%       [P, F] = FTEST(X1, X2) gives the probability P and returns
%       the value of F.
%
%       A small value of P would lead to reject the hypothesis that
%       both data sets are sampled from distributions with the same
%       variances.
%
%See also : TTEST, TEST.
[l1 c1] = size(d1) ;
n1 = l1 * c1 ;
x1 = reshape(d1, l1 * c1, 1) ;
[l2 c2] = size(d2) ;
n2 = l2 * c2 ;
x2 = reshape(d2, l2 * c2, 1) ;
%[a1, v1] = avevar(x1) ;
a1=mean(x1);v1=var(x1);
%[a2, v2] = avevar(x2) ;
a2=mean(x2);v2=var(x2);
f = v1 / v2 ;
df1 = n1 - 1 ;
df2 = n2 - 1 ;
if (v1 > v2)
    p = 2 * betainc( df2 / (df2 + df1 * f), df2 / 2, df1 / 2) ;
else
    f = 1 / f ;
    p = 2 * betainc( df1 / (df1 + df2 * f), df1 / 2, df2 / 2) ;
end
if (p > 1)
    p = 2 - p ;
end



% --------------------------------------------------------------------
function print_vocabulary_freq_ass_Callback(hObject, eventdata, handles)
% hObject    handle to print_vocabulary_freq_ass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
f=fopen('vocabulary_freq_ass.txt','w');
fprintf('word\tfrequency\tfirst_ass\tdistance\tlast_ass\tdistance\tfrequency\trandom_ass\tdistance\tfrequency\n')
fprintf(f,'word\tfrequency\tfirst_ass\tdistance\tlast_ass\tdistance\tfrequency\trandom_ass\tdistance\tfrequency\n');
for i=1:s.N
%    if savereportas.skip(i)==0
        [ass, word_a]=nearest_associations2_s(s,s.fwords{i},'descend');
        j2=length(ass);
        while word_a{j2}(1)=='_';
            j2=j2-1;
        end
        j1=2;
        while word_a{j1}(1)=='_';
            j1=j1+1;
        end
        i1=find(strcmpi(s.fwords,word_a{2}));f1=s.f(i1);
        i2=find(strcmpi(s.fwords,word_a{j2}));f2=s.f(i2);
        j3=round(rand*(length(ass)-s.Ndim)+.5);f3=s.f(j3);
        fprintf('%s\t%.0f\t %s\t%.2f\t%.0f\t %s\t%.2f\t%.0f\t %s\t%.2f\t%.0f\t\n',s.fwords{i},s.f(i),word_a{2},ass(2),f1,word_a{j2},ass(j2),f2,word_a{j3},ass(j3),f3)
        fprintf(f,'%s\t%.0f\t %s\t%.2f\t%.0f\t %s\t%.2f\t%.0f\t %s\t%.2f\t%.0f\t\n',s.fwords{i},s.f(i),word_a{2},ass(2),f1,word_a{j2},ass(j2),f2,word_a{j3},ass(j3),f3);
%    end
end
fclose(f);


% --------------------------------------------------------------------
function split_document_Callback(hObject, eventdata, handles)
% hObject    handle to split_document (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fil,PathName]=uigetfile2('*.txt','Context file 1','DefaultName');
criteron=inputdlg3('Documents including this string will be placed in the exclude file','background');

f=fopen([PathName fil],'r');
o1=fopen([PathName 'include_' fil],'w');
o2=fopen([PathName 'exclude_' fil],'w');
o=o1;a='';
fprintf('Dividing file.');
while not(feof(f))
    while not(feof(f)) & isempty(strfind(lower(a),'</text>'))
        a=[a fgets(f)];
    end
    if isempty(strfind(a,criteron))
        o=o1;
    else
        o=o2;
    end
    a=regexprep(a,'<text>','<TEXT>');
    a=regexprep(a,'</text>','</TEXT>');
    a=regexprep(a,'<doc>','<DOC>');
    a=regexprep(a,'</doc>','</DOC>');
    fprintf(o,'%s',a);
    a='';
    if rand<.001
        fprintf('.');
    end
end
fclose(f);
fclose(o1);
fclose(o2);
fprintf('\nDone!\n');
beep2



% --------------------------------------------------------------------
function list_sem_relatnedness_Callback(hObject, eventdata, handles)
% hObject    handle to list_sem_relatnedness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words to measure average distance','*');
for i=1:length(o.input2)
    o2=getWord(s,o.input2{i},o.out);
    r{i}=o.x*shiftdim(o2.x1,1);
    fprintf('Average distance between the words and the prototype of the words for %s: %.3f\n',o.input2{i},nanmean(r{i}))
    if i>1
        [tmp p]=ttest2(r{i},r{i-1});
        fprintf('ttest betwween %s and %s, p=%.4f\n',o.input2{i-1},o.input2{i},p);
    end
end

function [d, dist]=ass_list(list1,list2,s)
k=0;
for i=1:length(list1)
    for j=1:length(list2)
        if not(strcmpi(list1{i},list2{j}))
            k=k+1;
            dist(k)=getProperty(s,list1{i},list2{j});
        end
    end
end
d=nanmean(dist);


function remove_duplicates_Callback(hObject, eventdata, handles)
% hObject    handle to remove_duplicates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fil,PathName]=uigetfile2('*.txt','Fil','');

text=textread([PathName fil],'%s');
j=0;text2{1}='';
fprintf('Removing: ');
for i=1:length(text);
    if isempty(find(strcmpi(lower(text2),lower(text{i}))))
        j=j+1;
        text2{j}=text{i};
        if even(i,500)
            fprintf('.');
        end
    else
        fprintf('%s ',text{i});
    end
end
fprintf('\nKeeping %d of %d words\n',length(text2),length(text));
fil=inputdlg3('Name of outputfile',[PathName 'duplicate_removed_' fil]);
f=fopen(fil,'w');
for i=1:length(text2)
    fprintf(f,'%s\n',lower(text2{i}));
end
fclose(f);
beep2

% --------------------------------------------------------------------
function test_quality_Callback(hObject, eventdata, handles)
% hObject    handle to test_quality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
testSpaceQuality;


function extract_characters_Callback(hObject, eventdata, handles)
[fil,PathName]=uigetfile2('*.txt','Choice files to extract characters from','');
f=fopen([PathName fil],'r');
characters='';j=0;
while not(feof(f))
    s=fgets(f);
    for i=1:length(s)
        if isempty(strfind(characters,s(i)))
            characters(length(characters)+1)=s(i);
            fprintf('%s',s(i));
        end
    end
    j=j+1;
    if even(j,100) | feof(f)
        fprintf('.');
        characters=sort(characters);
        out=fopen('characters.txt','w');
        %save('characters');
        fprintf(out,'%s',characters);
        fclose(out);
    end
end
beep2
f=fclose(f);
fprintf('Characters:\n%s\nResults printed to file: ''characters.txt''\n',characters)

function prepare_lsa_Callback(hObject, eventdata, handles)
% hObject    handle to prepare_lsa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fil,PathName]=uigetfile2('*.txt','Choice files to prepare for LSA','');
f=fopen([PathName fil],'r')
out=fopen([PathName 'LSA_' fil],'w')
while not(feof(f))
    s=fgets(f);
    fprintf(out,'<DOC><TEXT>%s</TEXT></DOC>\n',s);
    if even(i,100) | feof(f)
        fprintf('.');
    end
end
fclose(f);
fclose(out);
fprintf('Done\n')
%filecopy([PathName 'temp.txt'],[PathName fil])
beep2

function pairwise_association_Callback(hObject, eventdata, handles)
% hObject    handle to pairwise_association (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[file,PathName]=uigetfile2('*.txt','Input file with two columns of words','');
if file==0; return; end
%[words data col]=textread2([PathName file]);
%f=fopen([pathname file],'r');
[w1 w2]=textread([PathName file],'%s %s');

name=[regexprep(file,'.txt','')];
name=inputdlg3('Store result in prototype',['_' name]);
%fprintf('Creating labeling _category%savereportas+number for all clustered words\n',catname);
infow.specialword=1;
s=addX2space(s,name,[],infow,0,'semantic distance');

fprintf('word1\tword2\tdistance\n')
for i=1:length(w1)
    i1=find(strcmpi(w1{i},s.fwords));
    i2=find(strcmpi(w2{i},s.fwords));
    if not(isempty(i1)) & not(isempty(i2))
        %if savereportas.skip(i1)==0 & savereportas.skip(i2)==0
            d=sum(s.x(i1,:).*s.x(i2,:));
            fprintf('%s\t%s\t%.2f\n',w1{i},w2{i},d);
            eval(['s.info{i1}.' regexprep(name,'_','') '=d;']);
        %end
    else
        fprintf('%s',w1{i});
        if isempty(i1) fprintf('=missing');end
        fprintf('\t%s',w2{i});
        if isempty(i2) fprintf('=missing');end
        fprintf('\n');
    end
end
s=getSpace('set',s);



function entropy_Callback(hObject, eventdata, handles)
% hObject    handle to entropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
fprintf('This calculates the information entropy (I=-sum(p*log(p))), divided into positive and negative assocations\n')
fprintf('word I(positive) I(negative) N(pos) N(neg)\n')
for i=1:length(s.wordlist)
    i1=find(strcmpi(s.wordlist{i},s.fwords));
    [ass, word_a]=nearest_associations2_s(s,s.wordlist{i},'descend');
    [tmp i_pos]=find(ass>0);
    ass_pos=ass(i_pos)/sum(ass(i_pos));
    e_pos(i)=-sum(ass_pos.*log2(ass_pos));
    [tmp i_neg]=find(ass<0);
    ass_neg=ass(i_neg)/sum(ass(i_neg));
    e_neg(i)=-sum(ass_neg.*log2(ass_neg));
    fprintf('%s %.3f %.3f %d %d\n',s.wordlist{i},e_pos(i),e_neg(i),length(i_pos),length(i_neg));
end
[m sd]=entropy_bootstrap(s);
tmp=1;

function [m, sd]=entropy_bootstrap(s)
fprintf('Calculating bootstrap, please wait');
x=icdf('norm',rand(s.N,s.Ndim),0,1);
x2=(sum(shiftdim(x,1).^2).^.5);
x=x./shiftdim(repmat(x2,s.Ndim,1),1);
for i=1:50
    fprintf('.');
    [ass, word_a,ok,index]=nearest_associations2(s.fwords{i},s.fwords,x,'descend');
    [tmp i_pos]=find(ass>0);
    ass_pos=ass(i_pos)/sum(ass(i_pos));
    e_pos(i)=-sum(ass_pos.*log2(ass_pos));
end
m=mean(e_pos);sd=std(e_pos);
fprintf('\nRandom entropy: I(mean)=%.3f std(I)=%.4f\n',m,sd);

function zipfs_entropy
for i=3:5
    N=10^i;
    a=[1:N];
    b=a.^-1;
    c=b/sum(b);
    d=-sum(c.*log2(c));
    fprintf('Words in language N=%d Entropy=%.3f Lowest frequency per million %.2f\n',N,d,c(length(c))*10^6);
end
for i=-1:2
    f=5*10^i/10^6;fprintf('Frequency per million=%.1f Entropy=%.3f\n',f*10^6,-1/f*f*log2(f));
end


% --------------------------------------------------------------------
function entropy_corpus_Callback(hObject, eventdata, handles)
% hObject    handle to entropy_corpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Calculates entropy from a corpus-file.\n');
if 1
    s=getSpace('s');
    clear s.x;clear s.fwords;
    %clear savereportas.skip;
    [fil1,PathName]=uigetfile2('*.txt','Fil','');
    tmp{1}='20';Ncontext=inputdlg2('Number of words for context (+/- correct word)','Context',1,tmp);Ncontext=str2num(Ncontext{1});
    %save('tmp.mat');
else
    load('entropy.mat');
end
f=fopen([PathName fil1],'r');i=0;i2=0;
wsum={' '};dic=[];N=0;
while not(feof(f))
    if i>2500
        if i2>50000
            hmmmm=1;
        end
        save('tmp.mat');
        i=1;fprintf('.');
        clear p;
        for j=1:length(s.wordlist)
            if sum(N(j,:))>0
                select=find(N(j,:)>0);
                p(j,select)=N(j,select)/sum(N(j,select));
                fprintf('%s entropy=%.3f N=%.d\n',s.wordlist{j},-sum(p(j,select).*log2(p(j,select))),sum(N(j,select)));
            end
        end
    else
        i=i+1;i2=i2+1;
    end
    w=clear_char(fgets(f));
    w=strread(w,'%s');
    if not(isempty(w))
        for j=1:length(w) %Make dictionary and frequency count
            if isempty(find(strcmpi(dic,w{j})))
                dic=[dic;w(j)];N(length(s.wordlist),length(dic))=0;Ntot(length(dic))=0;
            end
            k=find(strcmpi(dic,w{j}));
            Ntot(k)=Ntot(k)+1;
        end
        wsum=[wsum; w]; %Count context specific frequency
        for j=1:length(s.wordlist)
            found=find(strcmpi(wsum(1:max(1,length(wsum)-Ncontext)),lower(s.wordlist{j})));
            for k=1:length(found)
                for l=max(1,found(k)-Ncontext):found(k)+Ncontext
                    m=find(strcmpi(dic,wsum{l}));
                    N(j,m)=N(j,m)+1;
                end
                wsum{found(k)}=[wsum{found(k)} '1'];
            end
        end
        wsum=wsum(max(1,length(wsum)-2*Ncontext):length(wsum));
    end
end
fclose(f);
Ptot=Ntot/sum(Ntot);
save('entropy.mat');

%Print frequency list
fprintf('A frequency list is printed to the file: frequency.txt');
[tmp index]=sort(Ntot,'descend');
out=fopen('frequency.txt','w');
for j=1:length(dic)
    fprintf(out,'%s %d\n',dic{index(j)},Ntot(index(j)));
end
fclose(out);

figure;
tmp=1:length(Ptot);plot(log2(tmp),log2(Ptot(index)))
xlabel('log(rank order)');ylabel('log(frequency)');title('zipf''s law')
fprintf('Exponenet on zip''s law: %.3f\n',log2(Ptot(index))/log2(tmp));

%Print entropy output
clear p;
for j=1:length(s.wordlist)
    if sum(N(j,:))>0
        select=find(N(j,:)>0);
        p(j,select)=N(j,select)/sum(N(j,select));
        k=find(strcmpi(dic,s.wordlist(j)));
        if not(isempty(k))
            Nf=Ptot(k)*10^6;
        else
            Nf=0;
        end
        tmp=1:length(select);pt=1./tmp;pt=pt/sum(pt);
        p2=sort(p(j,select),'descend');
        KL=sum(p2.*log2(p2./pt));
        KL2=sum(p(j,select).*log2(p(j,select)./Ptot(select)));
        e=-sum(p(j,select).*log2(p(j,select)));
        fprintf('%s frequency per million=%.1f KullbackLeibler divergence=%.3f %.3f entropy=%.3f e+KL2 %.3f N=%.d\n',s.wordlist{j},Nf,KL,KL2,e,e+KL2,sum(N(j,select)));
    end
end
fprintf('entropy tot=%.3f\n',-sum(Ptot.*log2(Ptot)));
beep2

function w=clear_char(w,low)
%Removes unwanted characters from corpus-file
if nargin<2 w=lower(w); end
i1=findstr(w,'<');
i2=findstr(w,'>');
while not(isempty(i1)) & not(isempty(i2))
    w=[w(1:i1(1)-1) w(i2(1)+1:length(w))];
    i1=findstr(w,'<');
    i2=findstr(w,'>');
end
remove='!:;()/0123456789??$+%-*.,?"''|?&}{=&[]';
for j=1:length(remove)
    w=regexprep(w,['\' remove(j)],' ');
end

function entropy_std
i=[1:10000];
N=[734,3189,30766,70830, 238669];%70830];
for j=1:length(N)
    f=1./i;
    f=f/sum(f)*N(j);
    sf=f.^.5;
    noise=icdf('norm',rand(1,length(f)),0,1).*sf;
    f2=f+noise;
    select=find(f2>0);
    p(j,:)=f2/sum(f2);
    e=-sum(p(j,select).*log2(p(j,select)));
end
for j=1:length(N)
    select2=find(p(j,:)>0 & p(length(N),:)>0);
    e1=sum(p(j,select2).*log2(p(j,select2)./p(length(N),select2)));
    fprintf('KL=%.3f\n',e1);
    %e2=sum(p(2,select2).*log2(p(2,select2)./p(1,select2)))
end



function string=struct2string(struct)
string=[];
for i=1:length(struct)
    string=[string ' ' struct{i}];
end

% --------------------------------------------------------------------
function cluster_words_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_words (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words to cluster','*');%x x wordOut ok ok_index
if o.N==0 return; end
name=[];
[s info]=clusterSpace(s,o.index,[],name);
showOutput({info.results},['Cluster:' name])
s=getSpace('set',s);




function [x1, x2]=ttest_space(x,select1,select2)
x1=mean(x(select1,:));x1=x1./sum(x1.*x1)^.5;
x2=mean(x(select2,:));x2=x2./sum(x2.*x2)^.5;
d=sum(x1.*x2);

select=[select1 select2];
for i=1:250
    [s index]=sort(rand(1,length(select)));
    rs1=select(index(1:length(select1)));rs2=select(index(length(select1)+1:length(select)));
    r1=mean(x(rs1,:));r1=r1./sum(r1.*r1)^.5;
    r2=mean(x(rs2,:));r2=r2./sum(r2.*r2)^.5;
    dr(i)=sum(r1.*r2);
end
z=(d-mean(dr))/std(dr);
fprintf('u1=%.3f u0=%.3f std=%.3f z=%.3f p=%.3f\n',d,mean(dr),std(dr),z,cdf('Normal',-abs(z),0,1)*2)

% --------------------------------------------------------------------
function open_single_space_Callback(hObject, eventdata, handles)
% hObject    handle to open_single_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fil,PathName]=uigetfile2('space*','Open space','');
if not(fil==0)
    s=getNewSpace([PathName fil]);
end

function prediction_Callback(hObject, eventdata, handles)
s=train;
s=getSpace('set',s);

% --------------------------------------------------------------------
function prediction_advanced_Callback(hObject, eventdata, handles)
% hObject    handle to prediction_advanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[file,PathName]=uigetfile2('*.txt','First column words, other columns user defined','');
if not(file==0)
    dim=str2num(inputdlg3('Number of dimension to use (0=optimize)',num2str(s.Ndim)));
    cond=str2num(inputdlg3('Columns to categories (empty no categories)','3 4'));
    sumi=str2num(inputdlg3('Columns sum over column','0'));
    regnr=str2num(inputdlg3('Columns to regress','7'));
    crit=inputdlg3('Select rows','data(:,3)==1');
    [words data col]=textread2(file);
    if not(isempty(crit))
        fprintf('Selecting %s\n',crit);
        select=eval(['find(' crit ');']);
        words=words(select);data=data(select,:);
    end
    %save('test2.mat','words','data','col')
    name=inputdlg3('Name of regressor',['_' regexprep(file,'.txt','')]);
    for i=1:length(regnr)
        if length(regnr)==1
            n=name;
        else
            n=[name '_' num2str(regnr(i))];
        end
        s=prediction2(s,words,data,n,cond,sumi,regnr(i));
    end
    beep2
end

function s=prediction2(s,words,data,name,cond,sumi,regnr)
if isempty(cond)
    s=prediction3(s,words,data,name,sumi,regnr);
else
    for j=min(data(:,cond(1))):max(data(:,cond(1)))
        select=find(data(:,cond(1))==j);
        if length(cond)>1
            s=prediction2(s,words(select),data(select,:),[name '_' num2str(j)],cond(2:length(cond)),sumi,regnr);
        else
            if not(isempty(select))
                s=prediction3(s,words(select),data(select,:),[name '_' num2str(j)],sumi,regnr);
            end
        end
    end
end

function s=prediction3(s,words,data,name,sumi,regnr);
if sumi(1)>0
    k=0;
    for i=min(data(:,sumi(1))):max(data(:,sumi(1)))
        for j=min(data(:,sumi(2))):max(data(:,sumi(2)))
            select=find(data(:,sumi(1))==i & data(:,sumi(2))==j);
            if not(isempty(select))
                k=k+1;
                words2{k}=words{select(1)};data2(k,:)=mean(data(select,:));
            end
        end
    end
    words=words2;data=data2;
end
s=train(s,data(:,regnr),name,word2index(s,word));







function save_one_space_Callback(hObject, eventdata, handles,filename)
s=getSpace;
saveSpace(s);

function save_space_as_Callback(hObject, eventdata, handles)
[filename,PathName] =uiputfile('*','Save space as');
if not(filename==0)
    s=getSpace;
    saveSpace(s,[PathName filename]);
end

function starteeglab
path='/Users/sverkersikstrom/Documents/Dokuments/Diverce/eeglab5.01b/eeglab5.01b';
try
    addpath(path);
    eeglab
catch
    fprintf('Could not find EEGLAB in path %s\n',path);
end


% --------------------------------------------------------------------
function eeglab_extract_Callback(hObject, eventdata, handles)
% hObject    handle to eeglab_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Extracting data from eeglab-files\n')
dbstop if error
allwords=textread('allwords.txt','%s');allwords_fel=allwords;
for i=1:length(allwords)
    allwords_fel{i}=regexprep(allwords_fel{i},'?','');
    allwords_fel{i}=regexprep(allwords_fel{i},'?','');
    allwords_fel{i}=regexprep(allwords_fel{i},'?','');
end

starteeglab;
t1(1)=.120;t2(1)=.200;
t1(2)=.200;t2(2)=.350;
t1(3)=.350;t2(3)=.550;
t1(4)=.550;t2(4)=.800;
t1(5)=.800;t2(5)=1.250;
t1(6)=.080;t2(6)=.120;
t1(7)=-.500;t2(7)=.000;%Baseline

freq1(1)=3;freq2(1)=8;
freq1(2)=8;freq2(2)=12;
freq1(3)=12;freq2(3)=20;
freq1(4)=20;freq2(4)=40;

t1=str2num(inputdlg3('Extact time periods starting with (s)', num2str(t1)));
t2=str2num(inputdlg3('Extact time periods ending with (s)', num2str(t2)));

power=strcmpi('Yes',questdlg2('Extract power spectrum','Power','Yes','No','Yes'));
coherence=strcmpi('Yes',questdlg2('Extract coherence','Coherence','Yes','No','Yes'));
if power | coherence
    freq1=str2num(inputdlg3('Extact frequency periods starting with (f)', num2str(freq1)));
    freq2=str2num(inputdlg3('Extact frequency periods ending with (f)', num2str(freq2)));
else
    freq1=[];
    freq2=[];
end

fid=fopen('results.txt','w');
file=inputdlg3('Output file', 'results_eeg.txt');
[c1 c2]=textread('coherence_channels.txt');
f2=fopen(file,'w');
[file,PathName]=uigetfile2('*.set','Open EEGLAB file including ''2''','ERP_petter/WFLSA_S2_01_w_artrem.set');
save=0;
EEG_d = pop_loadset( 'filename', 'default.set', 'filepath', '');
fpnumber=str2num(inputdlg3('Extract fp number:', '1:100'));
if strcmpi('Yes',questdlg2('Randomize order of fps','Randomize','Yes','No','No'));
    [tmp index]=sort(rand(1,length(fpnumber)));
else
    index=[1:length(fpnumber)];
end
for fp=fpnumber(index)
    fil=[PathName regexprep(file,'2',[num2str(fp)])];
    %cohfile=['coh' num2str(fp) '.mat'];coh=1;
    if exist(fil) %& not(exist(cohfile))
        %f10=fopen(cohfile,'w');fprintf(f10,'runing');fclose(f10);
        fprintf('Processing %d %s\n',fp,fil);
        EEG = pop_loadset( 'filename', fil, 'filepath', '');
        mdata=mean(shiftdim(EEG.data,2));
        c_power=not(isfield(EEG,'pow')) & power;
        c_coherence=not(isfield(EEG,'coh')) & coherence;
        for c=1:EEG.nbchan
            for i=1:EEG.trials;
                EEG_d.data=EEG.data(:,:,i);
                if c_power
                    save=1;
                    fprintf('Channel %d trial %d %s\n',c,i,fil);
                    [EEG.pow.ersp,EEG.pow.itc,EEG.pow.powbase,EEG.pow.times,EEG.pow.freqs,EEG.pow.erspboot,EEG.pow.itcboot,EEG.pow.itcphase] =pop_timef( EEG_d, 1, c, [EEG.xmin*1000 EEG.xmax*1000] , [0 0.5]  ,'type', 'phasecoher', 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'title','Channel HEOL power and inter-trial phase coherence (fp1-epoched pruned with ICA)','padratio', 4, 'plotphase','off','plotersp','off','plotitc','off');
                    for f=1:length(freq1)
                        select_f=find(EEG.pow.freqs>=freq1(f) & EEG.pow.freqs<freq2(f));
                        select_tbase=find(EEG.pow.times<0);
                        baseline=mean(mean(EEG.pow.ersp(select_f,select_tbase)));
                        for t=1:length(t1)
                            select_t=find(EEG.pow.times>=t1(t)*1000 &  EEG.pow.times<t2(t)*1000);
                            EEG.pow.data(f,c,t,i)=mean(mean(EEG.pow.ersp(select_f,select_t)))-baseline;
                        end
                    end
                end
                if c_coherence %Coherence
                    f9=fopen('status','w');fprintf(f9,'fp=%d channel %d trial %d %s\n',fp,c,i,fil);fclose(f9);
                    save=1;
                    fprintf('Channel %d trial %d %s\n',c,i,fil);
                    EEG_d.data(:,:,2)=mdata;
                    [EEG.coh.coh,EEG.coh.mcoh,EEG.coh.timesout,EEG.coh.freqsout,EEG.coh.cohboot,EEG.coh.coangle,EEG.coh.coangles]=pop_crossf( EEG_d, 1, c1(c), c2(c), [EEG.xmin*1000 EEG.xmax*1000], [0.5 0.5] ,'type', 'phasecoher', 'topovec', [1  2], 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'title','Channel HEOL-HEOR Phase Coherence','padratio', 4, 'plotphase','off','plotamp','off','savecoher',1);
                    for f=1:length(freq1)
                        select_f=find(EEG.coh.freqsout>=freq1(f) & EEG.coh.freqsout<freq2(f));
                        select_tbase=find(EEG.coh.timesout<0);
                        baseline=mean(mean(EEG.coh.coh(select_f,select_tbase)));
                        for t=1:length(t1)
                            select_t=find(EEG.coh.timesout>=t1(t)*1000 &  EEG.coh.timesout<t2(t)*1000);
                            EEG.coh.data(f,c,t,i)=mean(mean(EEG.coh.coh(select_f,select_t)))-baseline;
                            EEG.coh.angle(f,c,t,i)=mean(mean(EEG.coh.coangles(select_f,select_t,1)));
                        end
                    end
                end
            end
        end
        if not(isfield(EEG.epoch, 'mix')) | 0 %Set variables for conditions
            save=1;
            for i=1:length(EEG.epoch)
                c=EEG.epoch(i).eventtype;%n248-c208-r0-sp2-regatta
                c=c(1:16);
                c=regexprep(c,'-c207','-m-hf-ns');
                c=regexprep(c,'-c208','-m-lf-ns');
                c=regexprep(c,'-c209','-p-hf-ns');
                c=regexprep(c,'-c210','-p-lf-ns');
                c=regexprep(c,'-c215','-p-hf-hs');
                c=regexprep(c,'-c211','-m-hf-hs');
                c=regexprep(c,'-c212','-m-lf-hs');
                c=regexprep(c,'-c216','-p-lf-hs');
                %c=regexprep(c,'-c214','-m-lf-hs');%WRONG!
                c=regexprep(c,'-c214','-m-lf-ls');%CORRECTED
                c=regexprep(c,'-c213','-m-hf-ls');
                c=regexprep(c,'-c217','-p-hf-ls');
                c=regexprep(c,'-c218','-p-lf-ls');
                c=regexprep(c,'-c219','-xxxxx');
                EEG.epoch(i).category=(rand<.5)+1;save=1;
                EEG.epoch(i).correct=isempty(strfind(c,'r0'))+.0;
                EEG.epoch(i).mix=not(isempty(strfind(c,'-m')))+.0;
                EEG.epoch(i).hf=not(isempty(strfind(c,'-hf')))+.0;
                if not(isempty(strfind(c,'-ls')))
                    EEG.epoch(i).sem=1;
                elseif not(isempty(strfind(c,'-ns')))
                    EEG.epoch(i).sem=2;
                else
                    EEG.epoch(i).sem=3;
                end
                index=findstr('-r',c);
                EEG.epoch(i).rorder=str2num(c(index(1)+2));
                index=findstr('-sp',c);
                EEG.epoch(i).serial=str2num(c(index(1)+3));
                EEG.epoch(i).train=not(isempty(strfind(c,'-x')))+.0;
            end
        end
        
        for i=1:length(EEG.epoch)
            etype=EEG.epoch(i).eventtype;
            index=findstr('-',etype);
            words=etype(index(4)+1:length(etype));
            
            if findstr(words,'')>0 %Correct f?r ??? in petters data
                f1=find(strcmpi(allwords_fel,words));
                if not(isempty(f1))
                    words=allwords{f1(1)};
                    EEG.epoch(i).eventtype=[etype(1:index(4)) words];
                    save=1;
                else
                    fprintf('Problem: %s\n',words);
                end
                if length(f1)>1
                    fprintf('Duplicate word: %s\n',words);
                end
            end
            correct=isempty(strfind(etype,'r0'))+.0;
            fprintf(fid,'%s %d %d %d\n',words,correct,fp,EEG.epoch(i).sem);
            if 0
                fprintf('Time on rows\n');
                for t=1:length(t1)%erps
                    for c=1:EEG.nbchan
                        fprintf(f2,'%s %d %d %d %d %d ',words,fp,t,c,i,correct);
                        time=round((t1(t)-EEG.xmin)*EEG.srate+1:(t2(t)-EEG.xmin)*EEG.srate);
                        data=mean(EEG.data(c,time,i));%channel, time, word
                        fprintf(f2,'%.4f ',data);%erps
                        for f=1:length(freq1)%power 8-11
                            fprintf(f2,'%.4f ',EEG.pow.data(f,c,t,i));
                        end
                        for f=1:length(freq1)%coherence 12-15
                            fprintf(f2,'%.4f ',EEG.coh.data(f,c,t,i));
                        end
                        for f=1:length(freq1)%angle
                            %fprintf(f2,'%.4f ',EEG.coh.angle(f,c,t,i));
                        end
                        fprintf(f2,'%d ',EEG.epoch(i).category);
                        fprintf(f2,'%d %d %d %d %d %d %d\n',EEG.epoch(i).mix,EEG.epoch(i).hf,EEG.epoch(i).sem,EEG.epoch(i).rorder,EEG.epoch(i).serial,EEG.epoch(i).train,length(words));
                    end
                end
            else
                fprintf('Time on columns\n');
                for c=1:EEG.nbchan
                    fprintf(f2,'%s %d %d %d %d %d ',words,fp,0,c,i,correct);
                    for t=1:length(t1)%erps
                        time=round((t1(t)-EEG.xmin)*EEG.srate+1:(t2(t)-EEG.xmin)*EEG.srate);
                        data=mean(EEG.data(c,time,i));%channel, time, word
                        fprintf(f2,'%.4f ',data);
                    end
                    for t=1:length(t1)%power
                        for f=1:length(freq1)
                            fprintf(f2,'%.4f ',EEG.pow.data(f,c,t,i));
                        end
                    end
                    for t=1:length(t1)%coherence
                        for f=1:length(freq1)
                            fprintf(f2,'%.4f ',EEG.coh.data(f,c,t,i));
                        end
                    end
                    for t=1:length(t1)%angle
                        for f=1:length(freq1)
                            %fprintf(f2,'%.4f ',EEG.coh.angle(f,c,t,i));
                        end
                    end
                    fprintf(f2,'%d ',EEG.epoch(i).category);
                    fprintf(f2,'%d %d %d %d %d %d %d\n',EEG.epoch(i).mix,EEG.epoch(i).hf,EEG.epoch(i).sem,EEG.epoch(i).rorder,EEG.epoch(i).serial,EEG.epoch(i).train,length(words));
                end
            end
        end %trial
        if save
            save=0;
            %coh=EEG.coh;
            %save(cohfile,'coh');
            pop_saveset(EEG,'savemode','resave');
        end
    end%if fp exist
end %fp
fclose(fid);
fclose(f2);
beep2


function add_word_copies_Callback(hObject, eventdata, handles)
s=getSpace('s');
x=ones(1,s.Ndim);
info=[];
word=inputdlg3('Type the name of the new Identifier','',1);
if strcmpi('Yes',questdlg2('Add a semantic representation to the Identfier?','Add','No','Yes','No'))
    [o s]=getWordFromUser(s,'Select the semantic representation of the new Identfier','');
    o.out.word=word;
    o.out.words{1}=word;
    o.out.labels{1}=word;
    info.worddef=o.out;
    %if o.ok
    x=average_vector(s,o.x1);
    if strcmpi('Yes',questdlg2('Subtract a semantic representation from the Identfier?','Subtract','No','Yes','No'))
        [oSub s]=getWordFromUser(s,'Select the semantic representation to subtract from the new Identfier','');
        if oSub.ok
            xSub=average_vector(s,oSub.x1);
            x=x-xSub;
            x=x/sum(x.^2)^.5;
        end
    end
    %end
    %info.specialword=9;
else
    o.input='';
    %info.specialword=3;
end
if length(word)>0 & not(word(1)=='_')
    if strcmpi('No',questdlg2('Add ''_'' to the Identifier?','Add','No','Yes','No'))
        word=['_' word];%info.normalword=0;
    end
end
answer=questdlg('Type of identifier','Choice the type of identifer','Cluster','Text','Norm','Norm');
if strcmpi(answer,'Cluster')
    info.specialword=3;
elseif strcmpi(answer,'Text')
    info.specialword=9;
else %if strcmpi(answer,'Norm')
    info.specialword=13;
end
fprintf('Adding identifier %s\n',word)
s=addX2space(s,word,x,info);
s=getSpace('set',s);

% --------------------------------------------------------------------
function compare_regres_Callback(hObject, eventdata, handles)
% hObject    handle to compare_regres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
fprintf('\n')
[file,PathName]=uigetfile2('*.txt','First column words, second column binary number (0/1)','');
if not(file==0)
    [words reg]=textread(file,'%s %f');
    index=word2index(s,words,1);
    word=inputdlg2('Choice regressor','Regressor',1,{'_valence'});
    i=find(strcmpi(s.fwords,word));
    pred=get_reg(s,i,s.x(index,:));
    select0=find(reg==0);
    select1=find(reg==1);
    [h p]=ttest2(pred(select0),pred(select1));
    m0=mean(pred(select0));m1=mean(pred(select1));s0=std(pred(select0));s1=std(pred(select1));N0=length(select0);N1=length(select1);
    z=(m1-m0)/(s0/N0^.5+s1/N1^.5);
    fprintf('regressor: %s u0=%.3f u1=%.3f std0=%.3f std1=%.3f N0=%d N1=%d p=%.3f z=%.3f\n',word{1},m0,m1,s0,s1,N0,N1,p,z)
end

function r=get_reg(s,i,words)
length=1;c=0;
if isfield(s.info{i},'c')
    c=s.info{i}.c;
end
if isfield(s.info{i},'length')
    length=s.info{i}.length;
end
[N tmp]=size(words);
for j=1:N
    r(j)=sum(words(j,:).*s.x(i,:))*length+c;
end




% --------------------------------------------------------------------
function remove_words_Callback(hObject, eventdata, handles)
% hObject    handle to remove_words (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Remove selected words','_doc*');
select=zeros(1,s.N);
for i=1:o.N
    select(o.index(i))=1;%not(isempty(find(strcmpi(wordOut,s.fwords{i}))));
end
include=find(select==0);
s=remove_words_now(s,include);
s=getSpace('set',s);



% --------------------------------------------------------------------
function add_dim_Callback(hObject, eventdata, handles)
% hObject    handle to add_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
s=add_dimensions_definitions(s);

function s=add_dimensions_definitions(s)
for i=1:s.Ndim
    name=['_dim' num2str(i)];
    x=zeros(1,s.Ndim);x(i)=1;
    s=addX2space(s,name,x);
end



% --------------------------------------------------------------------
function analys_cluster_quality_Callback(hObject, eventdata, handles)
% hObject    handle to analys_cluster_quality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
fprintf('Analysis the means distance (d) to the clusters means:\n');
[o s]=getWordFromUser(s,'Choice words to cluster','_doc*');
x=o.x;
o.N=str2num(inputdlg3('Maximum number of clusters',num2str(o.N)));
include=find(not(isnan(mean(shiftdim(x,1)))));
x=x(include,:);
x0=x;
Nrep=20;
baseline=nan(1,o.N);
for type=1:2
    if type==2
        fprintf('\nCluster quality based on %d repetions\n',Nrep)
    else
        fprintf('\nRandom cluster quality\n')
    end
    dl=0;
    N=1;lN=0;
    while N<=o.N
        %for N=1:10
        clear d;
        clear dall;
        for i=1:Nrep%Repeate 20 times...
            if type==1 %Select random x for cluster centroids...
                x=x0;
                [Nword Ndim]=size(x);
                for k=1:Ndim
                    [temp index]=sort(rand(1,Nword));
                    x(index,k)=x(:,k);
                end
                for j=1:Nword
                    x(j,:)=x(j,:)/(sum(x(j,:).^2)^.5);%Normalize random words
                end
            else
                x=x0;
            end
            if N==1
                c1=nanmean(x);y=1:length(x);
            else
                [y c1]=kmeans(x,N,'Maxiter',1500);
            end
            for j=1:N
                c1(j,:)=c1(j,:)/(sum(c1(j,:).^2)^.5);%Normalize cluster centroid
                select=find(y==j);
                Nc(j)=length(select);%Select cluster j
                tmp=((x(select,:).*repmat(c1(j,:),length(select),1)));
                dall(i,j)=mean(sum(shiftdim(tmp,1)));%Mean distance...
            end
        end
        d=mean(dall);
        dstd=std(dall);
        fprintf('Nclusters=%d: Mean closeness for all clusters d=%.4f, d-baseline=%.4f (diff. adding one cluster=%.4f): ',N,mean(d),mean(d)-baseline(N),(mean(d)-dl)/(N-lN));
        baseline(N)=mean(d);
        dl=mean(d);
        for j=1:N
            fprintf('d%d=%.3f (%.3f) N=%d, ',j,d(j),dstd(j),Nc(j));
        end
        fprintf('\n');
        lN=N;N=round(N*1.05+1);
    end
end

% --------------------------------------------------------------------
function normalize_dimension_Callback(hObject, eventdata, handles)
s=getSpace('s');
%Rearranges the matrix so that mean for each dimension is always positive....
fprintf('Setting the mean of all dimensions to zero!\n');
tmp=mean(s.x);
for i=1:length(s.x)
    s.x(i,:)=s.x(i,:)-tmp;
    s.x(i,:)=s.x(i,:)./sum(s.x(i,:).^2)^.5;
end
s=getSpace('set',s);



%_arousal _abstract _dominance _valence_gerd _eegc1 _eegc2 _eegc3



% --------------------------------------------------------------------
function compare_frequency_Callback(hObject, eventdata, handles)
% hObject    handle to compare_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace;
[o1 s]=getWordFromUser(s,'Compare words list1','');
[o2 s]=getWordFromUser(s,'With words list2','');
for i=1:length(o1.word)
    l1(i)=length(o1.word{i});
end
for i=1:length(o1.word)
    l2(i)=length(o2.word{i});
end
fprintf('%s f=%.3f N=%d wordlength=%.3f\n',o1.input, mean(s.f(o1.index)),length(o1.index),mean(l1))
fprintf('%s f=%.3f N=%d wordlength=%.3f\n',o2.input, mean(s.f(o2.index)),length(o2.index),mean(l2))
[h p]=ttest2(log(s.f(o1.index)),log(s.f(o2.index)));
fprintf('difference frequency: p=%.4f\n',p)
[h p]=ttest2(l1,l2);
fprintf('difference wordlength: p=%.4f\n',p)



% --------------------------------------------------------------------
function regression_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to regression_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function calculate_bigram_Callback(hObject, eventdata, handles)
s=getSpace('s');
s=calculate_bigram(s);
s=getSpace('set',s);



% --------------------------------------------------------------------
function minimize_Callback(hObject, eventdata, handles)
[file,PathName]=uigetfile2('*.txt','First column words, other columns user defined','results_eeg_small.txt');
time=str2num(inputdlg3('Select time periods','2'));
regressor=str2num(inputdlg3('Select regressor','7'));
s=getSpace('s');
[words data col]=textread2(file);
dim=38;
select=find(data(:,4)==1 & data(:,3)==time(1));
[index index_erp]=word2index(s,words(select),1);
for c=1:38
    erp_a(:,c)=data(select+c-1,regressor);
end
global erp;
erp=erp_a(index_erp,:);
sem=s.x(index,1:dim);
N=5;
x=rand(38,N);
y=rand(N,dim);
xy(1,:,:)=x;
xy(2,:,:)=shiftdim(y,1);
file=['findmin' num2str(N) '.mat'];
if exist(file)
    fprintf('loading...\n');
    load(file);
end
if strcmpi('Yes',questdlg2('Minimize now','','Yes','No','Yes'))
    exitflag=0;
    while not(exitflag==1)
        [xy,fval,exitflag,output] = fminsearch(@(xy) ban(xy,erp,sem),xy, optimset('MaxIter',3000,'Display','Final'));
        save(file,'xy','erp','sem','fval','exitflag','output');
    end
end
for i=1:N
    s=addX2space(s,['_erpmin' num2str(i)],[squeeze(xy(2,:,i)) zeros(1,s.Ndim-dim)]);
end

beep2




function change_characterset_PC_Callback(hObject, eventdata, handles)
change_characterset_Callback(hObject, eventdata, handles,'PC')

function change_characterset_Callback(hObject, eventdata, handles,ver)
%FileName='associations_test_greece.txt'
%FileName='gtest.txt'
if nargin<4
    ver='';
end
[FileName,PathName] =uigetfile2('*.txt','Convert characterset in file','DefaultName');
if FileName==0; return; end
infile=[PathName FileName]; fi=fopen(infile,'r');
outfile=[PathName 'converted_' FileName]; f=fopen(outfile,'w');
s(1)=239;s(2)=187;s(3)=191;
for i=1:length(s)
    %    fprintf(f,'%c',savereportas(i)*1);
end
clear s;
fprintf('File conversion started, please wait.');
while not(feof(fi))
    s=fgets(fi);
    s=convertCharacter(s);
    if rand<.0001
        fprintf('.');
    end
    fprintf(f,'%s',s);
end
fclose(f);fclose(fi);
beep2
movefile(outfile,infile);
fprintf('\nFile conversion completed.\n');


function data=hp_filter(data,f)
N=5000;%f=.010
h = fir1(N,f,'high');%The higher value the more linish...
data = conv(h,data);
data=data(N/2+1:length(data)-N/2);%Removes padding...


function mk_word_time_serie_Callback(hObject, eventdata, handles)
setPropertyFromTimeFile;


% --------------------------------------------------------------------
function OLD_mk_word_time_serie_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words','_doc*');
file='closeingprices9507';
price=textread([file '.txt']);
labels=lower(textread([file '_labels.txt'],'%s'));
[Nt N]=size(price);
price_exp(1,1:N)=0;
for i=2:Nt
    price_exp(i-1,find(isnan(price_exp(i-1,:))))=0;
    price_exp(i,:)=price_exp(i-1,:)+price(i,:)./price(i-1,:)-1;
end
for i=2:N %Normalize so each stock get a mean of 1 over time!
    price_n1(:,i)=price(:,i)/nanmean(price(:,i));%*Nt;
end
price_hp=price_n1;
%price_hp=1+(rand(2480,45)-.5);
for i=1:Nt
    price_hp2(i+Nt,:)=price_hp(i,:);
    price_hp2(i,:)=price_hp(Nt-(i-1),:);
    price_hp2(i+2*Nt,:)=price_hp(Nt-(i-1),:);
end
%price_hp=[ones(2480,45) price_hp ones(2480,45)];
%price_hp=shiftdim(repmat(sin((1:2480)/1.),45,1),1)+rand(2480,45);
price_hp=price;
for i=2:N %Normalize high pass filering
    N1=5000;f=.0080;
    h = fir1(N1,f,'high');%The higher value the more linish...
    tmp= conv(h,price_hp2(:,i));
    price_hp(:,i) =tmp(N1/2+1+Nt:length(tmp)-N1/2-Nt);%Removes padding...
    %price_hp(:,i)=hp_filter(price_hp(:,i),.01);
end
save([file '_hp.txt'],'-ASCII','price_hp')
price_n2=price;
for i=1:Nt %Normalize so each time period get a mean of 1 across stocks!
    price_n2(i,2:N)=price_n1(i,2:N)/nanmean(price_n1(i,2:N));%*(N-1);
end
save([file '_norm2.txt'],'-ASCII','price_n2')
figure;plot(smooth(nanmean(shiftdim(price_hp(:,2:N),1)),50));
figure;plot(price_n2(:,2:N));
figure;plot(price_hp(:,2:N));

%index=find(strcmpi(labels,aktie));
for i=1:length(price)
    date(i)=datenum(num2str(price(i,1)),'yyyymmdd');
end
f=fopen(['mktimeserie.txt'],'w');
for i=1:length(o.index)
    if isfield(s.info{o.index(i)},'time')
        
        if 0 %REMOVE
            w=s.fwords{o.index(i)};l=1;
            w=regexprep(w,'_doc','');
            w=regexprep(w,'_','');
            while isempty(str2num(w(l))) | w(l)=='i'
                l=l+1;
            end
            s.fwords{o.index(i)}=['_doc_' w(1:l-1) '_' w(l:length(w))];
            o.word{i}=s.fwords{o.index(i)};
        end
        
        if rand<.001
            fprintf('.');
        end
        t(i)=s.info{o.index(i)}.time;
        tmp=find(t(i)<date);
        if t(i)>0 & not(isempty(tmp))
            index_t=tmp(1)-1;
            a=strread(regexprep(o.word{i},'_',' '),'%s');index_p=[];k=0;
            for j=2:length(a)
                index=find(strcmpi(labels,a{j}));
                if not(isempty(index))
                    k=k+1;index_p(k)=index;
                elseif isempty(str2num(a{j}))
                    fprintf('missing %s\n',a{j});
                end
            end
            diff=[1 3 7 30 120 364];
            if not(isempty(index_p))
                s.info{o.index(i)}.price=mean(shiftdim(price(index_t,index_p),1));
                s.info{o.index(i)}.price_hp=mean(shiftdim(price_hp(index_t,index_p),1));
                s.info{o.index(i)}.price_n1=mean(shiftdim(price_n1(index_t,index_p),1));
                tprice_n2=mean(shiftdim(price_n2(index_t,index_p),1));
                s.info{o.index(i)}.price_n2=tprice_n2;
                tprice_exp=mean(shiftdim(price_exp(index_t,index_p),1));
                try;eval(['s.info{o.index(i)}.price_ep7=mean(shiftdim(price_exp(index_t+7,index_p),1))-tprice_exp;']);end;
                try;eval(['s.info{o.index(i)}.price_ep30=mean(shiftdim(price_exp(index_t+30,index_p),1))-tprice_exp;']);end;
                
                for k=1:length(diff)
                    try;eval(['s.info{o.index(i)}.price_dp' num2str(diff(k)) '=mean(shiftdim(price_n2(index_t+diff(k),index_p),1))-tprice_n2;']);end;
                    try;eval(['s.info{o.index(i)}.price_dm' num2str(diff(k)) '=mean(shiftdim(price_n2(index_t-diff(k),index_p),1))-tprice_n2;']);end;
                    try;eval(['s.info{o.index(i)}.price_sp' num2str(diff(k)) '=mean(shiftdim(price_hp(index_t+diff(k),index_p),1));']);end;
                    try;eval(['s.info{o.index(i)}.price_sm' num2str(diff(k)) '=mean(shiftdim(price_hp(index_t-diff(k),index_p),1));']);end;
                end
                tmp=shiftdim(price_n1(index_t-15:index_t+15,index_p),1);
                if length(index_p)>1
                    tmp=mean(tmp);
                end
                try;s.info{o.index(i)}.voialitet=std(tmp);end;
                fprintf(f,'%s %.2f %s\n',s.fwords{o.index(i)},s.info{o.index(i)}.price_n2,datestr(t(i)));
            end
            %if not(isempty(tmp))
            %    fprintf(f,'%savereportas %.2f %savereportas\n',savereportas.fwords{o.index(i)},price(tmp(1)-1,index),datestr(t(i)));
            %end
        end
    else
        fprintf('missing time marker %s\n',s.fwords{o.index(i)})
    end
end
fclose(f);
info.specialword=1;
s=addX2space(s,'_price_ep7',[],info,0,'Price diff at t+7 (exponential)');
s=addX2space(s,'_price_ep30',[],info,0,'Price diff at t+30 (exponential)');

s=addX2space(s,'_price',[],info,0,'Price at time t');
s=addX2space(s,'_price',[],info,0,'Price at time t');
s=addX2space(s,'_price_n1',[],info,0,'Price normalized to mean 1 over time');
s=addX2space(s,'_price_hp',[],info,0,'Price high pass filtered');
s=addX2space(s,'_price_n2',[],info,0,'Price normalized to mean 1 over time and mean 1 over stocks');
s=addX2space(s,'_voialitet',[],info,0,'Price voialitet');
for k=1:length(diff)
    s=addX2space(s,['_price_dp' num2str(diff(k))],[],info,0,'Future (X days) price minus current price');
    s=addX2space(s,['_price_dm' num2str(diff(k))],[],info,0,'Past (X days) price minus current price');
    s=addX2space(s,['_price_sp' num2str(diff(k))],[],info,0,'');
    s=addX2space(s,['_price_sm' num2str(diff(k))],[],info,0,'');
end
s=getSpace('set',s);
save(s.filename,'s');
beep2

% --------------------------------------------------------------------
function plot__Callback(hObject, eventdata, handles)
% hObject    handle to plot_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function check_for_infomaptags_Callback(hObject, eventdata, handles)
% hObject    handle to check_for_infomaptags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] =uigetfile2('*.txt','Choice file for checking infomap tags','DefaultName');
f=fopen([PathName FileName],'r');
nd=0;nt=0;i=0;ntot=0;
while not(feof(f))
    a=fgets(f);i=i+1;
    n1=strfind(a,'<TEXT>');nt=nt+length(n1);
    ntot=ntot+length(n1);
    n2=strfind(a,'</TEXT>');nt=nt-length(n2);
    n3=strfind(a,'<DOC>');nd=nd+length(n3);
    n4=strfind(a,'</DOC>');nd=nd-length(n4);
    if nt>1
        fprintf('Problem line %d, missing </TEXT>\n',i);
    end
    if nt<0
        fprintf('Problem line %d, missing <TEXT>\n',i);
    end
    if nd>1
        fprintf('Problem line %d, missing </DOC>\n',i);
    end
    if nd<0
        fprintf('Problem line %d, missing <DOC>\n',i);
    end
    if rand<.0001
        fprintf('%d',nt);
    end
end
fprintf('\n');
if not(nt==0)
    fprintf('\Missing </TEXT> at end of file\n',i);
end
if not(nd==0)
    fprintf('Missing </DOC> at end of file\n',i);
end
fprintf('Found %d lines and %d <TEXT> markers\n',i,ntot);
fclose(f);
beep2



function rename_word_Callback(hObject, eventdata, handles)
% hObject    handle to rename_word (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
w=getWordFromUser(s,'Name of old word',[],[],1);
if w.N==0 return;end
old=w.input;
i=word2index(s,old);
if isempty(i)
    fprintf('Word does not exist\n');
else
    new=inputdlg3(['New name of ' old],old);
    j=find(strcmpi(s.fwords,new));
    if isempty(j)
        s.fwords{i}=new;
        s=mkHash(s,1);
        s=getSpace('set',s);
    else
        fprintf('Word already exist, no changes made\n');
    end
end


% --------------------------------------------------------------------
function list_word_properties_Callback(hObject, eventdata, handles)
% hObject    handle to list_word_properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words to list properties of','');
if o.N==0; return; end
for i=1:length(o.index)
    j=o.index(i);
    fprintf('word: %s \n',s.fwords{j})
    s.info{j}
    if isfield(s.info{j},'context')
        fprintf('%s\n',s.info{j}.context)
    end
end



% --------------------------------------------------------------------
function copy_words_to_new_space_Callback(hObject, eventdata, handles)
% hObject    handle to copy_words_to_new_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if 1
    [FileName,PathName]=uigetfile('*.mat;','Choise space to copy words from','');
    load([PathName FileName]);
    %[savereportas.N savereportas.Ndim]=size(savereportas.x);
    s.par=getPar;
    [o s]=getWordFromUser(s,'Choice words to copy','');
    s2=s;
    s=getSpace('s');
    if not(strcmpi(s.languagefile,s2.languagefile))
        if strcmpi('No',questdlg2('Mismatching language-files, continue anyway?','Yes','No','Yes'));
            return
        end
    end
    for i=1:o.N
        if o.fwords{i}(1)=='_'
            word=[o.fwords{i}(1) 'i' o.fwords{i}(2:end)];
        else
            word=['i' o.fwords{i}(1:end)];
        end
        s=addX2space(s,word,o.x(i,:),s2.info{o.index(i)});
    end
    s=getSpace('set',s);
else
    s=getSpace('s');
    [o s]=getWordFromUser(s,'Choice words to copy to a new space','');
    s.fwords=s.fwords(o.index);
    s.x=s.x(o.index,:);
    %savereportas.skip=savereportas.skip(o.index);
    s.f=s.f(o.index);
    s.info=s.info(o.index);
    s.filename=inputdlg3('Save modified space',s.filename);
    save(s.filename,'s');
end
% clear a
% %a{20000}='asdf';
% tic
% %for i=2000:-1:1
% for i=1:2000
%     a(i,:)=ones(1,100);
% end
% toc

function eeg_mk_nback
[words data col]=textread2(file);
f=fopen('results_eeg_diffword.txt','w');
for i=1:length(words)/38/7
    o=38*7*(i-1);
    i1=find(strcmpi(s.fwords,words{1+o}));
    if i==1
        w2='temp';
    else
        w2=words{1+o-38*7};
    end
    i2=find(strcmpi(s.fwords,w2));
    if even(i+5,6)
        d(i)=NaN;
    elseif not(isempty(i1)) & not(isempty(i2))
        d(i)=sum(s.x(i1,:).*s.x(i2,:));
    else
        d(i)=NaN;
    end
    for j=1:38*7
        fprintf(f,'%s %d %d %d %d %d %.3f %d\n',words{1+o},data(j+0,2),data(j+0,3),data(j+0,4),data(j+0,5), data(j+0,6),d(i),data(j+0,8));
    end
end
fclose(f);
save('eeg_diff.txt','d','-ASCII');




function optimize_dimensions_Callback(hObject, eventdata, handles)
swap_check(handles.optimize_dimensions)
if not(strcmpi(get(handles.optimize_dimensions,'checked'),'on'))
    parameter(handles.optimize_dimensions,'set');
end

function calculate_bootstrap_stats_Callback(hObject, eventdata, handles)
swap_check(handles.calculate_bootstrap_stats)

function length_one_Callback(hObject, eventdata, handles)
swap_check(handles.length_one)

function opitions_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function set_property_by_context_Callback(hObject, eventdata, handles)
set_word_property_Callback(hObject, eventdata, handles,'context')


function set_word_property_Callback(hObject, eventdata, handles,ver)
if nargin<4 ver=''; end
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words to set word property','_doc*');
if o.N==0 return; end
label=inputdlg3('Choise properity to set (a word will be created with this name)','_category');
if length(label)==0 return; end
info.specialword=1;
s=addX2space(s,label,[],info);
setto=inputdlg3('Set properity to','rand<.5');
setto2=setto;
if length(setto)==0 return; end
if label(1)=='_'; label=label(2:length(label)); end
for i=1:length(o.index)
    if setto2(1)=='_';
        if strcmpi(ver,'context')
            [tmp context]=getProperty(s,'_context',o.index(i));
            setto=[];
            try;context=strread(context{1},'%s');end
            for j=1:length(context)
                setto(j)=getProperty(s,setto2,context{j});
            end
            if rand<.01 fprintf('.');end
            setto=num2str(nanmean(setto));
        else
            setto=num2str(getProperty(s,setto2,o.index(i)));
        end
    end
    eval(['s.info{o.index(i)}.' label '=' setto ';']);
end
s=getSpace('set',s);
beep2
fprintf('\n')

function set_word_property_from_file_Callback(hObject, eventdata, handles)
getReport;


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=get(gcf,'Position');
if a(4)<37
    set(gcf,'Position',[13.6 16 184.4 37.3846])
else
    set(gcf,'Position',[89.6000   48.4615  108.4000    4.9231])
end
a=1;



function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%if getSpace(0,'isset');
global spaceIsLoaded
if spaceIsLoaded==1
    s=getSpace('s');
    check_if_saved(s);
end
delete(hObject);




function Opitions_Callback(hObject, eventdata, handles)

function Untitled_2_Callback(hObject, eventdata, handles)
function Untitled_6_Callback(hObject, eventdata, handles)
function Untitled_7_Callback(hObject, eventdata, handles)

function time_ztransform_Callback(hObject, eventdata, handles)
swap_check(handles.time_ztransform)

function time_new_graf_Callback(hObject, eventdata, handles)
swap_check(handles.time_new_graf)

function time_words_Callback(hObject, eventdata, handles)
swap_check(handles.time_words)

function time_randomsubset_Callback(hObject, eventdata, handles)
swap_check(handles.time_randomsubset)

function print_some2_Callback(hObject, eventdata, handles)
swap_check(handles.print_some2)

function animate2_Callback(hObject, eventdata, handles)
swap_check(handles.animate2)

function text_all2_Callback(hObject, eventdata, handles)
swap_check(handles.text_all2)

function time_autocorrelation_Callback(hObject, eventdata, handles)
swap_check(handles.time_autocorrelation)

function time_average_Callback(hObject, eventdata, handles)
swap_check(handles.time_average)

function time_auto_words_Callback(hObject, eventdata, handles)
swap_check(handles.time_auto_words)

function time_smooth_Callback(hObject, eventdata, handles)
parameter(handles.time_smooth,'set');

function number_of_ass2_Callback(hObject, eventdata, handles)
parameter(handles.number_of_ass2,'set');


function options_Callback(hObject, eventdata, handles)

function buy_criterion_Callback(hObject, eventdata, handles)
parameter(handles.buy_criterion,'set');

function plot_bs_Callback(hObject, eventdata, handles)
swap_check(handles.plot_bs)

function time_serie_buy_weights_Callback(hObject, eventdata, handles)
parameter(handles.time_serie_buy_weights,'set');



function eeg_column_Callback(hObject, eventdata, handles)
parameter(handles.eeg_column,'set');


function eeg_time_period_Callback(hObject, eventdata, handles)
parameter(handles.eeg_time_period,'set');


function eeg_subtract_word_Callback(hObject, eventdata, handles)
swap_check(handles.eeg_subtract_word)

function eeg_covariates_Callback(hObject, eventdata, handles)
swap_check(handles.eeg_covariates)

function eeg_subset_Callback(hObject, eventdata, handles)
swap_check(handles.eeg_subset)

function n_bootstraps_Callback(hObject, eventdata, handles)
parameter(handles.n_bootstraps,'set');



function addwords_EOF_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_EOF)

function addwords_include_all_documents_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_include_all_documents)

function addwords_savetexts_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_savetexts)

function addwords_15context_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_15context)

function addwords_std_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_std)

function addwords_finish_Callback(hObject, eventdata, handles)
swap_check(handles.addwords_finish)

function figure_ass_matrix_Callback(hObject, eventdata, handles)
swap_check(handles.figure_ass_matrix)

function plot_mean_Callback(hObject, eventdata, handles)
swap_check(handles.plot_mean)

function java
javaclasspath('lucene-core-2.3.0.jar','semanticvectors-1.6.jar')


function import_semantic_vector_Callback(hObject, eventdata, handles)
[infile,PathName]=uigetfile2('*.txt','Select semantic vector file','');
f=fopen([PathName infile],'r');
w=fgets(f);
file=regexprep(infile,'.txt','');
fw=fopen(['dictionary_' file '.txt'],'w');
fx=fopen(['space_' file '.txt'],'w');
ff=fopen(['freq_' file '.txt'],'w');
while not(feof(f))
    w=fgets(f);
    j=0;
    for i=1:length(w)
        if w(i)==char(124)
            w(i)=' ';
            if j==0; j=i;end
        end
    end
    fprintf(fx,'%s\n',w(j:length(w)));
    fprintf(fw,'%s\n',w(1:j-1));
    fprintf(ff,'%s\n','1');
end
fclose(f);
fclose(fw);
fclose(fx);

fclose(ff);

function allow_matlab_function_Callback(hObject, eventdata, handles)
swap_check(handles.topoplot_3dhead)

function option_Callback(hObject, eventdata, handles)
a=1;
%function cdf(a,b,c,d)
%function pdf(a,b,c,d)
function topoplot_3dhead_Callback(hObject, eventdata, handles)
swap_check(handles.topoplot_3dhead)

function getdicfile
[a b c d]=textread('dic','%d %d %d %s');
d2=d(1:70000);
f=fopen('dictionary.txt','w')
for i=1:length(d2)
    fprintf(f,'%s\n',d2{i});
end
fclose(f);


% --------------------------------------------------------------------
function apppend_files_Callback(hObject, eventdata, handles)
% hObject    handle to apppend_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file1,PathName]=uigetfile2('*.txt','Select first file','');
file2=1;
while not(file2==0)
    [file2,PathName]=uigetfile2('*.txt','Select new file to append (or cancel)','');
    if not(file2==0)
        f1=fopen([PathName file1],'a');
        f2=fopen([PathName file2],'r');
        while not(feof(f2))
            fprintf(f1,'%s',fgets(f2));
        end
        fclose(f2);
        fclose(f1);
    end
end

function temp99
a=open('matrix.mat');
b=a.var(:,3);
b=b(2:length(b));
cat=a.var(:,2);
cat=cat(2:length(cat));
for i=1:length(b)
    c(i)=str2num(b{i});
    cat2(i)=str2num(cat{i});
end


% --------------------------------------------------------------------
function word_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to word_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameter(handles.word_prefix,'set');




% --------------------------------------------------------------------
function save_assocation_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to save_assocation_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swap_check(handles.save_assocation_matrix)




% --------------------------------------------------------------------
function word_context_size_Callback(hObject, eventdata, handles)
% hObject    handle to word_context_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameter(handles.word_context_size,'set');




% --------------------------------------------------------------------
function plot_f_Callback(hObject, eventdata, handles)
% hObject    handle to plot_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function capital_count_Callback(hObject, eventdata, handles)
% hObject    handle to capital_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to entropy_corpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Calculates frequency and capital letter frequency in corpus-file.\n');

s=getSpace('s');
clear s.x;clear s.fwords;
%clear savereportas.skip;
[fil1,PathName]=uigetfile2('*.txt','Fil','');
if fil1==0 return; end
f=fopen([PathName fil1],'r');
dic=[];upp(1)=0;
while not(feof(f))
    w=clear_char(fgets(f),1);
    w=strread(w,'%s');
    if not(isempty(w))
        for j=1:length(w) %Make dictionary and frequency count
            if isempty(find(strcmpi(dic,lower(w{j}))))
                dic=[dic;lower(w(j))];
                Ntot(length(dic))=0;
                upp(length(dic))=0;
            end
            k=find(strcmpi(dic,lower(w{j})));
            Ntot(k)=Ntot(k)+1;
            upp(k)=upp(k)+strcmpi(upper(w{j}(1)),w{j}(1));
        end
    end
end
fclose(f);
Ptot=Ntot/sum(Ntot);

%Print frequency list
fprintf('A frequency list is printed to the file: frequency.txt');
[tmp index]=sort(Ntot,'descend');
[FileName,PathName] =uiputfile('frequency.txt','Save word count and capital frequency file');
out=fopen([PathName FileName],'w');
for j=1:length(dic)
    fprintf(out,'%s %d %.3f\n',dic{index(j)},Ntot(index(j)),upp(index(j))/Ntot(index(j)));
end
fclose(out);

function testspeed
%Test how fast 100 dim space can be sorted depending on the dimension of
%the space
N=100;
for i=1:12
    x=rand(N,100);
    fprintf('N=%d ',N);
    tic
    o=sort(x*shiftdim(x(1,:),1));
    toc
    N=N*2;
end

% function database_test
% %dbase='space';field='data';
% dbase='sedermera';field='archive_latin1';
% conn = database(dbase,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/' dbase])
% results = fetch(conn, ['SELECT * FROM  `' field '` LIMIT 0 , 30'])
% 
% 
% results = fetch(conn,'SELECT  `body` FROM  `archive_latin1` WHERE  `body` REGEXP  ''ericsson''  LIMIT 0 , 30')
% 
% 
% fastinsert(conn,'freq',{'word','freq','x1'},{'testword',.1,2})
% dbmeta = dmd(conn)
% t = tables(dbmeta, 'cata')
% 
% 
% 
% 
% import java.lang.Thread
% import java.lang.Class
% import java.sql.DriverManager
% current_thread = java.lang.Thread.currentThread();
% class_loader = current_thread.getContextClassLoader();
% class = java.lang.Class.forName('com.mysql.jdbc.Driver', true, class_loader);
% database_url = 'jdbc:mysql://localhost/test2';
% conn = java.sql.DriverManager.getConnection(database_url, 'DB_USERNAME', 'DB_PASSWORD');
% stmt = conn.createStatement();
% query = 'ALTER TABLE freq ADD X2 FLOAT NOT NULL';
% result = stmt.execute(query);



% --------------------------------------------------------------------
function time_serie_cluster_Callback(hObject, eventdata, handles)
% hObject    handle to time_serie_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swap_check(handles.time_serie_cluster)




% --------------------------------------------------------------------
function set_context_article_property_Callback(hObject, eventdata, handles)
% hObject    handle to set_context_article_property (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o_c s]=getWordFromUser(s,'Select contexts words','_doc_*');
art=inputdlg3('Select article prefix','_art_');
property=inputdlg3('Select property','catart');
for i=1:o_c.N
    i1=o_c.index(i);w=s.fwords{i1};
    a=strfind(w,'_');
    w=w(a(2)+1:a(3)-1);
    i2=find(strcmpi(s.fwords,[art w]));
    eval(['s.info{i1}.' property '=s.info{i2}.' property ';']);
end
s=getSpace('set',s);


function mk_fmri_file
s=getSpace;
for i=1:s.N
    s.fwords{i}=regexprep(s.fwords{i},'?','o');
    s.fwords{i}=regexprep(s.fwords{i},'?','a');
    s.fwords{i}=regexprep(s.fwords{i},'?','?');
end

f=fopen('onsets-para.txt','r');
out=fopen('onsets-para_new.txt','w');
fp=0;
while not(feof(f))
    fp=fp+1;
    a1=fgets(f);fprintf(out,'%s',a1);%fp
    a2=fgets(f);fprintf(out,'%s',a2);%fpname
    fprintf('%s ',a2);
    for k=1:4
        a3=fgets(f);fprintf(out,'%s',a3);%onsets
        words=fgets(f);fprintf(out,'%s',words);%words
        w=strread(words,'%s');
        rwords='_abstract_high _abstract_low';
        r=strread(rwords,'%s');
        for j=1:length(r)
            k2=find(strcmpi(s.fwords,r{j}));
            if isempty(k2)
                fprintf('MISSING REGRESSOR WORD')
            end
            for i=1:length(w)
                k1=find(strcmpi(s.fwords,w{i}));
                if not(isempty(k1))
                    rout_old=sum(s.x(k1(1),:).*s.x(k2,:));
                    rout=getProperty(s,k1(1),k2);
                else
                    fprintf('PROBLEM MISSING WORD %s\n',w{i});
                    rout=NaN;
                end
                fprintf(out,'%f ',rout);%regressors
            end
            fprintf(out,'\n');
        end
        a3=fgets(f);%reg1
        a4=fgets(f);%reg2
    end
    a3=fgets(f);%newline
end
fclose(f);fclose(out);


function mk_betula_file
f=fopen('fluency_all.txt','r');
out=fopen('fluency_corpus.txt','w');
while not(feof(f))
    a=lower(fgets(f));
    words=strread(a,'%s');
    fprintf(out,'<DOC><TEXT>\n');
    fprintf(out,'<DATA></DATA>\n');
    fprintf(out,'<LABEL>_flu_%s_%s</LABEL>\n',words{1},words{2});
    for i=3:length(words)
        fprintf(out,'%s ',words{i});
    end
    fprintf(out,'\n');
    fprintf(out,'</TEXT></DOC>\n');
end
fclose(f);
fclose(out);

% function mk_database
% p.database='betula2'
% p.file='betula_text_data.dat';
% 
% 
% p.database='betula'
% conn = database(p.database,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/' p.database]);
% 
% p.file='Total_080924.txt';
% f=fopen(p.file,'r');
% a=fgets(f);
% p.labels=strread(a,'%s');
% 
% results = exec(conn,['CREATE TABLE  `data` (`unikt_nr` BIGINT NOT NULL) ENGINE = MYISAM ']);
% db_mk_feilds(p)
% 
% d=fileread('Total_080924.txt');
% d2=strread(d,'%s');
% d4=reshape(d2,256,4318);
% d5=shiftdim(d4,1);
% %d=strread('Total_080924.txt','%savereportas');
% insert(conn,'data',shiftdim(d5(1,:),1),d5(2:4318,:));
% 
% results = fetch(conn,['SELECT `age_t1` FROM  `data` WHERE  `unikt_nr` =1001']);



% function db_mk_feilds(p)
% import java.lang.Thread
% import java.lang.Class
% import java.sql.DriverManager
% current_thread = java.lang.Thread.currentThread();
% class_loader = current_thread.getContextClassLoader();
% class = java.lang.Class.forName('com.mysql.jdbc.Driver', true, class_loader);
% database_url = ['jdbc:mysql://localhost/' p.database];
% conn = java.sql.DriverManager.getConnection(database_url, 'DB_USERNAME', 'DB_PASSWORD');
% stmt = conn.createStatement();
% for i=2:length(p.labels)
%     query = ['ALTER TABLE data ADD ' p.labels{i} '  FLOAT NOT NULL'];
%     result = stmt.execute(query);
% end
% 
% 
% persistent psave;
% if exist('p')==1
%     p=psave;
%     return;
% end
% psave=3305;
% conn_s.message='try';
% while not(isempty(conn_s.message)) & psave<3310
%     psave=psave+1;
%     fprintf('trying to open port %d\n',psave);
%     conn_s = database('space2','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' num2str(psave) '/DB_INSTANCE']);
% end
% if psave>=3310 fprintf('error in communicating with database\n'); end
% p=num2str(psave);
% 





function s=getWordDb(word,p,t1,t2)
if nargin>3
    t=[' AND  `time`>' num2str(t1) ' AND `time` <' num2str(t2) ];
else
    t='';
end
results=[];Nmax=5000;N=Nmax;Nstart=0;
while N==Nmax;
    query=['SELECT * FROM  `data` WHERE  `word` REGEXP  ''' word '''  ' t ' ORDER BY  `time` ASC LIMIT ' num2str(Nstart) ', ' num2str(Nmax)];
    r = fetch(p.conn_s,query);
    [Nmax tmp]=size(r);
    results=[results;r];Nstart=Nstart+Nmax;
end
if isempty(results); s=[];return; end
if p.random>0
    [s.Ns s.Np]=size(results);
    [temp index]=find(rand(1,s.Ns)<=p.random);
    if not(isempty(index))
        results=results(index,:);
    else
        results=results(1,:);
    end
    fprintf('Using random subsets %.2f selected %d of %d\n',p.random,length(results(:,1)),s.Ns);
end
[s.Ns s.Np]=size(results);
s.word=results(:,1);
s.time=cell2mat(results(:,2));
s.c=cell2mat(results(:,3));
s.length=cell2mat(results(:,4));
s.x=cell2mat(results(:,5:104));
%s.article=cell2mat(results(:,104+1));
s.context=results(:,110+1);
[~, s.Ndim]=size(s.x);



function mk_contexts(handles,searchString,maxArticles)
if nargin<3; maxArticles=0; end
s=getSpace('s');
p=getdb_parameters();

%Getting maxid from webarchive...
results = fetch(p.conn_a,['SELECT  `autoId`  FROM  `archive_latin1`   ORDER BY  `autoId` DESC LIMIT 0,1']);
maxid=results{1};

results = fetch(p.conn_s,['SELECT `word`, `id` FROM  `words` WHERE  `word` LIKE  ''' searchString '''  LIMIT 0,1']);
if isempty(results) %Creatring/updating maxid for searchString....
    newWord=1;
    ggr=0;
else
    newWord=0;
    ggr=results{2};
end
fprintf('New articles %d\n',maxid-ggr)

%Getting maxid from space...
query=['SELECT `word`, `article` FROM  `data` WHERE  `word` REGEXP  ''' '_doc_' searchString '''  ORDER BY  `id` DESC LIMIT 0,1'];
results = fetch(p.conn_s,query);

gstep=25000;
if isempty(results); skip=1;else; skip=0;end

results=1;
xmean=s.xmean2;
contextSizeSet=s.par.contextSizeSet;
contextSize=contextSizeSet;
Nadded=0;
searchwords=strread(searchString,'%s');

while ggr<maxid & (maxArticles==0 | Nadded<maxArticles)
    if strcmpi(searchString,'random')
        fprintf('Making context for 2000 random texts!\n');
        results = fetch(p.conn_a,['SELECT  `body`,  `published`, `autoId`  FROM  `archive_latin1` ORDER BY RAND() LIMIT 0,2000 ' ]);
        ggr=maxid+1;
    else
        fprintf('Making context for %s %.4f %d in %s',searchString,ggr*1.0/maxid,ggr,p.conn_a.instance);
        results = fetch(p.conn_a,['SELECT  `body`,  `published`, `autoId`  FROM  `archive_latin1` WHERE  `autoId`>= ' num2str(ggr) ' AND `autoId`< ' num2str(gstep+ggr) ' AND `published`>0 AND `body` REGEXP ''' searchString ''' ' ]);
    end
    ggr=ggr+gstep;
    fprintf('.');
    
    if isempty(results)
        fprintf('\n');
    else
        texts=results(:,1);
        dates=results(:,2);
        id=results(:,3);
        s1=[];x=[];
        for l=1:length(texts)
            t=regexprep(lower(texts{l}),'[^a-z??? ]','');
            t=strread(t,'%s');
            if strcmpi(searchString,'random')
                f=fix(rand*length(t))+1;
                t{f(1)}='random';
            elseif p.exactmatch %exact match
                f=find(strcmpi(searchwords{1},t));
                if length(searchwords)>1
                    %***!!!This is a bugg here occuring for multiple shearwords,
                    %when the second word does not match the first...
                end
            else
                f=[];
                for i=1:length(t)
                    if not(isempty(strfind(t{i},searchString)))
                        f=[f i];
                    end
                end
            end
            if contextSizeSet==0
                contextSize=1e+9;
                if length(f)>0
                    f=f(1);
                end
            end
            
            for i=1:length(f)
                x=zeros(1,s.Ndim);N=0;
                indexI=max(1,f(i)-contextSize):min(length(t),f(i)+contextSize);
                for j=indexI
                    index=word2index(s,t(j));
                    if not(isnan(index)) & not(j>=f(i) & j<f(i)+length(searchwords))
                        x=x+s.x(index,:)-xmean;N=N+1;
                    end
                end
                
                if N>0
                    if contextSizeSet==0
                        context=texts{l};
                    else
                        context=cell2string(t(indexI));
                    end
                    x=x/max(1,N)+xmean;
                    word=['_doc_' t{f(i)} '_' num2str(id{l}) '_' num2str(i)];
                    s1=addword(s1,'wait',word,x,datenum(dates{l},'yyyy-mm-dd HH:MM:SS'),p,0,id{l},skip,p.conn_a.instance,t{f(i)},context);
                    if rand<.01; fprintf('.'); end
                    Nadded=Nadded+1;
                else
                    fprintf('No words found, skipping...\n');
                end
            end
        end
        addword(s1,'','',x,0,p);
    end
end
if newWord %Creatring/updating maxid for searchString....
    newWord=1;
    try;results = fetch(p.conn_s,['INSERT INTO  `space2`.`words` (`word` ,`id`) VALUES (''' searchString ''',  ''' num2str(maxid) ''' )']);end
else
    try;results = fetch(p.conn_s,['UPDATE  `space2`.`words` SET  `id` =  ''' num2str(maxid) ''' WHERE `words`.`word`  =  ''' searchString ''' LIMIT 1']);end
end


function s=addword(s,ver,word,x,date,p,c,article,skip,dbase,wordchar,context)
if nargin<7; c=0; end
if nargin<8; article=-1; end
if nargin<9; skip=0; end
if nargin<10; dbase=''; end
if nargin<11; wordchar=''; end
if nargin<12; context=''; end
if not(isfield(s,'Ni'))
    s.Ni=0;
    s.x_name{1,1}=['word'];
    s.x_name{2,1}=['time'];
    s.x_name{3,1}=['c'];
    s.x_name{4,1}=['length'];
    for k=1:length(x)
        s.x_name{k+4,1}=['x' num2str(k)];
    end
    s.x_name{5+length(x),1}=['article'];
    s.x_name{6+length(x),1}=['dbase'];
    s.x_name{7+length(x),1}='wordchar';
    s.x_name{8+length(x),1}='updated_date';
    s.x_name{9+length(x),1}='context';
    s.x_in=[];
end

if length(s.x_in)<s.Ni
    s.x_in{length(s.x_name),2*s.Ni+10}=[];
end

if length(word)>0
    if skip
        results=[];
    else
        results = fetch(p.conn_s,['SELECT * FROM  `data` WHERE  `word` = ''' word ''' ']);
    end
    %if not(isempty(results))
    %results = fetch(p.conn_s,['DELETE FROM `data` WHERE  `id` = ' num2str(results{1,6} ) ]);
    %end
    if isempty(results)
        s.Ni=s.Ni+1;
        s.x_in{s.Ni,1}=word;
        s.x_in{s.Ni,2}=date;
        s.x_in{s.Ni,3}=c;
        s.x_in{s.Ni,4}=sum(x.*x)^.5;
        x=x/sum(x.*x)^.5;
        for k=1:length(x)
            s.x_in{s.Ni,k+4}=x(k);
        end
        s.x_in{s.Ni,5+length(x)}=article;
        s.x_in{s.Ni,6+length(x)}=dbase;
        if length(wordchar)>20
            fprintf('\nWarning: %s is too long, truncating\n',wordchar);
            wordchar=wordchar(1:20);
        end
        s.x_in{s.Ni,7+length(x)}=wordchar;
        s.x_in{s.Ni,8+length(x)}=datestr(now,'yyyy-mm-dd HH:MM:SS');
        s.x_in{s.Ni,9+length(x)}=regexprep(context,'''','');
    else
        fprintf('Word %s already exists, skipping\n',word)
    end
end

if strcmpi(ver,'')
    if s.Ni>0
        %r=fetch(p.conn_s,['DELETE FROM  `data` WHERE  `stock` = ''' searchString '''  AND  `time` >=' num2str(t1) ' AND  `time` <=' num2str(t2) ]);
        fprintf('Inserting %d records\n',s.Ni)
        %try
        %    fastinsert(p.conn_s,'data',savereportas.x_name,savereportas.x_in(1:savereportas.Ni,1:length(savereportas.x_name)));
        %catch
        fprintf('*')
        insert(p.conn_s,'data',s.x_name,s.x_in(1:s.Ni,1:length(s.x_name)));
        %end
        %else
        %fetch(p.conn_s,'data
        %end
    end
end


function db_insert_stockprices
conn_p = database('stock','DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://DB_HOST:PORT/stock']);

labels=lower(textread('closeingprices9507_labels.txt','%s'));
price=textread('closeingprices9507.txt');
[Nt Ns]=size(price);
for i=1:length(price)
    time(i)=datenum(num2str(price(i,1)),'yyyymmdd');
end
k=0;
exdata{4,4000*55*2}='';
for i=2:Ns
    for j=1:Nt
        if not(isnan(price(j,i)))
            if j>1
                for l=max(time(j)-4,time(j-1)+1):time(j)-1;
                    %filling missing data up to four days back
                    k=k+1;
                    exdata(1:4,k)=exdata(1:4,k-1);
                    exdata{2,k}=l;
                    exdata{4,k}=1;
                end
            end
            k=k+1;
            exdata{1,k}=labels{i};
            exdata{2,k}=time(j);
            exdata{3,k}=price(j,i);
            exdata{4,k}=0;
        end
    end
end
exdata2=shiftdim(exdata(:,1:k),1);
fastinsert(conn_p,'price',{'stock';'time';'price';'missing'},exdata2)

% function remove_db_mk_feilds(p)
% %CREATE DATABASE  `space` ;
% %CREATE TABLE  `data` (
% % `word` VARCHAR( 60 ) NOT NULL ,
% % `time` DOUBLE NOT NULL ,
% % `c` FLOAT NOT NULL ,
% % `length` FLOAT NOT NULL
% %) ENGINE = MYISAM ;
% 
% import java.lang.Thread
% import java.lang.Class
% import java.sql.DriverManager
% current_thread = java.lang.Thread.currentThread();
% class_loader = current_thread.getContextClassLoader();
% class = java.lang.Class.forName('com.mysql.jdbc.Driver', true, class_loader);
% database_url = 'jdbc:mysql://localhost/space';
% conn = java.sql.DriverManager.getConnection(database_url, 'DB_USERNAME', 'DB_PASSWORD');
% stmt = conn.createStatement();
% for i=1:100
%     query = ['ALTER TABLE data ADD X' num2str(i) '  FLOAT NOT NULL'];
%     result = stmt.execute(query);
% end

function remove_beep2
try
    sound(sin(1:10000/10));
catch
end


% function remove_temp
% java.lang.Runtime.getRuntime.maxMemory
% java.lang.Runtime.getRuntime.totalMemory
% java.lang.Runtime.getRuntime.freeMemory






% --------------------------------------------------------------------
function add_words_from_database_Callback(hObject, eventdata, handles)
% hObject    handle to add_words_from_database (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stocks='sm?bolag facket fackf?reningar arbetsgivare direkt?r l?ntagare avtalsr?relse n?ringslivet sm?f?retag storf?retag';
stocks='astrazeneca autoliv axfood boliden carnegie castellum electrolux eniro ericsson fabege getinge hexagon holmen hufvudstaden husqvarna investor kaupthing kinnevik latour lawson lundbergs lundin meda millicom ncc biocare nobia nordea omx oriflame peab ratos saab sandvik sas sca scania seb seco securitas handelsbanken skf ssab enso swedbank tele2 teliasonera tietoenator volvo vostok jm';
words=inputdlg3('Choise words to add from database',stocks);
word=strread(words,'%s');
for i=1:length(word)
    add_words_from_database_Callback2(hObject, eventdata, handles,word{i})
end
beep2

function add_words_from_database_Callback2(hObject, eventdata, handles,word)
s=getSpace('s');
p=getdb_parameters();
fprintf('loading..');
snew=getWordDb(word,p);
if isempty(snew)
    fprintf('no words found\n');
    return
end

%removing duplicates
index=ones(1,length(snew.word));
for i=1:length(snew.word)
    if not(isempty(find(strcmpi(s.fwords,snew.word{i})))) | length(find(strcmpi(snew.word,snew.word{i})))>1
        fprintf('Removing duplicate %s\n',snew.word{i})
        index(i)=0;
    end
end
index=find(index);

fprintf('found %d %s words..',length(index),word);

s.x=[s.x;snew.x(index,:)];
s.fwords=[s.fwords;snew.word(index)];
s.f=[s.f nan(1,length(snew.word(index)))];
%savereportas.skip=[savereportas.skip zeros(1,length(snew.word(index)))];
for i=1:length(snew.time(index))
    %if snew.time(index(i))>0 %PERHAPS THIS SHOULD BE REMOVED?
    try
        s.hash.put(lower(snew.word{index(i)}),i+s.N);
        s.info{i+s.N}.context=snew.context{index(i)};
        s.info{i+s.N}.time=snew.time(index(i));
        s.info{i+s.N}.c=snew.c(index(i));
        s.info{i+s.N}.length=snew.length(index(i));
    catch
        fprintf('error\n')
    end
    %end
end
%if not(isfield(s,'article')) s.article=nan(s.N,1);end
%s.article=[s.article;snew.article(index)];


s.N=length(s.fwords);
%savereportas=mkHash(savereportas);
s=getSpace('set',s);
fprintf('done\n');

function hearical_cluster
s=getSpace;
[tmp include]=sort(rand(1,s.N));
X0=s.x(include(1:2000),:);
[c1 X]=kmeans(X0,25,'Maxiter',500,'distance','cosine');fprintf('done.\n');

Y = pdist(X,'cosine');
squareform(Y);
Z = linkage(Y);
[H,T]=dendrogram(Z);



% --------------------------------------------------------------------
function frequency_weighted_average_Callback(hObject, eventdata, handles)
% hObject    handle to frequency_weighted_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swap_check(handles.frequency_weighted_average)





% --------------------------------------------------------------------
function paired_semantic_difference_Callback(hObject, eventdata, handles)
swap_check(handles.paired_semantic_difference)

function large_seach
s=getSpace('s');
s.N=1000;s.x=rand(s.N,100);
dist_type='cosine';
N=10;
[y c1]=kmeans(s.x,N,'Maxiter',500,'distance',dist_type);fprintf('done.\n');
for i=1:N
    [clusterindex{i} b]=find(y==i);
end

i=round(rand*s.N+.5);
%standard seach
tic;
d=s.x*shiftdim(s.x(i,:),1);
[d1 index]= sort(d);
t=toc;
fprintf('normal search time %.5f\n',t)
for i=1:10
    fprintf('%d %.2f ',index(i),sum(s.x(index(i),:).*s.x(j,:)));
end
fprintf('\n')

%kmeans search
tic;
d=c1*shiftdim(s.x(i,:),1);
[d1 cindex]= sort(d);

d=s.x(clusterindex{cindex(1)},:)*shiftdim(s.x(i,:),1);
[d1 index]= sort(d);
t=toc;
fprintf('kmean search time %.5f\n',t)
for i=1:10
    k=clusterindex{cindex(1)}(index(i));
    fprintf('%d ',k,sum(s.x(k,:).*s.x(j,:)));
end
fprintf('\n')

function remove_covariates
[w a]=textread('accuracy.txt','%s %f');
[w c]=textread('confidence.txt','%s %f');
a1(:,1)=ones(1,length(a));
a1(:,2)=a;
c1(:,1)=ones(1,length(c));
c1(:,2)=c;
ka=a1\c
kc=c1\a

ka(1)=0;
cnew=c-a1*ka;
kc(1)=0;
anew=a-c1*kc;

function m=test_findmaxid
dbase='dump6';
p.port='3301';
conn = database(dbase,'DB_USERNAME','DB_PASSWORD','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' p.port '/' dbase]);
m=zeros(1,10);
for i=1:8
    results = fetch(conn,['SELECT resourceId, MAX( autoId ) FROM dump' num2str(i) '.archive_latin1 GROUP BY resourceId LIMIT 0 , 30;']);
    for j=1:length(results)
        k=results{j,1};
        m(k)=max(m(k),results{j,2});
    end
end
m

function mkconvert
%in matlab run....
s=getSpace;
for i=1:s.N
    s.fwords{i}=regexprep(s.fwords{i},'?','/a');
    s.fwords{i}=regexprep(s.fwords{i},'?','/e');
    s.fwords{i}=regexprep(s.fwords{i},'?','/o');
end
save('space_allmansum3_new.mat','s')
clear s;

%in octave run
load('space_allmansum3_new.mat')
for i=1:s.N
    s.fwords{i}=regexprep(s.fwords{i},'/a','?');
    s.fwords{i}=regexprep(s.fwords{i},'/e','?');
    s.fwords{i}=regexprep(s.fwords{i},'/o','?');
end


function dist_number_words_Callback(hObject, eventdata, handles)
parameter(handles.dist_number_words,'set');

function keywords_frequency_Callback(hObject, eventdata, handles)
swap_check(handles.keywords_frequency)



% --------------------------------------------------------------------
function semanticTestNdimUsed_Callback(hObject, eventdata, handles)
%parameter(handles.semanticTestNdimUsed,'set');

function d=dist(x1,x2)
d=sum(x1.*x2);

function remove_word_property_Callback(hObject, eventdata, handles)
s=getSpace('s');
prop=inputdlg3('Choice word property to remove','coherence');
if isempty(prop);return; end
if prop(1)=='_'; prop=prop(2:length(prop));end
N=0;
for i=1:s.N
    if isfield(s.info{i},prop)
        s.info{i}=rmfield(s.info{i},prop);
        N=N+1;
    end
end
fprintf('%d properties removed\n',N);
s=getSpace('set',s);






% --------------------------------------------------------------------
function add_word_difference_Callback(hObject, eventdata, handles)
s=getSpace('s');
[file,PathName]=uigetfile2('.*.txt','Choice file with two word columns');
f=fopen([PathName file ],'r');
i=0;
while not(feof(f))
    i=i+1;
    word=fgets(f);
    word=regexprep(word,char(140),'?');
    word=regexprep(word,char(138),'?');
    word=regexprep(word,char(154),'?');
    
    [w1 w2]=strread(word,'%s %s');w1=lower(w1{1});w2=lower(w2{1});
    word=['_diff_' w1 '_' w2 '_' num2str(i)];
    fprintf('%s\t',word);
    i1=find(strcmpi(s.fwords,w1));
    i2=find(strcmpi(s.fwords,w2));
    if not(isempty(i1)) && not(isempty(i2))
        x=s.x(i1,:)-s.x(i2,:);
        info.distance=sum(s.x(i1,:).*s.x(i2,:));
        fprintf('%.3f\t',info.distance);
        s=addX2space(s,word,x,info);
    else
        fprintf('\tmissing word(s), skipping\n')
    end
end
fclose(f);
s=getSpace('set',s);


% --------------------------------------------------------------------
function regression_on_time_serie_Callback(hObject, eventdata, handles)
swap_check(handles.regression_on_time_serie)

% --------------------------------------------------------------------
function time_serie_delay_Callback(hObject, eventdata, handles)
parameter(handles.time_serie_delay,'set');

% --------------------------------------------------------------------
function bootstrap_subject_Callback(hObject, eventdata, handles)
swap_check(handles.bootstrap_subject)
if strcmpi(get(handles.bootstrap_subject,'checked'),'on');
    parameter(handles.bootstrap_subject,'set');
end

function summarize_table_over_time_Callback(hObject, eventdata, handles)
[file,PathName]=uigetfile2('.*.txt','Choice file with a _date column and several data columns');
if file==0; return; end
[words data col labels]=textread2([PathName file]);
i=find(strcmpi(labels,'_date'));
[Nr N]=size(data);
include(Nr)=0;

for j=1:Nr
    include(j)=length(words{j,i})<12;
end
data=data(find(not(include)),:);
words=words(find(not(include)),:);
d=datenum(words(:,i));

t1=min(d);
t2=max(d);
tstep=7;
t1=round(t1/tstep)*tstep;
file=[PathName 'time_' file ];
f=fopen(file,'w');
fprintf(f,'t1_to_t2\tn\t');
for i=1:N
    fprintf(f,'%s\t',labels{i});
end
fprintf(f,'\n');

for t=t1:tstep:t2
    select=find(d>=t & d<t+tstep);
    fprintf(f,'%s-%s\t%d\t',datestr(t),datestr(t+tstep),length(select));
    if not(isempty(select))
        for i=1:N
            fprintf(f,'%.3f\t',mean(data(select,i)));
        end
    end
    fprintf(f,'\n');
end
fclose(f);
fprintf('Done creating file %s\n',file);


% --------------------------------------------------------------------
function covariates_properties_Callback(hObject, eventdata, handles)
parameter(handles.covariates_properties,'setInputdialog');




% --------------------------------------------------------------------
function remap_repeated_Callback(hObject, eventdata, handles)
[file,PathName]=uigetfile2('.*.txt','Choice file with two word columns');
[words data col labels]=textread2([PathName file]);
%time=[3 4];
time=str2num(inputdlg3('Time on row',num2str([2])));
time(2)=1;
subject=str2num(inputdlg3('Subjects on row',num2str(3)));
maxtime(2)=1;
subjects=unique(data(:,subject));
for i=1:length(time)
    time1(i)=min(data(:,time(i)));
    time2(i)=max(data(:,time(i)));
    maxtime(i)=time2(i)-time1(i)+1;
end
[N Nc]=size(data);
clear d;
for i=1:N
    s=find(subjects==data(i,subject))+1;
    if isempty(s)
        fprintf('problem on row %s\n',i);
    else
        for j=1:Nc
            if i==1 %write labels
                for t=time1:time2
                    for k=1:length(time)
                        d{i,(j-1)*maxtime(1)*maxtime(2)+t+(k-1)*maxtime(1)}=[labels{j} '_t' num2str(t) '_c' num2str(k) ];
                    end
                end
            else
                index=(j-1)*maxtime(1)*maxtime(2)+data(i,time(1))+maxtime(1)*data(i,time(2) );
                e=0;
                try
                    if not(isempty(d{s,index}))
                        e=1;
                    end
                end
                if e
                    fprintf('dubbel data point at %d %d %d\n',i,data(i,time(1)),data(i,time(2)));
                else
                    d{s,index}=words{i,j};
                end
            end
            
        end
    end
end
f=fopen(['repeated_' file],'w');
[N Nc]=size(d);
for i=1:N
    for j=1:Nc
        fprintf(f,'%s\t',d{i,j});
    end
    fprintf(f,'\n');
end
fclose(f);
1;



% --------------------------------------------------------------------
function keyword_statistic_test_Callback(hObject, eventdata, handles,NB)
[out, s,in1,in2]=keywordsTest;
s=getSpace('set',s);


% --------------------------------------------------------------------
function regression_extension_Callback(hObject, eventdata, handles)
parameter(handles.regression_extension,'set');


% --------------------------------------------------------------------
function prediction_textfile_Callback(hObject, eventdata, handles)
s=getSpace('s');
[file,PathName]=uigetfile2('*.txt','First column words, second column numbers','');
if not(file==0)
    name=inputdlg3('Name of regressor',['_' regexprep(file,'.txt','')],1);
    [words data col]=textread2([PathName file]);
    words=lower(words(:,1));
    index=word2index(s,words);
    s=train(s,data(:,2),name,0,index);
end
s=getSpace('set',s);


% --------------------------------------------------------------------
function contexts2sentence_Callback(hObject, eventdata, handles)
% hObject    handle to contexts2sentence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Split the context of these words into sentences','');
for i=1:length(o.index)
    try
        context=s.info{o.index(i)}.context;
        splitword=split2sentence(context);
        for j=1:length(splitword)
            s=addText2space(s,splitword{j},['_sentence' num2str(j) s.fwords{o.index(i)}],s.info{o.index(i)} );
        end
    catch
        fprintf('Error in word: %s\n', s.fwords{o.index(i)});
    end
end



% --------------------------------------------------------------------
function Context2Sentences_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]=getWordFromUser(s,'Split the context of these words into sentences','');
if o.N==0; return; end
context=[];
for i=1:length(o.index)
    try
        context=[context s.info{o.index(i)}.context];
    catch
        fprintf('Error missing context in word: %s\n', s.fwords{o.index(i)});
    end
end
splitword=split2sentence(context);

[x N]=text2space(s,splitword);

for i=1:length(N)
    s=addX2space(s,['_sentence' num2str(i)],x(i,:),[],0,['Sentence ' num2str(i)]);
end
getSpace(s,'set')

function NOT_USED
Ncategories=4;
NperCategory=5;

select=find(N>0);
x=x(select,:);splitword=splitword(select);N=N(select);
%Cluster text
[spaceObj.category xcenteroid spaceObj.sumd spaceObj.D]=kmeans(x,Ncategories,'distance','cosine');

%Find the text that is closest to each centroid!
k=0;
for i=1:Ncategories
    index=find(spaceObj.category==i);
    d=x(index,:)*shiftdim(xcenteroid(i,:),1);
    [dsort index_d]=sort(d,'descend');
    if NperCategory>1
        fprintf('\n\n')
    end
    for j=1:NperCategory
        k=k+1;
        indexResults(k)=index(index_d(j));
        if NperCategory>1
            fprintf('%d %d ',i,j)
        end
        fprintf('%s\n',regexprep(regexprep(splitword{indexResults(k)},char(13),''),char(10),''));
    end
end


% --------------------------------------------------------------------
function printDistance_Callback(hObject, eventdata, handles)
swap_check(handles.printDistance)

% --------------------------------------------------------------------
function xmeanCorrection_Callback(hObject, eventdata, handles)
swap_check(handles.xmeanCorrection)

% --------------------------------------------------------------------
function match_paired_test_on_subject_property_Callback(hObject, eventdata, handles)
swap_check(handles.match_paired_test_on_subject_property)


% --- Executes when entered data in editable cell(savereportas) in report.
function report_CellEditCallback(hObject, eventdata, handles,command)
% hObject    handle to report (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(savereportas) edited
%	PreviousData: previous data for the cell(savereportas) edited
%	EditData: string(savereportas) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
commandOrData_Callback(hObject, eventdata, handles,'Command')

global reportFilename
%global noUpdateCol
%noUpdateCol=0;
if length(reportFilename)==0 & isfield(eventdata,'NewData') & length(eventdata.NewData)>0
    reportFilename=' ';
end

if nargin<4; command='';end
d=get(hObject,'Data');
d{1,1}='_identifier';%
[Nr Nc]=size(d);
s=getSpace('s');
if strcmpi(command,'addColumn')
    r=1;
elseif not(strcmpi(command,'addRow')) ;
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    if r==1;
        d{r,c}=eventdata.EditData;
    else
        d{r,c}=eventdata.EditData;
    end
end
updateRow=0;

if strcmpi(command,'addRow');   %Insert multiple words
    c=1;r=0;
    [words s]=getWordFromUser(s,'Choice words','');
    if words.N==0 return; end
    for r0=1:words.N
        r=find(strcmpi(d(:,1),words.word{r0}));
        if isempty(r)
            [Nr Nc]=size(d);
            r=find(strcmpi(d(:,1),''));
            if isempty(r)
                [Nr Nc]=size(d);
                r=Nr+1;
                d{r,1}='';
            end
        end
        r=r(1);
        d{r,1}=words.word{r0};
        if r>1
            d=reportUpdateRow(s,d,r,[],0);
        end
    end
    setReportData(handles.report,d);
elseif strcmpi(command,'addColumn');   %Insert multiple words
    r=1;
    c=1;
    [words s]=getWordFromUser(s,'Choice words','');
    if words.N==0; return; end
    if words.N>10
        if not(strcmpi('Yes',questdlg2(['Do you want to to add ' num2str(words.N) ' columns?'],'Yes','No','Yes')))
            return
        end
    end
    for c0=1:words.N
        [d s c]=reportUpdateCol(s,d,[],words.word{c0});
    end
elseif c==1 %Update word/row
    updateRow=1;
elseif r==1
    if 1 %New
        [~ , text ,s]=getProperty(s,d{1,c},word2index(s,d(2:Nr,1)),getReportCommand(2:Nr,c));%d{row,c},
        d(2:Nr,c)=text;
    else %Old remove
        s=updateContext(s,word2index(s,d(2:Nr,1)));
        for row=2:Nr
            if length(d{row,1})>0
                [~, text s]=getProperty(s,d{1,c},d{row,1},getReportCommand(row,c));%d{row,c},
                d{row,c}=text{1};
            end
        end
    end
elseif strcmpi(d{1,c},'_context') | strcmpi(d{1,c},'_text') | strcmpi(d{1,c},s.par.variableToCreateSemanticRepresentationFrom) %Update property/column
    updateRow=1;
end

%if r>-1 %Update property
property=d{1,c};
word=d{r,1};
data=d{r,c};
global reportCommand;
reportCommand{r,c}=data;
if length(data)>1 & data(1)=='='
    command=strread(data,'%s');
    command{1}=command{1}(2:length(command{1}));
    if length(command)==1;
        command{3}=command{1};
        command{1}=d{1,c};
        command{2}=d{r,1};
    elseif length(command)==2;
        command{3}=[];
    elseif length(command)>=3;
        if length(command)<=4; command{5}=''; end
        command=command([2 3 1 4 5]);
    end
    if length(command)<=4; command{5}=''; end
    [tmp , tmp2, s]=getProperty(s,command{1},command{2},command{3},command{4},command{5});
    d{r,c}=tmp2{1};
else
    [s newword]=setProperty(s,word,property,data);
    if not(isempty(newword)) & r==1; d{r,c}=newword;end
end
s=getSpace('set',s);
%end

if updateRow
    d=reportUpdateRow(s,d,r);
end

[Nr Nc]=size(d);
if r>=Nr %Expand row
    d{Nr+1,1}='';
end
if c>=Nc %Expand col
    d{1,Nc+1}='';
end
[Nr Nc]=size(d);
setReportData(hObject,d);




% --------------------------------------------------------------------
function openReport_Callback(hObject, eventdata, handles)
% hObject    handle to openReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%commandOrData_Callback(hObject, eventdata, handles,'Command');
%global noUpdateCol
%noUpdateCol=1;
getReport;
%set_word_property_from_file_Callback(hObject, eventdata, handles)
%noUpdateCol=0;
%commandOrData_Callback(hObject, eventdata, handles,'Command');


% --------------------------------------------------------------------
function report_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'report_button'


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addRowReport.
function addRowReport_Callback(hObject, eventdata, handles)
% hObject    handle to addRowReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
report_CellEditCallback(handles.report, eventdata, handles,'addRow')

% --- Executes on button press in addColumnReport.
function addColumnReport_Callback(hObject, eventdata, handles)
% hObject    handle to addColumnReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
report_CellEditCallback(handles.report, eventdata, handles,'addColumn')


% --- Executes on key press with focus on report and none of its controls.
function report_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to report (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(savereportas) that was pressed
%	Modifier: name(savereportas) of the modifier key(savereportas) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
'keypress';
1;


% --- Executes when selected cell(savereportas) is changed in report.
function report_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to report (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(savereportas) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global reportCommand;

function space_time_CreateFcn(hObject, eventdata, handles)
function space_random_CreateFcn(hObject, eventdata, handles)
function comp_text_CreateFcn(hObject, eventdata, handles)
function input_text_CreateFcn(hObject, eventdata, handles)
function myprint_CreateFcn(hObject, eventdata, handles)



% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fixResize(handles.addColumnReport,1);

function fixResize(h,i)
persistent h0
h0{10}='';
b=get(gcf,'Position');
if isempty(h0{i})
    a=get(h,'Position');
    b=get(gcf,'Position');
    h0{i}=a.*b;
end
a=h0{i}./b;
%a(3)=69.4/b(3)*.144;
%a(4)=23/b(4)*.09;
set(h,'Position',a);



% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in tableFunction.
function tableFunction_Callback(hObject, eventdata, handles,ver)
% hObject    handle to tableFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tableFunction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tableFunction
if nargin<4
    ver=get(hObject,'Value');
end

if ver==2 | ver==3
    s=getSpace;
    if strcmpi('Words in report',questdlg2('Base on','Words in report','Words in report','Select Wordset','Words in report'));
        d=get(handles.report,'Data');
        [Nr Nc]=size(d);
        wordSet=d(2:Nr,1);
        word=cell2string(wordSet);
        [wordset s]=getWord(s,word);
    else
        [wordset s]=getWordFromUser(s,'Choice words');
    end
    if wordset.N==0 return; end
    
    if ver==2
        s=train(s);%,[],wordset.word);%,propertyPredict,propertySet);
    elseif ver==3
        N=str2num(inputdlg3('Number of cluster','8'));
        propertySet=fixpropertyname(inputdlg3('Labels for clusters','_category'));
        [s info]=clusterSpace(s,wordset.index,N,propertySet);
        fprintf('%s',info.results)
        [d s]=reportUpdateCol(s,[],[],propertySet);
    end
    s=getSpace('set',s);
end

try
    set(hObject,'Value',1);
catch
    fprintf('Can not set Value in hObject\n')
end

% --- Executes during object creation, after setting all properties.
function tableFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function keyword_NB_Callback(hObject, eventdata, handles)
keywordsTest(s,[],[],1);
s=getSpace('set',s);


% --------------------------------------------------------------------
function aggregate_Callback(hObject, eventdata, handles)
% hObject    handle to aggregate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace('s');
[o s]=getWordFromUser(s,'Choice words to aggregate','');
if o.N==0; return; end
[property s]=getWordFromUser(s,'Choice properties to aggregate on','');
if property.N==0; return; end
for i=1:length(o.index)
    propertyData{i}=[];
    for j=1:length(property.index)
        [data w]=getProperty(s,o.index(i),property.index(j));
        if not(isempty(w{1}))
            data=w{1};
        else
            data=num2str(data);
        end
        propertyData{i}=[propertyData{i} '-XXX-' data];
    end
end
propertyU=unique(propertyData);
seperator=word2index(s,'_NAN');
for i=1:length(propertyU)
    index=find(strcmpi(propertyU(i),propertyData));
    if not(isempty(index))
        f=fields(s.info{o.index(index(1))});
        info=[];
        for j=1:length(f)
            data=[];
            try
                ok=eval(['ischar(s.info{o.index(j)}.' f{j} ');']);
                if ok==1
                    for k=1:length(index)
                        data=[data ' ' eval(['s.info{o.index(index(k))}.' f{j} ';']) ' _NAN '];
                    end
                    eval(['info.' f{j} '=data;']);
                elseif strcmpi(f{j},'index')
                    for k=1:length(index)
                       data =eval(['[data s.info{o.index(index(k))}.' f{j} ' seperator];']);
                    end
                    eval(['info.' f{j} '=data;']);
                else
                    for k=1:length(index)
                        data(k)=eval(['s.info{o.index(index(k))}.' f{j} ';']);
                    end
                    eval(['info.' f{j} '=mean(data);']);
                end
            catch
                
            end
        end
        if not(isempty(info))
            if isfield(info,'wordclass')
                info=rmfield(info,'wordclass');
            end
            
            %global noUpdateCol
            %noUpdateCol=1;
            newword=['_aggregate' num2str(i)];
            %x= average_vector(s,s.x(o.index(index),:));
            if isfield(info,'context')
                fprintf('Adding aggregated word %s based on %s for property value %.3f\n',newword,struct2string(s.fwords(o.index(index))),propertyU{i})
                [s N word]=addText2space(s,info.context,newword,info);
            end
        end
    end
end
s=getSpace('set',s);



% --------------------------------------------------------------------
function sort_columns_Callback(hObject, eventdata, handles)
% hObject    handle to sort_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d=get(handles.report,'Data');
c=str2num(inputdlg3('Choice column to sort','1'));
if not(isempty(c))
    [tmp index]=sort(d(2:end,c));
    d=d([1; index+1],:);
    set(handles.report,'Data',d);
    global reportCommand;
    try
        reportCommand=reportCommand([1; index+1],:);
    end
end




% --------------------------------------------------------------------
function optimize_dimensions_conservative_Callback(hObject, eventdata, handles)
swap_check(handles.optimize_dimensions_conservative)
% hObject    handle to optimize_dimensions_conservative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function preprocess_with_SVD_Callback(hObject, eventdata, handles)
swap_check(handles.preprocess_with_SVD)
% hObject    handle to preprocess_with_SVD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function context2word_Callback(hObject, eventdata, handles)
s=getSpace('s');
[o s]= getWordFromUser(s,'Choice words to extract contexts from','');
if o.N==0;return;end
contextWord=inputdlg3('Choice context word','');
if length(contextWord)==0;return;end
contextSize=15;
for i=1:length(o.index)
    try
        context=s.info{o.index(i)}.context;
        [x N Ntot t index]=text2space(s,context);
        index=strfind(lower(t),lower(contextWord));
        index2=zeros(1,length(index));
        for j=1:length(index)
            if not(isempty(index{j}))
                index2(j)=index{j};
            end
        end
        index=find(index2);
        for j=1:length(index)
            info=s.info{o.index(i)};
            info.orginalword=s.fwords{o.index(i)};
            info.contextword=contextWord;
            info.contextnr=i;
            info.contextcontext=j;
            contextText=struct2string(t(max(1,index(j)-contextSize):min(length(t),index(j)+contextSize)));
            s=addText2space(s,contextText,['_context'  regexprep(s.fwords{o.index(i)},'_','') contextWord num2str(j)],info );
        end
    catch
        fprintf('Error in word: %s\n', s.fwords{o.index(i)});
    end
end



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
1;


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function holmes_correction_Callback(hObject, eventdata, handles)
% hObject    handle to holmes_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swap_check(handles.holmes_correction)


% --------------------------------------------------------------------
function keywords_over_articles_Callback(hObject, eventdata, handles)
swap_check(handles.keywords_over_articles)


% --------------------------------------------------------------------
function predictionProperties_Callback(hObject, eventdata, handles)
parameter(handles.predictionProperties,'setInputdialog');



% --------------------------------------------------------------------
function update_report_automatic_Callback(hObject, eventdata, handles)
swap_check(handles.update_report_automatic)


% --------------------------------------------------------------------
function NleaveOuts_Callback(hObject, eventdata, handles)
parameter(handles.NleaveOuts,'set');


% --------------------------------------------------------------------
function predictOnWordClass_Callback(hObject, eventdata, handles)
swap_check(handles.predictOnWordClass)


% --------------------------------------------------------------------
function selectBestDimensions_Callback(hObject, eventdata, handles)
swap_check(handles.selectBestDimensions)


% --------------------------------------------------------------------
function extendedOutput_Callback(hObject, eventdata, handles)
swap_check(handles.extendedOutput)


% --------------------------------------------------------------------
function regressionCategory_Callback(hObject, eventdata, handles)
swap_check(handles.regressionCategory)


% --------------------------------------------------------------------
function logisticRegression_Callback(hObject, eventdata, handles)
swap_check(handles.logisticRegression)


% --------------------------------------------------------------------
function stdOfSimiliarity_Callback(hObject, eventdata, handles)
swap_check(handles.stdOfSimiliarity)


% --------------------------------------------------------------------
function forceMaxDimToN2_Callback(hObject, eventdata, handles)
swap_check(handles.forceMaxDimToN2)



% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function weightByContextWords_Callback(hObject, eventdata, handles)
w=parameter(handles.weightByContextWords,'set');
s=getSpace;
if isnan(word2index(s,w)) & length(w)>0
    questdlg2('This Identifier does not have semantic representation. 1. Use ''Data/Add Identifier'' to add a semantic representation. 2. Reload your data','Ok','Ok');
    %info.normalword=1;
    %s=addX2space(s,w,s.x(1,:)*NaN,info);
    %s=getSpace('set',s);
end


% --------------------------------------------------------------------
function getProperyShowSemanticTest_Callback(hObject, eventdata, handles)
parameter(handles.getProperyShowSemanticTest,'set');


% --------------------------------------------------------------------
function resultsVariables_Callback(hObject, eventdata, handles)
parameter(handles.resultsVariables,'set');


% --------------------------------------------------------------------
function freezeSecondsParameterGetProperty_Callback(hObject, eventdata, handles)
swap_check(handles.freezeSecondsParameterGetProperty);
s=getSpace;
s.par2=getPar;
s=getSpace('set',s);



% --------------------------------------------------------------------
function LIWCkeywords_Callback(hObject, eventdata, handles)
parameter(handles.LIWCkeywords,'setInputdialog',0);


% --------------------------------------------------------------------
function LIWCcorr_Callback(hObject, eventdata, handles)
parameter(handles.LIWCcorr,'set');


% --------------------------------------------------------------------
function LDA_Callback(hObject, eventdata, handles)
LDA


% --------------------------------------------------------------------
function saveLanguageFile_Callback(hObject, eventdata, handles)
s=getSpace;
one=0;
[o1 s]=getWordFromUser(s,'Identifiers to copy to the active languagefile','','',one);
if o1.N==0; return;end
[~,comment]=getProperty(s,o1.index(1),'_comment');
comment=inputdlg3('Provide a detailed describtion of the Identifier',comment{1},0);

for i=1:length(o1.index)
    s.info{o1.index(i)}.persistent=1;
    s.info{o1.index(i)}.comment=comment;
    if regexp(s.fwords{o1.index(i)},'_liwc')>0
        fprintf('Making a LIWC category\n');
        s.info{o1.index(i)}.specialword=5;
    end
end
getSpace('set',s);
saveSpace(s,s.filename,1);


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function opition_Callback(hObject, eventdata, handles)
% hObject    handle to opition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function db2space_Callback(hObject, eventdata, handles)
s=db2space;
getSpace('set',s);


% --------------------------------------------------------------------
function saveReport_Callback(hObject, eventdata, handles)
% hObject    handle to saveReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveReport;%(hObject, eventdata, handles);


% --------------------------------------------------------------------
function saveReportAs_Callback(hObject, eventdata, handles)
saveReport;%(hObject, eventdata, handles,1);


% --------------------------------------------------------------------
function Ncluster_Callback(hObject, eventdata, handles)
parameter(handles.Ncluster,'set');


% --------------------------------------------------------------------
function NgramPOS_Callback(hObject, eventdata, handles)
swap_check(handles.NgramPOS)


% --------------------------------------------------------------------
function searchText_Callback(hObject, eventdata, handles)
s=getSpace;
search=inputdlg3('Search for text','');

for i=1:s.N
    if isfield(s.info{i},'context')
        text=s.info{i}.context;
    else
        text=s.fwords{i};
    end
    if strfind(text,search)>0
        fprintf('%s\t%s\n',s.fwords{i},regexprep(text,char(13),' '));
    end
end


% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function similarityMeasure_Callback(hObject, eventdata, handles,word)
set(handles.similarityMeasure(1),'UserData',word)
set(handles.similarityMeasure,'checked','off');
choice={'','standarddeviation','mean','min','max','standarddeviation','negative','positive','sortword','sortvalue','LIWC','keywords','word','target','seperator','noliwc'};
%'positivenegative',
i=strcmpi(word,choice);
i=find(handles.similarityMeasure==hObject);
set(handles.similarityMeasure(i),'checked','on');



% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to similarityMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_15_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function weightWordClass_Callback(hObject, eventdata, handles)
s=getSpace;
for i=1:length(s.classlabel)
    set(handles.wordClass(20-i),'label',s.classlabel{i});
end
return


% --------------------------------------------------------------------
function wordClass_Callback(hObject, eventdata, handles)
s=getSpace;
swap_check(hObject)
if strcmpi(get(hObject,'Label'),'set/clear all')
    for i=1:length(s.classlabel)
       set(handles.wordClass(20-i),'Checked',get(hObject,'Checked')); 
    end
end



% --------------------------------------------------------------------
function plotEachDataPoint_Callback(hObject, eventdata, handles)
swap_check(handles.plotEachDataPoint)


% --------------------------------------------------------------------
function includeStopwords_Callback(hObject, eventdata, handles)
swap_check(handles.includeStopwords)


% --------------------------------------------------------------------
function includeNonStopwords_Callback(hObject, eventdata, handles)
swap_check(handles.includeNonStopwords)


% --------------------------------------------------------------------
function stopwordsSmooth_Callback(hObject, eventdata, handles)
swap_check(handles.stopwordsSmooth)


% --------------------------------------------------------------------
function correctionForMultipleComparisions_Callback(hObject, eventdata, handles)
s=getSpace;
for i=1:3
    set(handles.correctionForMultipleComparisions(i),'Checked','Off');
%    set(handles.option(i),'label',s.classlabel{i});
end
swap_check(hObject)

return
text=get(handles.weightWordClass,'label');
label='';
for i=1:length(s.classlabel)
    label=[label num2str(i) ' ' s.classlabel{i} ', '];
end
set(handles.weightWordClass,'label',[label ':']);
N=parameter(handles.weightWordClass,'set');
set(handles.weightWordClass,'label',['Weight semantic by wordclass: '  num2str(N)]);


% --------------------------------------------------------------------
function trainMedianSplitKeywordAnalysis_Callback(hObject, eventdata, handles)
swap_check(handles.trainMedianSplitKeywordAnalysis)


% --------------------------------------------------------------------
function keywordCorrProperty_Callback(hObject, eventdata, handles)
parameter(handles.keywordCorrProperty,'set',0);

% --------------------------------------------------------------------
function keywordsPlot_Callback(hObject, eventdata, handles)
par.plotwordCountCorrelation=0;%Use median split, in plotWordCount
par.persistent=1;
getPar(par);
s=plotWordcount;
s=getSpace('set',s);

% --------------------------------------------------------------------
function keywordPlotKeywords_Callback(hObject, eventdata, handles)
swap_check(handles.keywordPlotKeywords)

% --------------------------------------------------------------------
function keywordPlotWordcloud_Callback(hObject, eventdata, handles)
swap_check(handles.keywordPlotWordcloud)

% --------------------------------------------------------------------
function optition_Callback(hObject, eventdata, handles)
% hObject    handle to optition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function keywordsPlotRedo_Callback(hObject, eventdata, handles)
swap_check(handles.keywordsPlotRedo)

% --------------------------------------------------------------------
function keywordsPlotSpread_Callback(hObject, eventdata, handles)
parameter(handles.keywordsPlotSpread,'set',0);


% --------------------------------------------------------------------
function keywordsPlotPvalue_Callback(hObject, eventdata, handles)
parameter(handles.keywordsPlotPvalue,'set',0);


% --------------------------------------------------------------------
function plotkeywordsFontsize_Callback(hObject, eventdata, handles)
parameter(handles.plotkeywordsFontsize,'set',0);


% --------------------------------------------------------------------
function plotWordcountMinMaxFontsize_Callback(hObject, eventdata, handles)
parameter(handles.plotWordcountMinMaxFontsize,'set',0);

% --------------------------------------------------------------------
function plotWordCountWords_Callback(hObject, eventdata, handles)
swap_check(handles.plotWordCountWords)


% --------------------------------------------------------------------
function plotWordPrintDots_Callback(hObject, eventdata, handles)
swap_check(handles.plotWordPrintDots)


% --------------------------------------------------------------------
function plotWordcountMaxNumber_Callback(hObject, eventdata, handles)
parameter(handles.plotWordcountMaxNumber,'set',0);


% --------------------------------------------------------------------
function plotWordcountWeightCluster_Callback(hObject, eventdata, handles)
parameter(handles.plotWordcountWeightCluster,'set',0);


% --------------------------------------------------------------------
function clusterPlot_Callback(hObject, eventdata, handles)
swap_check(handles.clusterPlot)


% --------------------------------------------------------------------
function setParametersFromFile_Callback(hObject, eventdata, handles)
text=get(handles.setParametersFromFile,'label');
i=findstr(text,':');
[file,PathName]=uigetfile2('*.txt','Choose parameter file','');
set(handles.setParametersFromFile,'label',[text(1:i) PathName file]);
1;


% --------------------------------------------------------------------
function keyword_variable_Callback(hObject, eventdata, handles)
s=getSpace('s');
[index1 s]=getWordFromUser(s,'Choice identifiers','_m*');
if index1.N==0 return; end;
[index2 s]=getWordFromUser(s,'Choice variable to correlate with','');
if index2.N==0 return; end;
for i=1:length(index2.index)
    fprintf('\n\nCorrelated identifier: %s\n',index2.fwords{i});
    corrProperty=getProperty(s,index2.index(i),index1.index);
    [out{i}, s]=keywordsTest(s,index1.index,NaN,0,'','',2,corrProperty);
end
s=getSpace('set',s);


% --------------------------------------------------------------------
function createConcept_Callback(hObject, eventdata, handles)
createConcept


% --------------------------------------------------------------------
function keywordsPlotCorrelation_Callback(hObject, eventdata, handles)
par.plotwordCountCorrelation=1;%Use correlation, rater than median split, in plotWordCount
par.plotOnSemanticScale=0;
par.persistent=1;
getPar(par);
s=plotWordcount;
s=getSpace('set',s);


% --------------------------------------------------------------------
function subtractSemanticRepresenationOnTrain_Callback(hObject, eventdata, handles)
swap_check(handles.subtractSemanticRepresenationOnTrain)

% --------------------------------------------------------------------
function aggregateColomns2Rows_Callback(hObject, eventdata, handles)
handles=getHandles;
d=get(handles.report,'Data');
N=size(d);
d2{1,1}='_identifier';
d2{1,2}='_text';
for c=1:N(2)
    d2{c+1,1}=[d{1,c} 'aggregate'];
    d2{c+1,2}=struct2string(d(2:N(1),c));
    for i=1:10
        d2{c+1,2}=regexprep(d2{c+1,2},'  ',' ');
    end
end
global reportFilename 
reportFilename=regexprep(reportFilename,'Aggregated','');
reportFilename=[reportFilename ' Aggregated'];
set(handles.report,'Data',d2);
set_word_property_from_variables(getSpace,d2(2:N(1),:), [], 1, d2(1,:))


% --------------------------------------------------------------------
function figures2Plot_Callback(hObject, eventdata, handles)
% hObject    handle to figures2Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
label={'1 Keywords','2 Cluster with keywords','3 Cluster with semantic associates','4 Cluster all words (no axis)','5 Wordcloud (text-norm)','6 Wordcloud (high-low)','7 Wordcloud (low-high)','8 Semantic LIWC','9 Frequency LIWC','10 Predictions','11 Variables','12 Wordclasses','13 Functions','14 Cluster','15 Wordcloud (shared words)','Select all','Deselect all'};
for i=1:length(label)
    set(handles.figuresSwap(i),'label',label{length(label)-i+1});
end


% --------------------------------------------------------------------
function figuresSwap_Callback(hObject, eventdata, handles)
% hObject    handle to figuresSwap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swap_check(hObject)
if strcmpi('Deselect all',hObject.Label)
    for i=1:length(handles.figuresSwap)
        handles.figuresSwap(i).Checked='off';
    end
end
if strcmpi('Select all',hObject.Label)
    for i=1:length(handles.figuresSwap)
        handles.figuresSwap(i).Checked='on';
    end
end

% --------------------------------------------------------------------
function figuresSwap19_Callback(hObject, eventdata, handles)
% hObject    handle to figuresSwap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
% --------------------------------------------------------------------
function SemanticPlotCorrelation_Callback(hObject, eventdata, handles)
par.plotwordCountCorrelation=1;%Use correlation, rater than median split, in plotWordCount
par.plotOnSemanticScale=1;
par.persistent=1;
getPar(par);
s=plotWordcount;
s=getSpace('set',s);


% --------------------------------------------------------------------
function Untitled_34_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_35_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function getProperty2file_Callback(hObject, eventdata, handles)
getProperty2file;
% hObject    handle to getProperty2file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotNew_Callback(hObject, eventdata, handles)
plotWordCloud;


% --------------------------------------------------------------------
function setParameters_Callback(hObject, eventdata, handles)
% hObject    handle to setParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=getSpace;
generalUseDefaultSettings=s.par.generalUseDefaultSettings;
s.par.generalUseDefaultSettings=0;
getPar(s.par);
[o1 s]=getWordFromUser(s,'Set parameters','','',2);
if generalUseDefaultSettings & not(s.par.generalUseDefaultSettings)
    s.par.generalUseDefaultSettings=0;
end
getPar(s.par);



% --------------------------------------------------------------------
function spaceEnglish_Callback(hObject, eventdata, handles)
% hObject    handle to spaceEnglish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getNewSpace('spaceEnglish2');



% --------------------------------------------------------------------
function spaceSwedish_Callback(hObject, eventdata, handles)
% hObject    handle to spaceSwedish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getNewSpace('spaceSwedish2');

% --------------------------------------------------------------------
function Untitled_36_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Diagnos_Callback(hObject, eventdata, handles)
diagnos;


% --------------------------------------------------------------------
function Translate_Callback(hObject, eventdata, handles)
% hObject    handle to Translate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
translateFile


% --------------------------------------------------------------------
function semanticCorrelation_Callback(hObject, eventdata, handles)
% hObject    handle to semanticCorrelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
semanticCorrelation;


% --------------------------------------------------------------------
function IRT_Callback(hObject, eventdata, handles)
IRT;
% hObject    handle to IRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Semantic_ttest_median_split_Callback(hObject, eventdata, handles)
% hObject    handle to Semantic_ttest_median_split (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s=getSpace('s');
par=[];
[par.texts s]=getWordFromUser(s,'Choice text identifier for t-test median split','*');
if par.texts.N==0 return; end
[properties s]=getWordFromUser(s,'Choice variable to conduct t-test on','*');
if properties.N==0 return; end
[medianSplit s]=getWordFromUser(s,'Choice variable(s) to conduct median split on','*');
if medianSplit.N==0 return; end

par.properties=cell2string([properties.fwords medianSplit.fwords']);
scriptTrain(s,par,{'getProperty-ttest-mediansplit'});

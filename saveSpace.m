function [sin s includeLanguageSpace]=saveSpace(sin,filename,saveAsLanguageFile);
%saveAsLanguageFile = 1 save as languafile, = 2 return those that are not
%in languagfile
if nargin<1
    sin=getSpace;
end
if nargin<2 
    filename=[];
end
if nargin<3 | isempty(saveAsLanguageFile)
    saveAsLanguageFile=0;
end
if isempty(filename)
    if saveAsLanguageFile
        filename=sin.languagefile;
    else
        filename=sin.datafile;
    end
end
%if nargin<4 %Specifies which identifiers are in the language space (includeLanguageSpace==1)
includeLanguageSpace=ones(1,length(sin.fwords));
for i=1:length(sin.fwords)
    if length(sin.fwords{i})>0 & sin.fwords{i}(1)=='_'
        if isfield(sin.info{i},'persistent') & sin.info{i}.persistent==1
            %Put in language-file!
            1;
        else
            includeLanguageSpace(i)=0;
        end
    end
end

if saveAsLanguageFile==2
    s=remove_words_now(sin,find(not(includeLanguageSpace)),2);
    return;
elseif saveAsLanguageFile>0
    %Save languafile
    s=remove_words_now(sin,find(includeLanguageSpace==1));
    fprintf('Saving language space %s with %d words...',filename,s.N);
    s=rmfield(s,'handles');
    save(filename,'s');
    fprintf('done\n');
    return
end

%Save datafile
if nargin>1 & length(filename)>0
    sin.datafile= filename;
    sin=getSpace('set',sin);
elseif (nargin<=1 & not(isfield(sin,'datafile'))) | (isfield(sin,'datafile') & length(sin.datafile)==0)
    fprintf('Input name of the SPACE data file!\n')
    [file,path] =uiputfile('*','Save data space');
    sin.datafile=[path  file];
    if sin.datafile==0; 
        sin.datafile='';
        return; 
    end
    sin=getSpace('set',sin);
end

includeDataFile=find(not(includeLanguageSpace));

s.fwords=sin.fwords(includeDataFile);
s.x=sin.x(includeDataFile,:);
s.info=sin.info(includeDataFile);
s.f=sin.f(includeDataFile);
try
    if sin.par.variables
        if size(sin.var.data,1)<max(includeDataFile)
            sin.var.data(max(includeDataFile),:)=0;
        end
        s.var.data=sin.var.data(includeDataFile,:);
        s.var.name=sin.var.name;
        s.var.hash=sin.var.hash;
    end
end
s.datafile=sin.datafile;

if not(isfield(sin,'path')) sin.path=pwd; end
s.data=1;
s.filename=sin.filename;
s.languagefile=sin.languagefile;
s.languagefilePath=sin.languagefilePath;
if isfield(sin,'extraData')
    s.extraData=sin.extraData;
end

fprintf('Saving data space: %s with %d words...',s.datafile,length(s.fwords) );
global saveSpaceBackup
if saveSpaceBackup
    movefile(s.datafile,[regexprep(s.datafile,'.mat','') '.mat.bak']);
end
if length(s.fwords)>400000
    fprintf('\nSaving HUGE file (N>400000) without compression which is slow and takes a lot of space!!!\n')
    save(s.datafile ,'s','-v7.3');
else
    save(s.datafile ,'s');
end
fprintf('done!\n');



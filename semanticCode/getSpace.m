function sOut=getSpace(version,sSave,filename)
%version: set/init
%snew: old space
%filenam: new space name
%version, sNewSpace

persistent s
persistent s2;
if nargin<1
    version='';
end 
if strcmpi(version,'space2')
    if isempty(s2) | not(strcmpi(s2.filename,sSave.par.space2))
        s2=getSpace2(sSave.par.space2);
    end
    s2.par=getPar;
    sOut=s2;
    return
elseif strcmpi(version,'set2')
    sSave.saved=0; 
    s2=sSave;sOut=s;
elseif strcmpi(version,'set')
    sSave.saved=0; 
    s=sSave;sOut=s;
elseif strcmpi(version,'init') 
    s.par=getPar;
    check_if_saved(s);
    clear s;
    sOut=[];
    s.init=1;
else
    if nargin>=3
        s=getNewSpace(filename,version,sSave);
    end
    s.par=getPar;
    s.handles=getHandles;
    if not(isfield(s,'filename'))
        s.filename='spaceenglish.mat';
        if exist(s.filename)
            fprintf('Loading default space %s\n',s.filename)
            s=getNewSpace(s.filename);
        end
    end
    if not(isfield(s,'x')) %Possible wrong file!
        if not(isfield(s,'filename'))
            if not(isfield(s,'filname'))
                s.filename='';
            end
            [s.filename,PathName]=uigetfile('space*',['Please locate a space-language file, e.g.: ' s.filename],'');
            s.filename=[PathName s.filename];
        end
        s=getNewSpace(s.filename);
    end
    if strcmpi(version,'s') | strcmpi(version,'') | strcmpi(version,'noSave')
        sOut=s;
    end
end
sOut=printSpaceInfo(s);




function s=getSpace2(file)
PathName='';
if not(exist(file)) & not(exist([file '.mat']))
    [file,PathName]=uigetfile2(['*'],['Please locate missing space-file:' char(13) file]);
end
load([PathName file])
s.filename=file;
s=mkHash(s);
[s.N s.Ndim]=size(s.x);



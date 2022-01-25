function  [fil,PathName]=uigetfile2(a1,a2,fil);
if nargin<3 fil='';end
global default
if isempty(default)
    default=0;
end
%d=defaultData(a1,0);
PathName='';
if default==-1
    tmp=fil;
    fil=input(['Input filename:' a1 '(' fil ')'],'s');
    if isempty(fil)
        fil=tmp;
    end
elseif  not(default) 
    [fil,PathName]=uigetfile(a1,a2,fil);
    if not(fil==0)
        fprintf('%s : %s\n',a2, fil);
    end
else
    if ispc
        fil=regexprep(fil,'/','\');
    elseif isunix
        fil=regexprep(fil,'\','/');
    end
    fprintf('Using default file %s\n',fil);
end
%defaultData(d,1);

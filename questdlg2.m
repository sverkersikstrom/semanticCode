function a5=questdlg2(a1,a2,a3,a4,a5,a6)
if nargin<6
    a6='';
end
if nargin<5
    a5='';
end
if nargin<4
    a4='';
end
global default
if default==-1
    tmp=a5;
    a5=input([a1 '(' a3 ' or ' a4 ' default=' a5 ')'],'s');
    if isempty(a5)
        a5=tmp;
    end
elseif not(default)
    fprintf('%s: ',a1);
    a5=questdlg(a1,a2,a3,a4,a5,a6);
    fprintf('%s\n',a5);
else
    fprintf('Using default value: %s: %s\n',a1,a5);
end

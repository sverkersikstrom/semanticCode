function out=inputdlg3(titel,default,usedefault)
if nargin<3 usedefault=1; else usedefault=-1;end
if isempty(default)
    d{1}='';
else
    d{1}=regexprep(default,char(10),'');
end
tmp=inputdlg2(titel,'',usedefault,d);
try; out=tmp{1}; catch; out='';end

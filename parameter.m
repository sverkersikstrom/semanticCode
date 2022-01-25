function N=parameter(handles,ver,usedefaults)
if nargin<2
    ver='';
end 
if nargin<3
    usedefaults=1;
end
text=get(handles,'label');
i=findstr(text,':');
N=text(i+1:length(text));
if strcmpi(ver,'string')
    if strcmpi(N,' ') | isempty(N) N=''; end
elseif strcmpi(ver,'setInputdialog')
    s=getSpace;
    [o s]=getWordFromUser(s,text(1:i-1),'*');
    N=o.input;
    set(handles,'label',[text(1:i) N]);
elseif strcmpi(ver,'set')
    N=inputdlg3(text(1:i-1),N,usedefaults);
    set(handles,'label',[text(1:i) N]);
else
    N=str2num(N);
    if isnan(N) N=[];end
end

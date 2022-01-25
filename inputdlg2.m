function out=inputdlg2(prompt,name,usedefault,default1,input1);
if nargin<4 | isempty(default1)
    default1={''};
end
if nargin<5
    input1=0;
end
f=[regexprep(prompt,' ','_') '_'];
f=regexprep(f,'=','');
f=regexprep(f,'(','');
f=regexprep(f,')','');
f=regexprep(f,'-','');
f=regexprep(f,'/','');
f=regexprep(f,',','');
f=regexprep(f,';','');
f=regexprep(f,':','');
f=f(1:min(60,length(f)));
if not(isnan(str2double(f(1))))
    f=['num' f];
end
if exist('default.mat')
    load('default');
    if isfield(d,f)  & not(usedefault==-1)
        eval(['default1=d.' f ';']);
    end
end
global default
if input1==-1 | default==1 %default parameters...
    fprintf('%s :Using default parameters: %s\n',prompt,default1{1});
    out=default1;
elseif default==-1
    out{1}=input([prompt '(' default1{1} ')'],'s');
    if isempty(out{1})
        out=default1;
    end
else
    if size(default1)==0 default1{1}='';end
    fprintf('%s :%s\n',prompt,default1{1} );
    out=inputdlg(prompt,name,1,default1);
    fprintf('%s :%s\n',prompt,out{:});
end
try
    eval(['d.' f '=out;']);
    save('default','d')
catch
    fprintf('warning could not save default parameters\n');
end
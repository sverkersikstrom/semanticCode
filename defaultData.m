function [default1 d]=defaultData(prompt,ver)
f=[regexprep(prompt,' ','_') '_'];
f=regexprep(f,'=','');
f=regexprep(f,'(','');
f=regexprep(f,')','');
f=regexprep(f,';','');
f=f(1:min(60,length(f)));
if ver==0
    if exist('default.mat')
        load('default');
        if isfield(d,f)  & not(usedefault==-1)
            eval(['default1=d.' f ';']);
        end
    end
else
    out=prompt;
    try
        eval(['d.' f '=out;']);
        save('default','d')
    catch
        fprintf('warning could not save default parameters\n');
    end
end
function saveDefault(file,d)
u=[pwd ':' datestr(now,'yyyy-mm-dd') ] ;
if isfield(d,'user')
    i=find(strcmpi(u,d.user));
    if isempty(i)
        i=length(d.user)+1;
        d.N(i)=0;
    end
else
    i=1;
    d.N(i)=0;
end
d.user{i}=u;
d.N(i)=d.N(i)+1;
try
    save(file,'d')
catch
    fprintf('Could not write to file: %s\n',file);
end

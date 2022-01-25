function [x, ok, index]=getXword(s,w)
index=word2index(s,w);
%index=find(strcmpi(s.fwords,w));
if isnan(index) %isempty(index)
    x=ones(1,s.Ndim)*NaN;
    ok=0;
    index=NaN;
else
    x=s.x(index(1),:);
    ok=1;
    if length(index)>1 
        index=index(1);
        fprintf('Warning: Multipel entreizes of %s\n',s.fwords{index})
    end
end

return

%Old version calcultes an expression....
w=lower(w);
keywords='()+-*/.^';
i1=1;ok=1;index=NaN;
k=0;
x=NaN;
while i1<=length(w)
    while i1<=length(w) & not(isempty(findstr(w(i1),keywords)))
        i1=i1+1;
    end
    i0=i1;
    k=k+1;
    while i1<=length(w) & isempty(findstr(w(i1),keywords)) 
        i1=i1+1;
    end
    w2=w(i0:min(length(w),i1-1));
    try
        if not(s.par.text_all2) eval('mkerror'); end
        eval([w2 '(1)']);
        matlabcommando=1;
    catch
        matlabcommando=0;
        tmp=find(strcmpi(s.fwords,w2));
    end

    if matlabcommando
    elseif length(s.x)<tmp
        ok=0;
    elseif not(isempty(tmp))
        index(k)=tmp(1);
        xnow=['s.x(index(' num2str(k) '),:)'];
        w=regexprep(w,w2,xnow);
        i1=findstr(w,xnow)+length(xnow);
    elseif isempty(w2)
        i1=length(w)+1;
    else
        i1=length(w)+1;
        ok=0;
    end
end
if ok
    try
        x=eval(w);
    catch
        fprintf('Could not calculate ''%s''\n',w);
        try;
            index(k)=find(strcmpi(s.fwords,w2));
            x=s.x(index(k),:);
        end
    end
else
    x=ones(1,s.Ndim)*NaN;
end

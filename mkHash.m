function s=mkHash(s,update)
if nargin>1 & update==2 & isfield(s,'hash')
    %Optimized
    i1=s.N;cont=1;
    while cont
        if i1<1
            cont=0;
        elseif isempty(s.hash.get(lower(s.fwords{i1})))
        elseif s.hash.get(lower(s.fwords{i1}))==i1
            cont=0;
        end
        i1=i1-1000;
    end
    i1=max(1,i1);
    for i=i1:length(s.fwords)
        if length(s.fwords{i})>0
            s.hash.put(lower(s.fwords{i}),i);
        end
    end 
    return
end
if nargin>1 & update==1
    if isfield(s,'hash')
        s=rmfield(s,'hash');
    end
end
if not(isfield(s,'hash'))
    %Creating hash table
    s.hash=java.util.Hashtable;
    for i=1:length(s.fwords)
        if length(s.fwords{i})>0
            s.hash.put(lower(s.fwords{i}),i);
        end
    end
    %Done :);
end

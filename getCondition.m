function select=getCondition(s,index,nowevaulate)
%Selects index matching a condition, i.s. selected=getCondition(s,[10 11],'_age>30')
p=[];e=0;

a1=findstr(nowevaulate,'_');
for i=1:length(a1);
    a1=findstr(nowevaulate,'_');
    a2(i)=a1(i)+1;
    while a2(i)<=length(nowevaulate) & isalpha_num(nowevaulate(a2(i)))
        a2(i)=a2(i)+1;
    end
    tmp=nowevaulate(a1(i):a2(i)-1);
    nowevaulate=[nowevaulate(1:a1(i)-1) ['getProperty(s,''' tmp ''',index)'] nowevaulate(a2(i):end)];
end

a1=findstr(nowevaulate,'?');
for i=1:length(a1);
    a1=findstr(nowevaulate,'?');
    a1=a1(1);
    a2=a1+1;
    while a2<=length(nowevaulate) & isalpha_num(nowevaulate(a2))
        a2=a2+1;
    end
    tmp=nowevaulate(a1+1:a2-1);
    nowevaulate=[nowevaulate(1:a1-1) ['getProperty(s,''' tmp ''',index)'] nowevaulate(a2:end)];
end


try
    p=eval(nowevaulate);
catch
    p=zeros(1,length(index));
    e=lasterror;
    fprintf('Error ''%s'' during calculation of: %s\n',e.message,nowevaulate);
end

select=find(p);


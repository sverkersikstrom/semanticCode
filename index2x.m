function [x f]=index2x(s,index);
index=reshape(index,1,size(index,1)*size(index,2));
index=index(not(isnan(index)));
f=zeros(1,s.N);
for i=1:length(index)
    f(index(i))=f(index(i))+1;
end
x=zeros(1,size(s.x,2));ok=not(isnan(sum(s.x')));
indexOk=find(f>0 & ok);
for i=indexOk %1:length(f)
    x=x+s.x(i,:)*f(i);
    %if f(i)>0 & ok(i); x=x+s.x(i,:)*f(i);end
end
x=x/sum(x.*x)^.5;
